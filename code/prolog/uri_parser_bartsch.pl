uri_parse(URIString, URI):-
	string_to_list(URIString, URICodeList),
	codeListToAtomList(URICodeList, URIList),
	member(':', URIList),
	splitList(URIList, ':', X, Y),
	append(X, ':', Scheme),
	!.




codeListToAtomList([], []) :- !.
codeListToAtomList([X | Xs], [Y | Ys]) :- 
 	char_code(Y, X), 
 	codeListToAtomList(Xs, Ys).


splitList([A|Ls], A, [], Ls).
splitList([L|Ls], A, [L|Xs], R):- 
		L\==A,
		splitList(Ls, A, Xs, R).
