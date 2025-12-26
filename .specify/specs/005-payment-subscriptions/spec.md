# 005 - Payment & Subscriptions Specification

## Overview

The payment system handles all monetary transactions on RenoRadar, including one-time listing fees and recurring subscription payments. PayPal is the primary payment processor.

## User Stories

### Seller Payments

### US-050: Pay Listing Fee
**As a** seller
**I want to** pay the listing fee
**So that I** my property goes live on RenoRadar

#### Acceptance Criteria
- [ ] Listing fee: £25 one-time payment
- [ ] Payment required after completing listing form
- [ ] PayPal checkout integration
- [ ] Support for PayPal account and card payments
- [ ] Payment confirmation page
- [ ] Receipt email sent after payment
- [ ] Property automatically published after successful payment
- [ ] Clear error handling for failed payments
- [ ] Retry option for failed payments

### US-051: Upgrade to Premium Listing
**As a** seller
**I want to** upgrade my listing to premium
**So that I** get more visibility for my property

#### Acceptance Criteria
- [ ] Premium listing: £20/month subscription
- [ ] Clear benefits explanation before purchase
- [ ] PayPal subscription creation
- [ ] Immediate premium badge activation
- [ ] Monthly auto-renewal via PayPal
- [ ] Cancel anytime option
- [ ] Premium status expires at end of paid period
- [ ] Downgrade email notification before expiry
- [ ] Re-upgrade option after cancellation

### Buyer Payments

### US-052: Subscribe to Premium Membership
**As a** buyer
**I want to** subscribe to premium membership
**So that I** get early access and alerts for new properties

#### Acceptance Criteria
- [ ] Two pricing options:
  - Monthly: £25/month
  - Annual: £199/year (save £101)
- [ ] Clear benefits comparison (Free vs Premium)
- [ ] PayPal subscription checkout
- [ ] Immediate premium access after payment
- [ ] Auto-renewal with PayPal
- [ ] Cancel anytime, access until period ends
- [ ] Renewal reminder email (7 days before)
- [ ] Switch between monthly and annual

### US-053: Manage Subscription
**As a** subscribed user
**I want to** manage my subscription
**So that I** can update payment or cancel

#### Acceptance Criteria
- [ ] View current subscription status
- [ ] View next billing date
- [ ] View payment history
- [ ] Cancel subscription (takes effect at period end)
- [ ] Reactivate cancelled subscription before expiry
- [ ] Download invoices/receipts

### US-054: Handle Payment Failures
**As a** subscribed user
**I want to** be notified of payment failures
**So that I** can update my payment method

#### Acceptance Criteria
- [ ] Email notification on failed renewal
- [ ] 3-day grace period before access revoked
- [ ] Clear instructions to update payment
- [ ] Link to PayPal to update payment method
- [ ] Access restored immediately on successful payment

## Non-Functional Requirements

### Security
- All payment data handled by PayPal (PCI DSS compliant)
- Webhook verification using PayPal signatures
- HTTPS for all payment pages
- No card details stored locally
- Audit log for all transactions

### Reliability
- Idempotent payment processing
- Webhook retry handling
- Failed payment recovery flows
- Graceful degradation if PayPal unavailable

### User Experience
- Clear pricing display
- No surprise charges
- Easy cancellation process
- Immediate access after payment

## Pricing Structure

### Seller Products

| Product | Price | Type | Description |
|---------|-------|------|-------------|
| Standard Listing | £25 | One-time | Publish property for 6 months |
| Premium Listing | £20/month | Subscription | Enhanced visibility |
| Listing Renewal | £15 | One-time | Extend by 6 months |

### Buyer Products

| Product | Price | Type | Description |
|---------|-------|------|-------------|
| Premium Monthly | £25/month | Subscription | Monthly premium access |
| Premium Annual | £199/year | Subscription | Annual premium (save £101) |

## PayPal Integration Points

### Payment Methods
1. **PayPal Checkout** - One-time payments (listing fees)
2. **PayPal Subscriptions** - Recurring payments (premium memberships)

### Webhook Events to Handle
- `PAYMENT.SALE.COMPLETED` - Successful payment
- `PAYMENT.SALE.DENIED` - Failed payment
- `BILLING.SUBSCRIPTION.ACTIVATED` - New subscription
- `BILLING.SUBSCRIPTION.CANCELLED` - Subscription cancelled
- `BILLING.SUBSCRIPTION.SUSPENDED` - Payment failed, subscription paused
- `BILLING.SUBSCRIPTION.PAYMENT.FAILED` - Renewal failed
- `PAYMENT.SALE.REFUNDED` - Refund processed

## UI Components Required

1. **Pricing Table Component**
   - Feature comparison
   - Price display
   - CTA buttons
   - Popular/recommended badge

2. **Payment Summary Component**
   - Item description
   - Price breakdown
   - Total amount
   - Payment button

3. **PayPal Button Component**
   - PayPal SDK integration
   - Loading states
   - Error handling

4. **Subscription Status Card**
   - Current plan
   - Next billing date
   - Status indicator
   - Manage button

5. **Invoice List Component**
   - Date, amount, status
   - Download button
   - Pagination

6. **Cancellation Confirmation Modal**
   - Clear messaging
   - Confirm/Cancel buttons
   - End date display

## Email Notifications

| Event | Recipient | Email |
|-------|-----------|-------|
| Listing payment success | Seller | Receipt + listing live |
| Premium upgrade success | Seller | Receipt + benefits |
| Subscription created | Buyer | Welcome + benefits |
| Payment failed | User | Update payment prompt |
| Subscription cancelled | User | Confirmation + end date |
| Renewal reminder | User | 7 days before renewal |
| Subscription expired | User | Access revoked notice |
| Refund processed | User | Refund confirmation |
