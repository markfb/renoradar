# 001 - Core Platform Tasks

## Phase 1: Project Setup

### 1.1 Initialize Project Structure
- [ ] Create directory structure as defined in plan.md
- [ ] Initialize Composer with `composer init`
- [ ] Add PHPMailer dependency
- [ ] Create `.htaccess` for URL rewriting
- [ ] Create `public/index.php` front controller
- [ ] Set up configuration files (`config/app.php`, `config/database.php`)

### 1.2 Core Framework Classes [P]
- [ ] Implement `src/Core/Application.php` - Bootstrap and DI container
- [ ] Implement `src/Core/Router.php` - Route registration and matching
- [ ] Implement `src/Core/Request.php` - HTTP request abstraction
- [ ] Implement `src/Core/Response.php` - HTTP response handling
- [ ] Implement `src/Core/View.php` - Template rendering engine
- [ ] Implement `src/Core/Database.php` - PDO wrapper with connection pooling

### 1.3 Middleware Implementation [P]
- [ ] Implement `src/Middleware/CsrfMiddleware.php`
- [ ] Implement `src/Middleware/RateLimitMiddleware.php`

## Phase 2: Database Setup

### 2.1 Migration System
- [ ] Create migration runner script
- [ ] Create `database/migrations/001_create_pages_table.php`
- [ ] Create `database/migrations/002_create_blog_posts_table.php`
- [ ] Create `database/migrations/003_create_contact_submissions_table.php`
- [ ] Create `database/migrations/004_create_newsletter_subscribers_table.php`

### 2.2 Seed Data
- [ ] Create seeds for initial pages (About, Terms, Privacy, Cookies)
- [ ] Create seeds for sample blog posts

## Phase 3: Frontend Foundation

### 3.1 Tailwind CSS Setup
- [ ] Configure `tailwind.config.js` with brand colors and fonts
- [ ] Create `src/css/input.css` with Tailwind directives
- [ ] Build initial `public/assets/css/app.css`
- [ ] Add Google Fonts (Inter) link

### 3.2 Base Templates [P]
- [ ] Create `templates/layouts/main.php` with HTML5 structure
- [ ] Create `templates/partials/header.php` with navigation
- [ ] Create `templates/partials/footer.php`
- [ ] Create `templates/partials/nav.php` with mobile menu structure

### 3.3 Reusable Components [P]
- [ ] Create `templates/partials/components/hero.php`
- [ ] Create `templates/partials/components/property-card.php`
- [ ] Create `templates/partials/components/faq-accordion.php`
- [ ] Create `templates/partials/components/newsletter-form.php`
- [ ] Create `templates/partials/components/cookie-consent.php`

## Phase 4: JavaScript Components

### 4.1 Core JavaScript [P]
- [ ] Create `public/assets/js/app.js` - Main initialization
- [ ] Create `public/assets/js/components/mobileNav.js`
- [ ] Create `public/assets/js/components/faqAccordion.js`
- [ ] Create `public/assets/js/components/newsletter.js`
- [ ] Create `public/assets/js/components/cookieConsent.js`
- [ ] Create `public/assets/js/components/lazyImages.js`

## Phase 5: Controllers & Routes

### 5.1 Route Configuration
- [ ] Define all routes in `config/routes.php`

### 5.2 Controllers [P]
- [ ] Implement `src/Controllers/HomeController.php`
- [ ] Implement `src/Controllers/PageController.php`
- [ ] Implement `src/Controllers/ContactController.php`
- [ ] Implement `src/Controllers/BlogController.php`

### 5.3 Models [P]
- [ ] Implement `src/Models/Page.php`
- [ ] Implement `src/Models/BlogPost.php`
- [ ] Implement `src/Models/ContactSubmission.php`
- [ ] Implement `src/Models/NewsletterSubscriber.php`

## Phase 6: Page Templates

### 6.1 Homepage
- [ ] Create `templates/home/index.php`
- [ ] Implement hero section with CTAs
- [ ] Implement featured properties carousel (placeholder data)
- [ ] Implement "How It Works" section
- [ ] Implement "Why Choose RenoRadar" section
- [ ] Implement regional highlights section
- [ ] Implement before/after showcase
- [ ] Implement blog preview section
- [ ] Implement FAQ section

### 6.2 Static Pages [P]
- [ ] Create `templates/pages/about.php`
- [ ] Create `templates/pages/contact.php`
- [ ] Create `templates/pages/terms.php`
- [ ] Create `templates/pages/privacy.php`
- [ ] Create `templates/pages/cookies.php`

### 6.3 Blog Pages
- [ ] Create `templates/blog/index.php` with filtering
- [ ] Create `templates/blog/show.php` for single posts

## Phase 7: Services & Helpers

### 7.1 Services [P]
- [ ] Implement `src/Services/MailService.php` for email sending
- [ ] Implement `src/Services/CacheService.php` for file caching

### 7.2 Helper Functions
- [ ] Create `src/Helpers/functions.php` with utility functions
  - `e()` - HTML escaping
  - `csrf_token()` - Generate/retrieve CSRF token
  - `csrf_field()` - Output hidden CSRF input
  - `old()` - Retrieve old form input
  - `asset()` - Generate asset URL with cache busting
  - `url()` - Generate application URL
  - `redirect()` - HTTP redirect helper

## Phase 8: SEO & Meta

### 8.1 Meta Tags
- [ ] Implement meta tag helper in View class
- [ ] Add Open Graph tags to layout
- [ ] Add Twitter Card tags to layout

### 8.2 Structured Data
- [ ] Add Organization schema to homepage
- [ ] Add BreadcrumbList schema to internal pages
- [ ] Add Article schema to blog posts

### 8.3 Technical SEO
- [ ] Create `public/robots.txt`
- [ ] Create XML sitemap generator
- [ ] Add canonical URLs to all pages

## Phase 9: Testing & QA

### 9.1 Cross-Browser Testing
- [ ] Test on Chrome (latest)
- [ ] Test on Firefox (latest)
- [ ] Test on Safari (latest)
- [ ] Test on Edge (latest)

### 9.2 Mobile Testing
- [ ] Test on iPhone Safari
- [ ] Test on Android Chrome
- [ ] Test responsive breakpoints (320px, 375px, 768px, 1024px, 1280px)

### 9.3 Accessibility Audit
- [ ] Run Lighthouse accessibility audit
- [ ] Test keyboard navigation
- [ ] Verify ARIA labels
- [ ] Check color contrast

### 9.4 Performance Audit
- [ ] Run Lighthouse performance audit
- [ ] Optimize images
- [ ] Verify caching headers
- [ ] Test on slow connections

## Legend
- [P] = Tasks can be executed in parallel
- Dependencies flow top-to-bottom within phases
- Phases 3.2, 3.3, 4.1, 5.2, 5.3, 6.2, 7.1 contain parallel tasks
