import '../constants/app_strings.dart';

/// Comprehensive input validation utility class
/// Provides validation methods with user-friendly error messages
class InputValidator {
  InputValidator._();

  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.fieldRequired;
    }
    
    final email = value.trim();
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    
    if (!emailRegex.hasMatch(email)) {
      return AppStrings.invalidEmail;
    }
    
    return null;
  }

  // Enhanced password validation with security requirements
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.fieldRequired;
    }
    
    if (value.length < 12) {
      return AppStrings.passwordTooShort;
    }
    
    // Check complexity requirements
    if (!_hasPasswordComplexity(value)) {
      return AppStrings.passwordComplexityRequired;
    }
    
    // Check for weak patterns
    if (_hasWeakPasswordPattern(value)) {
      return AppStrings.passwordTooWeak;
    }
    
    return null;
  }

  // Password complexity checker
  static bool _hasPasswordComplexity(String password) {
    bool hasUpperCase = password.contains(RegExp(r'[A-Z]'));
    bool hasLowerCase = password.contains(RegExp(r'[a-z]'));
    bool hasDigits = password.contains(RegExp(r'[0-9]'));
    bool hasSpecialCharacters = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    
    // Require at least 3 of 4 character types
    int complexity = 0;
    if (hasUpperCase) complexity++;
    if (hasLowerCase) complexity++;
    if (hasDigits) complexity++;
    if (hasSpecialCharacters) complexity++;
    
    return complexity >= 3;
  }

  // Weak password pattern detection
  static bool _hasWeakPasswordPattern(String password) {
    final lowercasePassword = password.toLowerCase();
    
    // Common weak passwords
    const weakPatterns = [
      'password', '123456', 'qwerty', 'abc123', 'admin', 'welcome',
      'letmein', 'monkey', 'dragon', 'master', 'shadow', 'password123',
      'collabfuture', 'education', 'student'
    ];
    
    for (final pattern in weakPatterns) {
      if (lowercasePassword.contains(pattern)) return true;
    }
    
    // Keyboard patterns
    const keyboardPatterns = [
      'qwertyuiop', 'asdfghjkl', 'zxcvbnm', '1234567890'
    ];
    
    for (final pattern in keyboardPatterns) {
      if (lowercasePassword.contains(pattern.substring(0, 4))) return true;
    }
    
    // Repeated characters (3+ in a row)
    if (RegExp(r'(.)\1{2,}').hasMatch(password)) return true;
    
    return false;
  }

  // Confirm password validation
  static String? validateConfirmPassword(String? value, String originalPassword) {
    if (value == null || value.isEmpty) {
      return AppStrings.fieldRequired;
    }
    
    if (value != originalPassword) {
      return AppStrings.passwordsDoNotMatch;
    }
    
    return null;
  }

  // Name validation
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.nameRequired;
    }
    
    final name = value.trim();
    if (name.length < 2) {
      return 'Name must be at least 2 characters';
    }
    
    // Check for valid characters (letters, spaces, hyphens, apostrophes)
    final nameRegex = RegExp(r"^[a-zA-Z\s\-']+$");
    if (!nameRegex.hasMatch(name)) {
      return 'Name can only contain letters, spaces, hyphens, and apostrophes';
    }
    
    return null;
  }

  // Phone number validation
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.phoneRequired;
    }
    
    final phone = value.trim().replaceAll(RegExp(r'[^\d]'), '');
    
    if (phone.length < 10 || phone.length > 15) {
      return AppStrings.invalidPhone;
    }
    
    return null;
  }

  // Enhanced PIN validation with security checks
  static String? validatePIN(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.fieldRequired;
    }
    
    if (value.length < 4 || value.length > 8) {
      return AppStrings.pinTooShort;
    }
    
    // Check if PIN contains only digits
    final pinRegex = RegExp(r'^\d+$');
    if (!pinRegex.hasMatch(value)) {
      return 'PIN can only contain numbers';
    }
    
    // Check for weak PIN patterns
    if (_hasWeakPINPattern(value)) {
      return AppStrings.pinTooWeak;
    }
    
    return null;
  }

  // Weak PIN pattern detection
  static bool _hasWeakPINPattern(String pin) {
    // All same digits
    if (RegExp(r'^(\d)\1+$').hasMatch(pin)) return true;
    
    // Sequential patterns (ascending or descending)
    bool isSequential = true;
    for (int i = 0; i < pin.length - 1; i++) {
      final current = int.parse(pin[i]);
      final next = int.parse(pin[i + 1]);
      if ((next - current).abs() != 1) {
        isSequential = false;
        break;
      }
    }
    if (isSequential) return true;
    
    // Common weak PINs
    const weakPins = [
      '0000', '1111', '2222', '3333', '4444', '5555', 
      '6666', '7777', '8888', '9999', '1234', '4321', 
      '0123', '3210', '1357', '2468', '1122', '2233'
    ];
    
    return weakPins.contains(pin);
  }

  // Generic required field validation
  static String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null ? '$fieldName is required' : AppStrings.fieldRequired;
    }
    return null;
  }

  // Text length validation
  static String? validateLength(String? value, {
    int? minLength,
    int? maxLength,
    String? fieldName,
  }) {
    if (value == null) return AppStrings.fieldRequired;
    
    if (minLength != null && value.length < minLength) {
      return '${fieldName ?? 'Field'} must be at least $minLength characters';
    }
    
    if (maxLength != null && value.length > maxLength) {
      return '${fieldName ?? 'Field'} must not exceed $maxLength characters';
    }
    
    return null;
  }

  // URL validation
  static String? validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.fieldRequired;
    }
    
    final urlRegex = RegExp(
      r'^https?:\/\/(?:www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b(?:[-a-zA-Z0-9()@:%_\+.~#?&=]*)$'
    );
    
    if (!urlRegex.hasMatch(value.trim())) {
      return 'Please enter a valid URL';
    }
    
    return null;
  }

  // Age validation
  static String? validateAge(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.fieldRequired;
    }
    
    final age = int.tryParse(value.trim());
    if (age == null) {
      return 'Please enter a valid age';
    }
    
    if (age < 13 || age > 120) {
      return 'Please enter a valid age between 13 and 120';
    }
    
    return null;
  }

  // Date validation (for future dates like deadlines)
  static String? validateFutureDate(DateTime? value) {
    if (value == null) {
      return AppStrings.fieldRequired;
    }
    
    if (value.isBefore(DateTime.now())) {
      return 'Please select a future date';
    }
    
    return null;
  }

  // Custom validation for specific patterns
  static String? validatePattern(String? value, RegExp pattern, String errorMessage) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.fieldRequired;
    }
    
    if (!pattern.hasMatch(value.trim())) {
      return errorMessage;
    }
    
    return null;
  }

  // Enhanced input sanitization
  static String sanitizeInput(String input) {
    return input
        .trim()
        .replaceAll(RegExp(r'<[^>]*>'), '') // Remove HTML tags
        .replaceAll(RegExp(r'[<>&"\'`]'), '') // Remove potentially dangerous characters
        .replaceAll(RegExp(r'\s+'), ' ') // Normalize whitespace
        .replaceAll(RegExp(r'[\x00-\x1F\x7F]'), ''); // Remove control characters
  }

  // Enhanced security check for malicious content
  static bool isSafeInput(String input) {
    final dangerousPatterns = [
      RegExp(r'<script', caseSensitive: false),
      RegExp(r'javascript:', caseSensitive: false),
      RegExp(r'on\w+\s*=', caseSensitive: false),
      RegExp(r'<iframe', caseSensitive: false),
      RegExp(r'<object', caseSensitive: false),
      RegExp(r'<embed', caseSensitive: false),
      RegExp(r'eval\s*\(', caseSensitive: false),
      RegExp(r'expression\s*\(', caseSensitive: false),
      RegExp(r'vbscript:', caseSensitive: false),
    ];
    
    for (final pattern in dangerousPatterns) {
      if (pattern.hasMatch(input)) {
        return false;
      }
    }
    
    return true;
  }

  // Validate and sanitize input in one step
  static String? validateAndSanitize(String? value, {
    bool required = true,
    int? minLength,
    int? maxLength,
    RegExp? pattern,
    String? patternError,
  }) {
    if (value == null || value.trim().isEmpty) {
      return required ? AppStrings.fieldRequired : null;
    }
    
    final sanitized = sanitizeInput(value);
    
    if (!isSafeInput(sanitized)) {
      return AppStrings.invalidInput;
    }
    
    if (minLength != null && sanitized.length < minLength) {
      return 'Must be at least $minLength characters';
    }
    
    if (maxLength != null && sanitized.length > maxLength) {
      return 'Must not exceed $maxLength characters';
    }
    
    if (pattern != null && !pattern.hasMatch(sanitized)) {
      return patternError ?? AppStrings.invalidInput;
    }
    
    return null;
  }
}