% Allora boys, in breve cosa fa:
% Presa una stringa "https://user@info.com:8080/altro"
% 1) Splitta la lista dove ci sono i :
%	[https] [//user@info.com:8080/altro]
% 2) Controlla se è presente l'authority con i // e li rimuove
%	Se presente allora AuthorityPresence = 1, altrimenti 0
%	[https] [user@info.com:8080/altro]
% 	NB: Il caso in cui non c'è l'authority è ancora da gestire, infatti se non c'è una authority correttamente
%	formattata ritorna false
% 3) Aggiunge uno / alla fine della stringa per il caso in cui sia https://domain.com per riconoscere l'authority
%	Questo passaggio sarà da gestire nel momento in cui si fa il path, o trovare un metodo per aggiungere lo /
%	finale SOLO SE non presente nell'authority, ma per determinare l'authority uso lo / quindi è un po' un casino ma si può fare,
%	bisogna solo trovare un metodo
% 4) Divide l'authority in presenza dello /
%	[https] [user@info.com:8080] [altro]
% 5) Lavora sull'authority, individua se sono presenti userinfo e port
% 	Setta di conseguenza PortPresence e UserinfoPresence (come per AuthorityPresence)
% 6) Divide di conseguenza la porta in presenza dei :
%	[https] [user@info.com] [8080] [altro]
%	Se PortPresence == 0 allora Port = []
% 7) Divide di conseguenza lo userinfo in presenza di @
%	[https] [user] [info.com] [8080] [altro]
% 	Se UserinfoPresence == 0 allora Userinfo = []
% 8) E niente poi stampa tutto come era per lo scheme
% 8*) Altro = Path + Query(?) + Fragmanetà(#)
% 9) Isola il fragment da Altro basandosi sull'#
%
%================================ 
% Prossimi step per terminare la parte dell'authority:
% 1) Gestire quando non è presente l'authority
% 2) Gestire le porte di default
% 3) E boh controllare i caratteri che non so se ho tenuto conto di tutti
% 4) Aggiungere controllo IP sul dominio
% 5) Quando è presente l'authority, si deve riconoscere con / , ? , # oppure il '', adesso appenda uno / e riconosce con quello

uri_parse(URIString, URI) :- 
	string_to_list(URIString, URICodeList),

    %conversione da lista di codici a lista leggibile
    codeListToAtomList(URICodeList, URIList),

    %se trovo un ":" nella lista di char non faccio backtracking dato che è l'elemento che mi indica la fine dello scheme
    member(':', URIList),
    !,

	splitList(URIList, :, Scheme, Sottostringa),

	%append([':'], Sottostringa, Sottostringa1),

	%BooleanAuthority controlla se l'authorithy è presente o meno (1 o 0)
	presenzaAuthority(Sottostringa, AuthorityPresence),
	
	%Authority è userinfo + host + port
	%isolateAuthority(Sottostringa, BooleanAuthority, Z),

	%after è tutto quello dopo l'authority
	list_append(/, Sottostringa, Sottostringa1),

	splitAuthority(Sottostringa1, /, AuthorityPresence, Authority, After),

	presenzaPort(Authority, PortPresence, AuthorityPresence),
    presenzaUserinfo(Authority, UserinfoPresence, AuthorityPresence),
    presenzaFragment(After, FragmentPresence),
    presenzaQuery(After, QueryPresence),

	splitPort(Authority, :, TempAuthority, Port, PortPresence),
    splitHost(TempAuthority, @, Userinfo, Host, UserinfoPresence),
    splitFragment(After, #, OtherString, Fragment, FragmentPresence),
    splitQuery(OtherString, ?, Path, Query, QueryPresence),

	out_scheme(Scheme, SchemeOut),
	out_userinfo(Userinfo, UserinfoOut),
	out_host(Host, HostOut),
    out_porta(Port, PortaOut),
    out_fragment(Fragment, FragmentOut),
    out_query(Query, QueryOut),
    out_Path(Path, PathOut),

	%URI = uri(AuthorityPresence, Sottostringa1).
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

presenzaUserinfo(Authority, UserinfoPresence, AuthorityPresence) :- 
	AuthorityPresence == 1,
	member(@, Authority), !,
	UserinfoPresence = 1.

presenzaUserinfo(Authority, UserinfoPresence, AuthorityPresence) :- 
	AuthorityPresence == 1,
	nonmember(@, Authority), !,
	UserinfoPresence = 0.

presenzaFragment(String, PresenzaFragment) :-
    member(#, String), !,
    PresenzaFragment = 1.

presenzaFragment(String, PresenzaFragment) :-
    nonmember(#, String), !,
    PresenzaFragment = 0.

presenzaFragment([], PresenzaFragment) :-
    PresenzaFragment = 0, !.

presenzaQuery(Query, QueryPresence) :-
    member(?, Query), !,
    QueryPresence = 1.

presenzaQuery(Query, QueryPresence) :-
    nonmember(?, Query), !,
    QueryPresence = 0.

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

splitFragment(String, Car, Before, After, FragmentPresence) :-
    FragmentPresence == 0,
	After = [],
	Before = String, !.

splitFragment(String, Car, Before, After, FragmentPresence) :-
	FragmentPresence == 1,
	splitList(String, Car, Before, After), !.

splitQuery(String, Car, Before, After, QueryPresence) :-
    QueryPresence == 1,
    splitList(String, Car, Before, After), !.

splitQuery(String, Car, Before, After, QueryPresence) :-
    QueryPresence == 0,
    Before = Path,
    After = Query, !.

%Out code
out_porta([], SottostringaOut) :- 
	SottostringaOut = [], !.

out_porta(Sottostringa, SottostringaOut) :- 
	isDigit(Sottostringa), 
	number_string(SottostringaOut, Sottostringa).

out_scheme(Scheme, SchemeOut) :- 
	verifica_identificatori(Scheme),
	string_to_atom(Scheme, SchemeOut).

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

out_query(Query, QueryOut) :-
    nonmember(#, Query),
    string_to_atom(Query, QueryOut), !.

out_query([], QueryOut) :-
    QueryOut = [], !.

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