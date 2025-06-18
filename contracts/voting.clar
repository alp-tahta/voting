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
(define-constant voptions (list "OptionA" "OptionB" "OptionC" "OptionD"))

(define-read-only (get-voptions (choice (string-ascii 20)))
  (get count (map-get? vote-counts {choice: choice}))
)

;; Define who voted for what
(define-map votes {voter: principal} {choice: (string-ascii 20)})

;; Define vote counts per choice
(define-map vote-counts {choice: (string-ascii 20)} {count: uint})

;; Helper to check if a choice is in the allowed list
(define-private (is-allowed? (choice (string-ascii 20)))
  (is-some (fold
    allowed-choices
    (some false)
    (lambda (item acc)
      (if (or (is-eq item choice) (unwrap-panic acc)) (some true) acc)
    )
  ))
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
