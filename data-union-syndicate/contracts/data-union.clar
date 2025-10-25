;; DataUnion Syndicate
;; Enables users to pool and monetize data for AI training

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-member (err u101))
(define-constant err-already-member (err u102))
(define-constant err-insufficient-balance (err u103))
(define-constant err-invalid-amount (err u104))
(define-constant err-not-found (err u105))
(define-constant err-unauthorized (err u106))
(define-constant err-already-verified (err u107))
(define-constant err-proposal-expired (err u108))
(define-constant err-already-voted (err u109))
(define-constant err-invalid-tier (err u110))
(define-constant err-member-suspended (err u111))

;; Membership tiers
(define-constant tier-bronze u1)
(define-constant tier-silver u2)
(define-constant tier-gold u3)
(define-constant tier-platinum u4)

;; Contribution types
(define-constant type-text u1)
(define-constant type-image u2)
(define-constant type-audio u3)
(define-constant type-video u4)
(define-constant type-structured u5)

;; Data Variables
(define-data-var total-members uint u0)
(define-data-var total-contributions uint u0)
(define-data-var revenue-pool uint u0)
(define-data-var proposal-nonce uint u0)
(define-data-var minimum-stake uint u1000000) ;; 1 STX in microstacks
(define-data-var distribution-percentage uint u80) ;; 80% to contributors
(define-data-var governance-threshold uint u51) ;; 51% for proposals

;; Data Maps
(define-map members principal 
  {
    contribution-count: uint,
    total-earned: uint,
    joined-at: uint,
    tier: uint,
    reputation-score: uint,
    staked-amount: uint,
    suspended: bool,
    last-claim: uint
  }
)

(define-map contributions uint
  {
    contributor: principal,
    data-hash: (buff 32),
    timestamp: uint,
    verified: bool,
    data-type: uint,
    quality-score: uint,
    rewards-paid: uint
  }
)

(define-map proposals uint
  {
    proposer: principal,
    title: (string-ascii 100),
    description: (string-ascii 500),
    votes-for: uint,
    votes-against: uint,
    end-block: uint,
    executed: bool,
    proposal-type: uint
  }
)

(define-map votes
  {proposal-id: uint, voter: principal}
  {
    vote: bool,
    voting-power: uint
  }
)

(define-map buyer-licenses principal
  {
    active: bool,
    data-access-count: uint,
    total-paid: uint,
    license-expires: uint
  }
)

(define-map contribution-ratings
  {contribution-id: uint, rater: principal}
  {
    rating: uint,
    comment: (string-ascii 200)
  }
)

(define-map member-delegations
  {delegator: principal}
  {
    delegate: principal,
    active: bool
  }
)