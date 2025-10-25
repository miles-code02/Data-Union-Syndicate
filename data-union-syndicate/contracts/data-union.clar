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