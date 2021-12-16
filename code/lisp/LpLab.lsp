(defun split(l)
  (values(cond 
      ((eq (car l) 'h) (rest l))
      (t (add (car l) ()) (split(rest l)))
  ))
)



(defun add (element list)
  (cons element list))


(defun findPos(lista c)
  (defvar pos 0)
  (loop for i in lista
      if(eq i c)
        do(return pos)
      else
        do(setq pos (+ 1 pos))
  )
)

(defun split (list count)
           (values (subseq list 0 count) (nthcdr count list)))

 (defun invertiLista(l)
    (cond
        ((null l) '())
        (T (append (invertiLista (cdr l)) (list (car l))))))

(defun presenzaAuthority(lista)
  (cond((null lista) '())
       ((and (eq (nth 1 lista) #\/) (eq (nth 2 lista) #\/)) 1)
       (t 0)
  )
)

(defun presenzaUserinfo(lista)
  (cond((null lista) '())
       ((member #\@ lista)1)
       (t 0)
  )
)



(defun uri-parser(stringa)
    (setq pos 0) 
    (setq posizione 0)
    (setq uriList (coerce stringa 'list))
    (setq posizione (findPos uriList #\:))
    (setq scheme (split uriList posizione))
    (setq resto (set-difference uriList scheme))
    (setq resto(invertiLista resto))
    (setq presenzaAuthority (presenzaAuthority resto))
    (presenzaUserinfo resto)
    (setq pos@ (findPos resto #\@))
    (print resto)
    (nth 13 uriList)
    
)





