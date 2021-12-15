(defun uri-parser (str)
  (string-to-list (str)));non funziona per qualche fottuto motivo

(defun string-to-list (str)
  (coerce str 'list))  ;lista non leggibile "#\h #\t #\t #\p" 

(defun verifica-identificatori (str) ;l'idea c'è, male l'esecuzione
  (if (not (eq (car str (or ("#\/") ("#\?") ("#\#") ("#\@") ("#\:"))
    (t verifica-identificatori (cdr srt)))))))
        
(defun split(l)
  (cond 
        ((eq (car l) 'h) (rest l))
        (t (split(rest l)))
  )
)

 