import 'package:flutter_test/flutter_test.dart';
import 'package:crypto_market/shared/utils/validators.dart';

void main() {
  group('EmailValidator', () {
    test('should validate correct email formats', () {
      final validEmails = [
        'test@example.com',
        'user.name@domain.co.uk',
        'user+tag@gmail.com',
        'test123@subdomain.example.org',
      ];

      for (final email in validEmails) {
        final result = EmailValidator.validate(email);
        expect(result.isValid, isTrue, reason: 'Should accept: $email');
      }
    });

    test('should reject invalid email formats', () {
      final invalidEmails = [
        'invalid',
        '@example.com',
        'test@',
        'test@example',
        '',
        null,
      ];

      for (final email in invalidEmails) {
        final result = EmailValidator.validate(email);
        expect(result.isValid, isFalse, reason: 'Should reject: $email');
      }
    });

    test('should reject emails that are too long', () {
      final longEmail = '${'a' * 250}@example.com'; // Over 254 character limit
      final result = EmailValidator.validate(longEmail);

      expect(result.isValid, isFalse);
      expect(result.errors.first, contains('less than 254 characters'));
    });

    test('should sanitize email input', () {
      const input = '  Test@Example.COM  ';
      final sanitized = EmailValidator.sanitize(input);

      expect(sanitized, equals('test@example.com'));
    });

    test('should return appropriate error messages', () {
      // Test empty email
      var result = EmailValidator.validate(null);
      expect(result.fieldErrors['email'], equals('Email is required'));

      // Test invalid format
      result = EmailValidator.validate('invalid-email');
      expect(result.fieldErrors['email'], contains('valid email address'));

      // Test too long
      result = EmailValidator.validate('${'a' * 250}@example.com');
      expect(result.fieldErrors['email'], contains('less than 254 characters'));
    });
  });

  group('PasswordValidator', () {
    test('should validate strong passwords', () {
      final strongPasswords = [
        'MyP@ssw0rd123',
        'ComplexP@ss1',
        'SecureT3st!',
        'Str0ng&Valid',
      ];

      for (final password in strongPasswords) {
        final result = PasswordValidator.validate(password);
        expect(result.isValid, isTrue, reason: 'Should accept: $password');
      }
    });

    test('should reject weak passwords', () {
      final weakPasswords = [
        'password', // No uppercase, digits, special chars
        '12345678', // No letters
        'PASSWORD', // No lowercase, digits, special chars
        'Pass1', // Too short
        '', // Empty
        null, // Null
      ];

      for (final password in weakPasswords) {
        final result = PasswordValidator.validate(password);
        expect(result.isValid, isFalse, reason: 'Should reject: $password');
      }
    });

    test('should check password strength score', () {
      expect(
        PasswordValidator.getStrengthScore('password'),
        equals(1),
      ); // Only length
      expect(
        PasswordValidator.getStrengthScore('Password'),
        equals(2),
      ); // Length + case
      expect(
        PasswordValidator.getStrengthScore('Password1'),
        equals(3),
      ); // + digit
      expect(
        PasswordValidator.getStrengthScore('Password1!'),
        equals(4),
      ); // + special
    });

    test('should return appropriate strength labels', () {
      expect(PasswordValidator.getStrengthLabel(0), equals('Weak'));
      expect(PasswordValidator.getStrengthLabel(1), equals('Weak'));
      expect(PasswordValidator.getStrengthLabel(2), equals('Fair'));
      expect(PasswordValidator.getStrengthLabel(3), equals('Good'));
      expect(PasswordValidator.getStrengthLabel(4), equals('Strong'));
    });

    test('should provide detailed validation errors', () {
      final result = PasswordValidator.validate('pass');

      expect(result.isValid, isFalse);
      expect(result.errors, contains('Password must be at least 8 characters long'));
      expect(result.errors, contains('Password must contain at least one uppercase letter'));
      expect(result.errors, contains('Password must contain at least one digit'));
      expect(result.errors, contains('Password must contain at least one special character'));
    });
  });

  group('StringValidator', () {
    test('should validate string length correctly', () {
      // Valid length
      var result = StringValidator.validateLength(
        'valid string',
        'Test Field',
        minLength: 5,
        maxLength: 20,
      );
      expect(result.isValid, isTrue);

      // Too short
      result = StringValidator.validateLength('hi', 'Name', minLength: 5);
      expect(result.isValid, isFalse);
      expect(result.errors.first, contains('at least 5 characters'));

      // Too long
      result = StringValidator.validateLength(
        'this is way too long',
        'Title',
        maxLength: 10,
      );
      expect(result.isValid, isFalse);
      expect(result.errors.first, contains('less than 10 characters'));
    });

    test('should handle empty strings based on allowEmpty flag', () {
      // Empty not allowed (default)
      var result = StringValidator.validateLength('', 'Field');
      expect(result.isValid, isFalse);

      // Empty allowed
      result = StringValidator.validateLength('', 'Field', allowEmpty: true);
      expect(result.isValid, isTrue);
    });

    test('should validate patterns correctly', () {
      final alphaPattern = RegExp(r'^[a-zA-Z]+$');

      // Valid pattern
      var result = StringValidator.validatePattern(
        'ValidText',
        'Name',
        alphaPattern,
        'Only letters allowed',
      );
      expect(result.isValid, isTrue);

      // Invalid pattern
      result = StringValidator.validatePattern(
        'Invalid123',
        'Name',
        alphaPattern,
        'Only letters allowed',
      );
      expect(result.isValid, isFalse);
      expect(result.errors.first, equals('Only letters allowed'));
    });

    test('should sanitize strings', () {
      expect(StringValidator.sanitize('  text  '), equals('text'));
      expect(StringValidator.sanitize('\n\ttext\n\t'), equals('text'));
    });
  });

  group('NumericValidator', () {
    test('should validate numeric ranges', () {
      // Valid range
      var result = NumericValidator.validateRange(50, 'Age', min: 18, max: 100);
      expect(result.isValid, isTrue);

      // Below minimum
      result = NumericValidator.validateRange(10, 'Age', min: 18);
      expect(result.isValid, isFalse);
      expect(result.errors.first, contains('at least 18'));

      // Above maximum
      result = NumericValidator.validateRange(150, 'Age', max: 100);
      expect(result.isValid, isFalse);
      expect(result.errors.first, contains('at most 100'));
    });

    test('should validate positive numbers', () {
      expect(NumericValidator.validatePositive(10, 'Price').isValid, isTrue);
      expect(NumericValidator.validatePositive(0, 'Price').isValid, isFalse);
      expect(NumericValidator.validatePositive(-5, 'Price').isValid, isFalse);
    });

    test('should validate integer strings', () {
      expect(NumericValidator.validateInteger('123', 'Count').isValid, isTrue);
      expect(
        NumericValidator.validateInteger('12.5', 'Count').isValid,
        isFalse,
      );
      expect(NumericValidator.validateInteger('abc', 'Count').isValid, isFalse);
      expect(NumericValidator.validateInteger('', 'Count').isValid, isFalse);
    });

    test('should validate decimal strings with precision', () {
      // Valid decimal
      var result = NumericValidator.validateDecimal(
        '12.34',
        'Price',
        decimalPlaces: 2,
      );
      expect(result.isValid, isTrue);

      // Too many decimal places
      result = NumericValidator.validateDecimal(
        '12.345',
        'Price',
        decimalPlaces: 2,
      );
      expect(result.isValid, isFalse);
      expect(result.errors.first, contains('at most 2 decimal places'));

      // Invalid format
      result = NumericValidator.validateDecimal('abc', 'Price');
      expect(result.isValid, isFalse);
      expect(result.errors.first, contains('valid number'));
    });
  });

  group('InputValidator', () {
    test('should validate login form correctly', () {
      // Valid login
      var result = InputValidator.validateLogin(
        email: 'test@example.com',
        password: 'validpassword',
      );
      expect(result.isValid, isTrue);

      // Invalid email
      result = InputValidator.validateLogin(
        email: 'invalid-email',
        password: 'validpassword',
      );
      expect(result.isValid, isFalse);
      expect(result.fieldErrors.containsKey('email'), isTrue);

      // Missing password
      result = InputValidator.validateLogin(
        email: 'test@example.com',
        password: null,
      );
      expect(result.isValid, isFalse);
      expect(result.fieldErrors.containsKey('password'), isTrue);
    });

    test('should validate registration form correctly', () {
      // Valid registration
      var result = InputValidator.validateRegistration(
        email: 'test@example.com',
        password: 'StrongP@ss1',
        confirmPassword: 'StrongP@ss1',
        firstName: 'John',
        lastName: 'Doe',
      );
      expect(result.isValid, isTrue);

      // Passwords don't match
      result = InputValidator.validateRegistration(
        email: 'test@example.com',
        password: 'StrongP@ss1',
        confirmPassword: 'DifferentP@ss1',
      );
      expect(result.isValid, isFalse);
      expect(result.fieldErrors.containsKey('confirmPassword'), isTrue);

      // Weak password
      result = InputValidator.validateRegistration(
        email: 'test@example.com',
        password: 'weak',
        confirmPassword: 'weak',
      );
      expect(result.isValid, isFalse);
      expect(result.fieldErrors.containsKey('password'), isTrue);
    });
  });

  group('SecurityUtils', () {
    test('should sanitize potentially dangerous input', () {
      const maliciousInput = '<script>alert("xss")</script>Hello';
      final sanitized = SecurityUtils.sanitizeInput(maliciousInput);

      expect(sanitized, isNot(contains('<script>')));
      expect(sanitized, isNot(contains('javascript:')));
    });

    test('should detect suspicious input patterns', () {
      final suspiciousInputs = [
        '<script>alert("xss")</script>',
        'javascript:void(0)',
        'onclick=alert(1)',
        '<iframe src="evil.com"></iframe>',
      ];

      for (final input in suspiciousInputs) {
        final result = SecurityUtils.validateSecureInput(input, 'TestField');
        expect(result.isValid, isFalse, reason: 'Should detect: $input');
      }
    });

    test('should allow safe input', () {
      final safeInputs = [
        'Hello World',
        'user@example.com',
        'Valid text with numbers 123',
        'Special chars: !@#%^&*()',
      ];

      for (final input in safeInputs) {
        final result = SecurityUtils.validateSecureInput(input, 'TestField');
        expect(result.isValid, isTrue, reason: 'Should allow: $input');
      }
    });
  });

  group('ValidationResult', () {
    test('should create success result correctly', () {
      const result = ValidationResult.success();

      expect(result.isValid, isTrue);
      expect(result.errors, isEmpty);
      expect(result.fieldErrors, isEmpty);
      expect(result.firstError, isNull);
    });

    test('should create failure result correctly', () {
      const errors = ['Error 1', 'Error 2'];
      const fieldErrors = {'field1': 'Field error'};
      const result = ValidationResult.failure(errors, fieldErrors: fieldErrors);

      expect(result.isValid, isFalse);
      expect(result.errors, equals(errors));
      expect(result.fieldErrors, equals(fieldErrors));
      expect(result.firstError, equals('Error 1'));
      expect(result.getFieldError('field1'), equals('Field error'));
    });
  });
}
