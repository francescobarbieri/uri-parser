% Prossimi step per terminare il codice
% 1) E boh controllare i caratteri che non so se ho tenuto conto di tutti
% 2) (Forse) Controllo sul ".com" del dominio e che host sia valido se non è un ip
% 3) Quando è presente l'authority, si deve riconoscere con / , ? , # oppure il '', adesso appenda uno / e riconosce con quello
% 4) Risolvere l'is_IP con tel e fax che che ritorna 111.111.111.111 fixato temporaneamente con l'out_host, DA SISTEMARE ASSOLUTAMENTE
% 5) Zos

uri_parse(URIString, URI) :- 
	string_to_list(URIString, URICodeList),
    codeListToAtomList(URICodeList, URIList),

    %se trovo un ":" nella lista di char non faccio backtracking dato che è l'elemento che mi indica la fine dello scheme
    member(':', URIList),
    !,

	splitList(URIList, :, Scheme, Sottostringa),
	presenzaAuthority(Sottostringa, AuthorityPresence),

	% 0 -> nessuno
	% 1 -> mailto
	% 2 -> news
	% 3 -> tel
	% 4 -> fax
	% 5 -> zos
	isSpecialScheme(Scheme, BooleanSpecialScheme),

	mailto(Sottostringa, Userinfo, Host, BooleanSpecialScheme),
	news(Sottostringa, Host, BooleanSpecialScheme),
	tel(Sottostringa, Userinfo, BooleanSpecialScheme),
	fax(Sottostringa, Userinfo, BooleanSpecialScheme),
	
	list_append(/, Sottostringa, Sottostringa1),

	splitAuthority(Sottostringa1, /, AuthorityPresence, Authority, After),

	presenzaPort(Authority, PortPresence, AuthorityPresence),
    presenzaUserinfo(Authority, UserinfoPresence, AuthorityPresence),
    presenzaFragment(After, FragmentPresence),
    presenzaQuery(After, QueryPresence),

	splitPort(Authority, :, TempAuthority, Port, PortPresence),
    splitHost(TempAuthority, @, Userinfo, Host, UserinfoPresence),
    splitFragment(After, #, OtherString, Fragment, FragmentPresence),
	splitQuery(OtherString, ?, Path, Query, QueryPresence, BooleanSpecialScheme),

	is_IP(Host, BooleanIp),
    controlloIp(Host, BooleanIp),

	out_scheme(Scheme, SchemeOut),
	out_userinfo(Userinfo, UserinfoOut),
	out_host(Host, HostOut),
    out_porta(Port, PortaOut),
    out_fragment(Fragment, FragmentOut),
    out_query(Query, QueryOut),
    out_Path(Path, PathOut),

	%URI = uri(SchemeOut, Host, Userinfo, BooleanSpecialScheme, TempAuthority).
	URI = uri(SchemeOut, UserinfoOut, HostOut, PortaOut, PathOut, QueryOut, FragmentOut).

uri(_, _, _, _, _, _, _).

presenzaAuthority(X, Y) :- 
	nth1(1, X, /),
	nth1(2, X, /),
	Y is 1,
	!.

presenzaAuthority(_, Y) :- 
	Y is 0.

presenzaPort(Authority, PortPresence, AuthorityPresence) :- 
	AuthorityPresence == 1,
	member(:, Authority), !,
	PortPresence = 1.

presenzaPort(Authority, PortPresence, AuthorityPresence) :- 
	AuthorityPresence == 1,
	nonmember(:, Authority), !,
	PortPresence = 0.

presenzaPort(Authority, PortPresence, AuthorityPresence) :- 
	AuthorityPresence == 0,
	PortPresence = 0.

presenzaUserinfo(Authority, UserinfoPresence, AuthorityPresence) :- 
	AuthorityPresence == 1,
	member(@, Authority), !,
	UserinfoPresence = 1.

presenzaUserinfo(Authority, UserinfoPresence, AuthorityPresence) :- 
	AuthorityPresence == 1,
	nonmember(@, Authority), !,
	UserinfoPresence = 0.

presenzaUserinfo(Authority, UserinfoPresence, AuthorityPresence) :- 
	AuthorityPresence == 0,
	UserinfoPresence = 0.

presenzaFragment(String, PresenzaFragment) :-
    member(#, String), !,
    PresenzaFragment = 1.

presenzaFragment(String, PresenzaFragment) :-
    nonmember(#, String), !,
    PresenzaFragment = 0.

%presenzaFragment([], PresenzaFragment, AuthorityPresence) :-
%    PresenzaFragment = 0, !.

presenzaQuery(Query, QueryPresence) :-
    member(?, Query), !,
    QueryPresence = 1.

presenzaQuery(Query, QueryPresence) :-
    nonmember(?, Query), !,
    QueryPresence = 0.

digits123([A,B,C|R],R):-
    digit(A),
    digit(B),
    digit(C).
digits123([A,B|R],R):-
    digit(A),
    digit(B).
digits123([A|R],R):-
    digit(A).

is_IP(In, Boolean):-
    digits123(In,['.'|R1]),
    digits123(R1,['.'|R2]),
    digits123(R2,['.'|R3]),
    digits123(R3,[]),
    Boolean = 1, !.

is_IP(_, Boolean) :-
    Boolean = 0.

controlloIp(List, BooleanIp) :-
    BooleanIp == 1, 
	splitList(List, ., Out, Other1),
	splitList(Other1, ., Out1, Other2),
	splitList(Other2, ., Out2, Out3),
	tras(Out), tras(Out1), tras(Out2), tras(Out3), !.

controlloIp(_, BooleanIp) :-
    BooleanIp == 0.

isSpecialScheme(Scheme, BooleanSpecialScheme) :-
	Scheme = ['m','a','i','l','t','o'],
	BooleanSpecialScheme = 1, !.

isSpecialScheme(Scheme, BooleanSpecialScheme) :-
	Scheme = ['n','e','w','s'],
	BooleanSpecialScheme = 2, !.

isSpecialScheme(Scheme, BooleanSpecialScheme) :-
	Scheme = ['t','e','l'],
	BooleanSpecialScheme = 3, !.

isSpecialScheme(Scheme, BooleanSpecialScheme) :-
	Scheme = ['f','a','x'],
	BooleanSpecialScheme = 4, !.

isSpecialScheme(Scheme, BooleanSpecialScheme) :-
	Scheme = ['z','o','s'],
	BooleanSpecialScheme = 5, !.

isSpecialScheme(_, BooleanSpecialScheme) :-
	BooleanSpecialScheme = 0, !.

nonmember(Arg,[Arg|_]) :-
	!,
	fail.
nonmember(Arg,[_|Tail]) :-
	!,
	nonmember(Arg,Tail).
nonmember(_,[]).

%Il caso in cui no c'è l'authority è ancora da gestire, infatti se non c'è una authority correttamente formattata ritorna false
isolateAuthority(X, Y, Z) :-
	Y == 1,
	removeHead(X, Xfirst),
	removeHead(Xfirst, Z).

removeHead([_ | Xs], Xs).

splitAuthority(X, Car, BooleanAuthority, Before, After) :-
	BooleanAuthority == 1,
	removeHead(X, Xfirst),
	removeHead(Xfirst, Z),
	splitList(Z, Car, Before, After), !.

splitAuthority(X, Car, BooleanAuthority, Before, X) :-
	Before = [],
	BooleanAuthority == 0, !.

%Operazioni sull'authority

splitPort(String, Car, Before, After, PortPresence) :-
	PortPresence == 1,
	splitList(String, Car, Before, After), !.

splitPort(String, Car, Before, After, PortPresence) :-
	PortPresence == 0,
	Before = String,
	After = [], !.

splitHost(String, Car, Before, After, UserinfoPresence) :-
	UserinfoPresence == 1,
	splitList(String, Car, Before, After), !.

splitHost(String, Car, Before, After, UserinfoPresence) :-
	UserinfoPresence == 0,
	Before = [],
	After = String, !.

splitHost([], Car, Before, After, UserinfoPresence) :- !.

splitFragment(String, Car, Before, After, FragmentPresence) :-
    FragmentPresence == 0,
	After = [],
	Before = String, !.

splitFragment(String, Car, Before, After, FragmentPresence) :-
	FragmentPresence == 1,
	splitList(String, Car, Before, After), !.

splitQuery(String, Car, Before, After, QueryPresence, Boolean) :-
    QueryPresence == 1,
	Boolean == 0,
    splitList(String, Car, Before, After), !.

splitQuery(String, Car, Before, After, QueryPresence, Boolean) :-
    QueryPresence == 0,
	Boolean == 0,
    Before = String,
    After = [], !.

splitQuery(_, _, Before, _, _, _) :-
	Before = [], !.

mailto(List, Out, Out2, Boolean) :-
	Boolean == 1,
	nonmember(@, List),
	Out = List,
	Out2 = [], !.

mailto(List, Out, Out2, Boolean) :-
	Boolean == 1,
	member(@, List),
	splitList(List, @, Out, Out2), !.

mailto(List, Out, Out2, _) :- !.

news(List, Out, Boolean) :-
	Boolean == 2,
	Out = List, !.

news(List, Out, _) :- !.

tel(List, Out, Boolean) :-
	Boolean == 3,
	Out = List, !.

tel(List, Out, _) :- !.

fax(List, Out, Boolean) :-
	Boolean == 4,
	Out = List, !.

fax(List, Out, _) :- !.


%Out code
out_porta([], SottostringaOut) :- 
	SottostringaOut = [], !.

out_porta(Sottostringa, SottostringaOut) :- 
	isDigit(Sottostringa), 
	number_string(SottostringaOut, Sottostringa).

out_scheme(Scheme, SchemeOut) :- 
	verifica_identificatori(Scheme),
	string_to_atom(Scheme, SchemeOut).

out_host([], HostOut) :- 
	HostOut = [], !.

out_host(Host, HostOut) :- 
	Host = ['1', '1', '1', '.', '1', '1', '1', '.', '1', '1', '1', '.', '1', '1', '1'],
	HostOut = [], !.

out_host(Host, HostOut) :- 
	verifica_identificatori(Host),
	string_to_atom(Host, HostOut).

out_userinfo(Userinfo, UserinfoOut) :-
	Userinfo \= [],
	string_to_atom(Userinfo, UserinfoOut).

out_userinfo([], UserinfoOut) :- 
	UserinfoOut = [], !.

out_fragment(Fragment, FragmentOut) :-
	Fragment \= [],
	string_to_atom(Fragment, FragmentOut).

out_fragment([], FragmentOut) :-
    FragmentOut = [], !.

out_query([], QueryOut) :-
    QueryOut = [], !.

out_query(Query, QueryOut) :-
    nonmember(#, Query),
    string_to_atom(Query, QueryOut), !.

out_Path(Path, PathOut) :-
    Path \= [],
	string_to_atom(Path, PathOut), !.

out_Path([], PathOut) :-
    PathOut = []. 

% Fuffa

codeListToAtomList([], []) :- !.
codeListToAtomList([X | Xs], [Y | Ys]) :- 
	char_code(Y, X), 
	codeListToAtomList(Xs, Ys).

verifica_identificatori(X) :- 
	length(X, 1),  %True se la lista X contiene 1 elemento
	nth0(0, X, Y), %True se l'elemento Y alla posizione 0 della lista X è uno sei deguenti caratteri
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


splitList([A|Ls], A, [], Ls) :- !.
splitList([L|Ls], A, [L|Xs], R):- 
	L\==A,
	splitList(Ls, A, Xs, R),
	!.

list_append(X,[ ],[X]) :- !.
list_append(X,[H|T],[H|Z]) :-
	list_append(X,T,Z), !.    

%================

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

%TEST
%Test presi da https://datatracker.ietf.org/doc/html/rfc3986#section-1.1.2
%sezione 1.1.2
%?- uri_parse("ftp://ftp.is.co.za/rfc/rfc1808.txt", URI).
%?- uri_parse("http://www.ietf.org/rfc/rfc2396.txt", URI).
%?- uri_parse("ldap://[2001:db8::7]/c=GB?objectClass?one", URI).
%?- uri_parse("mailto:John.Doe@example.com", URI).   
%?- uri_parse("news:comp.infosystems.www.servers.unix", URI).
%?- uri_parse("tel:+1-816-555-1212", URI).
%?- uri_parse("telnet://192.0.2.16:80/", URI).
%?- uri_parse("urn:oasis:names:specification:docbook:dtd:xml:4.1.2", URI).
%
%Test aggiuntivi:
%?- uri_parse("http://disco.unimib.it", URI).
%?- uri_parse("http://disco.unimib.it",
%				uri(https, _, _, _, _, _, _)).
%?- uri_parse("http://disco.unimib.it",
%				uri(_, _, Host, _, _, _, _)).
%?- uri_parse("d?:/", URI).
%?- uri_parse("d#:/", URI).