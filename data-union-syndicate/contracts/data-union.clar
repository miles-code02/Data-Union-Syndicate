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

;; Read-only functions
(define-read-only (get-member-info (member principal))
  (map-get? members member)
)

(define-read-only (get-contribution (contribution-id uint))
  (map-get? contributions contribution-id)
)

(define-read-only (get-total-members)
  (ok (var-get total-members))
)

(define-read-only (get-revenue-pool)
  (ok (var-get revenue-pool))
)

(define-read-only (get-proposal (proposal-id uint))
  (map-get? proposals proposal-id)
)

(define-read-only (get-vote (proposal-id uint) (voter principal))
  (map-get? votes {proposal-id: proposal-id, voter: voter})
)

(define-read-only (get-buyer-license (buyer principal))
  (map-get? buyer-licenses buyer)
)

(define-read-only (get-contribution-rating (contribution-id uint) (rater principal))
  (map-get? contribution-ratings {contribution-id: contribution-id, rater: rater})
)

(define-read-only (get-member-tier (member principal))
  (match (map-get? members member)
    member-data (ok (get tier member-data))
    (ok u0)
  )
)

(define-read-only (get-delegation (delegator principal))
  (map-get? member-delegations {delegator: delegator})
)

(define-read-only (is-member (user principal))
  (is-some (map-get? members user))
)

(define-read-only (get-member-reputation (member principal))
  (match (map-get? members member)
    member-data (ok (get reputation-score member-data))
    (ok u0)
  )
)

(define-read-only (calculate-voting-power (member principal))
  (match (map-get? members member)
    member-data (ok (+ (get contribution-count member-data) 
                       (* (get tier member-data) u10)
                       (/ (get reputation-score member-data) u10)))
    (ok u0)
  )
)

;; Public functions
(define-public (join-union)
  (let
    (
      (caller tx-sender)
    )
    (asserts! (is-none (map-get? members caller)) err-already-member)
    (map-set members caller
      {
        contribution-count: u0,
        total-earned: u0,
        joined-at: stacks-block-height,
        tier: tier-bronze,
        reputation-score: u0,
        staked-amount: u0,
        suspended: false,
        last-claim: u0
      }
    )
    (var-set total-members (+ (var-get total-members) u1))
    (ok true)
  )
)

;; #[allow(unchecked_data)]
(define-public (submit-contribution (data-hash (buff 32)) (data-type uint))
  (let
    (
      (caller tx-sender)
      (member-data (unwrap! (map-get? members caller) err-not-member))
      (contribution-id (var-get total-contributions))
    )
    (asserts! (not (get suspended member-data)) err-member-suspended)
    (asserts! (and (>= data-type type-text) (<= data-type type-structured)) err-invalid-amount)
    (map-set contributions contribution-id
      {
        contributor: caller,
        data-hash: data-hash,
        timestamp: stacks-block-height,
        verified: false,
        data-type: data-type,
        quality-score: u0,
        rewards-paid: u0
      }
    )
    (map-set members caller
      (merge member-data { 
        contribution-count: (+ (get contribution-count member-data) u1),
        reputation-score: (+ (get reputation-score member-data) u1)
      })
    )
    (var-set total-contributions (+ contribution-id u1))
    (ok contribution-id)
  )
)

(define-public (verify-contribution (contribution-id uint) (quality-score uint))
  (let
    (
      (contribution-data (unwrap! (map-get? contributions contribution-id) err-not-found))
      (contributor (get contributor contribution-data))
      (member-data (unwrap! (map-get? members contributor) err-not-member))
    )
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (not (get verified contribution-data)) err-already-verified)
    (asserts! (<= quality-score u100) err-invalid-amount)
    (map-set contributions contribution-id
      (merge contribution-data { 
        verified: true,
        quality-score: quality-score
      })
    )
    ;; Update member reputation based on quality score
    (map-set members contributor
      (merge member-data {
        reputation-score: (+ (get reputation-score member-data) (/ quality-score u10))
      })
    )
    (ok true)
  )
)

(define-public (add-revenue (amount uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (> amount u0) err-invalid-amount)
    (var-set revenue-pool (+ (var-get revenue-pool) amount))
    (ok true)
  )
)

(define-public (claim-earnings (amount uint))
  (let
    (
      (caller tx-sender)
      (member-data (unwrap! (map-get? members caller) err-not-member))
      (pool-balance (var-get revenue-pool))
    )
    (asserts! (> amount u0) err-invalid-amount)
    (asserts! (>= pool-balance amount) err-insufficient-balance)
    (asserts! (> (get contribution-count member-data) u0) err-invalid-amount)
    (asserts! (not (get suspended member-data)) err-member-suspended)
    (var-set revenue-pool (- pool-balance amount))
    (map-set members caller
      (merge member-data { 
        total-earned: (+ (get total-earned member-data) amount),
        last-claim: stacks-block-height
      })
    )
    (ok true)
  )
)

(define-public (stake-tokens (amount uint))
  (let
    (
      (caller tx-sender)
      (member-data (unwrap! (map-get? members caller) err-not-member))
    )
    (asserts! (>= amount (var-get minimum-stake)) err-invalid-amount)
    (try! (stx-transfer? amount caller (as-contract tx-sender)))
    (map-set members caller
      (merge member-data {
        staked-amount: (+ (get staked-amount member-data) amount),
        reputation-score: (+ (get reputation-score member-data) u5)
      })
    )
    (ok true)
  )
)

(define-public (unstake-tokens (amount uint))
  (let
    (
      (caller tx-sender)
      (member-data (unwrap! (map-get? members caller) err-not-member))
    )
    (asserts! (<= amount (get staked-amount member-data)) err-insufficient-balance)
    (try! (as-contract (stx-transfer? amount tx-sender caller)))
    (map-set members caller
      (merge member-data {
        staked-amount: (- (get staked-amount member-data) amount)
      })
    )
    (ok true)
  )
)

(define-public (upgrade-tier (new-tier uint))
  (let
    (
      (caller tx-sender)
      (member-data (unwrap! (map-get? members caller) err-not-member))
      (required-contributions (* new-tier u10))
    )
    (asserts! (and (>= new-tier tier-bronze) (<= new-tier tier-platinum)) err-invalid-tier)
    (asserts! (>= (get contribution-count member-data) required-contributions) err-invalid-amount)
    (asserts! (> new-tier (get tier member-data)) err-invalid-tier)
    (map-set members caller
      (merge member-data { tier: new-tier })
    )
    (ok true)
  )
)