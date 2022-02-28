Contributors:
856375 - Barbieri Francesco
852255 - Bartsch Federico
856177 - Moscardo Alessandro

- Cosa fa uri-parse.lisp
    Il programma è formato da diverse funzioni che controllano 
    la presenza e la validità dei campi che formano un uri: 
    - Scheme
    - Userinfo
    - Host 
    - Port 
    - Path
    - Query 
    - Fragment

- Come avviene il parsing?
    Il controllo avviene da sinistra a destra, ciò significa che i campi 
    vengono controllati nell'ordine sopra mostrato.

    La funzione split è molto importante, in quanto si occupa di separare la
    parte della lista di nostro interesse dal resto della lista.

    La logica del programma funziona in questo modo:
    Innanzitutto viene controllata la presenza dello Scheme, 
    se lo scheme è di tipo speciale (tel, fax, mailto, news) vengono chiamate
    le  rispettive funzione per gestirli.

    Se invece lo Scheme è di tipo Standard viene controllata la presenza di 
    Authority, la quale è fondamentale per capire
    come proseguire con il parsing, infatti se authority non è presente viene
    chiamata la funzione authNotPresent, la quale si occupa di fare i dovuti 
    controlli e chiamare le funzioni per gestire questo tipo di uri.

    Proseguendo, vengono controllati Path, Query e Fragment se presenti, 
    tramite le funzioni check-path, check-query, check-fragment.

    Ad ognuna di queste funzioni sopra citate viene passata la lista Final 
    che viene costruita man mano che il programma va avanti.

    Final parte infatti vuota, e ad ogni funzione vengono appese le dovute
    parti dell'uri e i NIL, nel caso in cui esse non siano presenti.

    La funzione exit viene richiamata per ultima e si occupa di costruire la
    struttura dell'uri, a partire dalla lista final sopra citata.

    Infine vi è la funzione uri-display che si occupa di visualizzare la 
    struttura dell'uri.