# Security Checklist for Developers

This checklist covers baseline security practices for the crypto market application.

## Input Validation

### Email Validation
- [ ] Use `EmailValidator.validate()` for all email inputs
- [ ] Check for proper email format (RFC 5322 compliant)
- [ ] Sanitize email input to prevent injection attacks
- [ ] Validate maximum length (254 characters per RFC 5321)

### Password Validation
- [ ] Minimum 8 characters length
- [ ] Contains at least one uppercase letter
- [ ] Contains at least one lowercase letter  
- [ ] Contains at least one digit
- [ ] Contains at least one special character
- [ ] Use `PasswordValidator.validate()` helper

### String Length Validation
- [ ] Set maximum length limits for all text inputs
- [ ] Validate minimum required lengths where applicable
- [ ] Trim whitespace before validation
- [ ] Prevent null/empty strings where not allowed

### Numeric Range Validation
- [ ] Validate minimum/maximum values for all numeric inputs
- [ ] Check for overflow/underflow conditions
- [ ] Ensure positive values where negative not allowed
- [ ] Use `NumericValidator.validate()` helpers

## Principal Handling & Authentication

### Principal Checks
- [ ] Verify principal authentication before service calls
- [ ] Use `AuthGuard.requireAuth()` for protected operations
- [ ] Implement principal-based authorization checks
- [ ] Log all authentication attempts and failures

### Auth Guard Patterns
- [ ] Implement route-level auth guards
- [ ] Check session validity before sensitive operations
- [ ] Handle session expiration gracefully
- [ ] Redirect to login when authentication required

### Protected Routes
- [ ] Apply auth guards to all sensitive routes
- [ ] Implement role-based access controls where needed
- [ ] Validate permissions before displaying UI elements
- [ ] Handle unauthorized access attempts

## Rate Limiting Guidance

### Canister Call Rate Limits
- [ ] Authentication endpoints: 5 attempts per minute
- [ ] Listing creation: 10 requests per minute per user
- [ ] Search operations: 30 requests per minute per user
- [ ] Profile updates: 3 requests per minute per user

### Implementation Notes
- [ ] Track requests by principal/IP combination
- [ ] Use exponential backoff for repeated failures
- [ ] Implement proper error messages for rate limit violations
- [ ] Log rate limit violations for monitoring

### High-Risk Operations
- [ ] Password reset: 3 attempts per hour
- [ ] Account creation: 1 attempt per 5 minutes per IP
- [ ] Financial operations: 5 transactions per minute
- [ ] Admin operations: Strict monitoring required

## GDPR/CCPA Compliance

### Data Privacy
- [ ] Implement data minimization principles
- [ ] Provide clear privacy notices
- [ ] Enable user data export functionality
- [ ] Support data deletion requests

### User Consent
- [ ] Obtain explicit consent for data processing
- [ ] Provide opt-out mechanisms
- [ ] Track consent preferences
- [ ] Regular consent renewal where required

## Security Logging

### Required Security Events
- [ ] Authentication attempts (success/failure)
- [ ] Authorization failures
- [ ] Input validation failures
- [ ] Rate limit violations
- [ ] Suspicious activity patterns

### Log Security
- [ ] Do not log sensitive data (passwords, tokens)
- [ ] Use structured logging format
- [ ] Implement log tampering protection
- [ ] Regular log backup and archival

## Common Security Patterns

### Input Sanitization
```dart
// Always sanitize user input
final sanitizedInput = SecurityUtils.sanitizeInput(userInput);
```

### Authentication Check
```dart
// Verify authentication before sensitive operations
if (!AuthGuard.isAuthenticated()) {
  throw AuthError.sessionExpired();
}
```

### Rate Limit Check
```dart
// Check rate limits before processing
if (!RateLimiter.checkLimit(principal, operation)) {
  throw BusinessLogicError.rateLimitExceeded();
}
```

### Validation Pattern
```dart
// Comprehensive input validation
final validationResult = await InputValidator.validate(
  email: email,
  password: password,
  additionalFields: {...}
);

if (!validationResult.isValid) {
  throw ValidationError.invalidInput(validationResult.errors);
}
```

## Pre-Deploy Security Review

- [ ] All user inputs validated
- [ ] Auth guards applied to protected routes
- [ ] Rate limiting implemented for abuse-prone endpoints
- [ ] Security logging in place
- [ ] Error messages do not leak sensitive information
- [ ] HTTPS enforced for all communications
- [ ] Security headers properly configured
- [ ] Dependencies scanned for vulnerabilities

## References

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Flutter Security Best Practices](https://flutter.dev/docs/security)
- [GDPR Compliance Guide](https://gdpr.eu/)
- [CCPA Compliance Requirements](https://oag.ca.gov/privacy/ccpa)
