# 003 - Property Listings Technical Plan

## Architecture Overview

The property listings feature uses a multi-table design to support flexible property attributes, efficient image handling, and inquiry management.

## Directory Structure

```
src/
├── Controllers/
│   ├── PropertyController.php
│   ├── PropertyListingController.php
│   ├── FavoriteController.php
│   └── InquiryController.php
├── Models/
│   ├── Property.php
│   ├── PropertyImage.php
│   ├── PropertyFeature.php
│   ├── PropertyInquiry.php
│   └── Favorite.php
├── Services/
│   ├── PropertyService.php
│   ├── ImageUploadService.php
│   ├── GeocodingService.php
│   └── PropertySearchService.php
└── Repositories/
    ├── PropertyRepository.php
    └── InquiryRepository.php

templates/
├── properties/
│   ├── index.php              # Listing grid
│   ├── show.php               # Property detail
│   └── partials/
│       ├── card.php           # Property card
│       ├── gallery.php        # Image gallery
│       ├── contact-form.php   # Inquiry form
│       └── similar.php        # Similar properties
├── listing/
│   ├── create/
│   │   ├── step-1.php         # Basic info
│   │   ├── step-2.php         # Details
│   │   ├── step-3.php         # Features
│   │   ├── step-4.php         # Images
│   │   ├── step-5.php         # Preview
│   │   └── step-6.php         # Payment
│   ├── edit.php
│   └── dashboard.php          # Seller listings
└── favorites/
    └── index.php
```

## Routing Configuration

| Route | Controller | Method | Middleware | Description |
|-------|------------|--------|------------|-------------|
| `GET /properties` | PropertyController | index | - | Property listing page |
| `GET /properties/{slug}` | PropertyController | show | - | Property detail page |
| `POST /properties/{id}/favorite` | FavoriteController | toggle | Auth | Toggle favorite |
| `GET /favorites` | FavoriteController | index | Auth | User's favorites |
| `POST /properties/{id}/inquiry` | InquiryController | store | Throttle | Send inquiry |
| `GET /sell` | PropertyListingController | create | Auth | Start listing |
| `GET /sell/step/{step}` | PropertyListingController | step | Auth | Listing wizard step |
| `POST /sell/step/{step}` | PropertyListingController | saveStep | Auth | Save step data |
| `GET /sell/preview` | PropertyListingController | preview | Auth | Preview listing |
| `POST /sell/submit` | PropertyListingController | submit | Auth | Submit listing |
| `GET /my-listings` | PropertyListingController | dashboard | Auth | Seller dashboard |
| `GET /my-listings/{id}/edit` | PropertyListingController | edit | Auth | Edit listing |
| `POST /my-listings/{id}` | PropertyListingController | update | Auth | Update listing |
| `POST /my-listings/{id}/pause` | PropertyListingController | pause | Auth | Pause listing |
| `POST /my-listings/{id}/unpause` | PropertyListingController | unpause | Auth | Unpause listing |
| `POST /my-listings/{id}/sold` | PropertyListingController | markSold | Auth | Mark as sold |
| `DELETE /my-listings/{id}` | PropertyListingController | delete | Auth | Delete listing |

## Database Schema

### properties
```sql
CREATE TABLE properties (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NOT NULL,
    slug VARCHAR(300) NOT NULL UNIQUE,
    title VARCHAR(200) NOT NULL,
    property_type ENUM('detached', 'semi-detached', 'terraced', 'end-terrace', 'flat', 'maisonette', 'bungalow', 'cottage', 'barn-conversion', 'commercial', 'land', 'other') NOT NULL,
    condition_type ENUM('total-renovation', 'structural-issues', 'needs-modernisation', 'cosmetic-updates', 'good-condition') NOT NULL,
    description TEXT NOT NULL,
    price DECIMAL(12, 2) NOT NULL,
    price_qualifier ENUM('offers-over', 'offers-around', 'guide-price', 'fixed-price') DEFAULT 'guide-price',
    bedrooms TINYINT UNSIGNED NOT NULL DEFAULT 0,
    bathrooms TINYINT UNSIGNED NOT NULL DEFAULT 0,
    living_area_sqft INT UNSIGNED,
    land_area_sqft INT UNSIGNED,
    year_built YEAR,
    epc_rating ENUM('A', 'B', 'C', 'D', 'E', 'F', 'G', 'unknown') DEFAULT 'unknown',
    council_tax_band ENUM('A', 'B', 'C', 'D', 'E', 'F', 'G', 'H') NULL,
    tenure ENUM('freehold', 'leasehold', 'share-of-freehold') NULL,
    lease_years_remaining INT UNSIGNED NULL,

    -- Address (full details stored, only partial shown publicly)
    address_line_1 VARCHAR(200) NOT NULL,
    address_line_2 VARCHAR(200),
    city VARCHAR(100) NOT NULL,
    county VARCHAR(100),
    postcode VARCHAR(10) NOT NULL,
    postcode_area VARCHAR(4) NOT NULL, -- For public display (e.g., "SW1")
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),

    -- Optional media
    video_url VARCHAR(500),
    virtual_tour_url VARCHAR(500),
    floor_plan_path VARCHAR(500),

    -- Status
    status ENUM('draft', 'pending-payment', 'active', 'paused', 'sold', 'deleted') DEFAULT 'draft',
    is_premium TINYINT(1) DEFAULT 0,
    premium_expires_at TIMESTAMP NULL,

    -- Viewing
    viewing_notes TEXT,

    -- Stats
    view_count INT UNSIGNED DEFAULT 0,
    favorite_count INT UNSIGNED DEFAULT 0,
    inquiry_count INT UNSIGNED DEFAULT 0,

    -- Timestamps
    published_at TIMESTAMP NULL,
    sold_at TIMESTAMP NULL,
    deleted_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user (user_id),
    INDEX idx_slug (slug),
    INDEX idx_status (status),
    INDEX idx_type (property_type),
    INDEX idx_condition (condition_type),
    INDEX idx_price (price),
    INDEX idx_bedrooms (bedrooms),
    INDEX idx_location (postcode_area, city),
    INDEX idx_premium (is_premium, published_at),
    FULLTEXT idx_search (title, description)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### property_images
```sql
CREATE TABLE property_images (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    property_id INT UNSIGNED NOT NULL,
    filename VARCHAR(255) NOT NULL,
    original_filename VARCHAR(255) NOT NULL,
    path VARCHAR(500) NOT NULL,
    thumbnail_path VARCHAR(500),
    medium_path VARCHAR(500),
    large_path VARCHAR(500),
    alt_text VARCHAR(200),
    sort_order TINYINT UNSIGNED DEFAULT 0,
    is_primary TINYINT(1) DEFAULT 0,
    file_size INT UNSIGNED,
    width INT UNSIGNED,
    height INT UNSIGNED,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (property_id) REFERENCES properties(id) ON DELETE CASCADE,
    INDEX idx_property (property_id),
    INDEX idx_primary (property_id, is_primary),
    INDEX idx_sort (property_id, sort_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### property_features
```sql
CREATE TABLE property_features (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    property_id INT UNSIGNED NOT NULL,
    feature VARCHAR(200) NOT NULL,
    sort_order TINYINT UNSIGNED DEFAULT 0,

    FOREIGN KEY (property_id) REFERENCES properties(id) ON DELETE CASCADE,
    INDEX idx_property (property_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### favorites
```sql
CREATE TABLE favorites (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NOT NULL,
    property_id INT UNSIGNED NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (property_id) REFERENCES properties(id) ON DELETE CASCADE,
    UNIQUE KEY uk_user_property (user_id, property_id),
    INDEX idx_user (user_id),
    INDEX idx_property (property_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### property_inquiries
```sql
CREATE TABLE property_inquiries (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    property_id INT UNSIGNED NOT NULL,
    user_id INT UNSIGNED NULL, -- NULL if guest inquiry
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    message TEXT NOT NULL,
    ip_address VARCHAR(45),
    is_read TINYINT(1) DEFAULT 0,
    replied_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (property_id) REFERENCES properties(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_property (property_id),
    INDEX idx_user (user_id),
    INDEX idx_read (is_read)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### listing_drafts
```sql
CREATE TABLE listing_drafts (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NOT NULL,
    current_step TINYINT UNSIGNED DEFAULT 1,
    data JSON NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY uk_user (user_id),
    INDEX idx_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

## Services

### ImageUploadService

```php
class ImageUploadService
{
    private const SIZES = [
        'thumbnail' => ['width' => 300, 'height' => 200],
        'medium' => ['width' => 800, 'height' => 600],
        'large' => ['width' => 1600, 'height' => 1200],
    ];

    public function upload(UploadedFile $file, int $propertyId): PropertyImage;
    public function generateThumbnails(string $sourcePath): array;
    public function convertToWebP(string $sourcePath): string;
    public function stripExifData(string $path): void;
    public function delete(PropertyImage $image): void;
}
```

### PropertySearchService

```php
class PropertySearchService
{
    public function search(array $filters, int $page = 1, int $perPage = 12): PaginatedResult;
    public function getSimilar(Property $property, int $limit = 4): array;
    public function getFeatured(int $limit = 8): array;
    public function getByLocation(string $location, int $limit = 12): array;
}
```

### GeocodingService

```php
class GeocodingService
{
    // Uses UK Postcodes API (free tier) for geocoding
    public function geocodePostcode(string $postcode): ?array;
    public function getPostcodeArea(string $postcode): string;
}
```

## Image Upload Flow

1. User drags/drops or selects images
2. JavaScript uploads each image via AJAX to `/api/listings/upload-image`
3. Server validates file type, size
4. Original stored in `storage/uploads/properties/{property_id}/original/`
5. Thumbnails generated asynchronously
6. EXIF data stripped
7. WebP version created
8. Database record created
9. Image URL returned to frontend
10. Frontend updates UI with preview

## Listing Wizard Steps

### Step 1: Basic Information
- Property title
- Property type
- Condition
- Year built (optional)

### Step 2: Location
- Address line 1 & 2
- City
- County
- Postcode (with lookup)
- Map confirmation

### Step 3: Details
- Bedrooms
- Bathrooms
- Living area
- Land area (optional)
- EPC rating
- Council tax band
- Tenure

### Step 4: Description
- Full description (rich text)
- Key features (add up to 10)
- Viewing notes

### Step 5: Media
- Photo uploads (5 min, 20 max)
- Video URL (optional)
- Virtual tour URL (optional)
- Floor plan upload (optional)

### Step 6: Pricing
- Asking price
- Price qualifier
- Accept terms
- Preview link

### Step 7: Payment
- Stripe/PayPal integration
- £25 listing fee
- Upgrade to premium option

## Frontend Components

### Image Gallery
```javascript
// components/propertyGallery.js
// - Thumbnail navigation
// - Main image display
// - Lightbox with zoom
// - Touch swipe support
// - Keyboard navigation
```

### Image Uploader
```javascript
// components/imageUploader.js
// - Drag and drop zone
// - File selection
// - Preview thumbnails
// - Progress indicators
// - Reorder with drag
// - Delete capability
// - Max file validation
```

### Listing Wizard
```javascript
// components/listingWizard.js
// - Step navigation
// - Form validation per step
// - Auto-save draft
// - Progress indicator
```

## SEO & Schema

```html
<script type="application/ld+json">
{
    "@context": "https://schema.org",
    "@type": "RealEstateListing",
    "name": "{{ property.title }}",
    "description": "{{ property.description }}",
    "image": ["{{ property.images }}"],
    "price": "{{ property.price }}",
    "priceCurrency": "GBP",
    "numberOfBedrooms": {{ property.bedrooms }},
    "numberOfBathroomsTotal": {{ property.bathrooms }},
    "floorSize": {
        "@type": "QuantitativeValue",
        "value": {{ property.living_area_sqft }},
        "unitCode": "FTK"
    },
    "address": {
        "@type": "PostalAddress",
        "addressLocality": "{{ property.city }}",
        "addressRegion": "{{ property.county }}",
        "postalCode": "{{ property.postcode_area }}"
    }
}
</script>
```
