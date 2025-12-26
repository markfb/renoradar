# 007 - Admin Dashboard Specification

## Overview

The admin dashboard provides platform administrators with tools to manage users, listings, content, payments, and monitor platform health.

## User Stories

### US-070: Admin Authentication
**As an** administrator
**I want to** access a secure admin area
**So that I** can manage the platform

#### Acceptance Criteria
- [ ] Separate admin login page (or role-based access)
- [ ] Two-factor authentication option
- [ ] Session timeout after inactivity (30 minutes)
- [ ] Admin activity logging
- [ ] IP whitelist option

### US-071: Dashboard Overview
**As an** administrator
**I want to** see a platform overview
**So that I** can monitor health at a glance

#### Acceptance Criteria
- [ ] Key metrics cards:
  - Total users (new this week/month)
  - Total listings (active/pending)
  - Revenue (this month/all time)
  - Active subscriptions
- [ ] Charts:
  - User registrations over time
  - Listings over time
  - Revenue trend
- [ ] Recent activity feed
- [ ] System alerts (failed payments, errors)

### US-072: User Management
**As an** administrator
**I want to** manage platform users
**So that I** can handle support issues and violations

#### Acceptance Criteria
- [ ] User list with search and filters
- [ ] Filter by: role, subscription, status, date range
- [ ] View user details:
  - Profile information
  - Subscription status
  - Listings (if seller)
  - Favorites
  - Activity log
- [ ] Actions:
  - Edit user details
  - Change role
  - Reset password
  - Suspend account
  - Unsuspend account
  - Delete account
  - Impersonate user (login as)
- [ ] Export users to CSV

### US-073: Listing Management
**As an** administrator
**I want to** manage property listings
**So that I** can ensure quality and handle issues

#### Acceptance Criteria
- [ ] Listing list with search and filters
- [ ] Filter by: status, type, condition, date, price range
- [ ] View listing details:
  - All property information
  - Images
  - Seller info
  - View/favorite/inquiry stats
  - Payment history
- [ ] Actions:
  - Edit listing
  - Approve pending listings (if moderation enabled)
  - Pause/unpause listing
  - Mark as sold
  - Delete listing
  - Feature on homepage
  - Remove feature
- [ ] Bulk actions (select multiple)
- [ ] Export listings to CSV

### US-074: Content Management
**As an** administrator
**I want to** manage site content
**So that I** can keep pages and blog posts updated

#### Acceptance Criteria
- [ ] Page management:
  - List all pages
  - Edit page content (WYSIWYG)
  - Update meta tags
- [ ] Blog post management:
  - List all posts
  - Create new post
  - Edit existing post
  - Publish/unpublish
  - Delete post
  - Category management
- [ ] FAQ management:
  - Add/edit/delete FAQ items
  - Reorder FAQs
- [ ] Email template preview

### US-075: Payment & Subscription Management
**As an** administrator
**I want to** manage payments and subscriptions
**So that I** can handle billing issues

#### Acceptance Criteria
- [ ] Payment history list
- [ ] Filter by: status, type, date range, user
- [ ] View payment details:
  - PayPal transaction info
  - Associated user/listing
  - Invoice
- [ ] Actions:
  - Issue refund (via PayPal)
  - Mark as disputed
  - Add admin notes
- [ ] Subscription list
- [ ] View subscription details
- [ ] Actions:
  - Cancel subscription
  - Extend subscription (grace period)
  - Add notes
- [ ] Revenue reports
- [ ] Export transactions to CSV

### US-076: Inquiry Management
**As an** administrator
**I want to** monitor property inquiries
**So that I** can ensure communication is working

#### Acceptance Criteria
- [ ] Inquiry list
- [ ] Filter by: date, property, read status
- [ ] View inquiry details
- [ ] Flag problematic inquiries
- [ ] Bulk delete spam inquiries

### US-077: Contact Form Management
**As an** administrator
**I want to** manage contact form submissions
**So that I** can respond to user queries

#### Acceptance Criteria
- [ ] Submission list with unread count
- [ ] Mark as read/unread
- [ ] Reply directly (opens email)
- [ ] Delete submissions
- [ ] Archive submissions

### US-078: System Settings
**As an** administrator
**I want to** configure platform settings
**So that I** can customize behavior

#### Acceptance Criteria
- [ ] General settings:
  - Site name
  - Contact email
  - Support phone
- [ ] Listing settings:
  - Listing fee amount
  - Premium listing fee
  - Listing duration (months)
  - Moderation on/off
- [ ] Subscription settings:
  - Monthly price
  - Annual price
  - Trial period (if any)
- [ ] Email settings:
  - From address
  - Reply-to address
  - Email footer text
- [ ] SEO settings:
  - Default meta title
  - Default meta description
  - Google Analytics ID
- [ ] Maintenance mode toggle

### US-079: Reports & Analytics
**As an** administrator
**I want to** view platform reports
**So that I** can make data-driven decisions

#### Acceptance Criteria
- [ ] User reports:
  - Registration trends
  - Conversion rate (free to premium)
  - Churn rate
- [ ] Listing reports:
  - Listings by region
  - Listings by type
  - Listings by condition
  - Average time to sale
- [ ] Revenue reports:
  - Monthly revenue
  - Revenue by product type
  - Subscription MRR
- [ ] Search reports:
  - Popular search terms
  - Zero-result queries
  - Popular locations
- [ ] Export all reports to CSV

### US-080: Audit Logs
**As an** administrator
**I want to** view audit logs
**So that I** can track admin actions

#### Acceptance Criteria
- [ ] Log of all admin actions
- [ ] Filter by: admin user, action type, date
- [ ] Details for each action
- [ ] Log retention policy

## Non-Functional Requirements

### Security
- Admin-only access enforced
- All actions logged
- Sensitive actions require confirmation
- Session security (timeout, IP validation)
- No direct database access through UI

### Usability
- Responsive design (tablet-friendly)
- Clear navigation
- Confirmation dialogs for destructive actions
- Bulk action support
- Quick search across entities

### Performance
- Dashboard loads < 2 seconds
- Large lists paginated
- Charts load asynchronously
- Export handles large datasets

## UI Components Required

1. **Admin Sidebar Navigation**
   - Collapsible menu
   - Icon + label items
   - Active state indicator
   - User info footer

2. **Stats Cards**
   - Large number display
   - Comparison to previous period
   - Trend indicator

3. **Data Tables**
   - Sortable columns
   - Filter dropdowns
   - Bulk selection
   - Pagination
   - Actions column

4. **Charts**
   - Line charts for trends
   - Bar charts for comparisons
   - Pie charts for distributions

5. **Modal Dialogs**
   - Confirmation modals
   - Quick edit modals
   - Detail view modals

6. **WYSIWYG Editor**
   - Rich text editing
   - Image upload
   - HTML source view

7. **Activity Feed**
   - Timestamped entries
   - User/action context
   - Load more pagination
