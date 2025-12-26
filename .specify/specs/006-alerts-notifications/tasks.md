# 006 - Alerts & Notifications Tasks

## Phase 1: Database Setup

### 1.1 Migrations
- [ ] Create `database/migrations/022_create_alerts_table.php`
- [ ] Create `database/migrations/023_create_notifications_table.php`
- [ ] Create `database/migrations/024_create_email_queue_table.php`
- [ ] Create `database/migrations/025_create_notification_preferences_table.php`
- [ ] Create `database/migrations/026_create_alert_property_matches_table.php`
- [ ] Run migrations

## Phase 2: Models & Repositories

### 2.1 Models [P]
- [ ] Implement `src/Models/Alert.php`
  - Column mappings
  - Criteria JSON casting
  - User relationship
  - Matches relationship
  - Scopes (active, byFrequency)

- [ ] Implement `src/Models/Notification.php`
  - Column mappings
  - Data JSON casting
  - User relationship
  - Scopes (unread, byType)
  - markAsRead() method

- [ ] Implement `src/Models/EmailQueue.php`
  - Column mappings
  - Data JSON casting
  - User relationship
  - Status management

- [ ] Implement `src/Models/NotificationPreference.php`
  - Column mappings
  - User relationship
  - Default values
  - Generate unsubscribe token

### 2.2 Repositories [P]
- [ ] Implement `src/Repositories/AlertRepository.php`
  - findByUser()
  - findActive()
  - findByFrequency()
  - findMatchingCriteria()

- [ ] Implement `src/Repositories/NotificationRepository.php`
  - findByUser()
  - findUnread()
  - getUnreadCount()
  - markAllRead()

## Phase 3: Services

### 3.1 Alert Service
- [ ] Implement `src/Services/AlertService.php`
  - [ ] create() - Create new alert
  - [ ] update() - Update alert criteria
  - [ ] delete() - Delete alert
  - [ ] toggle() - Toggle active status
  - [ ] findMatches() - Find matching properties
  - [ ] propertyMatchesCriteria() - Check single property
  - [ ] processNewProperty() - Process instant alerts
  - [ ] recordMatch() - Record alert-property match

### 3.2 Notification Service
- [ ] Implement `src/Services/NotificationService.php`
  - [ ] notify() - Create in-app notification
  - [ ] getUnreadCount() - Count unread
  - [ ] getRecent() - Get recent notifications
  - [ ] markAsRead() - Mark single as read
  - [ ] markAllRead() - Mark all as read
  - [ ] delete() - Delete notification

### 3.3 Email Queue Service
- [ ] Implement `src/Services/EmailQueueService.php`
  - [ ] queue() - Add to queue
  - [ ] processPending() - Process queue
  - [ ] send() - Send individual email
  - [ ] shouldSendEmail() - Check preferences
  - [ ] getFailedEmails() - Get failed for retry

### 3.4 Digest Service
- [ ] Implement `src/Services/DigestService.php`
  - [ ] sendDailyDigests() - Compile and send daily
  - [ ] sendWeeklyDigests() - Compile and send weekly
  - [ ] sendSellerWeeklyStats() - Seller statistics
  - [ ] getMatchesForAlert() - Get unnotified matches

## Phase 4: Notification Triggers

### 4.1 Property Events
- [ ] Trigger alert processing on property publish
- [ ] Trigger price change notification on update
- [ ] Trigger sold notification when marked sold

### 4.2 Inquiry Events
- [ ] Trigger email notification to seller
- [ ] Create in-app notification for seller

### 4.3 Listing Events
- [ ] Trigger listing live notification
- [ ] Schedule expiry warning (7 days before)
- [ ] Trigger expired notification

### 4.4 Subscription Events
- [ ] Trigger premium welcome email
- [ ] Schedule premium expiry warning
- [ ] Trigger premium expired notification

## Phase 5: Controllers

### 5.1 Alert Controller
- [ ] Implement `src/Controllers/AlertController.php`
  - [ ] index() - List user's alerts
  - [ ] create() - Show create form
  - [ ] store() - Save new alert
  - [ ] edit() - Show edit form
  - [ ] update() - Update alert
  - [ ] destroy() - Delete alert
  - [ ] toggle() - Toggle active status
  - Enforce premium-only access

### 5.2 Notification Controller
- [ ] Implement `src/Controllers/NotificationController.php`
  - [ ] index() - Notification history
  - [ ] recent() - API: recent notifications
  - [ ] markRead() - API: mark as read
  - [ ] markAllRead() - API: mark all read
  - [ ] preferences() - Preferences page
  - [ ] updatePreferences() - Save preferences
  - [ ] unsubscribe() - Handle unsubscribe link

## Phase 6: Templates

### 6.1 Alert Pages [P]
- [ ] Create `templates/alerts/index.php`
  - Alert cards with criteria summary
  - Toggle switches
  - Edit/Delete buttons
  - Create new button

- [ ] Create `templates/alerts/create.php`
  - Criteria form (mirrors search filters)
  - Frequency selector
  - Name input

- [ ] Create `templates/alerts/edit.php`
  - Pre-filled form
  - Update button
  - Delete option

### 6.2 Notification Pages
- [ ] Create `templates/notifications/index.php`
  - Full notification history
  - Pagination
  - Mark all read

- [ ] Create `templates/notifications/preferences.php`
  - Category sections
  - Toggle switches
  - Save button

### 6.3 Email Templates [P]
- [ ] Create `templates/emails/alerts/instant.php`
- [ ] Create `templates/emails/alerts/daily-digest.php`
- [ ] Create `templates/emails/alerts/weekly-digest.php`
- [ ] Create `templates/emails/price-change.php`
- [ ] Create `templates/emails/property-sold.php`
- [ ] Create `templates/emails/listing-status/live.php`
- [ ] Create `templates/emails/listing-status/expiring.php`
- [ ] Create `templates/emails/listing-status/expired.php`
- [ ] Create `templates/emails/listing-status/weekly-stats.php`

## Phase 7: JavaScript Components

### 7.1 Notification Bell
- [ ] Create `public/assets/js/components/notificationBell.js`
  - Bell icon click handler
  - Dropdown toggle
  - Recent notifications list
  - Badge update
  - Mark as read
  - Polling for updates

### 7.2 Alert Form
- [ ] Create `public/assets/js/components/alertForm.js`
  - Criteria selection
  - Preview updates
  - Form validation

### 7.3 Preferences Toggles
- [ ] Create `public/assets/js/components/preferenceToggles.js`
  - Toggle handling
  - AJAX save
  - Confirmation feedback

## Phase 8: Cron Jobs

### 8.1 Job Files [P]
- [ ] Create `cron/process-alerts.php` (every 5 min)
- [ ] Create `cron/daily-digest.php` (daily 8 AM)
- [ ] Create `cron/weekly-digest.php` (Monday 8 AM)
- [ ] Create `cron/process-email-queue.php` (every min)
- [ ] Create `cron/check-listing-expiry.php` (daily)
- [ ] Create `cron/cleanup-old-notifications.php` (weekly)

### 8.2 Documentation
- [ ] Document cron configuration
- [ ] Create example crontab entries

## Phase 9: Middleware

### 9.1 Premium Check
- [ ] Create `src/Middleware/PremiumMiddleware.php`
  - Check user subscription tier
  - Redirect non-premium users
  - Flash appropriate message

## Phase 10: Testing

### 10.1 Unit Tests [P]
- [ ] Test AlertService criteria matching
- [ ] Test NotificationService methods
- [ ] Test EmailQueueService processing
- [ ] Test DigestService compilation

### 10.2 Integration Tests
- [ ] Test alert creation flow
- [ ] Test notification creation on events
- [ ] Test email queue processing
- [ ] Test preference enforcement

### 10.3 Email Tests
- [ ] Test email template rendering
- [ ] Test unsubscribe functionality
- [ ] Test digest compilation

## Phase 11: Monitoring

### 11.1 Logging
- [ ] Log alert matches
- [ ] Log email send success/failure
- [ ] Track notification delivery stats

### 11.2 Admin Views (for 007)
- [ ] Email queue status view
- [ ] Failed emails view
- [ ] Alert statistics

## Legend
- [P] = Tasks can be executed in parallel
