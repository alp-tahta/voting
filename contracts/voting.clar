;; Define who voted for what
(define-map votes {voter: principal} {choice: (string-ascii 20)})

;; Define vote counts per choice
(define-map vote-counts {choice: (string-ascii 20)} {count: uint})

(define-public (vote (choice (string-ascii 20)))
  (if (is-some (map-get? votes {voter: tx-sender}))
      (err u100) ;; Already voted
      (let
        (
          (current (default-to u0 (get count (map-get? vote-counts {choice: choice}))))
        )
        (begin
          (map-set votes {voter: tx-sender} {choice: choice})
          (map-set vote-counts {choice: choice} {count: (+ current u1)})
          (ok choice)
        )
      )
  )
)

(define-read-only (get-vote (who principal))
  (map-get? votes {voter: who})
)

(define-read-only (get-voptions)
  voptions
)

;; Allowed choices (hardcoded)
(define-data-var allowed-choices (list (string-ascii 20)) (list "OptionA" "OptionB" "OptionC" "OptionD"))

;; Define who voted for what
(define-map votes {voter: principal} {choice: (string-ascii 20)})

;; Define vote counts per choice
(define-map vote-counts {choice: (string-ascii 20)} {count: uint})


;; Return the allowed voting options
(define-read-only (get-allowed-choices)
  allowed-choices
)

;; Return allowed choices with their current vote counts
(define-read-only (get-allowed-choices-with-counts)
  (map
    (lambda (option)
      {
        choice: option,
        count: (default-to u0 (get count (map-get? vote-counts {choice: option})))
      }
    )
    allowed-choices
  )
)


(define-public (vote (choice (string-ascii 20)))
  (if (not (is-allowed? choice))
      (err u101) ;; Invalid choice
      (if (is-some (map-get? votes {voter: tx-sender}))
          (err u100) ;; Already voted
          (let (
            (current (default-to u0 (get count (map-get? vote-counts {choice: choice}))))
          )
            (begin
              (map-set votes {voter: tx-sender} {choice: choice})
              (map-set vote-counts {choice: choice} {count: (+ current u1)})
              (ok choice)
            )
          )
      )
  )
)

(define-read-only (get-vote (who principal))
  (map-get? votes {voter: who})
)

(define-read-only (get-count (choice (string-ascii 20)))
  (get count (map-get? vote-counts {choice: choice}))
)
