# 007 - Admin Dashboard Tasks

## Phase 1: Database Setup

### 1.1 Migrations
- [ ] Create `database/migrations/027_create_settings_table.php`
- [ ] Create `database/migrations/028_create_audit_logs_table.php`
- [ ] Run migrations

### 1.2 Seed Data
- [ ] Seed default settings
- [ ] Create initial admin user (or document creation process)

## Phase 2: Middleware & Security

### 2.1 Admin Middleware
- [ ] Implement `src/Middleware/AdminMiddleware.php`
  - Role check
  - Session timeout
  - Activity timestamp update

### 2.2 Route Registration
- [ ] Define all admin routes with prefix `/admin`
- [ ] Apply AdminMiddleware to all routes

## Phase 3: Models & Services

### 3.1 Models [P]
- [ ] Implement `src/Models/Setting.php`
  - Column mappings
  - Value casting
  - Group scope

- [ ] Implement `src/Models/AuditLog.php`
  - Column mappings
  - Admin relationship
  - Entity polymorphic accessor

### 3.2 Services [P]
- [ ] Implement `src/Services/SettingsService.php`
  - get() with caching
  - set()
  - getGroup()
  - clearCache()

- [ ] Implement `src/Services/AuditService.php`
  - log()
  - getRecent()
  - getByEntity()
  - cleanup()

- [ ] Implement `src/Services/ReportService.php`
  - getUserStats()
  - getListingStats()
  - getRevenueStats()
  - getTrends()
  - generateReport()

## Phase 4: Controllers

### 4.1 Dashboard Controller
- [ ] Implement `src/Controllers/Admin/DashboardController.php`
  - index() - Overview with stats

### 4.2 User Controller
- [ ] Implement `src/Controllers/Admin/UserController.php`
  - [ ] index() - User list with filters
  - [ ] show() - User detail
  - [ ] edit() - Edit form
  - [ ] update() - Save changes
  - [ ] suspend() - Suspend account
  - [ ] unsuspend() - Unsuspend account
  - [ ] destroy() - Delete user
  - [ ] impersonate() - Login as user
  - [ ] export() - CSV export

### 4.3 Listing Controller
- [ ] Implement `src/Controllers/Admin/ListingController.php`
  - [ ] index() - Listing list with filters
  - [ ] show() - Listing detail
  - [ ] edit() - Edit form
  - [ ] update() - Save changes
  - [ ] approve() - Approve pending
  - [ ] pause() - Pause listing
  - [ ] feature() - Feature on homepage
  - [ ] destroy() - Delete listing
  - [ ] export() - CSV export

### 4.4 Content Controller
- [ ] Implement `src/Controllers/Admin/ContentController.php`
  - [ ] pages() - Page list
  - [ ] editPage() - Edit page form
  - [ ] updatePage() - Save page
  - [ ] posts() - Post list
  - [ ] createPost() - Create post form
  - [ ] storePost() - Save new post
  - [ ] editPost() - Edit post form
  - [ ] updatePost() - Update post
  - [ ] destroyPost() - Delete post
  - [ ] faqs() - FAQ management

### 4.5 Payment Controller
- [ ] Implement `src/Controllers/Admin/PaymentController.php`
  - [ ] index() - Payment list
  - [ ] show() - Payment detail
  - [ ] refund() - Process refund
  - [ ] subscriptions() - Subscription list
  - [ ] cancelSubscription() - Cancel subscription

### 4.6 Inquiry Controller
- [ ] Implement `src/Controllers/Admin/InquiryController.php`
  - [ ] index() - Inquiry list
  - [ ] destroy() - Delete inquiry

### 4.7 Contact Controller
- [ ] Implement `src/Controllers/Admin/ContactController.php`
  - [ ] index() - Contact form submissions
  - [ ] markRead() - Mark as read
  - [ ] destroy() - Delete submission

### 4.8 Settings Controller
- [ ] Implement `src/Controllers/Admin/SettingsController.php`
  - [ ] index() - Settings form
  - [ ] update() - Save settings

### 4.9 Report Controller
- [ ] Implement `src/Controllers/Admin/ReportController.php`
  - [ ] index() - Reports overview
  - [ ] users() - User reports
  - [ ] listings() - Listing reports
  - [ ] revenue() - Revenue reports
  - [ ] search() - Search analytics
  - [ ] export() - Export to CSV

### 4.10 Audit Controller
- [ ] Implement `src/Controllers/Admin/AuditController.php`
  - [ ] index() - Audit log list

## Phase 5: Templates

### 5.1 Layout & Partials [P]
- [ ] Create `templates/admin/layouts/main.php`
- [ ] Create `templates/admin/partials/sidebar.php`
- [ ] Create `templates/admin/partials/header.php`
- [ ] Create `templates/admin/partials/stats-card.php`
- [ ] Create `templates/admin/partials/data-table.php`
- [ ] Create `templates/admin/partials/pagination.php`

### 5.2 Dashboard
- [ ] Create `templates/admin/dashboard/index.php`
  - Stats cards
  - Charts
  - Activity feed

### 5.3 User Management [P]
- [ ] Create `templates/admin/users/index.php`
- [ ] Create `templates/admin/users/show.php`
- [ ] Create `templates/admin/users/edit.php`

### 5.4 Listing Management [P]
- [ ] Create `templates/admin/listings/index.php`
- [ ] Create `templates/admin/listings/show.php`
- [ ] Create `templates/admin/listings/edit.php`

### 5.5 Content Management [P]
- [ ] Create `templates/admin/content/pages/index.php`
- [ ] Create `templates/admin/content/pages/edit.php`
- [ ] Create `templates/admin/content/posts/index.php`
- [ ] Create `templates/admin/content/posts/create.php`
- [ ] Create `templates/admin/content/posts/edit.php`
- [ ] Create `templates/admin/content/faqs/index.php`

### 5.6 Payment Management [P]
- [ ] Create `templates/admin/payments/index.php`
- [ ] Create `templates/admin/payments/show.php`
- [ ] Create `templates/admin/subscriptions/index.php`
- [ ] Create `templates/admin/subscriptions/show.php`

### 5.7 Other Sections [P]
- [ ] Create `templates/admin/inquiries/index.php`
- [ ] Create `templates/admin/contacts/index.php`
- [ ] Create `templates/admin/settings/index.php`
- [ ] Create `templates/admin/reports/index.php`
- [ ] Create `templates/admin/reports/users.php`
- [ ] Create `templates/admin/reports/listings.php`
- [ ] Create `templates/admin/reports/revenue.php`
- [ ] Create `templates/admin/reports/search.php`
- [ ] Create `templates/admin/audit/index.php`

## Phase 6: CSS & JavaScript

### 6.1 Admin Styles
- [ ] Create `public/assets/css/admin.css`
  - Sidebar styles
  - Header styles
  - Dashboard layout
  - Data tables
  - Form styles
  - Card styles

### 6.2 JavaScript Components [P]
- [ ] Create `public/assets/js/admin/dataTable.js`
  - Sorting
  - Selection
  - Bulk actions
  - Search

- [ ] Create `public/assets/js/admin/charts.js`
  - Line charts
  - Bar charts
  - Initialization

- [ ] Create `public/assets/js/admin/modals.js`
  - Confirmation modals
  - Quick edit modals

- [ ] Create `public/assets/js/admin/forms.js`
  - WYSIWYG editor init
  - Form validation
  - AJAX submission

## Phase 7: Audit Logging Integration

### 7.1 Integrate Audit Logging
- [ ] Add audit logging to UserController actions
- [ ] Add audit logging to ListingController actions
- [ ] Add audit logging to ContentController actions
- [ ] Add audit logging to PaymentController actions
- [ ] Add audit logging to SettingsController actions

## Phase 8: Export Functionality

### 8.1 CSV Exports
- [ ] Implement user export
- [ ] Implement listing export
- [ ] Implement payment export
- [ ] Implement report exports

## Phase 9: Testing

### 9.1 Access Control Tests
- [ ] Test non-admin access denied
- [ ] Test admin access granted
- [ ] Test session timeout

### 9.2 Functional Tests [P]
- [ ] Test user management CRUD
- [ ] Test listing management CRUD
- [ ] Test content management CRUD
- [ ] Test settings update
- [ ] Test audit logging

### 9.3 UI Tests
- [ ] Test data table interactions
- [ ] Test bulk actions
- [ ] Test charts loading
- [ ] Test responsive layout

## Phase 10: Documentation

### 10.1 Admin Documentation
- [ ] Document admin access setup
- [ ] Document available settings
- [ ] Document admin workflows
- [ ] Create admin user guide

## Legend
- [P] = Tasks can be executed in parallel
