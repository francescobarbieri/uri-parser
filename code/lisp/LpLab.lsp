(defun split(l)
  (values(cond 
      ((eq (car l) 'h) (rest l))
      (t (add (car l) ()) (split(rest l)))
  ))
)



(defun add (element list)
  (cons element list))


(defun sottostringa(stringa p)
  (coerce(subseq stringa 0 (search p stringa)) 'list)
)