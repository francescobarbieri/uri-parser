
(defun add (element list)
  (cons element list))


(defun split(list count)
      (values (subseq list 0 count) (nthcdr count list)))

(defun invertiLista(l)
    (cond
        ((null l) '())
        (t (append (invertiLista (cdr l)) (list (car l))))))

(defun presenzaFragment(l)
  (cond((null l) nil)
       ((contieneItem l #\#) 1)
       (t 0)))

(defun presenzaQuery(l)
  (cond((null l) nil)
       ((contieneItem l #\?) 1)
       (t 0)))

(defun presenzaAuthority(l)
  (cond((null l) nil)
       ((and (eq (nth 1 l) #\/) (eq (nth 2 l) #\/)) 1)
       (t 0)))


(defun presenzaUserinfo(l bool)
  (cond((null l) '())
       ((and (member #\@ l) (= bool 1))1)
       (t 0)
  )
)

(defun splitFragment(l bool)
  (cond((= bool 1) (multiple-value-bind (val1 val2) (split l (position #\# l)) val2))
     (t '())
  )
)
;split authority da implementare
(defun splitAuthority(l bool)
  (cond((and(= bool 1)(contieneItem l #\/)) (print "caso1"))
       ((and(= bool 1)(not(contieneItem l #\/))) (print "caso2")))
       
)








(defun uri-parser(stringa)
    (setq uriList (coerce stringa 'list))
    (position #\: (coerce stringa 'list))
    (setq scheme (multiple-value-bind (val1 val2) (split uriList (position #\: uriList)) val1))
    (setq resto (multiple-value-bind (val1 val2) (split uriList (position #\: uriList)) val2))  ;da sistemare(elmina piu ricorrenze 
    ;(identificatori resto "?#/")
    ;(setq fragment (splitFragment resto (presenzaFragment resto)))
    (setq frag (multiple-value-bind (val1 val2) (split resto (position #\# resto)) val2))
    (setq resto (multiple-value-bind (val1 val2) (split resto (position #\# resto)) val1))
 

)

;controlla se item è presente nella lista l
(defun contieneItem(l item)
  (cond((null l) nil)
       ((eq (car l) item) t)
       (t (contieneItem (rest l)item))))

;verifica se nella lista è presente un carattere speciale, se si ritorna 0 altrimenti 1
(defun identificatori(l id)
   (cond ((null l) 1)
         ((contieneItem (coerce id 'list) (car l)) 0)
         (t (identificatori (rest l) (coerce id 'list)))))


(defun prova(x)
(print x)
)