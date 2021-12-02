uri_parse(URIString, URI) :-
    %conversione da stringa a lista di codici
    string_to_list(URIString, URICodeList),

    %conversione da lista di codici a lista leggibile
    codeListToAtomList(URICodeList, URIList),

    %se trovo un ":" nella lista di char non faccio backtracking dato che è l'elemento che mi indica la fine dello scheme
    member(':', URIList),
    !,

	%divido la stringa URIList in due parti con il predicato splitString, spiegato dopo. Questo per identificare lo scheme e "separarlo" dal resto della stringa
	splitList(URIList, :, Scheme, Sottostringa),

	%a partire da Scheme genero una stringa SchemeOut da poter stampare a video
	out_scheme(Scheme, SchemeOut),
	
    URI = uri(SchemeOut). %, Userinfo, Host, Port, Path, Query, Fragment).

uri(_, _, _, _, _, _, _).

%genero una stringa SchemeOut da poter stampare a video
out_scheme(Scheme, SchemeOut) :- 
	verifica_identificatori(Scheme),
	string_to_atom(Scheme, SchemeOut).

%convertitore da codici dei caratteri in caratteri leggibili
codeListToAtomList([], []) :- !.
codeListToAtomList([X | Xs], [Y | Ys]) :- 
	char_code(Y, X), 
	codeListToAtomList(Xs, Ys).

%predicato che data una stringa, ritorna true se trova un identificatore
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

%predicato splitList, per dividere una stringa data in una parte prima e dopo un carattere dato
splitList([A|Ls], A, [], Ls) :- !.
splitList([L|Ls], A, [L|Xs], R):- 
	L\==A,
	splitList(Ls, A, Xs, R),
	!.

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