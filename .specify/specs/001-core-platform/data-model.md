# 001 - Core Platform Data Model

## Entity Relationship Diagram

```
┌─────────────────────┐
│       pages         │
├─────────────────────┤
│ id (PK)             │
│ slug                │
│ title               │
│ content             │
│ meta_title          │
│ meta_description    │
│ created_at          │
│ updated_at          │
└─────────────────────┘

┌─────────────────────┐
│    blog_posts       │
├─────────────────────┤
│ id (PK)             │
│ slug                │
│ title               │
│ excerpt             │
│ content             │
│ featured_image      │
│ category            │
│ author_name         │
│ meta_title          │
│ meta_description    │
│ is_published        │
│ published_at        │
│ created_at          │
│ updated_at          │
└─────────────────────┘

┌─────────────────────┐
│ contact_submissions │
├─────────────────────┤
│ id (PK)             │
│ name                │
│ email               │
│ subject             │
│ message             │
│ ip_address          │
│ user_agent          │
│ is_read             │
│ created_at          │
└─────────────────────┘

┌─────────────────────────┐
│ newsletter_subscribers  │
├─────────────────────────┤
│ id (PK)                 │
│ email                   │
│ is_confirmed            │
│ confirmation_token      │
│ confirmed_at            │
│ unsubscribed_at         │
│ created_at              │
└─────────────────────────┘
```

## Table Definitions

### pages

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT UNSIGNED | PK, AUTO_INCREMENT | Unique identifier |
| slug | VARCHAR(100) | NOT NULL, UNIQUE | URL-friendly identifier |
| title | VARCHAR(200) | NOT NULL | Page title |
| content | LONGTEXT | NOT NULL | HTML content |
| meta_title | VARCHAR(200) | NULL | SEO title override |
| meta_description | VARCHAR(300) | NULL | SEO meta description |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Creation timestamp |
| updated_at | TIMESTAMP | ON UPDATE CURRENT_TIMESTAMP | Last modified timestamp |

**Indexes:**
- PRIMARY KEY (id)
- UNIQUE INDEX idx_slug (slug)

---

### blog_posts

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT UNSIGNED | PK, AUTO_INCREMENT | Unique identifier |
| slug | VARCHAR(200) | NOT NULL, UNIQUE | URL-friendly identifier |
| title | VARCHAR(300) | NOT NULL | Post title |
| excerpt | TEXT | NULL | Short summary for listings |
| content | LONGTEXT | NOT NULL | Full post content (HTML) |
| featured_image | VARCHAR(500) | NULL | Path to featured image |
| category | ENUM | NOT NULL | Post category |
| author_name | VARCHAR(100) | NULL | Author display name |
| meta_title | VARCHAR(200) | NULL | SEO title override |
| meta_description | VARCHAR(300) | NULL | SEO meta description |
| is_published | TINYINT(1) | DEFAULT 0 | Publication status |
| published_at | TIMESTAMP | NULL | Publication date |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Creation timestamp |
| updated_at | TIMESTAMP | ON UPDATE CURRENT_TIMESTAMP | Last modified timestamp |

**Category ENUM Values:**
- `buying-guides`
- `selling-tips`
- `renovation-advice`
- `market-insights`

**Indexes:**
- PRIMARY KEY (id)
- UNIQUE INDEX idx_slug (slug)
- INDEX idx_category (category)
- INDEX idx_published (is_published, published_at)

---

### contact_submissions

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT UNSIGNED | PK, AUTO_INCREMENT | Unique identifier |
| name | VARCHAR(100) | NOT NULL | Sender's name |
| email | VARCHAR(255) | NOT NULL | Sender's email |
| subject | VARCHAR(200) | NOT NULL | Message subject |
| message | TEXT | NOT NULL | Message content |
| ip_address | VARCHAR(45) | NULL | Sender's IP (IPv6 compatible) |
| user_agent | TEXT | NULL | Browser user agent |
| is_read | TINYINT(1) | DEFAULT 0 | Read status flag |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Submission timestamp |

**Indexes:**
- PRIMARY KEY (id)
- INDEX idx_created (created_at)
- INDEX idx_read (is_read)

---

### newsletter_subscribers

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT UNSIGNED | PK, AUTO_INCREMENT | Unique identifier |
| email | VARCHAR(255) | NOT NULL, UNIQUE | Subscriber email |
| is_confirmed | TINYINT(1) | DEFAULT 0 | Email confirmed flag |
| confirmation_token | VARCHAR(64) | NULL | Token for double opt-in |
| confirmed_at | TIMESTAMP | NULL | Confirmation timestamp |
| unsubscribed_at | TIMESTAMP | NULL | Unsubscribe timestamp |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Signup timestamp |

**Indexes:**
- PRIMARY KEY (id)
- UNIQUE INDEX idx_email (email)
- INDEX idx_confirmed (is_confirmed)

## Data Integrity Rules

1. **Soft Deletes**: Not implemented for core platform tables (pages and blog posts managed through admin)
2. **Cascading**: No foreign key relationships in core platform
3. **Character Set**: All tables use `utf8mb4_unicode_ci` for full Unicode support
4. **Engine**: All tables use InnoDB for transaction support

## Sample Data

### pages (Initial Seeds)

```sql
INSERT INTO pages (slug, title, content, meta_title, meta_description) VALUES
('about', 'About RenoRadar', '<h1>About Us</h1>...', 'About RenoRadar - Renovation Property Marketplace', 'Learn about RenoRadar...'),
('terms', 'Terms of Service', '<h1>Terms</h1>...', 'Terms of Service - RenoRadar', 'Read our terms...'),
('privacy', 'Privacy Policy', '<h1>Privacy</h1>...', 'Privacy Policy - RenoRadar', 'Your privacy matters...'),
('cookies', 'Cookie Policy', '<h1>Cookies</h1>...', 'Cookie Policy - RenoRadar', 'How we use cookies...');
```

### blog_posts (Sample Seeds)

```sql
INSERT INTO blog_posts (slug, title, excerpt, content, category, author_name, is_published, published_at) VALUES
('first-time-buyers-guide', 'First-Time Buyer''s Guide to Renovation Properties', 'Everything you need to know...', '...', 'buying-guides', 'RenoRadar Team', 1, NOW()),
('how-to-price-your-fixer-upper', 'How to Price Your Fixer-Upper for a Quick Sale', 'Pricing strategies...', '...', 'selling-tips', 'RenoRadar Team', 1, NOW());
```
