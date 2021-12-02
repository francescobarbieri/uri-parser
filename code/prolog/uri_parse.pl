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