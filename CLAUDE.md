# RenoRadar - Claude Code Context

## Project Overview

RenoRadar is a property marketplace platform specializing in renovation-ready homes in the UK. Similar to DoerUpper.co.uk, it connects buyers seeking fixer-upper properties with sellers looking to sell properties "as-is."

**Tagline**: "Discover. Renovate. Transform."

**Domain**: renoradar.com

## Technology Stack

| Layer | Technology |
|-------|------------|
| Backend | PHP 8.0+ (strict types required) |
| Database | MariaDB 10.6+ |
| Frontend | HTML5, CSS3 (Tailwind), Vanilla JavaScript ES6+ |
| Payment Gateway | PayPal REST API |
| Image Processing | Intervention Image |
| Email | PHPMailer |
| Maps | Leaflet.js + OpenStreetMap |

## Project Structure

```
renoradar/
├── .specify/                 # Spec-kit specifications
│   ├── memory/
│   │   └── constitution.md   # Core principles and standards
│   └── specs/
│       ├── 001-core-platform/
│       ├── 002-user-authentication/
│       ├── 003-property-listings/
│       ├── 004-search-filtering/
│       ├── 005-payment-subscriptions/
│       ├── 006-alerts-notifications/
│       └── 007-admin-dashboard/
├── public/                   # Web root
│   ├── index.php            # Front controller
│   └── assets/              # CSS, JS, images
├── src/
│   ├── Controllers/         # Request handlers
│   ├── Models/              # Data entities
│   ├── Services/            # Business logic
│   ├── Repositories/        # Database operations
│   ├── Middleware/          # Request filters
│   └── Core/                # Framework classes
├── templates/               # View templates
├── config/                  # Configuration files
├── database/
│   ├── migrations/          # Schema migrations
│   └── seeds/               # Sample data
├── tests/                   # Test files
├── storage/                 # Uploads, cache, logs
└── vendor/                  # Composer dependencies
```

## Key Specifications

Detailed specifications are in `.specify/specs/`. Each feature has:
- `spec.md` - User stories and acceptance criteria
- `plan.md` - Technical architecture and implementation
- `tasks.md` - Actionable task breakdown
- `data-model.md` - Database schema (where applicable)

### Features

1. **Core Platform** (001) - Homepage, navigation, static pages, blog
2. **User Authentication** (002) - Registration, login, password management
3. **Property Listings** (003) - Create, manage, and display properties
4. **Search & Filtering** (004) - Property search with multiple filters
5. **Payments** (005) - PayPal integration for listing fees and subscriptions
6. **Alerts & Notifications** (006) - Property alerts, email notifications
7. **Admin Dashboard** (007) - Platform management interface

## Business Model

### For Sellers
- Standard Listing: £25 one-time fee
- Premium Listing: +£20/month for enhanced visibility

### For Buyers
- Free: Browse all listings
- Premium: £25/month or £199/year (early access, alerts)

## Development Standards

### PHP
- Use `declare(strict_types=1)` in all files
- Follow PSR-1, PSR-4, PSR-12 standards
- Use PDO prepared statements for all queries
- Hash passwords with ARGON2ID

### Security
- CSRF protection on all forms
- XSS prevention via output escaping
- SQL injection prevention via prepared statements
- Rate limiting on auth and contact endpoints

### Database
- InnoDB engine for all tables
- `utf8mb4_unicode_ci` character set
- snake_case naming convention
- Soft deletes for user data

### Frontend
- Mobile-first responsive design
- Tailwind CSS for styling
- Vanilla JavaScript (no jQuery)
- Progressive enhancement approach

## Quick Commands

```bash
# Install dependencies
composer install

# Run migrations
php database/migrate.php

# Seed sample data
php database/seed.php

# Start development server
php -S localhost:8000 -t public

# Build Tailwind CSS
npx tailwindcss -i src/css/input.css -o public/assets/css/app.css --watch
```

## Environment Variables

Copy `.env.example` to `.env` and configure:

```env
# Database
DB_HOST=localhost
DB_NAME=renoradar
DB_USER=root
DB_PASS=

# PayPal
PAYPAL_MODE=sandbox
PAYPAL_CLIENT_ID=
PAYPAL_CLIENT_SECRET=
PAYPAL_WEBHOOK_ID=

# Email
MAIL_HOST=
MAIL_PORT=587
MAIL_USER=
MAIL_PASS=
MAIL_FROM=noreply@renoradar.com

# App
APP_URL=http://localhost:8000
APP_ENV=development
APP_DEBUG=true
```

## Testing

```bash
# Run all tests
./vendor/bin/phpunit

# Run specific test suite
./vendor/bin/phpunit --testsuite=Unit
./vendor/bin/phpunit --testsuite=Integration
```

## Common Tasks

### Adding a New Page
1. Create controller in `src/Controllers/`
2. Add route in `config/routes.php`
3. Create template in `templates/`

### Adding a Database Table
1. Create migration in `database/migrations/`
2. Create model in `src/Models/`
3. Create repository in `src/Repositories/`

### Adding a New Feature
1. Review relevant spec in `.specify/specs/`
2. Follow the task breakdown in `tasks.md`
3. Update CLAUDE.md if architectural changes

## Important Files

- `.specify/memory/constitution.md` - Core principles
- `config/routes.php` - All application routes
- `src/Core/Application.php` - Main bootstrap
- `config/paypal.php` - Payment configuration
