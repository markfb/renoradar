# 005 - Payment & Subscriptions Tasks

## Phase 1: Database Setup

### 1.1 Migrations
- [ ] Create `database/migrations/018_create_payments_table.php`
- [ ] Create `database/migrations/019_create_subscriptions_table.php`
- [ ] Create `database/migrations/020_create_invoices_table.php`
- [ ] Create `database/migrations/021_create_webhook_logs_table.php`
- [ ] Run migrations

## Phase 2: Configuration

### 2.1 PayPal Setup
- [ ] Create `config/paypal.php` configuration file
- [ ] Add PayPal environment variables to `.env.example`
- [ ] Document PayPal dashboard setup (plans, webhooks)

### 2.2 PayPal Plans (Manual Setup in PayPal Dashboard)
- [ ] Create Buyer Monthly subscription plan (£25/month)
- [ ] Create Buyer Annual subscription plan (£199/year)
- [ ] Create Listing Premium subscription plan (£20/month)
- [ ] Configure webhook endpoint
- [ ] Note plan IDs in configuration

## Phase 3: Models & Repositories

### 3.1 Models [P]
- [ ] Implement `src/Models/Payment.php`
  - Column mappings
  - Status constants
  - Relationships (user, invoice)
  - isCompleted(), isFailed() helpers

- [ ] Implement `src/Models/Subscription.php`
  - Column mappings
  - Status constants
  - Relationships (user, invoices)
  - isActive(), isCancelled() helpers
  - daysRemaining() accessor

- [ ] Implement `src/Models/Invoice.php`
  - Column mappings
  - Relationships
  - getFormattedTotal() accessor
  - Download URL accessor

- [ ] Implement `src/Models/WebhookLog.php`
  - Column mappings
  - Status management

### 3.2 Repositories [P]
- [ ] Implement `src/Repositories/PaymentRepository.php`
  - findByPayPalOrderId()
  - findByUser()
  - getPending()

- [ ] Implement `src/Repositories/SubscriptionRepository.php`
  - findByPayPalSubscriptionId()
  - findActiveByUser()
  - getExpiring()

## Phase 4: PayPal Service

### 4.1 Core Service
- [ ] Implement `src/Services/PayPalService.php`
  - [ ] Authentication (OAuth token management)
  - [ ] createOrder() - One-time payments
  - [ ] captureOrder() - Capture payment
  - [ ] getOrderDetails() - Fetch order status
  - [ ] createSubscription() - Start subscription
  - [ ] getSubscription() - Fetch subscription status
  - [ ] cancelSubscription() - Cancel subscription
  - [ ] verifyWebhook() - Signature verification
  - [ ] Error handling and logging

## Phase 5: Payment Service

### 5.1 Payment Processing
- [ ] Implement `src/Services/PaymentService.php`
  - [ ] createListingPayment() - Create listing fee payment
  - [ ] createPremiumUpgrade() - Premium listing subscription
  - [ ] processPaymentSuccess() - Handle successful payment
  - [ ] processPaymentFailure() - Handle failed payment
  - [ ] refundPayment() - Process refund (admin)
  - [ ] updatePropertyStatus() - Publish property after payment

### 5.2 Subscription Service
- [ ] Implement `src/Services/SubscriptionService.php`
  - [ ] createBuyerSubscription() - Start buyer premium
  - [ ] processSubscriptionActivated() - Handle activation
  - [ ] processSubscriptionCancelled() - Handle cancellation
  - [ ] processSubscriptionSuspended() - Handle suspension
  - [ ] processSubscriptionPayment() - Handle renewal
  - [ ] updateUserPremiumStatus() - Update user tier
  - [ ] getSubscriptionStatus() - Fetch current status

## Phase 6: Invoice Service

### 6.1 Invoice Generation
- [ ] Implement `src/Services/InvoiceService.php`
  - [ ] generateInvoice() - Create invoice record
  - [ ] generateInvoiceNumber() - Sequential numbering
  - [ ] calculateVat() - VAT calculation
  - [ ] generatePdf() - PDF generation
  - [ ] getDownloadUrl() - Secure download link

## Phase 7: Controllers

### 7.1 Payment Controller
- [ ] Implement `src/Controllers/PaymentController.php`
  - [ ] checkoutListing() - Create listing payment
  - [ ] success() - Handle return from PayPal
  - [ ] cancel() - Handle cancellation
  - [ ] capturePayment() - AJAX capture endpoint

### 7.2 Subscription Controller
- [ ] Implement `src/Controllers/SubscriptionController.php`
  - [ ] pricing() - Display pricing page
  - [ ] checkout() - Create subscription
  - [ ] manage() - Subscription management page
  - [ ] cancel() - Cancel subscription
  - [ ] invoices() - List invoices
  - [ ] downloadInvoice() - Download PDF

### 7.3 Webhook Controller
- [ ] Implement `src/Controllers/WebhookController.php`
  - [ ] paypal() - Handle PayPal webhooks
  - [ ] Verify signatures
  - [ ] Idempotent processing
  - [ ] Event routing
  - [ ] Error handling

## Phase 8: Templates

### 8.1 Payment Pages [P]
- [ ] Create `templates/payments/checkout.php`
  - Payment summary
  - PayPal button container
  - Loading states

- [ ] Create `templates/payments/success.php`
  - Success message
  - Next steps
  - Property link (for listings)

- [ ] Create `templates/payments/failed.php`
  - Error message
  - Retry option
  - Support contact

### 8.2 Subscription Pages [P]
- [ ] Create `templates/subscriptions/pricing.php`
  - Pricing table
  - Feature comparison
  - Plan selection
  - PayPal button

- [ ] Create `templates/subscriptions/manage.php`
  - Current plan display
  - Next billing date
  - Cancel button
  - Upgrade/downgrade options

- [ ] Create `templates/subscriptions/invoices.php`
  - Invoice list
  - Download buttons
  - Pagination

- [ ] Create `templates/subscriptions/cancelled.php`
  - Cancellation confirmation
  - Access end date
  - Resubscribe option

## Phase 9: JavaScript Components

### 9.1 PayPal Integration
- [ ] Create `public/assets/js/components/paypalCheckout.js`
  - PayPal SDK initialization
  - Order creation
  - Payment capture
  - Error handling
  - Loading states

- [ ] Create `public/assets/js/components/paypalSubscription.js`
  - Subscription button
  - Plan selection handling
  - Success/error callbacks

## Phase 10: Email Templates

### 10.1 Payment Emails [P]
- [ ] Create `templates/emails/payment-receipt.php`
- [ ] Create `templates/emails/subscription-welcome.php`
- [ ] Create `templates/emails/payment-failed.php`
- [ ] Create `templates/emails/subscription-cancelled.php`
- [ ] Create `templates/emails/renewal-reminder.php`
- [ ] Create `templates/emails/subscription-expired.php`

## Phase 11: Scheduled Tasks

### 11.1 Cron Jobs
- [ ] Create renewal reminder job (7 days before)
- [ ] Create subscription expiry checker
- [ ] Create webhook retry processor
- [ ] Create invoice cleanup job

## Phase 12: Testing

### 12.1 Unit Tests [P]
- [ ] Test PaymentService methods
- [ ] Test SubscriptionService methods
- [ ] Test InvoiceService calculations
- [ ] Test webhook signature verification

### 12.2 Integration Tests
- [ ] Test PayPal sandbox order creation
- [ ] Test PayPal sandbox subscription
- [ ] Test webhook processing
- [ ] Test payment-to-listing flow

### 12.3 End-to-End Tests
- [ ] Test complete listing payment flow
- [ ] Test complete subscription flow
- [ ] Test subscription cancellation
- [ ] Test failed payment recovery

## Phase 13: Security

### 13.1 Security Measures
- [ ] Implement webhook signature verification
- [ ] Add CSRF protection to payment forms
- [ ] Secure invoice download (signed URLs)
- [ ] Rate limit payment endpoints
- [ ] Audit log all transactions

## Legend
- [P] = Tasks can be executed in parallel
