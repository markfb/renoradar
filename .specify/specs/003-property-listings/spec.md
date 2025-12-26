# 003 - Property Listings Specification

## Overview

The property listings feature is the core of RenoRadar, enabling sellers to list renovation-ready properties and buyers to browse, save, and inquire about them.

## User Stories

### Seller Stories

### US-020: List Property
**As a** seller
**I want to** list my property on RenoRadar
**So that I** can connect with buyers looking for renovation projects

#### Acceptance Criteria
- [ ] Multi-step listing form with progress indicator
- [ ] Save draft functionality (progress saved between sessions)
- [ ] Required fields:
  - Property title
  - Property type (House, Flat, Bungalow, etc.)
  - Address with postcode lookup
  - Number of bedrooms (0-10+)
  - Number of bathrooms (0-10+)
  - Living area (sq ft or sq m)
  - Land area (optional)
  - Property condition (Needs Total Renovation, Needs Modernisation, Structural Issues, Cosmetic Updates, Good Condition)
  - Asking price
  - Property description (min 100 characters)
  - Key features (at least 3)
  - EPC rating (A-G or Unknown)
  - At least 5 photos (max 20)
- [ ] Optional fields:
  - Video tour URL
  - Floor plan upload
  - Virtual tour link
  - Year built
  - Council tax band
  - Tenure (Freehold/Leasehold)
  - Viewing availability
- [ ] Image upload with drag-and-drop
- [ ] Image reordering capability
- [ ] Preview before submission
- [ ] Terms acceptance for listing
- [ ] Payment required before listing goes live (£25)

### US-021: Manage Listings
**As a** seller
**I want to** manage my property listings
**So that I** I can update information or remove listings

#### Acceptance Criteria
- [ ] Dashboard showing all my listings with status
- [ ] Edit listing capability
- [ ] Pause listing (temporarily hide from search)
- [ ] Unpause listing (make visible again)
- [ ] Mark as sold (removes from active search, shows "Sold" badge)
- [ ] Delete listing (soft delete with 30-day recovery)
- [ ] View statistics per listing:
  - Views count
  - Favorites count
  - Inquiry count
- [ ] Upgrade to premium listing option

### US-022: Premium Listing
**As a** seller
**I want to** upgrade to a premium listing
**So that I** my property gets more visibility

#### Acceptance Criteria
- [ ] Premium badge on listing
- [ ] Featured placement in search results
- [ ] Highlighted in carousel on homepage
- [ ] Priority in category pages
- [ ] Monthly subscription (£20/month)
- [ ] Cancel anytime

### Buyer Stories

### US-030: Browse Properties
**As a** buyer
**I want to** browse available properties
**So that I** can find suitable renovation projects

#### Acceptance Criteria
- [ ] Property grid/list view toggle
- [ ] Pagination (12 properties per page default)
- [ ] Sort options:
  - Newest first (default)
  - Price: Low to High
  - Price: High to Low
  - Most viewed
- [ ] Property cards showing:
  - Main image
  - Price
  - Title/Address (partial)
  - Bedrooms/Bathrooms
  - Property type
  - Condition badge
  - Premium badge (if applicable)
  - Favorite button (logged-in users)
  - New badge (if listed within 7 days)

### US-031: View Property Details
**As a** buyer
**I want to** view full property details
**So that I** can evaluate if it meets my needs

#### Acceptance Criteria
- [ ] Full image gallery with lightbox
- [ ] All property information displayed clearly
- [ ] Key features list
- [ ] Full description
- [ ] Location map (without exact address for privacy)
- [ ] EPC rating display
- [ ] Property condition explanation
- [ ] Similar properties suggestions
- [ ] Share buttons (social media, copy link)
- [ ] Print-friendly view option
- [ ] Save to favorites (logged-in users)
- [ ] Contact seller form
- [ ] View counter increment

### US-032: Save Favorites
**As a** logged-in buyer
**I want to** save properties to my favorites
**So that I** can easily find them later

#### Acceptance Criteria
- [ ] Heart icon toggle on property cards and detail pages
- [ ] Favorites list in user dashboard
- [ ] Remove from favorites functionality
- [ ] Sort favorites by date added
- [ ] Notification if favorited property price changes
- [ ] Notification if favorited property is sold

### US-033: Contact Seller
**As a** buyer
**I want to** contact a property seller
**So that I** can arrange a viewing or ask questions

#### Acceptance Criteria
- [ ] Contact form on property detail page
- [ ] Fields: Name, Email, Phone (optional), Message
- [ ] Pre-filled fields for logged-in users
- [ ] Copy sent to buyer's email
- [ ] Rate limiting (max 5 inquiries per hour)
- [ ] CAPTCHA for non-logged-in users
- [ ] Seller receives email notification
- [ ] Inquiry logged in seller dashboard

## Non-Functional Requirements

### Performance
- Property list page load < 2 seconds
- Image gallery loads progressively
- Lazy loading for off-screen images

### SEO
- SEO-friendly URLs: `/properties/[slug]`
- Schema.org RealEstateListing markup
- Meta tags with property details
- Breadcrumb navigation

### Image Handling
- Accept: JPG, PNG, WebP
- Max file size: 10MB per image
- Auto-resize to multiple resolutions (thumbnail, medium, large, original)
- WebP conversion for optimization
- Watermark option for premium listings
- EXIF data stripping for privacy

### Privacy
- Exact address hidden from public (only area/postcode prefix shown)
- Full address revealed only after seller approval
- Seller contact details never publicly displayed

## Property Types

| Type | Description |
|------|-------------|
| Detached House | Stand-alone residential house |
| Semi-Detached | House attached to one other house |
| Terraced | House in a row of houses |
| End Terrace | End house of a terrace row |
| Flat/Apartment | Unit in a multi-unit building |
| Maisonette | Flat across two floors |
| Bungalow | Single-story house |
| Cottage | Small rural house |
| Barn Conversion | Converted agricultural building |
| Commercial | Commercial property |
| Land | Land only, no building |
| Other | Other property type |

## Property Conditions

| Condition | Description | Badge Color |
|-----------|-------------|-------------|
| Needs Total Renovation | Major structural and interior work required | Red |
| Structural Issues | Foundation, roof, or major structural work needed | Orange |
| Needs Modernisation | Dated but liveable, needs updating | Yellow |
| Cosmetic Updates | Minor decorative work only | Blue |
| Good Condition | Move-in ready, light updates optional | Green |

## UI Components Required

1. **Property Card Component**
   - Image with lazy loading
   - Price badge
   - Condition badge
   - Favorite toggle
   - Quick stats (beds, baths, size)

2. **Property Gallery Component**
   - Thumbnail strip
   - Main image display
   - Lightbox modal
   - Image counter
   - Navigation arrows

3. **Property Listing Form**
   - Multi-step wizard
   - Progress indicator
   - Drag-and-drop image upload
   - Address autocomplete
   - Rich text editor for description

4. **Contact Seller Form**
   - Standard form fields
   - Auto-fill for logged-in users
   - Success/error states

5. **Property Map Component**
   - Static map showing approximate area
   - No exact pin (privacy)

6. **Similar Properties Grid**
   - 3-4 related property cards
   - Based on location/price/type
