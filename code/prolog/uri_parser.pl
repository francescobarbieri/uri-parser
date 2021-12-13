% Prossimi step per terminare il codice
% SOLVED 1) E boh controllare i caratteri che non so se ho tenuto conto di tutti
% 2) (Forse) Controllo sul ".com" del dominio e che host sia valido se non è u1n ip
% 3) Risolvere l'is_IP con tel e fax che che ritorna 111.111.111.111 fixato temporaneamente con l'out_host, DA SISTEMARE ASSOLUTAMENTE CHE L'ANTONIOTTI MI SPARA
% SOLVED 4)  Controllo sulle parti presenti o meno (quali sono obbligatorie etc)
% 5) diplay/2, display/1
% SOLVED 6) (!!!) PROBLEMA DA RISOLVERE ASSOLUTAMENTE: la stringa "https://pippo.com?query" e/o la stringa "https://pippo.com#fragment" ritornano false
% 7) " " -> "%20"
% 8) Sistemare nomi predicati e nomi variabili
% 9) Buttare tutto su emacs o convertirlo a emacs

uri_parse(URIString, URI) :- 
	string_to_list(URIString, URICodeList),
    code_list_to_atom_list(URICodeList, URIList),
    
    member(':', URIList),
    !,

	split_list(URIList, :, Scheme, Sottostringa),
	authority_presence(Sottostringa, AuthorityPresence),

	% 0 -> nessuno
	% 1 -> mailto
	% 2 -> news
	% 3 -> tel
	% 4 -> fax
	% 5 -> zos
	is_special_scheme(Scheme, BooleanSpecialScheme),

	mailto(Sottostringa, Userinfo, Host, BooleanSpecialScheme),
	news(Sottostringa, Host, BooleanSpecialScheme),
	tel(Sottostringa, Userinfo, BooleanSpecialScheme),
	fax(Sottostringa, Userinfo, BooleanSpecialScheme),

    fragment_presence(Sottostringa, FragmentPresence),
    query_presence(Sottostringa, QueryPresence),

    split_fragment(Sottostringa, #, OtherString, Fragment, FragmentPresence),
	split_query(OtherString, ?, BeforeQuery, Query, QueryPresence, BooleanSpecialScheme),

	remove_slash(BeforeQuery, Z, AuthorityPresence),
	remove_slash(Z, Z2, AuthorityPresence),

	split_authority(Z2, AuthorityPresence, Authority, Path),

	port_presence(Authority, PortPresence, AuthorityPresence),
    userinfo_presence(Authority, UserinfoPresence, AuthorityPresence),
	split_port(Authority, :, TempAuthority, Port, PortPresence),
    splot_host(TempAuthority, @, Userinfo, Host, UserinfoPresence),

	is_IP(Host, BooleanIp),
    check_IP(Host, BooleanIp),

	%checkSpaces(Query, TempQuery),
	%checkSpaces(Fragment, TempFragment),
	%checkSpaces(Path, TempPath),

	out_scheme(Scheme, SchemeOut),
	out_userinfo(Userinfo, UserinfoOut),
	out_host(Host, HostOut),
    out_porta(Port, PortaOut),
	out_query(Query, QueryOut),
    out_fragment(Fragment, FragmentOut),
    out_Path(Path, PathOut, BooleanSpecialScheme),

	%URI = uri(BooleanSpecialScheme, PortPresence, QueryPresence, FragmentPresence).
	%URI = uri(Z2, AuthorityPresence).
	URI = uri(SchemeOut, UserinfoOut, HostOut, PortaOut, PathOut, QueryOut, FragmentOut).

uri(_, _, _, _, _, _, _).

authority_presence(X, Y) :- 
	nth1(1, X, /),
	nth1(2, X, /),
	Y is 1,
	!.

authority_presence(_, Y) :- 
	Y is 0.

port_presence(Authority, PortPresence, AuthorityPresence) :- 
	AuthorityPresence == 1,
	member(:, Authority), !,
	PortPresence = 1.

port_presence(Authority, PortPresence, AuthorityPresence) :- 
	AuthorityPresence == 1,
	nonmember(:, Authority), !,
	PortPresence = 0.

port_presence(_, PortPresence, AuthorityPresence) :- 
	AuthorityPresence == 0,
	PortPresence = 0.

userinfo_presence(Authority, UserinfoPresence, AuthorityPresence) :- 
	AuthorityPresence == 1,
	member(@, Authority), !,
	UserinfoPresence = 1.

userinfo_presence(Authority, UserinfoPresence, AuthorityPresence) :- 
	AuthorityPresence == 1,
	nonmember(@, Authority), !,
	UserinfoPresence = 0.

userinfo_presence(_, UserinfoPresence, AuthorityPresence) :- 
	AuthorityPresence == 0,
	UserinfoPresence = 0.

fragment_presence(String, Boolean) :-
    member(#, String), !,
    Boolean = 1.

fragment_presence(String, Boolean) :-
    nonmember(#, String), !,
    Boolean = 0.

query_presence(Query, QueryPresence) :-
    member(?, Query), !,
    QueryPresence = 1.

query_presence(Query, QueryPresence) :-
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

check_IP(List, BooleanIp) :-
    BooleanIp == 1, 
	split_list(List, ., Out, Other1),
	split_list(Other1, ., Out1, Other2),
	split_list(Other2, ., Out2, Out3),
	tras(Out), tras(Out1), tras(Out2), tras(Out3), !.

check_IP(_, BooleanIp) :-
    BooleanIp == 0.

is_special_scheme(Scheme, BooleanSpecialScheme) :-
	Scheme = ['m','a','i','l','t','o'],
	BooleanSpecialScheme = 1, !.

is_special_scheme(Scheme, BooleanSpecialScheme) :-
	Scheme = ['n','e','w','s'],
	BooleanSpecialScheme = 2, !.

is_special_scheme(Scheme, BooleanSpecialScheme) :-
	Scheme = ['t','e','l'],
	BooleanSpecialScheme = 3, !.

is_special_scheme(Scheme, BooleanSpecialScheme) :-
	Scheme = ['f','a','x'],
	BooleanSpecialScheme = 4, !.

is_special_scheme(Scheme, BooleanSpecialScheme) :-
	Scheme = ['z','o','s'],
	BooleanSpecialScheme = 5, !.

is_special_scheme(_, BooleanSpecialScheme) :-
	BooleanSpecialScheme = 0, !.

nonmember(Arg,[Arg|_]) :-
	!,
	fail.
nonmember(Arg,[_|Tail]) :-
	!,
	nonmember(Arg,Tail).
nonmember(_,[]).

%Il caso in cui no c'è l'authority è ancora da gestire, infatti se non c'è una authority correttamente formattata ritorna false

removeHead([_ | Xs], Xs).

%split_authority(X, BooleanAuthority, Before, After) :-
%	BooleanAuthority == 1,
%	removeHead(X, Xfirst),
%	removeHead(Xfirst, Z),
%	split_list(Z, /, Before, After), !.

split_authority(X, BooleanAuthority,Before, After) :-
	BooleanAuthority == 1,
	member(/, X),
	split_list(X, /, Before, After), !.

split_authority(X, BooleanAuthority, Before, After) :-
	BooleanAuthority == 1,
	nonmember(/, X),
	Before = X, After = [], !.

split_authority(X, BooleanAuthority, Before, After) :-
	BooleanAuthority == 0,
	nonmember(/, X),
	Before = [], After = X, !.

split_authority(X, BooleanAuthority, Before, After) :-
	BooleanAuthority == 0,
	member(/, X),
	removeHead(X, Out),
	Before = [], After = Out, !.

%split_authority(X, _, BooleanAuthority, Before, X) :-
%	Before = [],
%	BooleanAuthority == 0, !.

%Operazioni sull'authority

split_port(String, Car, Before, After, PortPresence) :-
	PortPresence == 1,
	split_list(String, Car, Before, After), !.

split_port(String, _, Before, After, PortPresence) :-
	PortPresence == 0,
	Before = String,
	After = [], !.

splot_host(String, Car, Before, After, UserinfoPresence) :-
	UserinfoPresence == 1,
	split_list(String, Car, Before, After), !.

splot_host(String, _, Before, After, UserinfoPresence) :-
	UserinfoPresence == 0,
	Before = [],
	After = String, !.

splot_host([], _, _, _, _) :- !.

split_fragment(String, _, Before, After, FragmentPresence) :-
    FragmentPresence == 0,
	After = [],
	Before = String, !.

split_fragment(String, Car, Before, After, FragmentPresence) :-
	FragmentPresence == 1,
	split_list(String, Car, Before, After), !.

split_query(String, Car, Before, After, QueryPresence, Boolean) :-
    QueryPresence == 1,
	Boolean == 0,
    split_list(String, Car, Before, After), !.

split_query(String, _, Before, After, QueryPresence, Boolean) :-
    QueryPresence == 0,
	Boolean == 0,
    Before = String,
    After = [], !.

split_query(String, Car, Before, After, QueryPresence, Boolean) :-
    QueryPresence == 1,
	Boolean == 5,
    split_list(String, Car, Before, After), !.

split_query(String, _, Before, After, QueryPresence, Boolean) :-
    QueryPresence == 0,
	Boolean == 5,
    Before = String,
    After = [], !.

split_query(_, _, Before, _, _, _) :-
	Before = [], !.

mailto(List, Out, Out2, Boolean) :-
	Boolean == 1,
	nonmember(@, List),
	Out = List,
	Out2 = [], !.

mailto(List, Out, Out2, Boolean) :-
	Boolean == 1,
	member(@, List),
	split_list(List, @, Out, Out2), !.

mailto(_, _, _, _) :- !.

news(List, Out, Boolean) :-
	Boolean == 2,
	Out = List, !.

news(_, _, _) :- !.

tel(List, Out, Boolean) :-
	Boolean == 3,
	Out = List, !.

tel(_, _, _) :- !.

fax(List, Out, Boolean) :-
	Boolean == 4,
	Out = List, !.

fax(_, _, _) :- !.

%Out code
out_porta([], SottostringaOut) :- 
	SottostringaOut = 80, !.

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
	verifica_identificatori(Userinfo),
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

out_Path(Path, PathOut, Boolean) :-
    Boolean == 0,
    Path \= [],
	verifica_identificatori_path(Path),
	string_to_atom(Path, PathOut), !.

out_Path(Path, PathOut, Boolean) :-
	Boolean == 5,
    Path \= [],
    parentesiCheck(Path, BooleanParentesi),
    splitZos(Path, Id44, Id8, BooleanParentesi),
	length(Id44, N1),
	length(Id8, N2),
	N1 =< 44, N2 =< 9,
	alphabetical(Id8), alphabetical(Id44),
	last(Id44, A), checkChar(A, '.'),
	string_to_atom(Path, PathOut), !.

out_Path([], PathOut, _) :-
    PathOut = []. 

% Fuffa

code_list_to_atom_list([], []) :- !.
code_list_to_atom_list([X | Xs], [Y | Ys]) :- 
	char_code(Y, X), 
	code_list_to_atom_list(Xs, Ys).

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

verifica_identificatori_path(X) :- 
	length(X, 1),  %True se la lista X contiene 1 elemento
	nth0(0, X, Y), %True se l'elemento Y alla posizione 0 della lista X è uno sei deguenti caratteri
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
	list_append(X,T,Z), !.    

checkSpaces(Input, Output) :-
	member(' ', Input),
	replace(' ', '%20', Input, Output), !.

checkSpaces(Input, Output) :-
	nonmember(' ', Input),
	Output = Input.

remove_slash(X, Out, Boolean) :- Boolean == 1, removeHead(X, Out), !.
remove_slash(X, Out, Boolean) :- Boolean == 0, Out = X.

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

alphabetical([X | _]) :- char_type(X, alpha), !.

checkChar(A, Car) :- A \= Car, !.

delete_last(X,Y) :-
    reverse(X,[_|X1]), reverse(X1,Y), !.

delete_last([], Y) :- Y = [].

%#parentesiCHEEEEECK
parentesiCheck(List, Boolean) :-
    member('(', List),
    last(List, ')'),
    Boolean = 1, !.

parentesiCheck(List, Boolean) :-
    nonmember('(', List),
    nonmember(')', List),
    Boolean = 0, !.

splitZos(Path, Id44, After, Boolean) :-
    Boolean == 1,
    split_list(Path, '(', Id44, After),
    !.
splitZos(Path, Id44, _, Boolean) :-
    Boolean == 0, Id44 = Path.

replace(_, _, [], []).
replace(O, R, [O|T], [R|T2]) :- replace(O, R, T, T2).
replace(O, R, [H|T], [H|T2]) :- dif(H,O), replace(O, R, T, T2).

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