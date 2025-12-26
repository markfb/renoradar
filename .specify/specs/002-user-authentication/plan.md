# 002 - User Authentication Technical Plan

## Architecture Overview

The authentication system uses a secure, session-based approach with optional "remember me" tokens for persistent login. All sensitive operations use constant-time comparisons and proper cryptographic functions.

## Directory Structure

```
src/
├── Controllers/
│   └── Auth/
│       ├── LoginController.php
│       ├── RegisterController.php
│       ├── PasswordResetController.php
│       ├── EmailVerificationController.php
│       └── LogoutController.php
├── Models/
│   └── User.php
├── Services/
│   ├── AuthService.php
│   ├── SessionService.php
│   └── TokenService.php
├── Middleware/
│   ├── AuthMiddleware.php
│   ├── GuestMiddleware.php
│   └── ThrottleMiddleware.php
└── Repositories/
    └── UserRepository.php

templates/
└── auth/
    ├── login.php
    ├── register.php
    ├── forgot-password.php
    ├── reset-password.php
    ├── verify-email.php
    └── dashboard/
        ├── index.php
        ├── settings.php
        └── partials/
            ├── sidebar.php
            └── stats-cards.php
```

## Routing Configuration

| Route | Controller | Method | Middleware | Description |
|-------|------------|--------|------------|-------------|
| `GET /login` | LoginController | show | Guest | Show login form |
| `POST /login` | LoginController | login | Guest, Throttle | Process login |
| `GET /register` | RegisterController | show | Guest | Show registration |
| `POST /register` | RegisterController | register | Guest, Throttle | Process registration |
| `POST /logout` | LogoutController | logout | Auth | Process logout |
| `GET /forgot-password` | PasswordResetController | showRequest | Guest | Show reset request |
| `POST /forgot-password` | PasswordResetController | sendReset | Guest, Throttle | Send reset email |
| `GET /reset-password/{token}` | PasswordResetController | showReset | Guest | Show reset form |
| `POST /reset-password` | PasswordResetController | reset | Guest | Process reset |
| `GET /verify-email/{token}` | EmailVerificationController | verify | - | Verify email |
| `POST /resend-verification` | EmailVerificationController | resend | Auth, Throttle | Resend verification |
| `GET /account` | DashboardController | index | Auth | User dashboard |
| `GET /account/settings` | SettingsController | show | Auth | Account settings |
| `POST /account/settings` | SettingsController | update | Auth | Update settings |
| `POST /account/password` | SettingsController | updatePassword | Auth | Change password |
| `POST /account/delete` | SettingsController | delete | Auth | Delete account |

## Database Schema

### users
```sql
CREATE TABLE users (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    avatar VARCHAR(500),
    role ENUM('user', 'seller', 'admin') DEFAULT 'user',
    subscription_tier ENUM('free', 'premium') DEFAULT 'free',
    subscription_expires_at TIMESTAMP NULL,
    email_verified_at TIMESTAMP NULL,
    email_verification_token VARCHAR(64),
    email_verification_expires_at TIMESTAMP NULL,
    marketing_opt_in TINYINT(1) DEFAULT 0,
    failed_login_attempts INT UNSIGNED DEFAULT 0,
    locked_until TIMESTAMP NULL,
    last_login_at TIMESTAMP NULL,
    last_login_ip VARCHAR(45),
    deleted_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_role (role),
    INDEX idx_subscription (subscription_tier),
    INDEX idx_deleted (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### password_resets
```sql
CREATE TABLE password_resets (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL,
    token VARCHAR(64) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NOT NULL,
    used_at TIMESTAMP NULL,
    INDEX idx_email (email),
    INDEX idx_token (token),
    INDEX idx_expires (expires_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### remember_tokens
```sql
CREATE TABLE remember_tokens (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NOT NULL,
    token_hash VARCHAR(64) NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user (user_id),
    INDEX idx_token (token_hash),
    INDEX idx_expires (expires_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### auth_logs
```sql
CREATE TABLE auth_logs (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED,
    action ENUM('login', 'logout', 'register', 'password_reset', 'email_verify', 'failed_login', 'lockout') NOT NULL,
    ip_address VARCHAR(45),
    user_agent TEXT,
    metadata JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_user (user_id),
    INDEX idx_action (action),
    INDEX idx_created (created_at),
    INDEX idx_ip (ip_address)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

## Core Services

### AuthService

```php
class AuthService
{
    public function attempt(string $email, string $password, bool $remember = false): ?User;
    public function login(User $user, bool $remember = false): void;
    public function logout(): void;
    public function user(): ?User;
    public function check(): bool;
    public function guest(): bool;
    public function id(): ?int;
}
```

### SessionService

```php
class SessionService
{
    public function start(): void;
    public function regenerate(): void;
    public function destroy(): void;
    public function set(string $key, mixed $value): void;
    public function get(string $key, mixed $default = null): mixed;
    public function flash(string $key, mixed $value): void;
    public function getFlash(string $key, mixed $default = null): mixed;
}
```

### TokenService

```php
class TokenService
{
    public function generate(int $length = 32): string;
    public function hash(string $token): string;
    public function verify(string $token, string $hash): bool;
    public function createRememberToken(User $user): string;
    public function validateRememberToken(string $token): ?User;
    public function invalidateRememberTokens(User $user): void;
}
```

## Security Implementation

### Password Hashing

```php
// Hashing (registration/password change)
$hash = password_hash($password, PASSWORD_ARGON2ID, [
    'memory_cost' => 65536,
    'time_cost' => 4,
    'threads' => 3
]);

// Verification (login)
if (password_verify($password, $user->password)) {
    // Check if rehash needed
    if (password_needs_rehash($user->password, PASSWORD_ARGON2ID)) {
        $user->password = password_hash($password, PASSWORD_ARGON2ID);
        $user->save();
    }
}
```

### Session Security

```php
// Session configuration
ini_set('session.use_strict_mode', 1);
ini_set('session.cookie_httponly', 1);
ini_set('session.cookie_secure', 1); // HTTPS only
ini_set('session.cookie_samesite', 'Lax');
ini_set('session.gc_maxlifetime', 7200); // 2 hours
```

### Rate Limiting

```php
class ThrottleMiddleware
{
    private const MAX_ATTEMPTS = 5;
    private const DECAY_MINUTES = 15;

    public function handle(Request $request, Closure $next): Response
    {
        $key = $this->resolveRequestSignature($request);

        if ($this->tooManyAttempts($key)) {
            return $this->buildResponse($key);
        }

        $this->incrementAttempts($key);

        return $next($request);
    }
}
```

### CSRF Protection

```php
// Generate token
$_SESSION['csrf_token'] = bin2hex(random_bytes(32));

// Validate token
if (!hash_equals($_SESSION['csrf_token'], $_POST['_token'] ?? '')) {
    throw new CsrfTokenMismatchException();
}
```

## Email Templates

### Welcome Email
- Subject: "Welcome to RenoRadar!"
- Content: Welcome message, verify email CTA, getting started tips

### Email Verification
- Subject: "Verify your RenoRadar email"
- Content: Verification link (valid 24 hours), resend instructions

### Password Reset
- Subject: "Reset your RenoRadar password"
- Content: Reset link (valid 1 hour), security notice if not requested

### Password Changed
- Subject: "Your RenoRadar password was changed"
- Content: Confirmation, security notice to contact if not them

### Account Deleted
- Subject: "Your RenoRadar account has been deleted"
- Content: Confirmation, 30-day recovery window notice

## Frontend Components

### Password Strength Meter
```javascript
// components/passwordStrength.js
const requirements = {
    minLength: 8,
    hasUppercase: /[A-Z]/,
    hasLowercase: /[a-z]/,
    hasNumber: /[0-9]/
};

function calculateStrength(password) {
    let score = 0;
    if (password.length >= requirements.minLength) score++;
    if (requirements.hasUppercase.test(password)) score++;
    if (requirements.hasLowercase.test(password)) score++;
    if (requirements.hasNumber.test(password)) score++;
    return score; // 0-4
}
```

### Form Validation
```javascript
// components/authForms.js
// Real-time email format validation
// Password confirmation matching
// Terms checkbox required
// Submit button state management
```

## Testing Strategy

### Unit Tests
- AuthService::attempt() with valid/invalid credentials
- TokenService token generation and verification
- Password hashing and verification
- Rate limiting logic

### Integration Tests
- Full registration flow
- Full login flow
- Password reset flow
- Email verification flow
- Remember me functionality

### Security Tests
- SQL injection attempts on login
- CSRF token validation
- Session fixation prevention
- Rate limiting enforcement
- Timing attack resistance
