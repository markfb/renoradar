# 006 - Alerts & Notifications Technical Plan

## Architecture Overview

The notification system uses a queue-based approach with cron jobs for processing. Email delivery uses PHPMailer with support for both instant and digest delivery modes.

## Directory Structure

```
src/
├── Controllers/
│   ├── AlertController.php
│   └── NotificationController.php
├── Services/
│   ├── AlertService.php
│   ├── NotificationService.php
│   ├── EmailQueueService.php
│   └── DigestService.php
├── Models/
│   ├── Alert.php
│   ├── Notification.php
│   └── EmailQueue.php
├── Jobs/
│   ├── ProcessPropertyAlertsJob.php
│   ├── SendDailyDigestJob.php
│   ├── SendWeeklyDigestJob.php
│   └── ProcessEmailQueueJob.php
└── Repositories/
    ├── AlertRepository.php
    └── NotificationRepository.php

templates/
├── alerts/
│   ├── index.php
│   ├── create.php
│   └── edit.php
├── notifications/
│   ├── index.php
│   └── preferences.php
└── emails/
    ├── alerts/
    │   ├── instant.php
    │   ├── daily-digest.php
    │   └── weekly-digest.php
    ├── price-change.php
    ├── property-sold.php
    ├── inquiry-received.php
    └── listing-status/
        ├── live.php
        ├── expiring.php
        ├── expired.php
        └── weekly-stats.php
```

## Routing Configuration

| Route | Controller | Method | Middleware | Description |
|-------|------------|--------|------------|-------------|
| `GET /alerts` | AlertController | index | Auth, Premium | List alerts |
| `GET /alerts/create` | AlertController | create | Auth, Premium | Create alert form |
| `POST /alerts` | AlertController | store | Auth, Premium | Save new alert |
| `GET /alerts/{id}/edit` | AlertController | edit | Auth, Premium | Edit alert form |
| `PUT /alerts/{id}` | AlertController | update | Auth, Premium | Update alert |
| `DELETE /alerts/{id}` | AlertController | destroy | Auth, Premium | Delete alert |
| `POST /alerts/{id}/toggle` | AlertController | toggle | Auth, Premium | Toggle active |
| `GET /notifications` | NotificationController | index | Auth | Notification history |
| `GET /api/notifications` | NotificationController | recent | Auth | Recent notifications |
| `POST /api/notifications/{id}/read` | NotificationController | markRead | Auth | Mark as read |
| `POST /api/notifications/read-all` | NotificationController | markAllRead | Auth | Mark all read |
| `GET /account/notifications` | NotificationController | preferences | Auth | Preferences page |
| `POST /account/notifications` | NotificationController | updatePreferences | Auth | Save preferences |
| `GET /unsubscribe/{token}` | NotificationController | unsubscribe | - | Email unsubscribe |

## Database Schema

### alerts
```sql
CREATE TABLE alerts (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NOT NULL,
    name VARCHAR(100) NOT NULL,
    criteria JSON NOT NULL,
    frequency ENUM('instant', 'daily', 'weekly') DEFAULT 'instant',
    is_active TINYINT(1) DEFAULT 1,
    last_sent_at TIMESTAMP NULL,
    last_matched_at TIMESTAMP NULL,
    match_count INT UNSIGNED DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user (user_id),
    INDEX idx_active (is_active),
    INDEX idx_frequency (frequency)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### notifications
```sql
CREATE TABLE notifications (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NOT NULL,
    type VARCHAR(50) NOT NULL,
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    data JSON,
    link VARCHAR(500),
    is_read TINYINT(1) DEFAULT 0,
    read_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user (user_id),
    INDEX idx_read (is_read),
    INDEX idx_type (type),
    INDEX idx_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### email_queue
```sql
CREATE TABLE email_queue (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NOT NULL,
    type VARCHAR(50) NOT NULL,
    template VARCHAR(100) NOT NULL,
    subject VARCHAR(200) NOT NULL,
    data JSON NOT NULL,
    priority TINYINT UNSIGNED DEFAULT 5,
    status ENUM('pending', 'processing', 'sent', 'failed') DEFAULT 'pending',
    attempts TINYINT UNSIGNED DEFAULT 0,
    max_attempts TINYINT UNSIGNED DEFAULT 3,
    last_error TEXT,
    scheduled_for TIMESTAMP NULL,
    sent_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_status (status),
    INDEX idx_scheduled (scheduled_for),
    INDEX idx_priority (priority)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### notification_preferences
```sql
CREATE TABLE notification_preferences (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NOT NULL UNIQUE,
    property_alerts TINYINT(1) DEFAULT 1,
    price_changes TINYINT(1) DEFAULT 1,
    sold_notifications TINYINT(1) DEFAULT 1,
    inquiry_notifications TINYINT(1) DEFAULT 1,
    listing_updates TINYINT(1) DEFAULT 1,
    weekly_stats TINYINT(1) DEFAULT 1,
    marketing_emails TINYINT(1) DEFAULT 0,
    newsletter TINYINT(1) DEFAULT 0,
    unsubscribe_token VARCHAR(64) UNIQUE,
    unsubscribed_at TIMESTAMP NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user (user_id),
    INDEX idx_token (unsubscribe_token)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### alert_property_matches
```sql
CREATE TABLE alert_property_matches (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    alert_id INT UNSIGNED NOT NULL,
    property_id INT UNSIGNED NOT NULL,
    notified_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (alert_id) REFERENCES alerts(id) ON DELETE CASCADE,
    FOREIGN KEY (property_id) REFERENCES properties(id) ON DELETE CASCADE,
    UNIQUE KEY uk_alert_property (alert_id, property_id),
    INDEX idx_notified (notified_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

## Services

### AlertService

```php
class AlertService
{
    /**
     * Find matching properties for an alert
     */
    public function findMatches(Alert $alert): array
    {
        $criteria = $alert->criteria;
        $query = Property::where('status', 'active')
            ->where('published_at', '>', $alert->last_matched_at ?? $alert->created_at);

        // Apply location filter
        if (!empty($criteria['location'])) {
            $query->where(function ($q) use ($criteria) {
                $q->where('city', 'LIKE', "%{$criteria['location']}%")
                  ->orWhere('postcode_area', $criteria['location']);
            });
        }

        // Apply type filter
        if (!empty($criteria['types'])) {
            $query->whereIn('property_type', $criteria['types']);
        }

        // Apply condition filter
        if (!empty($criteria['conditions'])) {
            $query->whereIn('condition_type', $criteria['conditions']);
        }

        // Apply price range
        if (!empty($criteria['min_price'])) {
            $query->where('price', '>=', $criteria['min_price']);
        }
        if (!empty($criteria['max_price'])) {
            $query->where('price', '<=', $criteria['max_price']);
        }

        // Apply bedroom range
        if (!empty($criteria['min_beds'])) {
            $query->where('bedrooms', '>=', $criteria['min_beds']);
        }
        if (!empty($criteria['max_beds'])) {
            $query->where('bedrooms', '<=', $criteria['max_beds']);
        }

        return $query->get();
    }

    /**
     * Process all instant alerts for a new property
     */
    public function processNewProperty(Property $property): void
    {
        $alerts = Alert::where('is_active', true)
            ->where('frequency', 'instant')
            ->whereHas('user', fn($q) => $q->where('subscription_tier', 'premium'))
            ->get();

        foreach ($alerts as $alert) {
            if ($this->propertyMatchesCriteria($property, $alert->criteria)) {
                $this->queueAlertNotification($alert, [$property]);
            }
        }
    }
}
```

### NotificationService

```php
class NotificationService
{
    /**
     * Create an in-app notification
     */
    public function notify(User $user, string $type, array $data): Notification
    {
        return Notification::create([
            'user_id' => $user->id,
            'type' => $type,
            'title' => $data['title'],
            'message' => $data['message'],
            'data' => $data['extra'] ?? null,
            'link' => $data['link'] ?? null,
        ]);
    }

    /**
     * Get unread count for user
     */
    public function getUnreadCount(User $user): int
    {
        return Notification::where('user_id', $user->id)
            ->where('is_read', false)
            ->count();
    }

    /**
     * Get recent notifications
     */
    public function getRecent(User $user, int $limit = 10): array
    {
        return Notification::where('user_id', $user->id)
            ->orderBy('created_at', 'desc')
            ->limit($limit)
            ->get();
    }
}
```

### EmailQueueService

```php
class EmailQueueService
{
    /**
     * Add email to queue
     */
    public function queue(
        User $user,
        string $type,
        string $template,
        string $subject,
        array $data,
        ?DateTime $scheduledFor = null
    ): EmailQueue {
        // Check user preferences
        if (!$this->shouldSendEmail($user, $type)) {
            return null;
        }

        return EmailQueue::create([
            'user_id' => $user->id,
            'type' => $type,
            'template' => $template,
            'subject' => $subject,
            'data' => $data,
            'scheduled_for' => $scheduledFor ?? now(),
        ]);
    }

    /**
     * Process pending emails
     */
    public function processPending(int $limit = 50): int
    {
        $pending = EmailQueue::where('status', 'pending')
            ->where('scheduled_for', '<=', now())
            ->where('attempts', '<', DB::raw('max_attempts'))
            ->orderBy('priority')
            ->orderBy('created_at')
            ->limit($limit)
            ->get();

        $sent = 0;
        foreach ($pending as $email) {
            try {
                $email->update(['status' => 'processing']);
                $this->send($email);
                $email->update([
                    'status' => 'sent',
                    'sent_at' => now(),
                ]);
                $sent++;
            } catch (Exception $e) {
                $email->update([
                    'status' => 'pending',
                    'attempts' => $email->attempts + 1,
                    'last_error' => $e->getMessage(),
                ]);
            }
        }

        return $sent;
    }
}
```

## Cron Jobs

### cron/alerts.php
```php
// Run every 5 minutes
// Process instant alerts for new properties

$alertService = new AlertService();
$properties = Property::where('published_at', '>', now()->subMinutes(5))->get();

foreach ($properties as $property) {
    $alertService->processNewProperty($property);
}
```

### cron/daily-digest.php
```php
// Run daily at 8:00 AM
// Send daily digest emails

$digestService = new DigestService();
$digestService->sendDailyDigests();
```

### cron/weekly-digest.php
```php
// Run weekly on Monday at 8:00 AM
// Send weekly digest and seller stats

$digestService = new DigestService();
$digestService->sendWeeklyDigests();
$digestService->sendSellerWeeklyStats();
```

### cron/email-queue.php
```php
// Run every minute
// Process email queue

$emailQueue = new EmailQueueService();
$sent = $emailQueue->processPending(100);
echo "Sent {$sent} emails\n";
```

## Frontend Components

### Notification Bell

```javascript
// components/notificationBell.js
class NotificationBell {
    constructor(element) {
        this.bell = element;
        this.dropdown = element.querySelector('.notification-dropdown');
        this.badge = element.querySelector('.notification-badge');
        this.list = element.querySelector('.notification-list');

        this.init();
    }

    init() {
        this.bell.addEventListener('click', () => this.toggle());
        this.loadRecent();
        this.startPolling();
    }

    async loadRecent() {
        const response = await fetch('/api/notifications');
        const data = await response.json();

        this.updateBadge(data.unread_count);
        this.renderList(data.notifications);
    }

    startPolling() {
        // Poll every 30 seconds
        setInterval(() => this.loadRecent(), 30000);
    }

    async markAsRead(notificationId) {
        await fetch(`/api/notifications/${notificationId}/read`, {
            method: 'POST',
            headers: { 'X-CSRF-Token': csrfToken },
        });
        this.loadRecent();
    }

    async markAllRead() {
        await fetch('/api/notifications/read-all', {
            method: 'POST',
            headers: { 'X-CSRF-Token': csrfToken },
        });
        this.loadRecent();
    }
}
```

### Alert Form

```javascript
// components/alertForm.js
class AlertForm {
    constructor(form) {
        this.form = form;
        this.init();
    }

    init() {
        // Mirror search filter functionality
        this.form.querySelectorAll('input, select').forEach(input => {
            input.addEventListener('change', () => this.updatePreview());
        });
    }

    updatePreview() {
        // Show summary of alert criteria
        const criteria = this.getCriteria();
        this.renderPreview(criteria);
    }

    getCriteria() {
        // Collect form data into criteria object
    }
}
```

## Email Templates

### Instant Alert Email
```html
<!-- templates/emails/alerts/instant.php -->
<h1>New Property Match!</h1>
<p>A new property matching your "{{ alert.name }}" alert has been listed:</p>

<div class="property-card">
    <img src="{{ property.thumbnail }}" alt="">
    <h2>{{ property.title }}</h2>
    <p class="price">£{{ property.price | number_format }}</p>
    <p>{{ property.bedrooms }} beds | {{ property.bathrooms }} baths</p>
    <p>{{ property.city }}, {{ property.postcode_area }}</p>
    <a href="{{ property.url }}">View Property</a>
</div>

<p>
    <a href="{{ manage_alerts_url }}">Manage your alerts</a> |
    <a href="{{ unsubscribe_url }}">Unsubscribe</a>
</p>
```

### Daily Digest Email
```html
<!-- templates/emails/alerts/daily-digest.php -->
<h1>Your Daily Property Digest</h1>
<p>{{ count }} new properties match your alerts:</p>

{% for property in properties %}
<div class="property-card">
    <!-- Property details -->
</div>
{% endfor %}

<a href="{{ browse_url }}">View All Properties</a>
```
