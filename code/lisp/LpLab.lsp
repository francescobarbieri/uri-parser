(defun split(l)
  (cond 
        ((eq (car l) 'h) (rest l))
        (t (split(rest l)))
  )
)

 