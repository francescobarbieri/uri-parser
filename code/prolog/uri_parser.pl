uri_parse(URIString, URI):-
	string_to_list(URIString, URICodeList),
	codeListToAtomList(URICodeList, URIList),
	member(':', URIList),
	!.


codeListToAtomList([], []) :- !.
codeListToAtomList([X | Xs], [Y | Ys]) :- 
 	char_code(Y, X), 
 	codeListToAtomList(Xs, Ys).