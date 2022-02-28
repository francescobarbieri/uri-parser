% Prolog Uri Parser [02/2022] - Linguaggi di Programmazione
% Contributors:
% Mat. 856375 - Francesco Barbieri
% Mat. 852255 - Federico Bartsch
% Mat. 856177 - Alessandro Moscardo

uri_parse(URIString, URI) :- 
    % Trasformazione da stringa a una lista di codici
    string_to_list(URIString, URICodeList),

    % Trasformazione da lista di codici a lista di caratteri
    code_list_to_atom_list(URICodeList, URIList),
    
    % Controllo sulla presenza dei :, obbligatori per qualsiasi tipo di URI,
    % se non presenti l'URI e' direttamente da scartare
    member(':', URIList),
    !,

    % Predicato che divide lo scheme dal resto della stringa tramite i primi :
    split_list(URIList, :, Scheme, String0),

    % Riconoscimento della presenza dell'authority in base allo '//' 
    % obbligatorio. Se presente BooleanAuthority = 1, altrimenti 0
    authority_presence(String0, BooleanAuthority),

    % Riconoscimento di evenutali scheme speciali, che necessitano di azioni
    % e/o controlli differenti tramite BooleanSpecialScheme che avra' i
    % seguenti valori:
    % Scheme 	|	BooleanSpecialScheme
    % Default	|	0
    % mailto	|	1
    % news	|	2
    % tel 	|	3
    % fax	|	4
    % zos	|	5
    is_special_scheme(Scheme, BooleanSpecialScheme),

    % Assegnazione alle rispettive parti dell'URI in base alla
    % tipologia di scheme
    mailto(String0, Userinfo, Host, BooleanSpecialScheme),
    news(String0, Host, BooleanSpecialScheme),
    tel(String0, Userinfo, BooleanSpecialScheme),
    fax(String0, Userinfo, BooleanSpecialScheme),

    % Riconoscimento della presenza del fragment, se presente
    % BooleanFragment = 1, altrimenti 0
    fragment_presence(String0, BooleanFragment),
    
    % Riconoscimento della presenza della query, se presente
    % BooleanQuery = 1, altrimenti 0
    query_presence(String0, BooleanQuery),

    % Predicato che splitta in corrispondenza del primo # se
    % BooleanFragment e' pari a 1
    split_fragment(String0, #, String1, Fragment, BooleanFragment),
    
    % Predicato che splitta in corrispondenza del primo ? se
    % BooleanQuery e' pari a 1
    split_query(String1, ?, String2, Query, BooleanQuery,
		BooleanSpecialScheme),

    % Rimozione dei due slash '//' dell'authority se quest'ultima
    % e' presente (BooleanAuthority = 1)
    remove_slash(String2, String3, BooleanAuthority),
    remove_slash(String3, String4, BooleanAuthority),

    % Predicato che splitta l'authority e il path in corrispondenza dello '/'',
    % del '?'' o dell' '#'. Per le query che non hanno path ma una tra
    % query e/o fragment
    split_authority(String4, BooleanAuthority, Authority, Path),

    % Predicato che controlla e rimuove la presenza dello / obbligatorio
    % dopo authority (se presente)

    %remove_auth_slash(TempAuthority, BooleanAuthority, Authority),

    % Analizza l'authority
    % Predicato che riconosce la presenza della porta basandosi sui ':',
    % BooleanPort = 1 se presente, altrimenti 0
    port_presence(Authority, BooleanPort, BooleanAuthority),

    % Predicato che riconosce la presenza dello userinfo basandosi su '@'
    % BooleanUserinfo = 1 se presente, altrimenti 0
    userinfo_presence(Authority, BooleanUserinfo, BooleanAuthority),
    
    % Predicato che splitta la port se presente basandosi sui ':'
    split_port(Authority, :, String5, Port, BooleanPort),

    % Predicato che splitta lo userinfo e la port basandosi su '@'
    split_host(String5, @, Userinfo, Host, BooleanUserinfo),

    % Predicato che riconosce se l'host e' un IP per eseguire il controllo
    % su di esso. Sono ammessi N.N.N.N, NNN.NNN.NNN.NNN e forme intermedie
    % con N digit. Inoltre NNN non puo' essere > di 255
    %is_IP(Host, BooleanIp),
    
    % Predicato che effettua il controllo sull'IP
    %controlloIp(Host, BooleanIp),

    % Predicati per la trasformazione da List a String per l'output
    out_scheme(Scheme, SchemeOut),
    out_userinfo(Userinfo, UserinfoOut, BooleanUserinfo, BooleanSpecialScheme),
    out_host(Host, HostOut, BooleanAuthority, BooleanSpecialScheme),
    out_porta(Port, PortaOut, BooleanPort),
    out_query(Query, QueryOut, BooleanQuery),
    out_fragment(Fragment, FragmentOut, BooleanFragment),
    out_Path(Path, PathOut, BooleanSpecialScheme),

    % Output delle componenti dell'URI
    URI = uri(SchemeOut,
	      UserinfoOut,
	      HostOut,
	      PortaOut,
	      PathOut,
	      QueryOut,
	      FragmentOut).

uri(_, _, _, _, _, _, _).

% Predicati per il controllo della presenza o meno delle varie componenti
% dell'URI

authority_presence(X, Y) :- 
    nth1(1, X, /),
    nth1(2, X, /),
    Y is 1,
    !.

authority_presence(_, Y) :- 
    Y is 0.

port_presence(Authority, BooleanPort, BooleanAuthority) :- 
    BooleanAuthority == 1,
    member(:, Authority),
    !,
    BooleanPort = 1.

port_presence(Authority, BooleanPort, BooleanAuthority) :- 
    BooleanAuthority == 1,
    nonmember(:, Authority),
    !,
    BooleanPort = 0.

port_presence(_, BooleanPort, BooleanAuthority) :- 
    BooleanAuthority == 0,
    BooleanPort = 0.

userinfo_presence(Authority, BooleanUserinfo, BooleanAuthority) :- 
    BooleanAuthority == 1,
    member(@, Authority),
    !,
    BooleanUserinfo = 1.

userinfo_presence(Authority, BooleanUserinfo, BooleanAuthority) :- 
    BooleanAuthority == 1,
    nonmember(@, Authority),
    !,
    BooleanUserinfo = 0.

userinfo_presence(_, BooleanUserinfo, BooleanAuthority) :- 
    BooleanAuthority == 0,
    BooleanUserinfo = 0.

fragment_presence(String, Boolean) :-
    member(#, String),
    !,
    Boolean = 1.

fragment_presence(String, Boolean) :-
    nonmember(#, String),
    !,
    Boolean = 0.

query_presence(Query, BooleanQuery) :-
    member(?, Query),
    !,
    BooleanQuery = 1.

query_presence(Query, BooleanQuery) :-
    nonmember(?, Query),
    !,
    BooleanQuery = 0.

% Predicati per il riconoscimento di specialScheme o default

is_special_scheme(Scheme, Boolean) :-
    Scheme = ['m','a','i','l','t','o'],
    Boolean = 1,
    !.

is_special_scheme(Scheme, Boolean) :-
    Scheme = ['n','e','w','s'],
    Boolean = 2,
    !.

is_special_scheme(Scheme, Boolean) :-
    Scheme = ['t','e','l'],
    Boolean = 3,
    !.

is_special_scheme(Scheme, Boolean) :-
    Scheme = ['f','a','x'],
    Boolean = 4,
    !.

is_special_scheme(Scheme, Boolean) :-
    Scheme = ['z','o','s'],
    Boolean = 5,
    !.

is_special_scheme(_, Boolean) :-
    Boolean = 0,
    !.

% Predicati per il riconoscimento ed il controllo dell'IP

digits123([A, B, C | R], R) :-
    digit(A),
    digit(B),
    digit(C).
digits123([A, B | R], R) :-
    digit(A),
    digit(B).
digits123([A | R], R) :-
    digit(A).

is_IP(In, Boolean) :-
    digits123(In, ['.' | R1]),
    digits123(R1, ['.' | R2]),
    digits123(R2, ['.' | R3]),
    digits123(R3, []),
    Boolean = 1,
    !.

is_IP(_, Boolean) :-
    Boolean = 0.

controlloIp(List, Boolean) :-
    Boolean == 1, 
    split_list(List, ., Out, Other1),
    split_list(Other1, ., Out1, Other2),
    split_list(Other2, ., Out2, Out3),
    tras(Out), tras(Out1), tras(Out2), tras(Out3),
    !.

controlloIp(_, Boolean) :-
    Boolean == 0.

% Predicati per lo split delle varie componenti dell'URI

split_authority(X, BooleanAuthority, Before, After) :-
    BooleanAuthority == 1,
    member(/, X),
    split_list(X, /, Before, After),
    !.

split_authority(X, BooleanAuthority, Before, After) :-
    BooleanAuthority == 1,
    nonmember(/, X),
    Before = X, After = [],
    !.

split_authority(X, BooleanAuthority, Before, After) :-
    BooleanAuthority == 0,
    nonmember(/, X),
    Before = [], After = X,
    !.

split_authority([X | Xs], BooleanAuthority, Before, After) :-
    BooleanAuthority == 0,
    member(/, [X | Xs]),
    X == '/',
    removeHead([X | Xs], Out),
    Before = [], After = Out,
    !.

split_authority(X, BooleanAuthority, Before, After) :-
    BooleanAuthority == 0,
    Before = [], After = X,
    !.

%Operazioni sull'authority

split_port(X, Car, Before, After, BooleanPort) :-
    BooleanPort == 1,
    split_list(X, Car, Before, After),
    !.

split_port(X, _, Before, After, BooleanPort) :-
    BooleanPort == 0,
    Before = X,
    After = [],
    !.

split_host(X, Car, Before, After, BooleanUserinfo) :-
    BooleanUserinfo == 1,
    split_list(X, Car, Before, After),
    !.

split_host(X, _, Before, After, BooleanUserinfo) :-
    BooleanUserinfo == 0,
    Before = [],
    After = X,
    !.

split_host([], _, _, _, _) :- !.

split_fragment(X, _, Before, After, BooleanFragment) :-
    BooleanFragment == 0,
    After = [],
    Before = X,
    !.

split_fragment(X, Car, Before, After, BooleanFragment) :-
    BooleanFragment == 1,
    split_list(X, Car, Before, After),
    !.

split_query(X, Car, Before, After, QueryPresence, BooleanSpecialScheme) :-
    QueryPresence == 1,
    BooleanSpecialScheme == 0,
    split_list(X, Car, Before, After),
    !.

split_query(X, _, Before, After, QueryPresence, BooleanSpecialScheme) :-
    QueryPresence == 0,
    BooleanSpecialScheme == 0,
    Before = X,
    After = [],
    !.

split_query(X, Car, Before, After, QueryPresence, BooleanSpecialScheme) :-
    QueryPresence == 1,
    BooleanSpecialScheme == 5,
    split_list(X, Car, Before, After),
    !.

split_query(X, _, Before, After, QueryPresence, BooleanSpecialScheme) :-
    QueryPresence == 0,
    BooleanSpecialScheme == 5,
    Before = X,
    After = [],
    !.

split_query(_, _, Before, _, _, _) :-
    Before = [],
    !.

mailto(List, Before, After, Boolean) :-
    Boolean == 1,
    nonmember(@, List),
    Before = List,
    After = [],
    !.

mailto(List, Before, After, Boolean) :-
    Boolean == 1,
    member(@, List),
    split_list(List, @, Before, After),
    !.

mailto(_, _, _, _) :- !.

news(List, Out, Boolean) :-
    Boolean == 2,
    Out = List,
    !.

news(_, _, _) :- !.

tel(List, Out, Boolean) :-
    Boolean == 3,
    Out = List,
    !.

tel(_, _, _) :- !.

fax(List, Out, Boolean) :-
    Boolean == 4,
    Out = List,
    !.

fax(_, _, _) :- !.

%Out code
out_porta([], _, BooleanPort) :- 
    BooleanPort == 1,
    fail.

out_porta([], PortaOut, BooleanPort) :- 
    BooleanPort == 0,
    PortaOut = 80,
    !.

out_porta(X, PortaOut, BooleanPort) :- 
    BooleanPort == 1,
    isDigit(X), 
    number_string(PortaOut, X).

out_scheme(Scheme, SchemeOut) :- 
    verifica_identificatori(Scheme),
    string_to_atom(Scheme, SchemeOut).

out_host([H | Host], HostOut, _, BooleanSpecialScheme) :-
    BooleanSpecialScheme == 1,
    H \= '.',
    last(Host, A),
    checkChar(A, '.'),
    no_dot_dot([H | Host]),
    verifica_identificatori([H | Host]),
    string_to_atom([H | Host], HostOut), !. 

out_host([H | Host], HostOut, _, BooleanSpecialScheme) :-
    BooleanSpecialScheme == 2,
    H \= '.',
    last(Host, A),
    checkChar(A, '.'),
    no_dot_dot([H | Host]),
    verifica_identificatori([H | Host]),
    string_to_atom([H | Host], HostOut), !.   

out_host([], HostOut, BooleanAuthority, _) :- 
    BooleanAuthority == 0,
    HostOut = [],
    !.

%out_host(Host, HostOut, BooleanAuthority, _) :- 
%	BooleanAuthority == 1,
%	Host = ['1', '1', '1',
%	'.', '1', '1', '1',
%	'.', '1', '1', '1',
%	'.', '1', '1', '1'],
%	HostOut = [],
%	!.

out_host([H | Host], HostOut, BooleanAuthority, _) :- 
    BooleanAuthority == 1,
    H \= '.',
    last(Host, A),
    checkChar(A, '.'),
    no_dot_dot([H | Host]),
    verifica_identificatori([H | Host]),
    string_to_atom([H | Host], HostOut).

out_userinfo(Userinfo, UserinfoOut, _, BooleanSpecialScheme) :-
    BooleanSpecialScheme == 1,
    Userinfo \= [],
    verifica_identificatori(Userinfo),
    string_to_atom(Userinfo, UserinfoOut), !. 

out_userinfo(Userinfo, UserinfoOut, _, BooleanSpecialScheme) :-
    BooleanSpecialScheme == 3,
    verifica_identificatori(Userinfo),
    string_to_atom(Userinfo, UserinfoOut), !. 

out_userinfo(Userinfo, UserinfoOut, _, BooleanSpecialScheme) :-
    BooleanSpecialScheme == 4,
    verifica_identificatori(Userinfo),
    string_to_atom(Userinfo, UserinfoOut), !. 

out_userinfo(Userinfo, UserinfoOut, BooleanUserinfo, _) :-
    BooleanUserinfo == 1,
    verifica_identificatori(Userinfo),
    Userinfo \= [],
    string_to_atom(Userinfo, UserinfoOut).

out_userinfo([], UserinfoOut, BooleanUserinfo, BooleanSpecialScheme) :- 
    BooleanUserinfo == 0,
    %BooleanSpecialScheme \= 2,
    UserinfoOut = [],
    !.

out_fragment([], _, BooleanFragment) :-
    BooleanFragment == 1,
    fail,
    !.

out_fragment([], FragmentOut, BooleanFragment) :-
    BooleanFragment == 0,
    FragmentOut = [],
    !.

out_fragment(Fragment, FragmentOut, BooleanFragment) :-
    BooleanFragment == 1,
    Fragment \= [],
    string_to_atom(Fragment, FragmentOut).

out_query([], _, BooleanQuery) :-
    BooleanQuery == 1,
    fail, !.

out_query([], QueryOut, BooleanQuery) :-
    BooleanQuery == 0,
    QueryOut = [],
    !.

out_query(Query, QueryOut, BooleanQuery) :-
    BooleanQuery == 1,
    Query \= [],
    nonmember(#, Query),
    string_to_atom(Query, QueryOut),
    !.

out_Path([P | Path], PathOut, BooleanSpecialScheme) :-
    BooleanSpecialScheme == 0,
    P \= '/',
    Path \= [],
    no_slash_slash([P | Path]),
    verifica_identificatori_path([P | Path]),
    string_to_atom([P | Path], PathOut),
    !.

out_Path([P | Path], PathOut, BooleanSpecialScheme) :-
    BooleanSpecialScheme == 5,
    Path \= [],
    char_type(P, alpha),
    parentesiCheck([P | Path], BooleanParentesi),
    splitZos([P | Path], Id44, Id8, BooleanParentesi),
    length(Id44, N1),
    length(Id8, N2),
    N1 =< 44, N2 =< 9,
    delete_last(Id8, TempId8),
    alphaNum(TempId8),
    is_alpha(TempId8),
    alphaNumDots(Id44),
    last(Id44, A),
    checkChar(A, '.'),
    string_to_atom([P | Path], PathOut),
    !.

%out_Path([], PathOut, BooleanSpecialScheme) :-
%	BooleanSpecialScheme \= 5,
%	PathOut = []. 

out_Path([], PathOut, _) :-
    PathOut = []. 

% Predicati per la stampa a video e su file

uri_display(URI) :-
    URI =.. [_, Scheme, Userinfo, Host, Port, Path, Query, Fragment | _],
    write('Scheme: '),
    write(Scheme),
    write('\n'),
    write('Userinfo: '),
    write(Userinfo),
    write('\n'),
    write('Host: '),
    write(Host),
    write('\n'),
    write('Port: '),
    write(Port),
    write('\n'),
    write('Path: '),
    write(Path),
    write('\n'),
    write('Query: '),
    write(Query),
    write('\n'),
    write('Fragment: '),
    write(Fragment), !.

uri_display(URI, Stream) :-
    URI =.. [_, Scheme, Userinfo, Host, Port, Path, Query, Fragment | _],
    write(Stream, 'Scheme: '),
    write(Stream, Scheme),
    write(Stream, '\n'),
    write(Stream, 'Userinfo: '),
    write(Stream, Userinfo),
    write(Stream, '\n'),
    write(Stream, 'Host: '),
    write(Stream, Host),
    write(Stream, '\n'),
    write(Stream, 'Port: '),
    write(Stream, Port),
    write(Stream, '\n'),
    write(Stream, 'Path: '),
    write(Stream, Path),
    write(Stream, '\n'),
    write(Stream, 'Query: '),
    write(Stream, Query),
    write(Stream, '\n'),
    write(Stream, 'Fragment: '),
    write(Stream, Fragment),
    close(Stream).

% Fuffa
is_alpha([X | _]) :-
    char_type(X, alpha), !.

code_list_to_atom_list([], []) :- !.

code_list_to_atom_list([X | Xs], [Y | Ys]) :- 
    char_code(Y, X), 
    code_list_to_atom_list(Xs, Ys).

verifica_identificatori(X) :- 
    length(X, 1),
    nth0(0, X, Y), 
    Y \= '/', 
    Y \= '?', 
    Y \= '#', 
    Y \= '@', 
    Y \= ':',
    !.

verifica_identificatori([X | Xs]) :-
    X \= '/', 
    X \= '?', 
    X \= '#', 
    X \= '@', 
    X \= ':',
    verifica_identificatori(Xs).

verifica_identificatori_path(X) :- 
    length(X, 1),
    nth0(0, X, Y),
    Y \= '?', 
    Y \= '#', 
    Y \= '@', 
    Y \= ':',
    !.

verifica_identificatori_path([X | Xs]) :-
    X \= '?', 
    X \= '#', 
    X \= '@', 
    X \= ':',
    verifica_identificatori_path(Xs).

split_list([A|Ls], A, [], Ls) :- !.

split_list([L|Ls], A, [L|Xs], R):- 
    L\==A,
    split_list(Ls, A, Xs, R),
    !.

list_append(X,[ ],[X]) :- !.

list_append(X,[H|T],[H|Z]) :-
    list_append(X,T,Z),
    !.    

checkSpaces(Input, Output) :-
    member(' ', Input),
    replace(' ', '%20', Input, Output),
    !.

checkSpaces(Input, Output) :-
    nonmember(' ', Input),
    Output = Input.

remove_slash(X, Out, Boolean) :-
    Boolean == 1,
    removeHead(X, Out),
    !.

remove_slash(X, Out, Boolean) :-
    Boolean == 0,
    Out = X.

isDigit([C | Cs]) :-
    digit(C),
    isDigit(Cs),
    !.

isDigit([C]) :-
    digit(C),
    !.

digit('1').
digit('2').
digit('3').
digit('4').
digit('5').
digit('6').
digit('7').
digit('8').
digit('9').
digit('0').

tras(X) :- 
    number_string(Y,X),
    Y < 256,
    Y > 0.

alphaNumDots([]) :- !.
alphaNumDots([X | Xs]) :- 
    char_type(X, alnum),
    alphaNumDots(Xs),
    !.
alphaNumDots([X | Xs]) :-
    X == '.',
    alphaNumDots(Xs), !.

alphaNum([]) :- !.
alphaNum([X | Xs]) :-
    char_type(X, alnum),
    alphaNum(Xs),
    !.

checkChar(A, Car) :-
    A \= Car,
    !.

delete_last(X,Y) :-
    reverse(X,[_|X1]),
    reverse(X1,Y),
    !.

delete_last([], Y) :-
    Y = [].

parentesiCheck(List, Boolean) :-
    member('(', List),
    last(List, ')'),
    %count('(', List, LOcc),
    %count(')', List, ROcc),
    %ROcc == 1,
    %LOcc == 1,
    Boolean = 1,
    !.

parentesiCheck(List, Boolean) :-
    nonmember('(', List),
    nonmember(')', List),
    Boolean = 0,
    !.

count(_, [], 0) :- !.
count(Value, [Value|Tail],Occurrences) :- !, 
    count(Value,Tail,TailOcc), 
    Occurrences is TailOcc+1.
count(Value, [_|Tail], Occurrences) :- count(Value,Tail,Occurrences).

splitZos(Path, Id44, After, Boolean) :-
    Boolean == 1,
    split_list(Path, '(', Id44, After),
    !.

splitZos(Path, Id44, After, Boolean) :-
    Boolean == 0,
    Id44 = Path,
    After = [].

replace(_, _, [], []).

replace(O, R, [O|T], [R|T2]) :-
    replace(O, R, T, T2).

replace(O, R, [H|T], [H|T2]) :-
    dif(H,O),
    replace(O, R, T, T2).

nonmember(Arg,[Arg|_]) :-
    !,
    fail.

nonmember(Arg,[_|Tail]) :-
    !,
    nonmember(Arg,Tail).

nonmember(_,[]).

removeHead([_ | Xs], Xs).

no_slash_slash([]).
no_slash_slash([E|Es]) :-
    no_slash_slash(Es, E).

no_slash_slash([], _).
no_slash_slash([E|Es], F) :-
    dif([E,F],[/,/]),
    no_slash_slash(Es, E).

no_dot_dot([]).
no_dot_dot([E|Es]) :-
    no_dot_dot(Es, E).

no_dot_dot([], _).
no_dot_dot([E|Es], F) :-
    dif([E,F],['.','.']),
    no_dot_dot(Es, E).

remove_auth_slash(Authority, BooleanAuthority, AuthorityOut) :-
    BooleanAuthority == 1,
    last(Authority, A),
    A == '/',
    delete_last(Authority, AuthorityOut), !.

remove_auth_slash(Authority, BooleanAuthority, AuthorityOut) :-
    BooleanAuthority == 0,
    Authority = AuthorityOut, !.

% END OF FILE
