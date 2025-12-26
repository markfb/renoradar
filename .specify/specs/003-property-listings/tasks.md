# 003 - Property Listings Tasks

## Phase 1: Database Setup

### 1.1 Migrations
- [ ] Create `database/migrations/009_create_properties_table.php`
- [ ] Create `database/migrations/010_create_property_images_table.php`
- [ ] Create `database/migrations/011_create_property_features_table.php`
- [ ] Create `database/migrations/012_create_favorites_table.php`
- [ ] Create `database/migrations/013_create_property_inquiries_table.php`
- [ ] Create `database/migrations/014_create_listing_drafts_table.php`
- [ ] Run migrations and verify schema

## Phase 2: Models & Repositories

### 2.1 Models [P]
- [ ] Implement `src/Models/Property.php`
  - All column mappings
  - Relationships (user, images, features)
  - Accessors (getFullAddress, getPrimaryImage, getFormattedPrice)
  - Scopes (active, premium, byLocation)

- [ ] Implement `src/Models/PropertyImage.php`
  - Column mappings
  - Relationship to property
  - URL accessor methods

- [ ] Implement `src/Models/PropertyFeature.php`
  - Column mappings
  - Relationship to property

- [ ] Implement `src/Models/Favorite.php`
  - Column mappings
  - Relationships

- [ ] Implement `src/Models/PropertyInquiry.php`
  - Column mappings
  - Relationships

### 2.2 Repositories
- [ ] Implement `src/Repositories/PropertyRepository.php`
  - findBySlug()
  - findByUser()
  - search() with filters
  - getSimilar()
  - getFeatured()
  - incrementViewCount()

- [ ] Implement `src/Repositories/InquiryRepository.php`
  - findByProperty()
  - findByUser()
  - markAsRead()

## Phase 3: Services

### 3.1 Image Service
- [ ] Implement `src/Services/ImageUploadService.php`
  - [ ] upload() - Handle file upload
  - [ ] validate() - Check type, size, dimensions
  - [ ] generateThumbnails() - Create resized versions
  - [ ] convertToWebP() - WebP optimization
  - [ ] stripExifData() - Privacy protection
  - [ ] delete() - Remove all versions
  - [ ] reorder() - Update sort order

### 3.2 Property Service
- [ ] Implement `src/Services/PropertyService.php`
  - [ ] create() - Create new listing
  - [ ] update() - Update existing listing
  - [ ] publish() - Activate listing
  - [ ] pause() / unpause()
  - [ ] markSold()
  - [ ] delete() - Soft delete
  - [ ] generateSlug()

### 3.3 Search Service
- [ ] Implement `src/Services/PropertySearchService.php`
  - [ ] search() - Full-text and filter search
  - [ ] buildFilters() - Convert request to SQL
  - [ ] getSimilar() - Find related properties
  - [ ] getFeatured() - Get premium/recent

### 3.4 Geocoding Service
- [ ] Implement `src/Services/GeocodingService.php`
  - [ ] geocodePostcode() - Get lat/lng from postcode
  - [ ] getPostcodeArea() - Extract prefix for privacy
  - [ ] validatePostcode() - UK postcode validation

## Phase 4: Controllers

### 4.1 Property Browsing [P]
- [ ] Implement `src/Controllers/PropertyController.php`
  - [ ] index() - Property grid with filters
  - [ ] show() - Property detail page
  - [ ] Increment view counter

- [ ] Implement `src/Controllers/FavoriteController.php`
  - [ ] index() - User's favorites list
  - [ ] toggle() - Add/remove favorite

- [ ] Implement `src/Controllers/InquiryController.php`
  - [ ] store() - Send inquiry to seller
  - [ ] Validation and rate limiting
  - [ ] Email notifications

### 4.2 Property Listing
- [ ] Implement `src/Controllers/PropertyListingController.php`
  - [ ] create() - Start listing wizard
  - [ ] step() - Display wizard step
  - [ ] saveStep() - Save step data to draft
  - [ ] preview() - Preview before payment
  - [ ] submit() - Finalize and pay
  - [ ] dashboard() - Seller's listings
  - [ ] edit() - Edit existing listing
  - [ ] update() - Save changes
  - [ ] pause() / unpause()
  - [ ] markSold()
  - [ ] delete()

### 4.3 API Endpoints
- [ ] Implement `src/Controllers/Api/PropertyImageController.php`
  - [ ] upload() - AJAX image upload
  - [ ] delete() - Remove image
  - [ ] reorder() - Update image order

## Phase 5: Templates

### 5.1 Property Browsing [P]
- [ ] Create `templates/properties/index.php`
  - Grid/list toggle
  - Filter sidebar
  - Pagination
  - Sort dropdown

- [ ] Create `templates/properties/show.php`
  - Full property detail layout
  - Image gallery
  - Contact form
  - Similar properties

- [ ] Create `templates/properties/partials/card.php`
  - Property card component

- [ ] Create `templates/properties/partials/gallery.php`
  - Image gallery with lightbox

- [ ] Create `templates/properties/partials/contact-form.php`
  - Inquiry form

- [ ] Create `templates/properties/partials/similar.php`
  - Similar properties grid

### 5.2 Listing Wizard [P]
- [ ] Create `templates/listing/create/step-1.php` - Basic info
- [ ] Create `templates/listing/create/step-2.php` - Location
- [ ] Create `templates/listing/create/step-3.php` - Details
- [ ] Create `templates/listing/create/step-4.php` - Description
- [ ] Create `templates/listing/create/step-5.php` - Media
- [ ] Create `templates/listing/create/step-6.php` - Pricing
- [ ] Create `templates/listing/create/step-7.php` - Payment
- [ ] Create `templates/listing/preview.php`
- [ ] Create `templates/listing/edit.php`
- [ ] Create `templates/listing/dashboard.php`

### 5.3 Favorites
- [ ] Create `templates/favorites/index.php`
  - Favorited properties grid
  - Remove buttons

## Phase 6: JavaScript Components

### 6.1 Gallery [P]
- [ ] Create `public/assets/js/components/propertyGallery.js`
  - Thumbnail navigation
  - Lightbox modal
  - Zoom capability
  - Touch swipe
  - Keyboard controls

- [ ] Create `public/assets/js/components/imageUploader.js`
  - Drag and drop zone
  - File selection
  - Upload progress
  - Preview display
  - Drag reorder
  - Delete button

### 6.2 Listing
- [ ] Create `public/assets/js/components/listingWizard.js`
  - Step navigation
  - Form validation
  - Draft auto-save
  - Progress indicator

- [ ] Create `public/assets/js/components/postcodeSearch.js`
  - Postcode lookup
  - Address autofill

### 6.3 Browsing
- [ ] Create `public/assets/js/components/propertyFilters.js`
  - Filter form handling
  - AJAX filter updates (optional)
  - URL parameter sync

- [ ] Create `public/assets/js/components/favoriteToggle.js`
  - AJAX favorite toggle
  - Heart icon animation

## Phase 7: Email Templates

### 7.1 Property Emails [P]
- [ ] Create `templates/emails/inquiry-received.php` - To seller
- [ ] Create `templates/emails/inquiry-confirmation.php` - To buyer
- [ ] Create `templates/emails/listing-published.php` - To seller
- [ ] Create `templates/emails/listing-expiring.php` - To seller
- [ ] Create `templates/emails/property-sold.php` - To favorited users

## Phase 8: SEO & Schema

### 8.1 Structured Data
- [ ] Implement RealEstateListing schema in property show page
- [ ] Implement BreadcrumbList schema
- [ ] Add OpenGraph tags for social sharing

### 8.2 Sitemap
- [ ] Add property pages to XML sitemap generator
- [ ] Implement lastmod dates

## Phase 9: Testing

### 9.1 Unit Tests [P]
- [ ] Test PropertyService methods
- [ ] Test ImageUploadService methods
- [ ] Test PropertySearchService filters
- [ ] Test slug generation

### 9.2 Integration Tests
- [ ] Test complete listing creation flow
- [ ] Test image upload flow
- [ ] Test favorite toggling
- [ ] Test inquiry submission
- [ ] Test search with various filters

### 9.3 UI Tests
- [ ] Test image gallery on mobile
- [ ] Test listing wizard navigation
- [ ] Test image uploader drag/drop
- [ ] Test responsive property grid

## Phase 10: Sample Data

### 10.1 Seeds
- [ ] Create sample properties with variety of types/conditions
- [ ] Generate sample images
- [ ] Create sample features
- [ ] Add sample inquiries for testing

## Legend
- [P] = Tasks can be executed in parallel
