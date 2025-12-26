# 002 - User Authentication Tasks

## Phase 1: Database Setup

### 1.1 Migrations
- [ ] Create `database/migrations/005_create_users_table.php`
- [ ] Create `database/migrations/006_create_password_resets_table.php`
- [ ] Create `database/migrations/007_create_remember_tokens_table.php`
- [ ] Create `database/migrations/008_create_auth_logs_table.php`
- [ ] Run migrations and verify schema

## Phase 2: Core Services

### 2.1 Session Management
- [ ] Implement `src/Services/SessionService.php`
  - [ ] start() - Initialize session with secure settings
  - [ ] regenerate() - Regenerate session ID
  - [ ] destroy() - Destroy session completely
  - [ ] set/get/has/remove methods
  - [ ] flash message support

### 2.2 Token Service
- [ ] Implement `src/Services/TokenService.php`
  - [ ] generate() - Cryptographically secure token generation
  - [ ] hash() - Hash tokens for storage
  - [ ] verify() - Constant-time token comparison
  - [ ] Remember token management methods

### 2.3 Authentication Service
- [ ] Implement `src/Services/AuthService.php`
  - [ ] attempt() - Validate credentials
  - [ ] login() - Establish authenticated session
  - [ ] logout() - Terminate session
  - [ ] user() - Get current user
  - [ ] check()/guest()/id() helpers
  - [ ] Account lockout logic

### 2.4 User Repository
- [ ] Implement `src/Repositories/UserRepository.php`
  - [ ] findByEmail()
  - [ ] findById()
  - [ ] create()
  - [ ] update()
  - [ ] softDelete()
  - [ ] incrementFailedAttempts()
  - [ ] resetFailedAttempts()

## Phase 3: Middleware

### 3.1 Auth Middleware [P]
- [ ] Implement `src/Middleware/AuthMiddleware.php`
  - Redirects unauthenticated users to login
  - Stores intended URL for post-login redirect

- [ ] Implement `src/Middleware/GuestMiddleware.php`
  - Redirects authenticated users to dashboard

- [ ] Implement `src/Middleware/ThrottleMiddleware.php`
  - File-based rate limiting
  - Configurable attempts and decay time
  - IP-based tracking

## Phase 4: Controllers

### 4.1 Registration [P]
- [ ] Implement `src/Controllers/Auth/RegisterController.php`
  - [ ] show() - Display registration form
  - [ ] register() - Process registration
  - [ ] Validation for all fields
  - [ ] Password hashing
  - [ ] Email verification token generation
  - [ ] Welcome email trigger

### 4.2 Login
- [ ] Implement `src/Controllers/Auth/LoginController.php`
  - [ ] show() - Display login form
  - [ ] login() - Process login attempt
  - [ ] Handle remember me
  - [ ] Track failed attempts
  - [ ] Log successful/failed logins

### 4.3 Logout
- [ ] Implement `src/Controllers/Auth/LogoutController.php`
  - [ ] logout() - Process logout
  - [ ] Clear remember token
  - [ ] Destroy session
  - [ ] Redirect with flash message

### 4.4 Email Verification
- [ ] Implement `src/Controllers/Auth/EmailVerificationController.php`
  - [ ] verify() - Process verification link
  - [ ] resend() - Resend verification email
  - [ ] Token validation
  - [ ] Expiry checking

### 4.5 Password Reset
- [ ] Implement `src/Controllers/Auth/PasswordResetController.php`
  - [ ] showRequest() - Display forgot password form
  - [ ] sendReset() - Send reset email
  - [ ] showReset() - Display reset form with token
  - [ ] reset() - Process password reset
  - [ ] Invalidate all sessions

## Phase 5: User Model

### 5.1 User Entity
- [ ] Implement `src/Models/User.php`
  - [ ] Properties matching database schema
  - [ ] getFullName() accessor
  - [ ] isPremium() check
  - [ ] isEmailVerified() check
  - [ ] isLocked() check
  - [ ] Password attribute mutator (auto-hash)

## Phase 6: Templates

### 6.1 Auth Forms [P]
- [ ] Create `templates/auth/register.php`
  - Registration form with all fields
  - Password strength indicator
  - Terms checkbox
  - Error display

- [ ] Create `templates/auth/login.php`
  - Email/password form
  - Remember me checkbox
  - Forgot password link
  - Error display

- [ ] Create `templates/auth/forgot-password.php`
  - Email input form
  - Success/error messages

- [ ] Create `templates/auth/reset-password.php`
  - New password form
  - Token hidden field
  - Password strength indicator

- [ ] Create `templates/auth/verify-email.php`
  - Verification status message
  - Resend option

### 6.2 Dashboard Templates
- [ ] Create `templates/auth/dashboard/index.php`
  - Account overview
  - Quick stats cards
  - Quick action buttons

- [ ] Create `templates/auth/dashboard/settings.php`
  - Profile form
  - Password change form
  - Account deletion section

- [ ] Create `templates/auth/dashboard/partials/sidebar.php`
  - Navigation menu
  - User info

## Phase 7: JavaScript Components

### 7.1 Form Enhancements [P]
- [ ] Create `public/assets/js/components/passwordStrength.js`
  - Strength calculation
  - Visual indicator
  - Requirements checklist

- [ ] Create `public/assets/js/components/authForms.js`
  - Real-time validation
  - Password confirmation matching
  - Form submission handling
  - Loading states

## Phase 8: Email Templates

### 8.1 Auth Emails [P]
- [ ] Create `templates/emails/welcome.php`
- [ ] Create `templates/emails/verify-email.php`
- [ ] Create `templates/emails/password-reset.php`
- [ ] Create `templates/emails/password-changed.php`
- [ ] Create `templates/emails/account-deleted.php`

## Phase 9: Auth Logging

### 9.1 Audit Trail
- [ ] Implement auth event logging in AuthService
  - [ ] Login success/failure logging
  - [ ] Registration logging
  - [ ] Password reset logging
  - [ ] Email verification logging
  - [ ] Account lockout logging

## Phase 10: Testing

### 10.1 Unit Tests [P]
- [ ] Test AuthService methods
- [ ] Test TokenService methods
- [ ] Test password hashing
- [ ] Test rate limiting

### 10.2 Integration Tests
- [ ] Test complete registration flow
- [ ] Test complete login flow
- [ ] Test password reset flow
- [ ] Test remember me persistence
- [ ] Test email verification flow

### 10.3 Security Tests
- [ ] Test CSRF protection
- [ ] Test SQL injection prevention
- [ ] Test rate limiting enforcement
- [ ] Test session security
- [ ] Test timing attack resistance

## Legend
- [P] = Tasks can be executed in parallel
