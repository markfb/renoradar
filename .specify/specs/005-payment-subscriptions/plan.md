# 005 - Payment & Subscriptions Technical Plan

## Architecture Overview

The payment system uses PayPal's REST API for all transactions. One-time payments use PayPal Orders API, while subscriptions use PayPal Subscriptions API. All webhook notifications are verified and processed idempotently.

## Directory Structure

```
src/
├── Controllers/
│   ├── PaymentController.php
│   ├── SubscriptionController.php
│   └── WebhookController.php
├── Services/
│   ├── PayPalService.php
│   ├── PaymentService.php
│   └── SubscriptionService.php
├── Models/
│   ├── Payment.php
│   ├── Subscription.php
│   └── Invoice.php
└── Repositories/
    ├── PaymentRepository.php
    └── SubscriptionRepository.php

templates/
├── payments/
│   ├── checkout.php
│   ├── success.php
│   └── failed.php
├── subscriptions/
│   ├── pricing.php
│   ├── manage.php
│   ├── invoices.php
│   └── cancelled.php
└── emails/
    ├── payment-receipt.php
    ├── subscription-welcome.php
    ├── payment-failed.php
    ├── subscription-cancelled.php
    └── renewal-reminder.php

config/
└── paypal.php
```

## Routing Configuration

| Route | Controller | Method | Middleware | Description |
|-------|------------|--------|------------|-------------|
| `GET /pricing` | SubscriptionController | pricing | - | Pricing page |
| `POST /checkout/listing` | PaymentController | checkoutListing | Auth | Listing payment |
| `POST /checkout/subscription` | SubscriptionController | checkout | Auth | Subscription checkout |
| `GET /payment/success` | PaymentController | success | Auth | Payment success |
| `GET /payment/cancel` | PaymentController | cancel | Auth | Payment cancelled |
| `POST /webhooks/paypal` | WebhookController | paypal | - | PayPal webhooks |
| `GET /account/subscription` | SubscriptionController | manage | Auth | Manage subscription |
| `POST /account/subscription/cancel` | SubscriptionController | cancel | Auth | Cancel subscription |
| `GET /account/invoices` | SubscriptionController | invoices | Auth | View invoices |
| `GET /account/invoices/{id}` | SubscriptionController | downloadInvoice | Auth | Download invoice |

## Database Schema

### payments
```sql
CREATE TABLE payments (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NOT NULL,
    paypal_order_id VARCHAR(50) UNIQUE,
    paypal_capture_id VARCHAR(50),
    type ENUM('listing', 'listing_premium', 'listing_renewal', 'subscription') NOT NULL,
    product_code VARCHAR(50) NOT NULL,
    description VARCHAR(255) NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'GBP',
    status ENUM('pending', 'completed', 'failed', 'refunded') DEFAULT 'pending',
    metadata JSON,
    paid_at TIMESTAMP NULL,
    refunded_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user (user_id),
    INDEX idx_paypal_order (paypal_order_id),
    INDEX idx_status (status),
    INDEX idx_type (type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### subscriptions
```sql
CREATE TABLE subscriptions (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NOT NULL,
    paypal_subscription_id VARCHAR(50) UNIQUE,
    paypal_plan_id VARCHAR(50) NOT NULL,
    type ENUM('buyer_monthly', 'buyer_annual', 'listing_premium') NOT NULL,
    status ENUM('pending', 'active', 'cancelled', 'suspended', 'expired') DEFAULT 'pending',
    current_period_start TIMESTAMP NULL,
    current_period_end TIMESTAMP NULL,
    cancelled_at TIMESTAMP NULL,
    cancel_reason TEXT,
    trial_ends_at TIMESTAMP NULL,
    metadata JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user (user_id),
    INDEX idx_paypal_subscription (paypal_subscription_id),
    INDEX idx_status (status),
    INDEX idx_type (type),
    INDEX idx_period_end (current_period_end)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### invoices
```sql
CREATE TABLE invoices (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NOT NULL,
    payment_id INT UNSIGNED NULL,
    subscription_id INT UNSIGNED NULL,
    invoice_number VARCHAR(50) NOT NULL UNIQUE,
    type ENUM('payment', 'subscription', 'refund') NOT NULL,
    description VARCHAR(255) NOT NULL,
    subtotal DECIMAL(10, 2) NOT NULL,
    vat_rate DECIMAL(5, 2) DEFAULT 20.00,
    vat_amount DECIMAL(10, 2) NOT NULL,
    total DECIMAL(10, 2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'GBP',
    status ENUM('draft', 'issued', 'paid', 'refunded') DEFAULT 'draft',
    issued_at TIMESTAMP NULL,
    paid_at TIMESTAMP NULL,
    pdf_path VARCHAR(500) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (payment_id) REFERENCES payments(id) ON DELETE SET NULL,
    FOREIGN KEY (subscription_id) REFERENCES subscriptions(id) ON DELETE SET NULL,
    INDEX idx_user (user_id),
    INDEX idx_number (invoice_number)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### webhook_logs
```sql
CREATE TABLE webhook_logs (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    provider VARCHAR(20) NOT NULL,
    event_id VARCHAR(100) NOT NULL,
    event_type VARCHAR(100) NOT NULL,
    payload JSON NOT NULL,
    status ENUM('received', 'processed', 'failed') DEFAULT 'received',
    error_message TEXT,
    processed_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    UNIQUE KEY uk_event (provider, event_id),
    INDEX idx_type (event_type),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

## PayPal Configuration

### config/paypal.php
```php
return [
    'mode' => env('PAYPAL_MODE', 'sandbox'), // 'sandbox' or 'live'
    'client_id' => env('PAYPAL_CLIENT_ID'),
    'client_secret' => env('PAYPAL_CLIENT_SECRET'),
    'webhook_id' => env('PAYPAL_WEBHOOK_ID'),

    'plans' => [
        'buyer_monthly' => env('PAYPAL_PLAN_BUYER_MONTHLY'),
        'buyer_annual' => env('PAYPAL_PLAN_BUYER_ANNUAL'),
        'listing_premium' => env('PAYPAL_PLAN_LISTING_PREMIUM'),
    ],

    'prices' => [
        'listing_standard' => 25.00,
        'listing_premium' => 20.00,
        'listing_renewal' => 15.00,
        'buyer_monthly' => 25.00,
        'buyer_annual' => 199.00,
    ],

    'return_urls' => [
        'success' => '/payment/success',
        'cancel' => '/payment/cancel',
    ],
];
```

## PayPal Service Implementation

```php
class PayPalService
{
    private string $baseUrl;
    private ?string $accessToken = null;

    public function __construct(
        private string $clientId,
        private string $clientSecret,
        private string $mode
    ) {
        $this->baseUrl = $mode === 'live'
            ? 'https://api-m.paypal.com'
            : 'https://api-m.sandbox.paypal.com';
    }

    /**
     * Create a one-time payment order
     */
    public function createOrder(array $data): array
    {
        return $this->request('POST', '/v2/checkout/orders', [
            'intent' => 'CAPTURE',
            'purchase_units' => [[
                'reference_id' => $data['reference_id'],
                'description' => $data['description'],
                'amount' => [
                    'currency_code' => 'GBP',
                    'value' => number_format($data['amount'], 2, '.', ''),
                ],
            ]],
            'application_context' => [
                'return_url' => url($data['return_url']),
                'cancel_url' => url($data['cancel_url']),
                'brand_name' => 'RenoRadar',
                'user_action' => 'PAY_NOW',
            ],
        ]);
    }

    /**
     * Capture payment for an order
     */
    public function captureOrder(string $orderId): array
    {
        return $this->request('POST', "/v2/checkout/orders/{$orderId}/capture");
    }

    /**
     * Create a subscription
     */
    public function createSubscription(string $planId, array $data): array
    {
        return $this->request('POST', '/v1/billing/subscriptions', [
            'plan_id' => $planId,
            'subscriber' => [
                'name' => [
                    'given_name' => $data['first_name'],
                    'surname' => $data['last_name'],
                ],
                'email_address' => $data['email'],
            ],
            'application_context' => [
                'return_url' => url($data['return_url']),
                'cancel_url' => url($data['cancel_url']),
                'brand_name' => 'RenoRadar',
                'user_action' => 'SUBSCRIBE_NOW',
            ],
        ]);
    }

    /**
     * Cancel a subscription
     */
    public function cancelSubscription(string $subscriptionId, string $reason): bool
    {
        $this->request('POST', "/v1/billing/subscriptions/{$subscriptionId}/cancel", [
            'reason' => $reason,
        ]);
        return true;
    }

    /**
     * Verify webhook signature
     */
    public function verifyWebhook(array $headers, string $body): bool
    {
        $response = $this->request('POST', '/v1/notifications/verify-webhook-signature', [
            'auth_algo' => $headers['PAYPAL-AUTH-ALGO'] ?? '',
            'cert_url' => $headers['PAYPAL-CERT-URL'] ?? '',
            'transmission_id' => $headers['PAYPAL-TRANSMISSION-ID'] ?? '',
            'transmission_sig' => $headers['PAYPAL-TRANSMISSION-SIG'] ?? '',
            'transmission_time' => $headers['PAYPAL-TRANSMISSION-TIME'] ?? '',
            'webhook_id' => config('paypal.webhook_id'),
            'webhook_event' => json_decode($body, true),
        ]);

        return ($response['verification_status'] ?? '') === 'SUCCESS';
    }

    private function getAccessToken(): string
    {
        if ($this->accessToken) {
            return $this->accessToken;
        }

        $response = Http::withBasicAuth($this->clientId, $this->clientSecret)
            ->asForm()
            ->post("{$this->baseUrl}/v1/oauth2/token", [
                'grant_type' => 'client_credentials',
            ]);

        $this->accessToken = $response->json('access_token');
        return $this->accessToken;
    }

    private function request(string $method, string $endpoint, array $data = []): array
    {
        $response = Http::withToken($this->getAccessToken())
            ->withHeaders(['Content-Type' => 'application/json'])
            ->{strtolower($method)}("{$this->baseUrl}{$endpoint}", $data);

        if (!$response->successful()) {
            throw new PayPalException($response->json('message', 'PayPal API error'));
        }

        return $response->json();
    }
}
```

## Webhook Handler

```php
class WebhookController
{
    public function paypal(Request $request): Response
    {
        $payload = $request->getContent();
        $headers = $request->getHeaders();

        // Verify webhook signature
        if (!$this->paypal->verifyWebhook($headers, $payload)) {
            return response('Invalid signature', 401);
        }

        $event = json_decode($payload, true);
        $eventId = $event['id'];
        $eventType = $event['event_type'];

        // Idempotency check
        if ($this->webhookLog->exists('paypal', $eventId)) {
            return response('Already processed', 200);
        }

        // Log webhook
        $log = $this->webhookLog->create([
            'provider' => 'paypal',
            'event_id' => $eventId,
            'event_type' => $eventType,
            'payload' => $event,
        ]);

        try {
            $this->processEvent($eventType, $event['resource']);
            $log->markProcessed();
        } catch (Exception $e) {
            $log->markFailed($e->getMessage());
            throw $e;
        }

        return response('OK', 200);
    }

    private function processEvent(string $type, array $resource): void
    {
        match ($type) {
            'PAYMENT.CAPTURE.COMPLETED' => $this->handlePaymentCompleted($resource),
            'PAYMENT.CAPTURE.DENIED' => $this->handlePaymentDenied($resource),
            'BILLING.SUBSCRIPTION.ACTIVATED' => $this->handleSubscriptionActivated($resource),
            'BILLING.SUBSCRIPTION.CANCELLED' => $this->handleSubscriptionCancelled($resource),
            'BILLING.SUBSCRIPTION.SUSPENDED' => $this->handleSubscriptionSuspended($resource),
            'PAYMENT.SALE.COMPLETED' => $this->handleSubscriptionPayment($resource),
            default => null, // Ignore unhandled events
        };
    }
}
```

## Frontend Integration

### PayPal JavaScript SDK

```html
<!-- Include in checkout pages -->
<script src="https://www.paypal.com/sdk/js?client-id={{ config.paypal.client_id }}&currency=GBP"></script>
```

### One-Time Payment Button

```javascript
// components/paypalCheckout.js
paypal.Buttons({
    createOrder: async () => {
        const response = await fetch('/checkout/listing', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-Token': csrfToken,
            },
            body: JSON.stringify({
                property_id: propertyId,
            }),
        });
        const data = await response.json();
        return data.paypal_order_id;
    },

    onApprove: async (data) => {
        window.location.href = `/payment/success?order_id=${data.orderID}`;
    },

    onCancel: () => {
        window.location.href = '/payment/cancel';
    },

    onError: (err) => {
        console.error('PayPal error:', err);
        showError('Payment failed. Please try again.');
    },
}).render('#paypal-button-container');
```

### Subscription Button

```javascript
// components/paypalSubscription.js
paypal.Buttons({
    style: {
        shape: 'rect',
        color: 'gold',
        layout: 'vertical',
        label: 'subscribe',
    },

    createSubscription: async (data, actions) => {
        const response = await fetch('/checkout/subscription', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-Token': csrfToken,
            },
            body: JSON.stringify({
                plan: selectedPlan, // 'monthly' or 'annual'
            }),
        });
        const result = await response.json();
        return result.paypal_subscription_id;
    },

    onApprove: (data) => {
        window.location.href = `/payment/success?subscription_id=${data.subscriptionID}`;
    },
}).render('#paypal-subscription-button');
```

## Invoice Generation

```php
class InvoiceService
{
    public function generateInvoice(Payment $payment): Invoice
    {
        $subtotal = $payment->amount;
        $vatRate = 20.00;
        $vatAmount = $subtotal * ($vatRate / 100);
        $total = $subtotal + $vatAmount;

        $invoice = Invoice::create([
            'user_id' => $payment->user_id,
            'payment_id' => $payment->id,
            'invoice_number' => $this->generateInvoiceNumber(),
            'type' => 'payment',
            'description' => $payment->description,
            'subtotal' => $subtotal,
            'vat_rate' => $vatRate,
            'vat_amount' => $vatAmount,
            'total' => $total,
            'status' => 'paid',
            'issued_at' => now(),
            'paid_at' => $payment->paid_at,
        ]);

        // Generate PDF
        $this->generatePdf($invoice);

        return $invoice;
    }

    private function generateInvoiceNumber(): string
    {
        $year = date('Y');
        $count = Invoice::whereYear('created_at', $year)->count() + 1;
        return sprintf('RR-%s-%05d', $year, $count);
    }
}
```
