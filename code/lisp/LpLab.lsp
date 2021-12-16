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

 
(defun uri-parser(stringa)
    (setq pos 0) 
    (setq posizione 0)
    (setq uriList (coerce stringa 'list))
    (setq posizione (findPos uriList #\:))
    (split uriList posizione)
   
   
)


