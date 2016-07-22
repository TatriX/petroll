;;;; petroll.asd

(asdf:defsystem :petroll
  :description "Describe petroll here"
  :author "TatriX <tatrics@gmail.com>"
  :license "Specify license here"
  :serial t
  :depends-on (:quri :dexador :jonathan :alexandria :clack :cl-ppcre)
  :components ((:file "package")
               (:file "petroll")))
