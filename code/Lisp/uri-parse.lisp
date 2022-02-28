;; Lisp uri-parser 02/2022 - Linguaggi di Programmazione
;; Contributors:
;; Mat. 856375 - Barbieri Francesco
;; Mat. 852255 - Bartsch Federico
;; Mat. 856177 - Moscardo Alessandro

(defstruct uri scheme userinfo host port path query fragment)

;; Funzione principle che converte la stringa in lista, divide la
;; lista con i ':' e in base alla presenza dell'authority, agisce di conseguenza
(defun uri-parse (stringa)
  (let ((lista (coerce stringa 'list)))
    (if (null lista) (error "Lista vuota non e' una uri")
      (let ((final (list '() )))
	(if (char-presence lista #\:)
	    (let ((l (multiple-value-bind
		      (val1 val2)
		      (split lista
			     (findPosition #\: lista)) val1))
		  (r (multiple-value-bind
		      (val1 val2)
		      (split lista (findPosition #\: lista)) val2)))
	      (if (and (equal (car r) #\/) (equal (car (cdr r)) #\/))
		  (if (and (no-special-scheme l) (identificators-presence l))
		      (check-userinfo (cdr (cdr r))
				      (append (list-to-betterList l))))
		(if (identificators-presence l)
		    (authNotPresent r
				    (append
				     (list-to-betterList l) final)))))
	  (error "l'uri non ha i :"))))))

;; Controlla la corretta formattazione di userinfo e i suoi caratteri.
;; Divide la lista in userinfo e resto, che viene passata a host-check.
(defun check-userinfo (lista final)
  (cond ((char-presence lista #\@) 
         (let ((l (multiple-value-bind
		   (val1 val2)
		   (split lista (findPosition #\@ lista)) val1))
               (r (multiple-value-bind
		   (val1 val2)
		   (split lista (findPosition #\@ lista)) val2)))
           (if (null l)
	       (error "userinfo non puo' essere vuoto se @ e' presente"))
           (if (null r)
	       (error "host non puo' essere vuoto se @ e' presente"))
           (if (is-userinfo l)
               (host-check r (append (list-to-betterList l) final)))))
        ((equal (in-position final 1) "mailto")
         (if (is-userinfo lista)
             (exit (append '(nil) '(nil) '(nil) '(nil) '(nil) final))))
        ((null lista)
	 (error "host non puo' essere vuoto"))
	((equal (car lista) #\:)
	 (error "':' non puo' essere il primo carattere dell'host" ))
	((eq (getlast lista) #\:)
	 (error "porta non valida"))
        (t (host-check lista (append '(nil) final)))))

;; Alternativa a check-userinfo, in base a scheme e/o sintassi particolari
;; agisce di conseguenza
(defun authNotPresent (lista final)
  (if (equal (car lista) #\:) (error "invalid char '::'"))
  (if (null (in-position final 1)) (error "scheme non puo' essere vuoto"))
  (cond 
   ((equal (in-position final 1) "mailto") (scheme-mailto lista final))
   ((equal (in-position final 1) "news") (scheme-news lista final))
   ((or (equal (in-position final 1) "tel")
	(equal (in-position final 1) "fax"))
    (scheme-telfax lista final))
   ((and (eq (car lista) #\/) (equal (in-position final 1) "zos"))
    (check-path-zos (cdr lista) (append '(nil) '(nil) '(nil)  final)))
   ((eq (car lista) #\/)
    (check-path (cdr lista) (append '(80) '(nil) '(nil) final)))
   ((equal (in-position final 1) "zos")
    (check-path-zos lista (append '(nil) '(nil) '(nil)  final)))
   (t (check-path lista (append '(80) '(nil) '(nil) final)))))

;; Controlla la corretta formattazione di host e i suoi caratteri.
;; Divide la lista in host e resti e in base al carattere seguente (:, ?, #, /)
;; viene invocata la funzione corrispondente.
(defun host-check (lista final)
  (cond 
   ((equal (in-position final 2) "mailto")
    (if (identificators-presence lista)
	(exit
	 (append '(nil) '(nil) '(nil) '(80)
		 (list-to-betterList lista) final))))
   ((char-presence lista #\:)
    (let ((l (multiple-value-bind
	      (val1 val2) (split lista (findPosition #\: lista)) val1))
	  (r (multiple-value-bind
	      (val1 val2) (split lista (findPosition #\: lista)) val2)))
      (if (is-host l)
	  (check-port r (append (list-to-betterList l) final)))))
   ((and (equal (in-position final 2) "zos") (char-presence lista #\/))
    (let ((l (multiple-value-bind
	      (val1 val2) (split lista (findPosition #\/ lista)) val1))
          (r (multiple-value-bind
	      (val1 val2) (split lista (findPosition #\/ lista)) val2)))
      (if (is-host l)
          (check-path-zos r (append '(80) (list-to-betterList l) final)))))
   ((char-presence lista #\/)
    (let ((l (multiple-value-bind
	      (val1 val2) (split lista (findPosition #\/ lista)) val1))
	  (r (multiple-value-bind
	      (val1 val2) (split lista (findPosition #\/ lista)) val2)))
      (if (is-host l)
	  (check-path r (append '(80) (list-to-betterList l) final)))))
   ((char-presence lista #\?)
    (let ((l (multiple-value-bind
	      (val1 val2) (split lista (findPosition #\? lista)) val1))
	  (r (multiple-value-bind (val1 val2)
				  (split lista
					 (findPosition #\? lista)) val2)))
      (if (is-host l)
	  (check-query
	   r (append '(nil) '(80) (list-to-betterList l) final)))))
   ((char-presence lista #\#)
    (let ((l (multiple-value-bind
	      (val1 val2) (split lista (findPosition #\# lista)) val1))

	  (r (multiple-value-bind
	      (val1 val2) (split lista (findPosition #\# lista)) val2)))
      (if (is-host l)
	  (check-fragment r (append '(nil) '(nil) '(80)
				    (list-to-betterList l) final)))))
   (t (if (is-host lista)
	  (exit (append '(nil) '(nil) '(nil) '(80)
			(list-to-betterList lista) final))))))

;; Controlla corretta formattazione di porta e i suoi caratteri.
;; Divide la lista in porta e resto e in base al carattere seguente (?, #, /)
;; viene invocata la funzione corrispondente.
(defun check-port (lista final)
  (cond
   ((and (equal (in-position final 3) "zos") (char-presence lista #\/))
    (let ((l (multiple-value-bind
	      (val1 val2) (split lista (findPosition #\/ lista)) val1))
          (r (multiple-value-bind
	      (val1 val2) (split lista (findPosition #\/ lista)) val2)))
      (if (identificators-presence l)
          (check-path-zos r (append (list-to-betterList l) final)))))
   ((char-presence lista #\/)
    (let ((l (multiple-value-bind
	      (val1 val2) (split lista (findPosition #\/ lista)) val1))
	  (r (multiple-value-bind
	      (val1 val2) (split lista (findPosition #\/ lista)) val2)))
      (if (equal (is-digit l) nil)
	  (error "la porta contiene caratteri non validi"))
      (if (identificators-presence l)
	  (check-path r (append (list-to-betterList l) final)))))
   ((char-presence lista #\?)
    (let ((l (multiple-value-bind
	      (val1 val2) (split lista (findPosition #\? lista)) val1))
	  (r (multiple-value-bind
	      (val1 val2) (split lista (findPosition #\? lista)) val2)))
      (if (equal (is-digit l) nil)
	  (error "la porta contiene caratteri non validi"))
      (if (identificators-presence l)
	  (check-query r (append '(nil) (list-to-betterList l) final)))))
   ((char-presence lista #\#)
    (let ((l (multiple-value-bind
	      (val1 val2) (split lista (findPosition #\# lista)) val1))
	  (r (multiple-value-bind
	      (val1 val2) (split lista (findPosition #\# lista)) val2)))
      (if (equal (is-digit l) nil)
	  (error "la porta contiene caratteri non validi"))
      (if (identificators-presence l)
	  (check-fragment
	   r (append '(nil) '(nil) (list-to-betterList l) final)))))
   (t (if (not (is-digit lista))
	  (error "la porta contiene caratteri non validi"))
      (exit (append '(nil) '(nil) '(nil)
		    (list-to-betterList lista) final)))))

;; Controlla corretta formattazione di path e i suoi caratteri.
;; Divide la lista in path e resto e in base al carattere seguente (?, #)
;; viene invocata la funzione corrispondente.
(defun check-path (lista final)
  (if (or (equal (car lista) #\/))
      (error "invalid path"))
  (cond
   ((char-presence lista #\?)
    (let ((l (multiple-value-bind
	      (val1 val2) (split lista (findPosition #\? lista)) val1))
	  (r (multiple-value-bind
	      (val1 val2) (split lista (findPosition #\? lista)) val2)))
      (if (is-path l)
	  (check-query r
		       (append (list-to-betterList l) final)))))
   ((char-presence lista #\#)
    (let ((l (multiple-value-bind
	      (val1 val2) (split lista (findPosition #\# lista)) val1))
	  (r (multiple-value-bind
	      (val1 val2) (split lista (findPosition #\# lista)) val2)))
      (if (is-path l)
	  (check-fragment r (append '(nil)
				    (list-to-betterList l) final)))))
   (t (if (is-path lista)
	  (exit (append '(nil) '(nil)
			(list-to-betterList lista) final))))))

;; Controlla corretta formattazione di path e i suoi caratteri.
;; Divide la lista in path-zos e in base al carattere seguente (?, #)
(defun check-path-zos (lista final)
  (cond
   ((char-presence lista #\?)
    (let ((l (multiple-value-bind
	      (val1 val2) (split lista (findPosition #\? lista)) val1))
          (r (multiple-value-bind
	      (val1 val2) (split lista (findPosition #\? lista)) val2)))
      (if (is-zos-path l)
          (check-query r (append (list-to-betterList l) final)))))
   ((char-presence lista #\#)
    (let ((l (multiple-value-bind
	      (val1 val2) (split lista (findPosition #\# lista)) val1))
          (r (multiple-value-bind
	      (val1 val2) (split lista (findPosition #\# lista)) val2)))
      (if (is-zos-path l)
          (check-fragment
	   r (append '(nil) '(nil) (list-to-betterList l) final)))))
   (t (if (is-zos-path lista) 
	  (exit (append '(nil) '(nil)
			(list-to-betterlist lista) final ))))))

;; Controlla corretta formattazione di query e i suoi caratteri.
;; Divide la lista in query e resto e in base al carattere seguente (#)
;; viene invocata la funzione corrispondente.
(defun check-query (lista final)
  (cond
   ((char-presence lista #\#)
    (let ((l (multiple-value-bind
	      (val1 val2) (split lista (findPosition #\# lista)) val1))
	  (r (multiple-value-bind
	      (val1 val2) (split lista (findPosition #\# lista)) val2)))
      (if (is-query l)
	  (check-fragment r
			  (append (list-to-betterList l) final)))))
   (t (if (is-query lista) (exit
			    (append '(nil)
				    (list-to-betterList lista) final))))))

;; Controlla corretta formattazione di fragment.
(defun check-fragment (lista final)
  (cond
   ((null lista)
    (error "fragment troppo corto"))
   (t (exit (append (list-to-betterList lista) final)))))

;; Viene invocata nel caso di scheme = tel/fax.
;; Controlla correttezza formattazione di questo special scheme.
(defun scheme-telfax (lista final)
  (if (is-userinfo lista)
      (exit (append '(nil) '(nil) '(nil) '(80) '(nil)
		    (list-to-betterList lista) final))))

;; Viene invocata nel caso di scheme = news.
;; Controlla correttezza formattazione di questo special scheme.
(defun scheme-news (lista final)
  (if (identificators-presence lista) 
      (exit (append '(nil) '(nil) '(nil) '(80)
		    (list-to-betterList lista) '(nil) final))))

;; Viene invocata nel caso di scheme = mailto.
;; Controlla correttezza formattazione di questo special scheme.
(defun scheme-mailto (lista final)
  (cond 
   ((null lista) (exit (append '(nil) '(nil) '(nil) '(80) '(nil)
			       (list-to-betterList lista) final)))
   ((char-presence lista #\@)
    (let
	((l (multiple-value-bind
	     (val1 val2) (split lista (findPosition #\@ lista)) val1))
	 (r (multiple-value-bind
	     (val1 val2) (split lista (findPosition #\@ lista)) val2)))
      (if (is-userinfo l)
	  (host-check r (append (list-to-betterList l) final)))))
   (t (if (is-userinfo lista)
          (exit (append '(nil) '(nil) '(nil) '(80) '(nil)
			(list-to-betterList lista) final ))))))

;; Funzione che assegna ad ogni campo di make-uri la corretta componente dell'uri
(defun exit (final)
  (make-uri :scheme (in-position final 7)
            :userinfo (in-position final 6)
            :host (in-position final 5)
            :port (in-position final 4)
            :path (in-position final 3)
            :query (in-position final 2)
            :fragment (in-position final 1)))

;; Funzione che stampa a video o su file (fornendo uno stream)
;; la defstruct correttamente formattata
(defun uri-display (struct &optional stream)
  (if (null stream)
      (format t " 
SCHEME:  ~C ~a 
USERINFO: ~C ~a 
HOST: ~C ~C ~a 
PORT: ~C ~C ~a 
PATH: ~C ~C ~a
QUERY:  ~C ~a 
FRAGMENT: ~C ~a "
	      #\tab (uri-scheme struct)
	      #\tab (uri-userinfo struct)
	      #\tab #\tab (uri-host struct)
	      #\tab #\tab (uri-port struct)
	      #\tab #\tab (uri-path struct)
	      #\tab (uri-query struct) #\tab (uri-fragment struct))
    (with-open-file (out stream
			 :direction :output
			 :if-exists :supersede
			 :if-does-not-exist :create)
		    (format out " 
SCHEME:  ~C ~a 
USERINFO: ~C ~a 
HOST: ~C ~C ~a 
PORT: ~C ~C ~a 
PATH: ~C ~C ~a
QUERY:  ~C ~a 
FRAGMENT: ~C ~a "
#\tab (uri-scheme struct)
#\tab (uri-userinfo struct) #\tab #\tab (uri-host struct) #\tab
#\tab (uri-port struct) #\tab #\tab (uri-path struct)
#\tab (uri-query struct) #\tab (uri-fragment struct)))) T)

;; funzioni di controllo caratteri e operazioni su liste
;; (miscellaneous)
(defun is-userinfo (lista)
  (cond ((null lista) t)
        ((not (identificators (car lista))) (error "carattere"))
        (t (is-userinfo (cdr lista)))))

(defun list-to-betterList (lista)
  (if (null lista) '(nil)
    (list(coerce lista 'string))))

(defun identificators (char)
  (if (null char) nil
    (if (or 
	 (eq char #\/)
	 (eq char #\?)
	 (eq char #\#)
	 (eq char #\@)
	 (eq char #\:)) nil t)))

(defun identificators-host (char)
  (if (null char) nil
    (if (or  (eq char #\/)
             (eq char #\?)
             (eq char #\#)
             (eq char #\@)
             (eq char #\:)) nil t)))

(defun identificators-path (char)
  (if (null char) nil
    (if (or  (eq char #\?)
             (eq char #\#)
             (eq char #\@)
             (eq char #\:)) nil t)))

(defun char-to-number (n)
  (cond ((eq n #\0) 0)
	((eq n #\1) 1)
	((eq n #\2) 2)
	((eq n #\3) 3)
	((eq n #\4) 4)
	((eq n #\5) 5)
	((eq n #\6) 6)
	((eq n #\7) 7)
	((eq n #\8) 8)
	((eq n #\9) 9)
	(t nil)))

(defun findPosition (character list)
  (cond
   ((null list) nil)
   ((eq (car list) character) 0)
   (t (1+ (findPosition character (cdr list))))))

(defun split (list count)
  (values (first-n list count) (nthcdr (+ 1 count) list)))

(defun char-presence (lista char)
  (cond
   ((null lista) nil)
   ((eq (car lista) char) t)
   (t (char-presence (cdr lista) char))))

(defun is-path (lista)
  (cond ((null lista) t)
        ((not (is-identificators-path lista)) (error "invalid path"))
        ((not (no-slash-slash lista)) (error "invalid path"))
        (t t)))

(defun is-identificators-path (lista)
  (cond
   ((null lista) t)
   ((not (identificators-path (car lista))) (error "caratteri non validi"))
   (t (is-identificators-path (cdr lista)))))

(defun identificators-presence (lista)
  (cond 
   ((null lista) t)
   ((not (identificators (car lista)))
    (error "sono presenti caratteri speciali non validi"))  
   (t (identificators-presence (cdr lista)))))

(defun first-n (list n)
  (when (not (zerop n))
    (cons (first list) (first-n (rest list) (1- n)))))

(defun no-dot-dot (lista)
  (cond
   ((null lista) T)
   ((and (equal (car lista) #\.) (equal (car (cdr lista)) #\.))
    (error "invalid host"))
   (T (no-dot-dot (cdr lista)))))

(defun no-slash-slash (lista)
  (cond
   ((null lista) T)
   ((and (equal (car lista) #\/) (equal (car (cdr lista)) #\/))
    (error "invalid path"))
   (T (no-slash-slash (cdr lista)))))

(defun in-position (lista n)
  (if (= n 1) (car lista)
    (in-position (cdr lista) (- n 1))))

(defun is-digit (lista)
  (eval (cons 'and (mapcar (lambda (num)
			     (if (null (char-to-number num)) nil t)) lista))))

(defun no-special-scheme (lista)
  (cond ((equal lista '(#\m #\a #\i #\l #\t #\o)) (error "invalid mailto"))
        ((equal lista '(#\n #\e #\w #\s)) (error "invalid news"))
        ((equal lista '(#\t #\e #\l)) (error "invalid tel"))
        ((equal lista '(#\f #\a #\x)) (error "invalid fax"))
        (t t)))

(defun is-host (lista)
  (cond 
   ((null lista) nil)
   ((or (equal (car lista) #\.) (equal (getlast lista) #\.)
	(not (no-dot-dot lista))) (error "invalid host"))
   ((identificators-presence lista) t)
   (t t)))

(defun is-zos-path (lista)
  (cond ((and (char-presence lista #\() (char-presence lista #\))
	      (eq (occ #\( lista) 1) (eq (occ #\) lista) 1))
         (let ((l (multiple-value-bind
		   (val1 val2)
		   (split lista (findPosition #\( lista)) val1))
               (r (multiple-value-bind
		   (val1 val2)
		   (split lista (findPosition #\( lista)) val2)))
           (if (and (id44 l) (id8 (removeLast r)))
               t
             (error "zos path non valido"))))
        (t (id44 lista))))

(defun id44 (lista)
  (cond 
   ((null lista)
    (error "id44 non puo' essere lungo 0"))
   ((eq (getlast lista) #\.)
    (error "id44 non puo' finire con un punto"))
   ((> (lunghezza lista) 44)
    (error "La lunghezza di id44 deve essere almeno di 44 caratteri"))
   ((not(alfanumerici-punti lista))
    (error "id44 ammette solo caratteri alfanumerici e punti"))
   ((not (alpha-char-p (car lista)))
    (error "id44 deve iniziare con un carattere alfabetico" ))
   (t t)))

(defun id8 (lista)
  (cond 
   ((null lista)
    (error "id8 non puo' essere lungo 0"))
   ((> (lunghezza lista) 8)
    (error "La lunghezza di id8 non puo' essere maggiore di 8"))
   ((not (alfanumerici lista))
    (error "id8 ammette solo caratteri alfanumerici"))
   ((not (alpha-char-p (car lista)))
    (error "id8 deve iniziare con un carattere alfabetico"))
   (t t)))

(defun getlast (list)
  (car (last list)))

(defun lunghezza (list)
  (cond ((null list) 0)
        (t (1+ (lunghezza (cdr list))))))

(defun occ (sym nested-list)
  (cond
   ((consp nested-list)
    (+ (occ sym (car nested-list)) (occ sym (cdr nested-list))))
   ((eq sym nested-list) 1)
   (t 0)))

(defun alfanumerici-punti (lista)
  (cond ((null lista) t)
        ((eq (car lista) #\.) (alfanumerici-punti (cdr lista)))
        ((not (alphanumericp (car lista))) nil)
        (t (alfanumerici-punti (cdr lista)))))

(defun alfanumerici (lista)
  (cond ((null lista) t)
        ((not (alphanumericp (car lista))) nil)
        ((alfanumerici (cdr lista)))))

(defun removeLast (lista)
  (removen lista (- (lunghezza lista) 1)))

(defun removen (l n)
  (cond ((null l) nil)
	((= n 0) (cdr l))
	(T (cons (car l) (removen (cdr l) (- n 1))))))

(defun is-query (lista)
  (cond ((null lista)
	 (error "query non puo' essere lunga 0"))
        ((identificatoriQuery lista))
        (t t)))

(defun identificatoriQuery (lista)
  (cond 
   ((null lista) t)
   ((eq (car lista) #\#)
    (error "non sono ammessi # in query"))
   (t (identificatoriQuery (cdr lista)))))

;; END OF FILE
