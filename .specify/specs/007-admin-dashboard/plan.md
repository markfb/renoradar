# 007 - Admin Dashboard Technical Plan

## Architecture Overview

The admin dashboard is a separate section of the application with its own layout, middleware, and controllers. It uses the same database and services as the main application but with elevated permissions.

## Directory Structure

```
src/
├── Controllers/
│   └── Admin/
│       ├── DashboardController.php
│       ├── UserController.php
│       ├── ListingController.php
│       ├── ContentController.php
│       ├── PaymentController.php
│       ├── InquiryController.php
│       ├── ContactController.php
│       ├── SettingsController.php
│       ├── ReportController.php
│       └── AuditController.php
├── Middleware/
│   └── AdminMiddleware.php
├── Services/
│   ├── AdminService.php
│   ├── ReportService.php
│   └── AuditService.php
└── Models/
    ├── Setting.php
    └── AuditLog.php

templates/
└── admin/
    ├── layouts/
    │   └── main.php
    ├── partials/
    │   ├── sidebar.php
    │   ├── header.php
    │   ├── stats-card.php
    │   └── data-table.php
    ├── dashboard/
    │   └── index.php
    ├── users/
    │   ├── index.php
    │   ├── show.php
    │   └── edit.php
    ├── listings/
    │   ├── index.php
    │   ├── show.php
    │   └── edit.php
    ├── content/
    │   ├── pages/
    │   │   ├── index.php
    │   │   └── edit.php
    │   ├── posts/
    │   │   ├── index.php
    │   │   ├── create.php
    │   │   └── edit.php
    │   └── faqs/
    │       └── index.php
    ├── payments/
    │   ├── index.php
    │   └── show.php
    ├── subscriptions/
    │   ├── index.php
    │   └── show.php
    ├── inquiries/
    │   └── index.php
    ├── contacts/
    │   └── index.php
    ├── settings/
    │   └── index.php
    ├── reports/
    │   ├── index.php
    │   ├── users.php
    │   ├── listings.php
    │   ├── revenue.php
    │   └── search.php
    └── audit/
        └── index.php
```

## Routing Configuration

All admin routes are prefixed with `/admin` and protected by AdminMiddleware.

| Route | Controller | Method | Description |
|-------|------------|--------|-------------|
| `GET /admin` | DashboardController | index | Dashboard overview |
| `GET /admin/users` | UserController | index | User list |
| `GET /admin/users/{id}` | UserController | show | User detail |
| `GET /admin/users/{id}/edit` | UserController | edit | Edit user |
| `PUT /admin/users/{id}` | UserController | update | Update user |
| `POST /admin/users/{id}/suspend` | UserController | suspend | Suspend user |
| `POST /admin/users/{id}/unsuspend` | UserController | unsuspend | Unsuspend |
| `DELETE /admin/users/{id}` | UserController | destroy | Delete user |
| `POST /admin/users/{id}/impersonate` | UserController | impersonate | Login as user |
| `GET /admin/users/export` | UserController | export | Export CSV |
| `GET /admin/listings` | ListingController | index | Listing list |
| `GET /admin/listings/{id}` | ListingController | show | Listing detail |
| `GET /admin/listings/{id}/edit` | ListingController | edit | Edit listing |
| `PUT /admin/listings/{id}` | ListingController | update | Update listing |
| `POST /admin/listings/{id}/approve` | ListingController | approve | Approve listing |
| `POST /admin/listings/{id}/pause` | ListingController | pause | Pause listing |
| `POST /admin/listings/{id}/feature` | ListingController | feature | Feature listing |
| `DELETE /admin/listings/{id}` | ListingController | destroy | Delete listing |
| `GET /admin/content/pages` | ContentController | pages | Page list |
| `GET /admin/content/pages/{id}` | ContentController | editPage | Edit page |
| `PUT /admin/content/pages/{id}` | ContentController | updatePage | Update page |
| `GET /admin/content/posts` | ContentController | posts | Post list |
| `GET /admin/content/posts/create` | ContentController | createPost | Create post |
| `POST /admin/content/posts` | ContentController | storePost | Store post |
| `GET /admin/content/posts/{id}` | ContentController | editPost | Edit post |
| `PUT /admin/content/posts/{id}` | ContentController | updatePost | Update post |
| `DELETE /admin/content/posts/{id}` | ContentController | destroyPost | Delete post |
| `GET /admin/payments` | PaymentController | index | Payment list |
| `GET /admin/payments/{id}` | PaymentController | show | Payment detail |
| `POST /admin/payments/{id}/refund` | PaymentController | refund | Refund payment |
| `GET /admin/subscriptions` | PaymentController | subscriptions | Subscription list |
| `POST /admin/subscriptions/{id}/cancel` | PaymentController | cancelSubscription | Cancel sub |
| `GET /admin/inquiries` | InquiryController | index | Inquiry list |
| `DELETE /admin/inquiries/{id}` | InquiryController | destroy | Delete inquiry |
| `GET /admin/contacts` | ContactController | index | Contact submissions |
| `POST /admin/contacts/{id}/read` | ContactController | markRead | Mark as read |
| `DELETE /admin/contacts/{id}` | ContactController | destroy | Delete submission |
| `GET /admin/settings` | SettingsController | index | Settings form |
| `PUT /admin/settings` | SettingsController | update | Update settings |
| `GET /admin/reports` | ReportController | index | Reports overview |
| `GET /admin/reports/{type}` | ReportController | show | Specific report |
| `GET /admin/reports/{type}/export` | ReportController | export | Export report |
| `GET /admin/audit` | AuditController | index | Audit logs |

## Database Schema

### settings
```sql
CREATE TABLE settings (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `key` VARCHAR(100) NOT NULL UNIQUE,
    value TEXT,
    type ENUM('string', 'integer', 'boolean', 'json') DEFAULT 'string',
    group_name VARCHAR(50) DEFAULT 'general',
    description VARCHAR(255),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_key (`key`),
    INDEX idx_group (group_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### audit_logs
```sql
CREATE TABLE audit_logs (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    admin_id INT UNSIGNED NOT NULL,
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(50),
    entity_id INT UNSIGNED,
    old_values JSON,
    new_values JSON,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (admin_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_admin (admin_id),
    INDEX idx_action (action),
    INDEX idx_entity (entity_type, entity_id),
    INDEX idx_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

## Middleware

### AdminMiddleware

```php
class AdminMiddleware
{
    public function handle(Request $request, Closure $next): Response
    {
        // Check if user is authenticated
        if (!auth()->check()) {
            return redirect('/login?redirect=' . urlencode($request->path()));
        }

        // Check if user has admin role
        if (auth()->user()->role !== 'admin') {
            abort(403, 'Access denied');
        }

        // Check session timeout (30 minutes)
        $lastActivity = session()->get('admin_last_activity');
        if ($lastActivity && (time() - $lastActivity) > 1800) {
            auth()->logout();
            return redirect('/login')->with('message', 'Session expired');
        }

        session()->set('admin_last_activity', time());

        return $next($request);
    }
}
```

## Services

### AuditService

```php
class AuditService
{
    public function log(
        string $action,
        ?string $entityType = null,
        ?int $entityId = null,
        ?array $oldValues = null,
        ?array $newValues = null
    ): AuditLog {
        return AuditLog::create([
            'admin_id' => auth()->id(),
            'action' => $action,
            'entity_type' => $entityType,
            'entity_id' => $entityId,
            'old_values' => $oldValues,
            'new_values' => $newValues,
            'ip_address' => request()->ip(),
            'user_agent' => request()->userAgent(),
        ]);
    }

    public function getRecent(int $limit = 50): array
    {
        return AuditLog::with('admin')
            ->orderBy('created_at', 'desc')
            ->limit($limit)
            ->get();
    }
}
```

### ReportService

```php
class ReportService
{
    public function getUserStats(): array
    {
        return [
            'total' => User::count(),
            'new_this_week' => User::where('created_at', '>', now()->subWeek())->count(),
            'new_this_month' => User::where('created_at', '>', now()->subMonth())->count(),
            'premium' => User::where('subscription_tier', 'premium')->count(),
            'sellers' => User::where('role', 'seller')->count(),
        ];
    }

    public function getListingStats(): array
    {
        return [
            'total' => Property::count(),
            'active' => Property::where('status', 'active')->count(),
            'pending' => Property::where('status', 'pending-payment')->count(),
            'sold' => Property::where('status', 'sold')->count(),
            'premium' => Property::where('is_premium', true)->count(),
        ];
    }

    public function getRevenueStats(): array
    {
        return [
            'total' => Payment::where('status', 'completed')->sum('amount'),
            'this_month' => Payment::where('status', 'completed')
                ->where('paid_at', '>', now()->startOfMonth())
                ->sum('amount'),
            'listing_fees' => Payment::where('status', 'completed')
                ->where('type', 'listing')
                ->sum('amount'),
            'subscriptions' => Payment::where('status', 'completed')
                ->where('type', 'subscription')
                ->sum('amount'),
        ];
    }

    public function getUserRegistrationTrend(int $days = 30): array
    {
        return User::selectRaw('DATE(created_at) as date, COUNT(*) as count')
            ->where('created_at', '>', now()->subDays($days))
            ->groupBy('date')
            ->orderBy('date')
            ->get()
            ->toArray();
    }

    public function getRevenueTrend(int $months = 12): array
    {
        return Payment::selectRaw('DATE_FORMAT(paid_at, "%Y-%m") as month, SUM(amount) as total')
            ->where('status', 'completed')
            ->where('paid_at', '>', now()->subMonths($months))
            ->groupBy('month')
            ->orderBy('month')
            ->get()
            ->toArray();
    }
}
```

### SettingsService

```php
class SettingsService
{
    private static array $cache = [];

    public function get(string $key, mixed $default = null): mixed
    {
        if (!isset(self::$cache[$key])) {
            $setting = Setting::where('key', $key)->first();
            self::$cache[$key] = $setting ? $this->castValue($setting) : $default;
        }

        return self::$cache[$key];
    }

    public function set(string $key, mixed $value): void
    {
        Setting::updateOrCreate(
            ['key' => $key],
            ['value' => $this->serializeValue($value)]
        );

        self::$cache[$key] = $value;
    }

    public function getGroup(string $group): array
    {
        return Setting::where('group_name', $group)
            ->get()
            ->mapWithKeys(fn ($s) => [$s->key => $this->castValue($s)])
            ->toArray();
    }
}
```

## Frontend Components

### Admin Layout

```html
<!-- templates/admin/layouts/main.php -->
<!DOCTYPE html>
<html>
<head>
    <title>Admin - RenoRadar</title>
    <link href="/assets/css/admin.css" rel="stylesheet">
</head>
<body class="admin-layout">
    <aside class="admin-sidebar">
        <?php include 'partials/sidebar.php'; ?>
    </aside>

    <main class="admin-main">
        <header class="admin-header">
            <?php include 'partials/header.php'; ?>
        </header>

        <div class="admin-content">
            <?php echo $content; ?>
        </div>
    </main>

    <script src="/assets/js/admin.js"></script>
</body>
</html>
```

### Data Table Component

```javascript
// admin/components/dataTable.js
class AdminDataTable {
    constructor(element, options = {}) {
        this.table = element;
        this.options = {
            sortable: true,
            selectable: true,
            searchable: true,
            ...options
        };

        this.init();
    }

    init() {
        if (this.options.sortable) this.initSorting();
        if (this.options.selectable) this.initSelection();
        if (this.options.searchable) this.initSearch();
    }

    initSorting() {
        this.table.querySelectorAll('th[data-sortable]').forEach(th => {
            th.addEventListener('click', () => this.sortBy(th.dataset.column));
        });
    }

    initSelection() {
        const selectAll = this.table.querySelector('.select-all');
        selectAll?.addEventListener('change', (e) => {
            this.table.querySelectorAll('.row-select').forEach(cb => {
                cb.checked = e.target.checked;
            });
            this.updateBulkActions();
        });

        this.table.querySelectorAll('.row-select').forEach(cb => {
            cb.addEventListener('change', () => this.updateBulkActions());
        });
    }

    getSelectedIds() {
        return Array.from(this.table.querySelectorAll('.row-select:checked'))
            .map(cb => cb.value);
    }

    updateBulkActions() {
        const selected = this.getSelectedIds().length;
        const bulkActions = document.querySelector('.bulk-actions');
        if (bulkActions) {
            bulkActions.style.display = selected > 0 ? 'block' : 'none';
            bulkActions.querySelector('.selected-count').textContent = selected;
        }
    }
}
```

### Chart Component

```javascript
// admin/components/charts.js
// Using Chart.js or similar library

function createLineChart(canvas, data, options = {}) {
    return new Chart(canvas, {
        type: 'line',
        data: {
            labels: data.labels,
            datasets: [{
                label: options.label || 'Data',
                data: data.values,
                borderColor: '#2563EB',
                backgroundColor: 'rgba(37, 99, 235, 0.1)',
                fill: true,
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            ...options.chartOptions
        }
    });
}

function createBarChart(canvas, data, options = {}) {
    // Similar implementation
}
```

## Settings Structure

```php
// Default settings to seed
$defaultSettings = [
    // General
    ['key' => 'site_name', 'value' => 'RenoRadar', 'group' => 'general'],
    ['key' => 'contact_email', 'value' => 'hello@renoradar.com', 'group' => 'general'],
    ['key' => 'support_phone', 'value' => '', 'group' => 'general'],

    // Listings
    ['key' => 'listing_fee', 'value' => '25.00', 'group' => 'listings', 'type' => 'string'],
    ['key' => 'premium_listing_fee', 'value' => '20.00', 'group' => 'listings'],
    ['key' => 'listing_duration_months', 'value' => '6', 'group' => 'listings', 'type' => 'integer'],
    ['key' => 'moderation_enabled', 'value' => '0', 'group' => 'listings', 'type' => 'boolean'],

    // Subscriptions
    ['key' => 'subscription_monthly', 'value' => '25.00', 'group' => 'subscriptions'],
    ['key' => 'subscription_annual', 'value' => '199.00', 'group' => 'subscriptions'],

    // Email
    ['key' => 'email_from_address', 'value' => 'noreply@renoradar.com', 'group' => 'email'],
    ['key' => 'email_from_name', 'value' => 'RenoRadar', 'group' => 'email'],

    // SEO
    ['key' => 'default_meta_title', 'value' => 'RenoRadar - Find Renovation Properties', 'group' => 'seo'],
    ['key' => 'google_analytics_id', 'value' => '', 'group' => 'seo'],

    // Maintenance
    ['key' => 'maintenance_mode', 'value' => '0', 'group' => 'system', 'type' => 'boolean'],
];
```
