# 006 - Alerts & Notifications Specification

## Overview

The alerts and notifications system enables users to receive timely updates about properties matching their criteria, price changes on favorited properties, and other platform communications.

## User Stories

### US-060: Property Alerts for Premium Users
**As a** premium subscriber
**I want to** receive alerts when new properties match my criteria
**So that I** can act quickly on new opportunities

#### Acceptance Criteria
- [ ] Create alerts based on saved searches
- [ ] Alert criteria includes:
  - Location (city, county, postcode area)
  - Property type (multi-select)
  - Condition (multi-select)
  - Price range (min/max)
  - Bedroom range (min/max)
- [ ] Alert frequency options:
  - Instant (email within 5 minutes)
  - Daily digest (once per day)
  - Weekly digest (once per week)
- [ ] Maximum 10 alerts per user
- [ ] Toggle alerts on/off without deleting
- [ ] Edit alert criteria
- [ ] Delete alerts
- [ ] Unsubscribe link in all emails

### US-061: Early Access Alerts
**As a** premium subscriber
**I want to** get notified before properties go public
**So that I** have first-mover advantage

#### Acceptance Criteria
- [ ] Premium users receive alerts 24 hours before general listing
- [ ] Property marked as "Coming Soon" during early access period
- [ ] Email includes property preview and quick-view link
- [ ] Respects user's alert criteria settings

### US-062: Price Change Notifications
**As a** user with favorited properties
**I want to** be notified when prices change
**So that I** can spot opportunities

#### Acceptance Criteria
- [ ] Email sent when favorited property price changes
- [ ] Shows old price vs. new price
- [ ] Includes direct link to property
- [ ] User can opt-out of price notifications
- [ ] Maximum one email per property per day

### US-063: Property Sold Notifications
**As a** user with favorited properties
**I want to** be notified when a property is sold
**So that I** can remove it from my list

#### Acceptance Criteria
- [ ] Email sent when favorited property marked sold
- [ ] Suggests similar properties
- [ ] One-click unfavorite option
- [ ] User can opt-out of sold notifications

### US-064: Inquiry Notifications for Sellers
**As a** property seller
**I want to** receive notifications for inquiries
**So that I** can respond promptly to buyers

#### Acceptance Criteria
- [ ] Email notification for each inquiry
- [ ] Includes buyer's message and contact info
- [ ] Quick reply link (opens email client)
- [ ] In-app notification badge
- [ ] Dashboard shows unread inquiry count

### US-065: Listing Status Notifications
**As a** property seller
**I want to** receive updates about my listing
**So that I** know when action is needed

#### Acceptance Criteria
- [ ] Notification when listing goes live
- [ ] Notification for listing expiry warning (7 days before)
- [ ] Notification when listing expires
- [ ] Weekly stats summary (views, favorites, inquiries)
- [ ] Notification when premium listing expires

### US-066: Notification Preferences
**As a** user
**I want to** control my notification settings
**So that I** receive only relevant communications

#### Acceptance Criteria
- [ ] Preferences page in account settings
- [ ] Toggle for each notification type:
  - Property alerts (premium only)
  - Price change notifications
  - Sold notifications
  - Inquiry notifications (sellers)
  - Listing updates (sellers)
  - Marketing emails
  - Newsletter
- [ ] Global unsubscribe option
- [ ] Preferences persist across sessions

### US-067: In-App Notifications
**As a** logged-in user
**I want to** see notifications in the platform
**So that I** stay informed while browsing

#### Acceptance Criteria
- [ ] Notification bell icon in header
- [ ] Badge with unread count
- [ ] Dropdown showing recent notifications
- [ ] Mark as read functionality
- [ ] Mark all as read option
- [ ] Link to full notification history
- [ ] Notification types with icons

## Non-Functional Requirements

### Performance
- Instant alerts sent within 5 minutes of trigger
- Daily/weekly digests sent at consistent times
- Notification bell updates without page refresh

### Deliverability
- SPF/DKIM/DMARC configured for email domain
- Unsubscribe link in all marketing emails
- Honor unsubscribe within 24 hours
- Monitor bounce rates

### Privacy
- Users control all notification preferences
- Easy opt-out from any communication
- GDPR-compliant consent management

## Notification Types

| Type | Trigger | Recipients | Channel |
|------|---------|------------|---------|
| Property Match | New listing matches alert | Premium users | Email |
| Early Access | Property in early access | Premium users | Email |
| Price Change | Favorited property price changes | Users with favorite | Email |
| Property Sold | Favorited property marked sold | Users with favorite | Email |
| New Inquiry | Buyer sends inquiry | Property seller | Email + In-app |
| Listing Live | Property published | Seller | Email |
| Listing Expiring | 7 days until expiry | Seller | Email |
| Listing Expired | Listing expired | Seller | Email |
| Weekly Stats | Weekly summary | Seller | Email |
| Premium Expiring | 7 days until premium ends | Subscriber | Email |

## UI Components Required

1. **Alert Creation Form**
   - Criteria fields (mirroring search filters)
   - Frequency selector
   - Name input
   - Save button

2. **Alert List Component**
   - Alert cards with criteria summary
   - Toggle switch for active/inactive
   - Edit/Delete buttons
   - Create new alert button

3. **Notification Bell**
   - Icon with badge count
   - Dropdown with recent notifications
   - Notification item component
   - View all link

4. **Notification Preferences Page**
   - Category sections
   - Toggle switches for each type
   - Save button
   - Global unsubscribe option

5. **Email Templates**
   - Property alert email
   - Digest email (multiple properties)
   - Price change email
   - Inquiry notification email
   - Listing status emails
