;; Enhanced Impact DAO Implementation
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
    proposer: principal,
    deadline: uint,
    executed: bool
  }
)

(define-map votes
  { proposal-id: uint, voter: principal }
  { weight: uint, support: bool }
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
(define-constant proposal-duration u144) ;; ~1 day in blocks

(define-public (submit-proposal 
  (title (string-ascii 50))
  (description (string-utf8 500))
  (amount uint)
  (recipient principal)
)
  (begin
    (asserts! (> (len title) u0) (err u400))
    (asserts! (> (len description) u0) (err u400))
    (asserts! (> amount u0) (err u400))
    (let (
      (proposal-id (+ (var-get proposal-count) u1))
      (deadline (+ block-height proposal-duration))
    )
      (var-set proposal-count proposal-id)
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
          proposer: tx-sender,
          deadline: deadline,
          executed: false
        }
      )
      (ok proposal-id)
    )
  )
)

(define-public (vote (proposal-id uint) (support bool))
  (let (
    (voter tx-sender)
    (voter-balance (unwrap! (contract-call? .dao-token get-balance voter) (err u401)))
    (proposal (unwrap! (map-get? proposals {id: proposal-id}) (err u404)))
  )
    (asserts! (> voter-balance u0) (err u401))
    (asserts! (is-eq (get status proposal) "active") (err u403))
    (asserts! (< block-height (get deadline proposal)) (err u405))
    (asserts! (is-none (map-get? votes {proposal-id: proposal-id, voter: voter})) (err u406))
    
    (map-set votes
      {proposal-id: proposal-id, voter: voter}
      {weight: voter-balance, support: support}
    )
    
    (if support
      (map-set proposals 
        {id: proposal-id}
        (merge proposal {votes-for: (+ (get votes-for proposal) voter-balance)})
      )
      (map-set proposals
        {id: proposal-id}  
        (merge proposal {votes-against: (+ (get votes-against proposal) voter-balance)})
      )
    )
    (ok true)
  )
)

(define-public (execute-proposal (proposal-id uint))
  (let ((proposal (unwrap! (map-get? proposals {id: proposal-id}) (err u404))))
    (asserts! (>= block-height (get deadline proposal)) (err u407))
    (asserts! (not (get executed proposal)) (err u408))
    (asserts! (> (get votes-for proposal) (get votes-against proposal)) (err u409))
    
    (map-set proposals
      {id: proposal-id}
      (merge proposal {
        status: "executed",
        executed: true
      })
    )
    (ok true)
  )
)

;; ... [rest of the existing functions] ...
