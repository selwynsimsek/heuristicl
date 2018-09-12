(in-package :heuristicl)

(defun update-position (position velocity)
  (mapcar #'+ position velocity))

(defun update-velocity (best-known-swarm-position &optional (phi-p 0.3) (phi-r 0.3) (omega 0.7))
  #'(lambda (position velocity best-known-position)
      (mapcar #'(lambda (position-i velocity-i best-known-position-i best-known-swarm-position-i)
                  (+ (* omega velocity-i)
                     (* phi-p (alexandria:gaussian-random 0 1)
                        (- best-known-position-i position-i))
                     (* phi-r (alexandria:gaussian-random 0 1)
                        (- best-known-swarm-position-i position-i))))
              position velocity best-known-position best-known-swarm-position)))

(defun update-best-known-position (goal-function)
  #'(lambda (best-known-score best-known-position position)
      (if (> best-known-score (funcall goal-function position)) position best-known-position)))

(defmacro with-pso (goal-function step-form return-form &key (population-size 100)
                                                          (problem-dimension 2)
                                                          (initial-scale-factor 1)
                                                             (number-of-generations 100)
                                                             (particle-initialiser '(lambda () (1- (* 2 (random 1.0))))))
  (let ((symb (gensym "i-s-f")))
    `(let* ((population-size ,population-size)
            (number-of-generations ,number-of-generations)
            (goal-function ,goal-function)
            (particle-initialiser ,particle-initialiser)
            (,symb ,initial-scale-factor)
            (cache (make-hash-table :test 'equal))
            (problem-dimension ,problem-dimension)
            (positions (loop for i from 1 to population-size collecting
                            (loop for j from 1 to problem-dimension
                               collecting (* ,symb (funcall particle-initialiser)))))
            (velocities (loop for i from 1 to population-size collecting
                             (loop for j from 1 to problem-dimension
                                collecting (* ,symb (funcall particle-initialiser)))))
            
            (best-known-positions (mapcar #'identity positions)))
       (flet ((cost-function-for-mapcar (n)
                (lambda (point)
                  (let-over-lambda:aif
                   (gethash point cache) let-over-lambda:it
                   (setf (gethash point cache) (apply (funcall goal-function n)
                                                      point))))))
         (let* ((best-known-scores (pso-mapcar
                                    (cost-function-for-mapcar 0) best-known-positions))
                (best-known-swarm-position (alexandria:extremum best-known-positions #'<
                                                                :key (cost-function-for-mapcar 0)))
                (best-known-swarm-score (funcall (cost-function-for-mapcar 0)
                                                 best-known-swarm-position)))
           (loop for generation-count from 1 to number-of-generations
                 do (progn
                      (setf velocities (pso-mapcar (update-velocity best-known-swarm-position)
                                                          positions velocities best-known-positions)
                            positions (mapcar #'update-position positions velocities)
                            best-known-positions (pso-mapcar
                                                  (update-best-known-position (cost-function-for-mapcar
                                                                               generation-count))
                                                  best-known-scores
                                                  best-known-positions
                                                  positions)
                            best-known-scores (pso-mapcar (cost-function-for-mapcar generation-count)
                                                          best-known-positions)
                            best-known-swarm-position
                            (alexandria:extremum best-known-positions #'< :key
                                                 (cost-function-for-mapcar generation-count))
                            best-known-swarm-score (funcall (cost-function-for-mapcar generation-count)
                                                            best-known-swarm-position)
                            cache (make-hash-table :test 'equal))
                      ,step-form))
           ,return-form)))))

(defun run-pso (goal-function &key (population-size 100) (number-of-generations 100) (verbose nil)
                                (problem-dimension 2)
                                (scale-factor 1))
  (with-pso goal-function (when verbose
                            (format t "~d: ~,8f~%" generation-count best-known-swarm-score))
            (values best-known-swarm-position best-known-swarm-score)
            :population-size population-size :number-of-generations number-of-generations
            :problem-dimension problem-dimension
            :initial-scale-factor scale-factor))

(defun pso-mapcar (function &rest args)
  (apply #'mapcar function args))

(defun observe-pso (goal-function &key (count 10))
  (with-pso goal-function (progn (format t "Generation ~d: ~%~{ ~$~%~} ~%" generation-count (subseq positions 0 count)))
            (values best-known-swarm-position best-known-swarm-score (subseq positions 0 count)) :number-of-generations 1000))

(export '(run-pso with-pso))
