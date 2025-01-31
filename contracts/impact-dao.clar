(define-map proposals
  { id: uint }
  {
    title: (string-ascii 50),
    description: (string-utf8 500),
    amount: uint,
    recipient: principal,
    votes-for: uint,
    votes-against: uint,
    status: (string-ascii 10),
    proposer: principal
  }
)

(define-map impact-reports
  { project-id: uint }
  {
    metrics: (list 10 uint),
    timestamp: uint,
    reporter: principal
  }
)

(define-data-var proposal-count uint u0)
(define-data-var min-votes uint u100)

(define-public (submit-proposal 
  (title (string-ascii 50))
  (description (string-utf8 500))
  (amount uint)
  (recipient principal)
)
  (let ((proposal-id (+ (var-get proposal-count) u1)))
    (map-set proposals
      { id: proposal-id }
      {
        title: title,
        description: description,
        amount: amount,
        recipient: recipient,
        votes-for: u0,
        votes-against: u0,
        status: "active",
        proposer: tx-sender
      }
    )
    (ok proposal-id)
  )
)

(define-public (vote (proposal-id uint) (support bool))
  (let ((voter-balance (unwrap! (contract-call? .dao-token get-balance tx-sender) (err u401))))
    (if (> voter-balance u0)
      (let ((proposal (unwrap! (map-get? proposals {id: proposal-id}) (err u404))))
        (if support
          (map-set proposals 
            {id: proposal-id}
            (merge proposal {votes-for: (+ (get votes-for proposal) u1)})
          )
          (map-set proposals
            {id: proposal-id}  
            (merge proposal {votes-against: (+ (get votes-against proposal) u1)})
          )
        )
        (ok true)
      )
      (err u401)
    )
  )
)

(define-public (report-impact (project-id uint) (metrics (list 10 uint)))
  (map-set impact-reports
    { project-id: project-id }
    {
      metrics: metrics,
      timestamp: block-height,
      reporter: tx-sender
    }
  )
  (ok true)
)

(define-read-only (get-proposal (id uint))
  (map-get? proposals {id: id})
)

(define-read-only (get-impact-metrics (project-id uint))
  (map-get? impact-reports {project-id: project-id})
)
