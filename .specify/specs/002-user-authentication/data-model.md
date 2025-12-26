# 002 - User Authentication Data Model

## Entity Relationship Diagram

```
┌─────────────────────────┐
│         users           │
├─────────────────────────┤
│ id (PK)                 │
│ email                   │
│ password                │
│ first_name              │
│ last_name               │
│ phone                   │
│ avatar                  │
│ role                    │
│ subscription_tier       │
│ subscription_expires_at │
│ email_verified_at       │
│ email_verification_token│
│ email_verification_...  │
│ marketing_opt_in        │
│ failed_login_attempts   │
│ locked_until            │
│ last_login_at           │
│ last_login_ip           │
│ deleted_at              │
│ created_at              │
│ updated_at              │
└───────────┬─────────────┘
            │
            │ 1:N
            ▼
┌─────────────────────────┐     ┌─────────────────────────┐
│    remember_tokens      │     │    password_resets      │
├─────────────────────────┤     ├─────────────────────────┤
│ id (PK)                 │     │ id (PK)                 │
│ user_id (FK)            │     │ email                   │
│ token_hash              │     │ token                   │
│ expires_at              │     │ created_at              │
│ created_at              │     │ expires_at              │
└─────────────────────────┘     │ used_at                 │
            │                   └─────────────────────────┘
            │ 1:N
            ▼
┌─────────────────────────┐
│       auth_logs         │
├─────────────────────────┤
│ id (PK)                 │
│ user_id (FK, nullable)  │
│ action                  │
│ ip_address              │
│ user_agent              │
│ metadata (JSON)         │
│ created_at              │
└─────────────────────────┘
```

## Table Definitions

### users

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT UNSIGNED | PK, AUTO_INCREMENT | Unique identifier |
| email | VARCHAR(255) | NOT NULL, UNIQUE | User's email address |
| password | VARCHAR(255) | NOT NULL | Argon2ID hashed password |
| first_name | VARCHAR(100) | NOT NULL | First name |
| last_name | VARCHAR(100) | NOT NULL | Last name |
| phone | VARCHAR(20) | NULL | Phone number |
| avatar | VARCHAR(500) | NULL | Path to avatar image |
| role | ENUM | DEFAULT 'user' | User role |
| subscription_tier | ENUM | DEFAULT 'free' | Subscription level |
| subscription_expires_at | TIMESTAMP | NULL | Premium expiry date |
| email_verified_at | TIMESTAMP | NULL | Email verification date |
| email_verification_token | VARCHAR(64) | NULL | Pending verification token |
| email_verification_expires_at | TIMESTAMP | NULL | Token expiry |
| marketing_opt_in | TINYINT(1) | DEFAULT 0 | Marketing consent |
| failed_login_attempts | INT UNSIGNED | DEFAULT 0 | Failed login counter |
| locked_until | TIMESTAMP | NULL | Account lockout expiry |
| last_login_at | TIMESTAMP | NULL | Last successful login |
| last_login_ip | VARCHAR(45) | NULL | Last login IP address |
| deleted_at | TIMESTAMP | NULL | Soft delete timestamp |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Registration date |
| updated_at | TIMESTAMP | ON UPDATE CURRENT_TIMESTAMP | Last update |

**Role ENUM Values:**
- `user` - Standard registered user
- `seller` - User with active listings
- `admin` - Platform administrator

**Subscription Tier ENUM Values:**
- `free` - Basic free tier
- `premium` - Paid premium tier

**Indexes:**
- PRIMARY KEY (id)
- UNIQUE INDEX idx_email (email)
- INDEX idx_role (role)
- INDEX idx_subscription (subscription_tier)
- INDEX idx_deleted (deleted_at)

---

### password_resets

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT UNSIGNED | PK, AUTO_INCREMENT | Unique identifier |
| email | VARCHAR(255) | NOT NULL | User's email address |
| token | VARCHAR(64) | NOT NULL | Hashed reset token |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Request timestamp |
| expires_at | TIMESTAMP | NOT NULL | Token expiry (1 hour) |
| used_at | TIMESTAMP | NULL | Token usage timestamp |

**Indexes:**
- PRIMARY KEY (id)
- INDEX idx_email (email)
- INDEX idx_token (token)
- INDEX idx_expires (expires_at)

**Notes:**
- Tokens are stored hashed using SHA-256
- Multiple reset requests create new records (old ones expire)
- Cleanup job removes expired/used tokens

---

### remember_tokens

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT UNSIGNED | PK, AUTO_INCREMENT | Unique identifier |
| user_id | INT UNSIGNED | NOT NULL, FK | Reference to users |
| token_hash | VARCHAR(64) | NOT NULL | Hashed remember token |
| expires_at | TIMESTAMP | NOT NULL | Token expiry (30 days) |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Token creation date |

**Indexes:**
- PRIMARY KEY (id)
- INDEX idx_user (user_id)
- INDEX idx_token (token_hash)
- INDEX idx_expires (expires_at)

**Foreign Keys:**
- user_id REFERENCES users(id) ON DELETE CASCADE

**Notes:**
- Users can have multiple remember tokens (different devices)
- Token stored in cookie: `user_id|selector|validator`
- Only validator portion is hashed in database

---

### auth_logs

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT UNSIGNED | PK, AUTO_INCREMENT | Unique identifier |
| user_id | INT UNSIGNED | NULL, FK | Reference to users (nullable for failed attempts) |
| action | ENUM | NOT NULL | Action type |
| ip_address | VARCHAR(45) | NULL | Client IP address (IPv6 compatible) |
| user_agent | TEXT | NULL | Browser user agent |
| metadata | JSON | NULL | Additional context data |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Event timestamp |

**Action ENUM Values:**
- `login` - Successful login
- `logout` - User logout
- `register` - New registration
- `password_reset` - Password reset completed
- `email_verify` - Email verified
- `failed_login` - Failed login attempt
- `lockout` - Account locked due to failed attempts

**Indexes:**
- PRIMARY KEY (id)
- INDEX idx_user (user_id)
- INDEX idx_action (action)
- INDEX idx_created (created_at)
- INDEX idx_ip (ip_address)

**Foreign Keys:**
- user_id REFERENCES users(id) ON DELETE SET NULL

**Metadata Examples:**
```json
// Failed login
{"email": "user@example.com", "reason": "invalid_password"}

// Account lockout
{"duration_minutes": 15, "failed_attempts": 5}

// Login
{"remember_me": true, "two_factor": false}
```

## Data Integrity Rules

1. **Soft Deletes**: Users use soft delete (`deleted_at`) for GDPR compliance
2. **Cascade Deletes**: Remember tokens cascade delete with user
3. **Set NULL**: Auth logs preserve history but null user_id on user deletion
4. **Token Expiry**: Cron job cleans expired password_resets and remember_tokens

## Queries

### Find Active User by Email
```sql
SELECT * FROM users
WHERE email = ?
AND deleted_at IS NULL
AND (locked_until IS NULL OR locked_until < NOW());
```

### Validate Remember Token
```sql
SELECT u.* FROM users u
JOIN remember_tokens rt ON rt.user_id = u.id
WHERE rt.token_hash = ?
AND rt.expires_at > NOW()
AND u.deleted_at IS NULL;
```

### Get User Login History
```sql
SELECT * FROM auth_logs
WHERE user_id = ?
AND action IN ('login', 'failed_login', 'logout')
ORDER BY created_at DESC
LIMIT 20;
```

### Count Failed Login Attempts (Rate Limiting)
```sql
SELECT COUNT(*) FROM auth_logs
WHERE ip_address = ?
AND action = 'failed_login'
AND created_at > DATE_SUB(NOW(), INTERVAL 15 MINUTE);
```

### Cleanup Expired Tokens
```sql
-- Password resets
DELETE FROM password_resets
WHERE expires_at < NOW()
OR used_at IS NOT NULL;

-- Remember tokens
DELETE FROM remember_tokens
WHERE expires_at < NOW();
```
