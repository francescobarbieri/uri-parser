Contributors:
856375 - Barbieri Francesco
852255 - Bartsch Federico
856177 - Moscardo Alessandro

- Cosa fa uri-parse.pl
    Il programma uri-file.pl è un parser di URI sviluppato interamente
    in Prolog.
    Data una uri generale 'scheme://userinfo@host:port/path?query#fragment'
    questa viene parsata e suddivisa nei suoi campi:
        - scheme
        - userinfo
        - host
        - port
        - path
        - query
        - fragment

- Come avviene il parsing?
    Il parsing avviene tramite una parte logica (di fatto un automa) che
    controlla la presenza o meno delle varie componenti dell'uri e, in base
    a questi controlli agisce di conseguenza.
    
    Il risultato del controllo
    viene salvato in apposite variabili chiamate 'Boolean-NomeComponente'
    che contengono 0 o 1 (0 componente non presente, 1 componente presente).
    
    Le variabili 'Boolean-NomeComponente' vengono richiamate all'interno dei
    predicati che devono agire in base a delle condizioni.

    Per esempio il predicato 'split_query/6' quando 'BooleanQuery' è pari a
    1 esegue lo split della lista dove vi è l'identificatore della query
    ('?'), altrimenti non farà niente e ritornerà query pari a lista vuota.
    
    Vi è infine un'ultima variabile chiamata 'Boolean-SpecialScheme' la quale
    può assumere valori compresi tra 0 e 5 in base alla tipologia di
    URI speciale:
        - 0 normale
        - 1 mailto
        - 2 news
        - 3 tel
        - 4 fax
        - 5 zos
