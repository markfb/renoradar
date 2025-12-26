# RenoRadar Constitution

## Project Overview

RenoRadar is a modern property marketplace platform specializing in renovation-ready homes. The platform connects buyers seeking fixer-upper properties with sellers looking to sell properties "as-is" without costly pre-sale renovations.

**Tagline**: "Discover. Renovate. Transform."

**Domain**: renoradar.com

## Core Principles

### 1. Code Quality Standards

- **PHP 8.3+**: Leverage modern PHP features including typed properties, match expressions, enums, and readonly classes
- **PSR Compliance**: Follow PSR-1, PSR-4, PSR-12 coding standards strictly
- **Type Safety**: Use strict types declaration in all PHP files (`declare(strict_types=1)`)
- **SOLID Principles**: Apply single responsibility, open-closed, Liskov substitution, interface segregation, and dependency inversion
- **DRY/KISS**: Avoid duplication while keeping solutions simple and maintainable

### 2. Security First

- **OWASP Top 10**: Guard against SQL injection, XSS, CSRF, and all common vulnerabilities
- **Prepared Statements**: Always use PDO prepared statements for database queries
- **Input Validation**: Validate and sanitize all user inputs server-side
- **Password Security**: Use `password_hash()` with ARGON2ID algorithm
- **Session Security**: Implement secure session handling with regeneration on privilege changes
- **HTTPS Only**: Enforce SSL/TLS for all connections
- **PayPal IPN Verification**: Validate all payment notifications cryptographically

### 3. Database Standards (MariaDB)

- **InnoDB Engine**: Use InnoDB for all tables requiring transactions
- **Foreign Keys**: Maintain referential integrity through proper constraints
- **Indexes**: Create appropriate indexes for query optimization
- **Naming Convention**: Use snake_case for tables and columns
- **Migrations**: Version-control all schema changes
- **Soft Deletes**: Implement soft deletes for critical business data

### 4. UI/UX Excellence

- **Mobile-First Design**: Build responsive layouts starting from mobile
- **Accessibility**: Meet WCAG 2.1 AA compliance standards
- **Performance**: Target Lighthouse scores of 90+ across all metrics
- **Consistency**: Maintain uniform spacing, typography, and color usage
- **Property Theme**: Use warm, trustworthy colors conveying stability and home

### 5. Testing Requirements

- **Unit Tests**: Cover business logic with PHPUnit tests
- **Integration Tests**: Test API endpoints and database interactions
- **Browser Testing**: Cross-browser compatibility (Chrome, Firefox, Safari, Edge)
- **Mobile Testing**: Test on iOS Safari and Android Chrome
- **Payment Testing**: Use PayPal Sandbox for payment flow testing

### 6. Performance Standards

- **Page Load**: Target < 3 seconds initial load on 3G connections
- **Time to Interactive**: Target < 5 seconds
- **Database Queries**: Optimize to minimize N+1 queries
- **Image Optimization**: Serve WebP with fallbacks, implement lazy loading
- **Caching**: Implement appropriate HTTP caching and server-side caching

### 7. Architecture Patterns

- **MVC Structure**: Separate concerns into Models, Views, Controllers
- **Repository Pattern**: Abstract database operations
- **Service Layer**: Encapsulate business logic in dedicated services
- **Dependency Injection**: Use constructor injection for dependencies
- **Configuration Management**: Externalize configuration, no hardcoded values

## Technology Stack

| Layer | Technology |
|-------|------------|
| Backend | PHP 8.3+ |
| Database | MariaDB 10.6+ |
| Frontend | HTML5, CSS3, Vanilla JavaScript (ES6+) |
| CSS Framework | Tailwind CSS 3.x |
| Payment Gateway | PayPal REST API |
| Image Processing | Intervention Image |
| Email | PHPMailer |
| Templating | Native PHP with Twig-like structure |

## Design System

### Color Palette

| Color | Hex | Usage |
|-------|-----|-------|
| Primary | #2563EB | CTAs, Links, Primary buttons |
| Secondary | #1E40AF | Hover states, Secondary actions |
| Accent | #F59E0B | Highlights, Premium badges |
| Success | #10B981 | Success states, Availability |
| Warning | #F59E0B | Alerts, Price changes |
| Error | #EF4444 | Errors, Required fields |
| Neutral Dark | #1F2937 | Text, Headers |
| Neutral Light | #F3F4F6 | Backgrounds |
| White | #FFFFFF | Cards, Content areas |

### Typography

- **Headings**: Inter or Poppins (modern, clean sans-serif)
- **Body**: Inter (highly readable across devices)
- **Scale**: 12px, 14px, 16px, 18px, 20px, 24px, 30px, 36px, 48px

### Spacing Scale

- 4px, 8px, 12px, 16px, 24px, 32px, 48px, 64px, 96px

### Border Radius

- Small: 4px (buttons, inputs)
- Medium: 8px (cards, modals)
- Large: 16px (featured elements)
- Full: 9999px (pills, avatars)

## File Structure

```
renoradar/
├── .specify/                 # Specification files
├── public/                   # Web root
│   ├── index.php            # Front controller
│   ├── assets/
│   │   ├── css/
│   │   ├── js/
│   │   └── images/
│   └── uploads/             # User uploads
├── src/
│   ├── Controllers/
│   ├── Models/
│   ├── Services/
│   ├── Repositories/
│   ├── Middleware/
│   └── Helpers/
├── templates/               # View templates
├── config/                  # Configuration files
├── database/
│   ├── migrations/
│   └── seeds/
├── tests/
├── storage/
│   ├── cache/
│   ├── logs/
│   └── sessions/
├── vendor/                  # Composer dependencies
├── composer.json
└── CLAUDE.md
```

## Business Model

### For Sellers
- **Standard Listing**: £25 one-time fee
- **Premium Listing**: +£20/month for enhanced visibility

### For Buyers
- **Free Tier**: Browse all listings
- **Premium Membership**: £25/month or £199/year
  - Early access to new listings
  - Email alerts for matching properties
  - Trade network access

## Constraints

1. Must work on shared PHP hosting environments
2. No Node.js dependencies in production
3. All assets must be self-hosted (no external CDNs for core functionality)
4. Support PHP 8.0+ for broader hosting compatibility
5. Mobile-first responsive design mandatory
6. GDPR compliance required for UK/EU users
