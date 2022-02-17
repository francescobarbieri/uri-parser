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
       (s (multiple-value-bind (val1 val2) (split lista (findPosition #\: lista)) val2)))
  (print l)
   (if (= 1 1) (which-scheme l s))
))


;metodo che controlla il tipo di scheme
(defun which-scheme (scheme r)
 (cond
 ((equal scheme '(#\m #\a #\i #\l #\t #\o)) (scheme-mailto scheme r))
 ((equal scheme '(#\n #\e #\w #\s)) (scheme-news shcme r))
 ((equal scheme '(#\f #\a #\x)) (scheme-fax scheme r))
 ((or (equal scheme '(#\h #\t #\t #\p)) (equal scheme '(#\h #\t #\t #\p #\s)) (equal scheme '(#\z #\o #\s))) (scheme-normal scheme r))))


(defun scheme-normal (scheme tail)
  (let ((final (list '() )))
    (if (and (equal (car tail) #\/) (equal (car (cdr tail)) #\/))
        (authPresent tail (append (list-to-betterList scheme) final))
        (authNotPresent tail (append (list-to-betterList scheme) final)))))


(defun authPresent (lista final)
  (print "authPresent")
  (userinfo-check lista final)
)

(defun authNotPresent (lista final)
  (print "authNotPresent")
)

(defun scheme-mailto (scheme tail)
  (print "mailto")
)


(defun scheme-news (scheme tail)
  (print "news")

)


(defun scheme-fax (scheme tail)
  (print "fax")
)


(defun userinfo-check (lista final)
  
)


;questo metodo trasforma una lista di tipo (#\h #t #t p) in una lista di tipo ("http")
(defun list-to-betterList (lista)
  (if (null lista) nil
  (list(coerce lista 'string))))
 


