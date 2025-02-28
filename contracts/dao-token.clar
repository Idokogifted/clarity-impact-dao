;; Enhanced DAO Token Implementation
(define-fungible-token dao-token)

(define-constant contract-owner tx-sender)
(define-constant token-name "ImpactDAO Token")
(define-constant token-symbol "IDAO")
(define-constant token-decimals u6)
(define-constant token-uri "https://impact-dao.org/token-metadata")

(define-public (mint (amount uint) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) (err u401))
    (ft-mint? dao-token amount recipient)
  )
)

(define-public (burn (amount uint) (owner principal))
  (begin
    (asserts! (or (is-eq tx-sender owner) (is-eq tx-sender contract-owner)) (err u401))
    (ft-burn? dao-token amount owner)
  )
)

(define-public (transfer (amount uint) (sender principal) (recipient principal))
  (ft-transfer? dao-token amount sender recipient)
)

(define-read-only (get-balance (account principal))
  (ok (ft-get-balance dao-token account))
)

(define-read-only (get-token-metadata)
  (ok {
    name: token-name,
    symbol: token-symbol,
    decimals: token-decimals,
    uri: token-uri
  })
)
