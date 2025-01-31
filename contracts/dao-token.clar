(define-fungible-token dao-token)

(define-constant contract-owner tx-sender)
(define-constant token-name "ImpactDAO Token")
(define-constant token-symbol "IDAO")

(define-public (mint (amount uint) (recipient principal))
  (if (is-eq tx-sender contract-owner)
    (ft-mint? dao-token amount recipient)
    (err u401)
  )
)

(define-public (transfer (amount uint) (sender principal) (recipient principal))
  (ft-transfer? dao-token amount sender recipient)
)

(define-read-only (get-balance (account principal))
  (ok (ft-get-balance dao-token account))
)
