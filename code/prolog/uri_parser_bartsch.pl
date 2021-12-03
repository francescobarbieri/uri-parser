uri_parse(URIString, URI):-
	string_to_list(URIString, URICodeList),
	codeListToAtomList(URICodeList, URIList),
	member(:, URIList),
	splitList(URIList, :, Scheme, Y),
	append(Scheme, [':','/','/'], X),

	ord_subtract(URIList, X, Remain),
	splitHost(Remain, [':'|'/'], Hl, Hr),
	out_scheme(Scheme, SchemeOut),
	string_to_atom(Hl, HostOut),
	%out_Host(Hl, HostOut),
    URI = uri(SchemeOut, HostOut). %, Userinfo, Host, Port, Path, Query, Fragment).

codeListToAtomList([], []).
codeListToAtomList([X | Xs], [Y | Ys]) :- 
 	char_code(Y, X), 
 	codeListToAtomList(Xs, Ys).


splitList([A|Ls], A, [], Ls):- !.
splitList([L|Ls], A, [L|Xs], R):- 
		L\==A,
		splitList(Ls, A, Xs, R).

splitHost([B|Ls], [A|B], [], Ls).
splitHost([A|Ls], [A|B], [], Ls).
splitHost([L|Ls], [A|B], [L|Xs], R):- 
		L\==A,
		splitHost(Ls, [A|B], Xs, R).
splitHost([L|Ls], [A|B], [L|Xs], R):- 
		L\==B,
		splitHost(Ls, [A|B], Xs, R).


out_scheme(Scheme, SchemeOut) :- 
	verifica_identificatori(Scheme),
	string_to_atom(Scheme, SchemeOut).

out_Host(Host, HostOut) :- 
	verifica_identificatori(Host),
	string_to_atom(Host, HostOut).


verifica_identificatori(X) :- 
	length(X, 1),  %True se la lista X contiene 1 elemento
	nth0(0, X, Y), %True se l'elemento Y alla posizione 0 della lista X non è uno sei deguenti caratteri
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




