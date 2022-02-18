(defstruct uri scheme userinfo host port path query fragment)

(defun findPosition (character list)
  (cond
    ((null list) nil)
    ((eq (car list) character) 0)
    (t (1+ (findPosition character (cdr list))))))


(defun split(list count)
      (values (subseq list 0 count) (nthcdr (+ 1 count) list)))

(defun string-to-list (stringa)
 (let ((lista (coerce stringa 'list)))
       (if (null lista) (error "Empty is not a URI")
       (uri-parse lista))))

(defun uri-parse (lista)
 (let ((l (multiple-value-bind (val1 val2) (split lista (findPosition #\: lista)) val1))
       (r (multiple-value-bind (val1 val2) (split lista (findPosition #\: lista)) val2)))
  (which-scheme l r))
)


;metodo che controlla il tipo di scheme
(defun which-scheme (scheme r)
 (cond
 ((equal scheme '(#\m #\a #\i #\l #\t #\o)) (scheme-mailto scheme r))
 ((equal scheme '(#\n #\e #\w #\s)) (scheme-news shcme r))
 ((equal scheme '(#\f #\a #\x)) (scheme-fax scheme r))
 ((or (equal scheme '(#\h #\t #\t #\p)) (equal scheme '(#\h #\t #\t #\p #\s)) (equal scheme '(#\z #\o #\s))) (scheme-normal scheme r))))

;entra in questa funzione se lo scheme è http, https oppure zos
(defun scheme-normal (scheme tail)
  (let ((final (list '() )))
    (if (and (equal (car tail) #\/) (equal (car (cdr tail)) #\/))
        (authPresent (cdr (cdr tail)) (append (list-to-betterList scheme) final))
        (authNotPresent tail (append (list-to-betterList scheme) final)))))





;entra in questa funzione se authority è presente
(defun authPresent (lista final)
  (if (equal (car lista) #\@) (error "non ci puo essere la @ a inizio userinfo"))
    (if (equal (char-presence lista) 1)       
      (let ((l (multiple-value-bind (val1 val2) (split lista (findPosition #\@ lista)) val1))
            (r (multiple-value-bind (val1 val2) (split lista (findPosition #\@ lista)) val2)))
            (host-check r (append (list-to-betterList l) final))))
   (if (not (equal (char-presence lista) 1)) 
     (host-check lista (append nil final))))  

;entra in questa funzione se authority non è presente
(defun authNotPresent (lista final)
  (print "authNotPresent")
)

;controllo correttezza host
(defun host-check (lista final)
  (print lista)
  (print final)
)

;entra se lo scheme è di tipo mailto 
(defun scheme-mailto (scheme tail)
  (print "mailto")
)

; entra se lo scheme è di tipo new
(defun scheme-news (scheme tail)
  (print "news")
)

;entra se lo scheme è di tipo fax
(defun scheme-fax (scheme tail)
 (print "fax")
)




;questo metodo trasforma una lista di tipo (#\h #t #t p) in una lista di tipo ("http")
(defun list-to-betterList (lista)
  (if (null lista) nil
  (list(coerce lista 'string))))

; controllo identificatori (se il carattere passato come argomento è uno di questi ritorna null 
(defun is-char-id (char)
(if (null char) nil
 (if (or (eq char #\/) 
          (eq char #\?)
          (eq char #\#)
          (eq char #\@)
          (eq char #\:)) nil t)))

;controlla se il il carattere indicato in is-char-id è presente nella lista, ritorna nil altrimenti 
(defun char-presence (lista)
  (cond
   ((null lista) nil)
   ((not(is-char-id (car lista))) 1)
   ((is-char-id (car lista)) (char-presence (cdr lista)))) 
)


 
