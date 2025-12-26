# 001 - Core Platform Technical Plan

## Architecture Overview

The core platform implements a lightweight MVC architecture without heavy frameworks, optimized for shared PHP hosting environments while maintaining clean, maintainable code.

## Directory Structure

```
public/
├── index.php                 # Front controller
├── assets/
│   ├── css/
│   │   ├── app.css          # Compiled Tailwind CSS
│   │   └── custom.css       # Custom overrides
│   ├── js/
│   │   ├── app.js           # Main JavaScript
│   │   ├── components/      # JS components
│   │   └── vendor/          # Third-party JS
│   └── images/
│       ├── logo.svg
│       ├── icons/
│       └── placeholders/
└── .htaccess                 # URL rewriting

src/
├── Core/
│   ├── Application.php       # Main app bootstrap
│   ├── Router.php           # URL routing
│   ├── Request.php          # HTTP request wrapper
│   ├── Response.php         # HTTP response wrapper
│   ├── View.php             # Template rendering
│   └── Database.php         # PDO wrapper
├── Controllers/
│   ├── HomeController.php
│   ├── PageController.php
│   ├── ContactController.php
│   └── BlogController.php
├── Models/
│   ├── Page.php
│   ├── BlogPost.php
│   └── ContactSubmission.php
├── Services/
│   ├── MailService.php
│   └── CacheService.php
└── Middleware/
    ├── CsrfMiddleware.php
    └── RateLimitMiddleware.php

templates/
├── layouts/
│   └── main.php             # Base layout
├── partials/
│   ├── header.php
│   ├── footer.php
│   ├── nav.php
│   └── components/
│       ├── property-card.php
│       ├── hero.php
│       ├── faq-accordion.php
│       └── newsletter-form.php
├── home/
│   └── index.php
├── pages/
│   ├── about.php
│   ├── contact.php
│   ├── terms.php
│   ├── privacy.php
│   └── cookies.php
└── blog/
    ├── index.php
    └── show.php
```

## Routing Configuration

| Route | Controller | Method | Description |
|-------|------------|--------|-------------|
| `GET /` | HomeController | index | Homepage |
| `GET /about` | PageController | about | About page |
| `GET /contact` | ContactController | show | Contact form |
| `POST /contact` | ContactController | submit | Handle submission |
| `GET /terms` | PageController | terms | Terms of Service |
| `GET /privacy` | PageController | privacy | Privacy Policy |
| `GET /cookies` | PageController | cookies | Cookie Policy |
| `GET /guides` | BlogController | index | Blog listing |
| `GET /guides/{slug}` | BlogController | show | Single post |

## Database Schema

### pages
```sql
CREATE TABLE pages (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    slug VARCHAR(100) NOT NULL UNIQUE,
    title VARCHAR(200) NOT NULL,
    content LONGTEXT NOT NULL,
    meta_title VARCHAR(200),
    meta_description VARCHAR(300),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_slug (slug)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### blog_posts
```sql
CREATE TABLE blog_posts (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    slug VARCHAR(200) NOT NULL UNIQUE,
    title VARCHAR(300) NOT NULL,
    excerpt TEXT,
    content LONGTEXT NOT NULL,
    featured_image VARCHAR(500),
    category ENUM('buying-guides', 'selling-tips', 'renovation-advice', 'market-insights') NOT NULL,
    author_name VARCHAR(100),
    meta_title VARCHAR(200),
    meta_description VARCHAR(300),
    is_published TINYINT(1) DEFAULT 0,
    published_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_slug (slug),
    INDEX idx_category (category),
    INDEX idx_published (is_published, published_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### contact_submissions
```sql
CREATE TABLE contact_submissions (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL,
    subject VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    ip_address VARCHAR(45),
    user_agent TEXT,
    is_read TINYINT(1) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_created (created_at),
    INDEX idx_read (is_read)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### newsletter_subscribers
```sql
CREATE TABLE newsletter_subscribers (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    is_confirmed TINYINT(1) DEFAULT 0,
    confirmation_token VARCHAR(64),
    confirmed_at TIMESTAMP NULL,
    unsubscribed_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_confirmed (is_confirmed)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

## Frontend Architecture

### CSS Strategy
1. Tailwind CSS for utility-first styling
2. Build process: Tailwind CLI (no Node.js in production)
3. Custom CSS for complex animations and property-specific styles
4. CSS custom properties for theming

### JavaScript Strategy
1. Vanilla ES6+ JavaScript (no jQuery dependency)
2. Module pattern for component organization
3. Progressive enhancement approach
4. Lazy loading for non-critical scripts

### Key JavaScript Components
```javascript
// components/mobileNav.js - Mobile navigation toggle
// components/faqAccordion.js - FAQ expand/collapse
// components/newsletter.js - Newsletter form with AJAX
// components/cookieConsent.js - Cookie banner logic
// components/lazyImages.js - Lazy loading images
// components/propertyCarousel.js - Featured properties slider
```

## Security Measures

1. **CSRF Protection**: Token-based validation on all forms
2. **XSS Prevention**: Output escaping via helper functions
3. **SQL Injection**: PDO prepared statements only
4. **Rate Limiting**: Contact form rate limiting (5 per hour per IP)
5. **Input Validation**: Server-side validation on all inputs
6. **Honeypot Fields**: Hidden fields for bot detection

## Caching Strategy

1. **Browser Caching**: Static assets cached for 1 year (with cache busting)
2. **Server Caching**: File-based caching for blog posts and pages
3. **Database Query Caching**: Frequently accessed data cached in file store

## Third-Party Dependencies

### PHP (via Composer)
- PHPMailer (email sending)
- Intervention Image (image processing - for future use)

### Frontend
- Tailwind CSS (build-time only)
- Alpine.js (lightweight reactivity, optional)
