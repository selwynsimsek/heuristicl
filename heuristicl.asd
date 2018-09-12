#|
  This file is a part of heuristicl project.
  Copyright (c) 2018 Selwyn Simsek (sgs16@ic.ac.uk)
|#

#|
  Heuristic optimisers for Common Lisp

  Author: Selwyn Simsek (sgs16@ic.ac.uk)
|#

(defsystem "heuristicl"
  :version "0.1.0"
  :author "Selwyn Simsek"
  :license "MIT License"
  :depends-on (:alexandria
               :lparallel
               :let-over-lambda)
  :components ((:module "src"
                :components
                ((:file "heuristicl")
                 (:file "pso"))))
  :description "Heuristic optimisers for Common Lisp"
  :long-description
  #.(read-file-string
     (subpathname *load-pathname* "README.markdown"))
  :in-order-to ((test-op (test-op "heuristicl-test"))))
