presenzaPath(Sottostringa, PresenzaAuthority, PresenzaPath):-
    PresenzaAuthority == 1,
    member(/, Sottostringa), 
    presenzaPath = 1, !.

presenzaPath(Sottostringa, PresenzaAuthority, PresenzaPath):-
    PresenzaAuthority == 1,
    nonmember(/, Sottostringa), 
    presenzaPath = 0, !.

presenzaPath(Sottostringa, PresenzaAuthority, PresenzaPath):-
    PresenzaAuthority == 0,
    member(/, Sottostringa),
    PresenzaPath = 1, !.

presenzaPath(Sottostringa, PresenzaAuthority, PresenzaPath):-
    PresenzaAuthority == 0,
    nonmember(/, Sottostringa),
    PresenzaPath = 0, !.
