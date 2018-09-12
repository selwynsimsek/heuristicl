#|
  This file is a part of heuristicl project.
  Copyright (c) 2018 Selwyn Simsek (sgs16@ic.ac.uk)
|#

(defsystem "heuristicl-test"
  :defsystem-depends-on ("prove-asdf")
  :author "Selwyn Simsek"
  :license "MIT License"
  :depends-on ("heuristicl"
               "prove")
  :components ((:module "tests"
                :components
                ((:test-file "heuristicl"))))
  :description "Test system for heuristicl"

  :perform (test-op (op c) (symbol-call :prove-asdf :run-test-system c)))
