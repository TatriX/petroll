;;;; petroll.lisp

(in-package :petroll)

(defparameter *port* 1488)

(defparameter *scheme* "https")
(defparameter *host* "2ch.hk")
(defparameter *board* "b")
(defparameter *thread* "132410266")

(defclass faction ()
  ((name :initarg :name)
   (post-regexp :initarg :post-regexp :reader faction-regexp)
   (dmg :initform 0)))

(defparameter *empire*
  (make-instance 'faction
                 :name "Empire"
                 :post-regexp "(?i)империя"))

(defparameter *confederation*
  (make-instance 'faction
                 :name "Confederation"
                 :post-regexp "(?i)конфедерация"))

(defparameter *max-hp* 100)

(defun get-post (thread)
  (let ((uri (quri:make-uri :scheme *scheme*
                            :host *host*
                            :path (format nil "/~a/res/~a.json" *board* thread))))
    (dexador:get uri)))

(defun parse-post (post-json)
  (jonathan:parse post-json))

(defun get-posts (post)
  (getf (car (getf post :|threads|)) :|posts|))

;;  Пусть обычные посты не наносят урона. Чтобы нанести урон нужен
;;  минимум дабл. Обычные посты увеличивают счётчик урона, который
;;  очередной дабл нанесёт. Если другая сторона выбивает дабл, то у
;;  твоей стороны счётчик урона обнуляется.

(defun update(&optional (thread *thread*))
  (loop
     with empire-posts = '()
     with empire-hp = *max-hp*
     with confederation-posts = '()
     with confederation-hp = *max-hp*
     for post in (get-posts (parse-post (get-post thread)))
     for comment = (getf post :|comment|)
     for num = (getf post :|num|)
     do
       (cond
         ((cl-ppcre:scan (faction-regexp *empire*) comment)
          (push num empire-posts)
          (decf confederation-hp 10))
         ((cl-ppcre:scan (faction-regexp *confederation*) comment)
          (push num confederation-posts)
          (decf empire-hp 10)))
     finally (return
               `(:|thread| ,*thread*
                  :|empire| (:|posts| ,empire-posts :|hp| ,empire-hp)
                  :|confederation| (:|posts| ,confederation-posts :|hp| ,confederation-hp)))))

(defun handler ()
  `(200
    (:content-type "text/plain"
     :access-control-allow-origin "http://rogalia.ru")
    (,(jonathan.encode:to-json (update)))))

(defvar *handler* nil)

(defun start()
  (setf *handler* (clack:clackup (lambda (env)
                                   (declare (ignore env))
                                   (handler))
                                 :port *port*)))
