# 003 - Property Listings Data Model

## Entity Relationship Diagram

```
┌──────────────────┐
│      users       │
└────────┬─────────┘
         │ 1:N
         ▼
┌──────────────────┐       ┌──────────────────┐
│    properties    │──────▶│ listing_drafts   │
├──────────────────┤       └──────────────────┘
│ id (PK)          │
│ user_id (FK)     │◀──┐
│ slug             │   │
│ title            │   │ 1:N
│ property_type    │   │
│ condition_type   │   │
│ description      │   │
│ price            │   │   ┌──────────────────┐
│ bedrooms         │   │   │    favorites     │
│ bathrooms        │   ├───├──────────────────┤
│ address fields   │   │   │ id (PK)          │
│ status           │   │   │ user_id (FK)     │
│ stats counters   │   │   │ property_id (FK) │
│ timestamps       │   │   └──────────────────┘
└────────┬─────────┘   │
         │             │
    ┌────┴────┐        │   ┌──────────────────┐
    │         │        │   │property_inquiries│
    │ 1:N     │ 1:N    │   ├──────────────────┤
    ▼         ▼        └───│ id (PK)          │
┌──────────┐ ┌──────────┐  │ property_id (FK) │
│property_ │ │property_ │  │ user_id (FK)     │
│ images   │ │ features │  │ name, email      │
└──────────┘ └──────────┘  │ message          │
                           └──────────────────┘
```

## Table Definitions

### properties

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT UNSIGNED | PK, AUTO_INCREMENT | Unique identifier |
| user_id | INT UNSIGNED | NOT NULL, FK | Owner reference |
| slug | VARCHAR(300) | NOT NULL, UNIQUE | URL-friendly identifier |
| title | VARCHAR(200) | NOT NULL | Property listing title |
| property_type | ENUM | NOT NULL | Type of property |
| condition_type | ENUM | NOT NULL | Renovation condition |
| description | TEXT | NOT NULL | Full description |
| price | DECIMAL(12,2) | NOT NULL | Asking price in GBP |
| price_qualifier | ENUM | DEFAULT 'guide-price' | Price type |
| bedrooms | TINYINT UNSIGNED | NOT NULL, DEFAULT 0 | Number of bedrooms |
| bathrooms | TINYINT UNSIGNED | NOT NULL, DEFAULT 0 | Number of bathrooms |
| living_area_sqft | INT UNSIGNED | NULL | Internal floor area |
| land_area_sqft | INT UNSIGNED | NULL | External land area |
| year_built | YEAR | NULL | Construction year |
| epc_rating | ENUM | DEFAULT 'unknown' | Energy rating |
| council_tax_band | ENUM | NULL | Tax band (A-H) |
| tenure | ENUM | NULL | Ownership type |
| lease_years_remaining | INT UNSIGNED | NULL | For leasehold |
| address_line_1 | VARCHAR(200) | NOT NULL | Street address |
| address_line_2 | VARCHAR(200) | NULL | Additional address |
| city | VARCHAR(100) | NOT NULL | City/town |
| county | VARCHAR(100) | NULL | County |
| postcode | VARCHAR(10) | NOT NULL | Full postcode |
| postcode_area | VARCHAR(4) | NOT NULL | Public postcode prefix |
| latitude | DECIMAL(10,8) | NULL | Geo coordinate |
| longitude | DECIMAL(11,8) | NULL | Geo coordinate |
| video_url | VARCHAR(500) | NULL | Video tour URL |
| virtual_tour_url | VARCHAR(500) | NULL | 360 tour URL |
| floor_plan_path | VARCHAR(500) | NULL | Floor plan file |
| status | ENUM | DEFAULT 'draft' | Listing status |
| is_premium | TINYINT(1) | DEFAULT 0 | Premium listing flag |
| premium_expires_at | TIMESTAMP | NULL | Premium expiry |
| viewing_notes | TEXT | NULL | Viewing availability |
| view_count | INT UNSIGNED | DEFAULT 0 | Page views |
| favorite_count | INT UNSIGNED | DEFAULT 0 | Favorites count |
| inquiry_count | INT UNSIGNED | DEFAULT 0 | Inquiries count |
| published_at | TIMESTAMP | NULL | First publish date |
| sold_at | TIMESTAMP | NULL | Sale date |
| deleted_at | TIMESTAMP | NULL | Soft delete |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Created |
| updated_at | TIMESTAMP | ON UPDATE CURRENT_TIMESTAMP | Modified |

**property_type ENUM Values:**
- `detached`, `semi-detached`, `terraced`, `end-terrace`
- `flat`, `maisonette`, `bungalow`, `cottage`
- `barn-conversion`, `commercial`, `land`, `other`

**condition_type ENUM Values:**
- `total-renovation` - Major work required
- `structural-issues` - Structural problems
- `needs-modernisation` - Dated interior
- `cosmetic-updates` - Light refresh
- `good-condition` - Move-in ready

**status ENUM Values:**
- `draft` - Being created
- `pending-payment` - Awaiting payment
- `active` - Live listing
- `paused` - Temporarily hidden
- `sold` - Marked as sold
- `deleted` - Soft deleted

**Indexes:**
- PRIMARY KEY (id)
- UNIQUE INDEX idx_slug (slug)
- INDEX idx_user (user_id)
- INDEX idx_status (status)
- INDEX idx_type (property_type)
- INDEX idx_condition (condition_type)
- INDEX idx_price (price)
- INDEX idx_bedrooms (bedrooms)
- INDEX idx_location (postcode_area, city)
- INDEX idx_premium (is_premium, published_at)
- FULLTEXT idx_search (title, description)

---

### property_images

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT UNSIGNED | PK, AUTO_INCREMENT | Unique identifier |
| property_id | INT UNSIGNED | NOT NULL, FK | Property reference |
| filename | VARCHAR(255) | NOT NULL | Stored filename |
| original_filename | VARCHAR(255) | NOT NULL | Upload filename |
| path | VARCHAR(500) | NOT NULL | Original file path |
| thumbnail_path | VARCHAR(500) | NULL | Thumbnail path |
| medium_path | VARCHAR(500) | NULL | Medium size path |
| large_path | VARCHAR(500) | NULL | Large size path |
| alt_text | VARCHAR(200) | NULL | Image description |
| sort_order | TINYINT UNSIGNED | DEFAULT 0 | Display order |
| is_primary | TINYINT(1) | DEFAULT 0 | Main image flag |
| file_size | INT UNSIGNED | NULL | File size in bytes |
| width | INT UNSIGNED | NULL | Image width |
| height | INT UNSIGNED | NULL | Image height |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Upload date |

**Indexes:**
- PRIMARY KEY (id)
- INDEX idx_property (property_id)
- INDEX idx_primary (property_id, is_primary)
- INDEX idx_sort (property_id, sort_order)

---

### property_features

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT UNSIGNED | PK, AUTO_INCREMENT | Unique identifier |
| property_id | INT UNSIGNED | NOT NULL, FK | Property reference |
| feature | VARCHAR(200) | NOT NULL | Feature text |
| sort_order | TINYINT UNSIGNED | DEFAULT 0 | Display order |

**Indexes:**
- PRIMARY KEY (id)
- INDEX idx_property (property_id)

---

### favorites

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT UNSIGNED | PK, AUTO_INCREMENT | Unique identifier |
| user_id | INT UNSIGNED | NOT NULL, FK | User reference |
| property_id | INT UNSIGNED | NOT NULL, FK | Property reference |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Favorited date |

**Indexes:**
- PRIMARY KEY (id)
- UNIQUE INDEX uk_user_property (user_id, property_id)
- INDEX idx_user (user_id)
- INDEX idx_property (property_id)

---

### property_inquiries

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT UNSIGNED | PK, AUTO_INCREMENT | Unique identifier |
| property_id | INT UNSIGNED | NOT NULL, FK | Property reference |
| user_id | INT UNSIGNED | NULL, FK | User if logged in |
| name | VARCHAR(100) | NOT NULL | Sender name |
| email | VARCHAR(255) | NOT NULL | Sender email |
| phone | VARCHAR(20) | NULL | Sender phone |
| message | TEXT | NOT NULL | Inquiry message |
| ip_address | VARCHAR(45) | NULL | Sender IP |
| is_read | TINYINT(1) | DEFAULT 0 | Read status |
| replied_at | TIMESTAMP | NULL | Reply timestamp |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Sent date |

**Indexes:**
- PRIMARY KEY (id)
- INDEX idx_property (property_id)
- INDEX idx_user (user_id)
- INDEX idx_read (is_read)

---

### listing_drafts

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT UNSIGNED | PK, AUTO_INCREMENT | Unique identifier |
| user_id | INT UNSIGNED | NOT NULL, FK, UNIQUE | User reference |
| current_step | TINYINT UNSIGNED | DEFAULT 1 | Wizard progress |
| data | JSON | NOT NULL | Draft form data |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Started date |
| updated_at | TIMESTAMP | ON UPDATE CURRENT_TIMESTAMP | Last saved |

**Indexes:**
- PRIMARY KEY (id)
- UNIQUE INDEX uk_user (user_id)

## Common Queries

### Search Properties with Filters
```sql
SELECT p.*, pi.thumbnail_path as primary_image
FROM properties p
LEFT JOIN property_images pi ON pi.property_id = p.id AND pi.is_primary = 1
WHERE p.status = 'active'
AND p.deleted_at IS NULL
AND (p.property_type = ? OR ? IS NULL)
AND (p.condition_type = ? OR ? IS NULL)
AND (p.bedrooms >= ? OR ? IS NULL)
AND (p.bathrooms >= ? OR ? IS NULL)
AND (p.price BETWEEN ? AND ?)
AND (p.postcode_area = ? OR p.city LIKE ? OR ? IS NULL)
ORDER BY p.is_premium DESC, p.published_at DESC
LIMIT ? OFFSET ?;
```

### Get Property with All Details
```sql
SELECT p.*, u.first_name, u.last_name
FROM properties p
JOIN users u ON u.id = p.user_id
WHERE p.slug = ?
AND p.status = 'active'
AND p.deleted_at IS NULL;

SELECT * FROM property_images
WHERE property_id = ?
ORDER BY sort_order ASC;

SELECT feature FROM property_features
WHERE property_id = ?
ORDER BY sort_order ASC;
```

### Get User's Favorites
```sql
SELECT p.*, pi.thumbnail_path, f.created_at as favorited_at
FROM favorites f
JOIN properties p ON p.id = f.property_id
LEFT JOIN property_images pi ON pi.property_id = p.id AND pi.is_primary = 1
WHERE f.user_id = ?
AND p.deleted_at IS NULL
ORDER BY f.created_at DESC;
```

### Get Similar Properties
```sql
SELECT p.*, pi.thumbnail_path
FROM properties p
LEFT JOIN property_images pi ON pi.property_id = p.id AND pi.is_primary = 1
WHERE p.id != ?
AND p.status = 'active'
AND p.deleted_at IS NULL
AND (
    p.postcode_area = ?
    OR p.property_type = ?
    OR ABS(p.price - ?) < ? * 0.2
)
ORDER BY
    (p.postcode_area = ?) DESC,
    (p.property_type = ?) DESC,
    ABS(p.price - ?) ASC
LIMIT 4;
```

### Increment View Count
```sql
UPDATE properties
SET view_count = view_count + 1
WHERE id = ?;
```

### Toggle Favorite
```sql
-- Check if exists
SELECT id FROM favorites
WHERE user_id = ? AND property_id = ?;

-- Insert if not exists
INSERT INTO favorites (user_id, property_id)
VALUES (?, ?);

-- Or delete if exists
DELETE FROM favorites
WHERE user_id = ? AND property_id = ?;

-- Update counter
UPDATE properties
SET favorite_count = (
    SELECT COUNT(*) FROM favorites WHERE property_id = ?
)
WHERE id = ?;
```
