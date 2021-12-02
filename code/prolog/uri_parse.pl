uri_parse (URIString, URI) :-
    %conversione da stringa a lista di codici
    string_to_list(URIString, URICodeList),

    %conversione da lista di codici a lista leggibile
    codeListToAtomList(URICodeList, URIList),

    %se trovo un ":" nella lista di char non faccio backtracking dato che è l'elemento che mi indica la fine dello scheme
    member (':', URIList),
    !.

    URI = uri(Scheme, Userinfo, Host, Port, Path, Query, Fragment).

%convertitore da codici dei caratteri in caratteri leggibili
codeListToAtomList([], []) :- !.
codeListToAtomList([X | Xs], [Y | Ys]) :- 
	char_code(Y, X), 
	codeListToAtomList(Xs, Ys).

%funzione che data una stringa, ritorna true se trova un identificatore
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
	verifica_identificatore(Xs).