import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import './supabase_service.dart';

class SecurityService {
  static SecurityService? _instance;
  static SecurityService get instance => _instance ??= SecurityService._();
  SecurityService._();

  final SupabaseClient _client = SupabaseService.instance.client;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Secure encryption setup using environment variables
  late final Encrypter _encrypter;
  late final IV _iv;

  // Initialize encryption with environment-based key
  Future<void> _initializeEncryption() async {
    // Get encryption key from environment or generate a secure one
    const String envKey = String.fromEnvironment('ENCRYPTION_KEY');

    String encryptionKey;
    if (envKey.isNotEmpty && envKey.length >= 32) {
      encryptionKey = envKey;
    } else {
      // Generate a device-specific key if environment key not available
      encryptionKey = await _generateDeviceSpecificKey();
    }

    // Ensure key is exactly 32 characters for AES-256
    if (encryptionKey.length > 32) {
      encryptionKey = encryptionKey.substring(0, 32);
    } else if (encryptionKey.length < 32) {
      encryptionKey = encryptionKey.padRight(32, '0');
    }

    final key = Key.fromBase64(base64.encode(encryptionKey.codeUnits));
    _encrypter = Encrypter(AES(key));
    _iv = IV.fromSecureRandom(16);
  }

  // Generate device-specific encryption key
  Future<String> _generateDeviceSpecificKey() async {
    const String storedKeyName = 'device_encryption_key';

    // Try to get existing key
    String? existingKey = await _secureStorage.read(key: storedKeyName);

    if (existingKey != null && existingKey.length >= 32) {
      return existingKey;
    }

    // Generate new secure key
    final random = Random.secure();
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*';
    final key = String.fromCharCodes(Iterable.generate(
        32, (_) => chars.codeUnitAt(random.nextInt(chars.length))));

    // Store securely for future use
    await _secureStorage.write(key: storedKeyName, value: key);

    return key;
  }

  // Security settings keys
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _pinEnabledKey = 'pin_enabled';
  static const String _backgroundBlurKey = 'background_blur_enabled';
  static const String _twoFactorEnabledKey = 'two_factor_enabled';
  static const String _userPinKey = 'user_pin_secure';
  static const String _failedAttemptsKey = 'failed_attempts';
  static const String _lastLockTimeKey = 'last_lock_time';
  static const String _pinHashKey = 'pin_hash_secure';

  // Get current user ID
  String? get _currentUserId => _client.auth.currentUser?.id;

  // Security Settings Management
  Future<Map<String, dynamic>?> getSecuritySettings() async {
    if (_currentUserId == null) return null;

    try {
      final response = await _client
          .from('security_settings')
          .select()
          .eq('user_id', _currentUserId!)
          .single();

      return response;
    } catch (error) {
      return null; // Return null instead of throwing error for better UX
    }
  }

  Future<void> updateSecuritySettings({
    bool? biometricEnabled,
    bool? pinEnabled,
    bool? backgroundBlurEnabled,
    bool? twoFactorEnabled,
    String? emergencyContactEmail,
  }) async {
    if (_currentUserId == null) return;

    try {
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (biometricEnabled != null)
        updates['biometric_enabled'] = biometricEnabled;
      if (pinEnabled != null) updates['pin_enabled'] = pinEnabled;
      if (backgroundBlurEnabled != null)
        updates['background_blur_enabled'] = backgroundBlurEnabled;
      if (twoFactorEnabled != null)
        updates['two_factor_enabled'] = twoFactorEnabled;
      if (emergencyContactEmail != null)
        updates['emergency_contact_email'] = emergencyContactEmail;

      await _client.from('security_settings').upsert({
        'user_id': _currentUserId!,
        ...updates,
      });

      // Update local preferences
      await _updateLocalSecuritySettings(updates);

      // Log security event
      await _logSecurityEvent('settings_change', 'Security settings updated');

      // Recalculate security score
      await _updateSecurityScore();
    } catch (error) {
      // Silently handle error to not disrupt user flow
      print('Security settings update failed: ${_sanitizeError(error)}');
    }
  }

  // Local Security Settings (for offline access)
  Future<void> _updateLocalSecuritySettings(
      Map<String, dynamic> settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (settings['biometric_enabled'] != null) {
        await prefs.setBool(
            _biometricEnabledKey, settings['biometric_enabled']);
      }
      if (settings['pin_enabled'] != null) {
        await prefs.setBool(_pinEnabledKey, settings['pin_enabled']);
      }
      if (settings['background_blur_enabled'] != null) {
        await prefs.setBool(
            _backgroundBlurKey, settings['background_blur_enabled']);
      }
      if (settings['two_factor_enabled'] != null) {
        await prefs.setBool(
            _twoFactorEnabledKey, settings['two_factor_enabled']);
      }
    } catch (error) {
      // Silently handle local storage errors
      print('Local settings update failed');
    }
  }

  Future<bool> isBiometricEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_biometricEnabledKey) ?? false;
    } catch (error) {
      return false;
    }
  }

  Future<bool> isPinEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_pinEnabledKey) ?? false;
    } catch (error) {
      return false;
    }
  }

  Future<bool> isBackgroundBlurEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_backgroundBlurKey) ?? true;
    } catch (error) {
      return true; // Default to enabled for security
    }
  }

  // Secure PIN Management with proper hashing and encryption
  Future<void> setPIN(String pin) async {
    try {
      // Validate PIN strength
      if (!_isValidPIN(pin)) {
        throw Exception(
            'PIN must be 4-8 digits with no repeating or sequential patterns');
      }

      await _initializeEncryption();

      // Hash the PIN for secure storage
      final pinHash = _hashPIN(pin);

      // Store hashed PIN in secure storage
      await _secureStorage.write(key: _pinHashKey, value: pinHash);

      // Also encrypt original PIN for verification
      final encryptedPin = _encrypter.encrypt(pin, iv: _iv);
      await _secureStorage.write(key: _userPinKey, value: encryptedPin.base64);

      await updateSecuritySettings(pinEnabled: true);
    } catch (error) {
      throw Exception('Unable to set PIN. Please try again.');
    }
  }

  // Validate PIN strength
  bool _isValidPIN(String pin) {
    if (pin.length < 4 || pin.length > 8) return false;
    if (!RegExp(r'^\d+$').hasMatch(pin)) return false;

    // Check for weak patterns
    if (_hasWeakPattern(pin)) return false;

    return true;
  }

  // Check for weak PIN patterns
  bool _hasWeakPattern(String pin) {
    // Check for all same digits
    if (RegExp(r'^(\d)\1+$').hasMatch(pin)) return true;

    // Check for sequential patterns (1234, 4321)
    for (int i = 0; i < pin.length - 1; i++) {
      final current = int.parse(pin[i]);
      final next = int.parse(pin[i + 1]);
      if ((next - current).abs() != 1) break;
      if (i == pin.length - 2) return true; // All digits are sequential
    }

    // Check for common weak PINs
    const weakPins = [
      '0000',
      '1111',
      '2222',
      '3333',
      '4444',
      '5555',
      '6666',
      '7777',
      '8888',
      '9999',
      '1234',
      '4321',
      '0123',
      '3210',
      '1357',
      '2468'
    ];
    if (weakPins.contains(pin)) return true;

    return false;
  }

  // Hash PIN using SHA-256 with salt
  String _hashPIN(String pin) {
    const String appSecret = String.fromEnvironment('APP_SECRET_KEY',
        defaultValue: 'fallback_secret_key_for_hashing');
    final salt = '$appSecret:${_currentUserId ?? 'anonymous'}';
    final bytes = utf8.encode(pin + salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<bool> verifyPIN(String pin) async {
    try {
      // First try hash-based verification (more secure)
      final storedHash = await _secureStorage.read(key: _pinHashKey);
      if (storedHash != null) {
        final inputHash = _hashPIN(pin);
        return inputHash == storedHash;
      }

      // Fallback to encrypted verification for backward compatibility
      final storedEncrypted = await _secureStorage.read(key: _userPinKey);
      if (storedEncrypted == null) return false;

      await _initializeEncryption();
      final encrypted = Encrypted.fromBase64(storedEncrypted);
      final decryptedPin = _encrypter.decrypt(encrypted, iv: _iv);
      return decryptedPin == pin;
    } catch (error) {
      return false;
    }
  }

  Future<void> removePIN() async {
    try {
      await _secureStorage.delete(key: _userPinKey);
      await _secureStorage.delete(key: _pinHashKey);
      await updateSecuritySettings(pinEnabled: false);
    } catch (error) {
      throw Exception('Unable to remove PIN. Please try again.');
    }
  }

  // Enhanced Failed Attempts Management with progressive lockout
  Future<int> getFailedAttempts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_failedAttemptsKey) ?? 0;
    } catch (error) {
      return 0;
    }
  }

  Future<void> incrementFailedAttempts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final attempts = await getFailedAttempts();
      final newAttempts = attempts + 1;
      await prefs.setInt(_failedAttemptsKey, newAttempts);

      await _logSecurityEvent(
          'failed_attempt', 'Authentication failed - attempt $newAttempts');

      // Progressive lockout: 3 attempts = 5 min, 5 attempts = 30 min, 7+ attempts = 2 hours
      if (newAttempts >= 7) {
        await _lockAccount(Duration(hours: 2));
      } else if (newAttempts >= 5) {
        await _lockAccount(Duration(minutes: 30));
      } else if (newAttempts >= 3) {
        await _lockAccount(Duration(minutes: 5));
      }
    } catch (error) {
      // Silently handle error
    }
  }

  Future<void> resetFailedAttempts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_failedAttemptsKey);
    } catch (error) {
      // Silently handle error
    }
  }

  Future<void> _lockAccount([Duration? lockDuration]) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lockUntil =
          DateTime.now().add(lockDuration ?? Duration(minutes: 30));
      await prefs.setString(_lastLockTimeKey, lockUntil.toIso8601String());

      if (_currentUserId != null) {
        await _client.from('security_settings').update({
          'locked_until': lockUntil.toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('user_id', _currentUserId!);
      }

      await _logSecurityEvent('account_locked',
          'Account locked until ${lockUntil.toIso8601String()}');
    } catch (error) {
      // Silently handle error
    }
  }

  Future<bool> isAccountLocked() async {
    if (_currentUserId == null) return false;

    try {
      // Check local lock first
      final prefs = await SharedPreferences.getInstance();
      final localLockString = prefs.getString(_lastLockTimeKey);
      if (localLockString != null) {
        final localLockUntil = DateTime.parse(localLockString);
        if (DateTime.now().isBefore(localLockUntil)) {
          return true;
        }
      }

      // Check remote lock
      final settings = await getSecuritySettings();
      if (settings == null || settings['locked_until'] == null) return false;

      final lockUntil = DateTime.parse(settings['locked_until']);
      return DateTime.now().isBefore(lockUntil);
    } catch (error) {
      return false;
    }
  }

  // Session Management
  Future<String?> createSession({
    required String deviceId,
    String? deviceName,
    String deviceType = 'mobile',
    String? ipAddress,
    String? userAgent,
  }) async {
    if (_currentUserId == null) return null;

    try {
      final response = await _client
          .from('user_sessions')
          .insert({
            'user_id': _currentUserId!,
            'device_id': deviceId,
            'device_name': deviceName,
            'device_type': deviceType,
            'ip_address': ipAddress,
            'user_agent': userAgent,
            'status': 'active',
            'expires_at':
                DateTime.now().add(const Duration(days: 30)).toIso8601String(),
          })
          .select()
          .single();

      await _logSecurityEvent('session_created', 'New session created');

      return response['id'];
    } catch (error) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getUserSessions() async {
    if (_currentUserId == null) return [];

    try {
      final response = await _client
          .from('user_sessions')
          .select()
          .eq('user_id', _currentUserId!)
          .eq('status', 'active')
          .order('last_activity', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      return [];
    }
  }

  Future<void> revokeSession(String sessionId) async {
    try {
      await _client.from('user_sessions').update({
        'status': 'revoked',
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', sessionId);

      await _logSecurityEvent('session_revoked', 'Session revoked manually');
    } catch (error) {
      throw Exception('Unable to revoke session. Please try again.');
    }
  }

  Future<void> revokeAllSessions() async {
    if (_currentUserId == null) return;

    try {
      await _client
          .from('user_sessions')
          .update({
            'status': 'revoked',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', _currentUserId!)
          .eq('status', 'active');

      await _logSecurityEvent('all_sessions_revoked', 'All sessions revoked');
    } catch (error) {
      throw Exception('Unable to revoke sessions. Please try again.');
    }
  }

  // Enhanced Encrypted Storage using secure encryption
  Future<void> storeEncryptedData(String key, String value) async {
    if (_currentUserId == null) return;

    try {
      await _initializeEncryption();
      final encryptedValue = _encrypter.encrypt(value, iv: _iv);

      await _client.from('encrypted_storage').upsert({
        'user_id': _currentUserId!,
        'storage_key': key,
        'encrypted_value': encryptedValue.base64,
        'iv': _iv.base64,
        'encryption_method': 'AES-256-CBC',
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (error) {
      throw Exception('Unable to store data securely. Please try again.');
    }
  }

  Future<String?> getEncryptedData(String key) async {
    if (_currentUserId == null) return null;

    try {
      final response = await _client
          .from('encrypted_storage')
          .select('encrypted_value, iv')
          .eq('user_id', _currentUserId!)
          .eq('storage_key', key)
          .single();

      await _initializeEncryption();

      // Use stored IV if available, otherwise use current IV
      final storedIv =
          response['iv'] != null ? IV.fromBase64(response['iv']) : _iv;

      final encrypted = Encrypted.fromBase64(response['encrypted_value']);
      return _encrypter.decrypt(encrypted, iv: storedIv);
    } catch (error) {
      return null;
    }
  }

  Future<void> deleteEncryptedData(String key) async {
    if (_currentUserId == null) return;

    try {
      await _client
          .from('encrypted_storage')
          .delete()
          .eq('user_id', _currentUserId!)
          .eq('storage_key', key);
    } catch (error) {
      throw Exception('Unable to delete data. Please try again.');
    }
  }

  // Security Audit
  Future<void> _logSecurityEvent(String eventType, String description) async {
    if (_currentUserId == null) return;

    try {
      await _client.from('security_audit_log').insert({
        'user_id': _currentUserId!,
        'event_type': eventType,
        'event_description': description,
        'ip_address': await _getClientIP(),
        'user_agent': await _getUserAgent(),
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (error) {
      // Silently fail logging to not interrupt main flow
    }
  }

  // Get client IP (placeholder - implement based on your needs)
  Future<String?> _getClientIP() async {
    try {
      // This would require additional packages for real IP detection
      return null;
    } catch (error) {
      return null;
    }
  }

  // Get user agent (placeholder - implement based on your needs)
  Future<String?> _getUserAgent() async {
    try {
      // This would require platform-specific detection
      return 'CollabFuture Mobile App';
    } catch (error) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getSecurityAuditLog({
    int limit = 50,
    String? eventType,
  }) async {
    if (_currentUserId == null) return [];

    try {
      // Build query with optional eventType filter
      var builder = _client
          .from('security_audit_log')
          .select()
          .eq('user_id', _currentUserId!);

      if (eventType != null) {
        builder = builder.eq('event_type', eventType);
      }

      final response = await builder
          .order('created_at', ascending: false)
          .limit(limit);
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      return [];
    }
  }

  // Enhanced Security Score calculation
  Future<void> _updateSecurityScore() async {
    if (_currentUserId == null) return;

    try {
      // Calculate security score based on enabled features and security strength
      int score = 20; // Base score (lowered due to security improvements)

      // Biometric authentication
      if (await isBiometricEnabled()) score += 25;

      // PIN security
      if (await isPinEnabled()) {
        score += 20;
        // Bonus for strong PIN (if we can verify without exposing it)
        score += 5; // Assume strong PIN if set through new system
      }

      // Background blur
      if (await isBackgroundBlurEnabled()) score += 10;

      // Two-factor authentication
      final settings = await getSecuritySettings();
      if (settings?['two_factor_enabled'] == true) score += 30;

      // Account not recently locked
      if (!(await isAccountLocked())) score += 5;

      // Regular security activity (has audit logs)
      final recentLogs = await getSecurityAuditLog(limit: 5);
      if (recentLogs.isNotEmpty) score += 5;

      // Cap at 100
      score = score > 100 ? 100 : score;

      await _client.from('security_settings').update({
        'security_score': score,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('user_id', _currentUserId!);
    } catch (error) {
      // Silently fail to not interrupt main flow
    }
  }

  Future<int> getSecurityScore() async {
    try {
      final settings = await getSecuritySettings();
      return settings?['security_score'] ??
          20; // Lowered default for improved security baseline
    } catch (error) {
      return 20;
    }
  }

  // Input validation and sanitization
  String _sanitizeError(dynamic error) {
    final errorString = error.toString();
    // Remove sensitive information from error messages
    return errorString
        .replaceAll(
            RegExp(r'password[^\s]*', caseSensitive: false), '[REDACTED]')
        .replaceAll(RegExp(r'key[^\s]*', caseSensitive: false), '[REDACTED]')
        .replaceAll(RegExp(r'token[^\s]*', caseSensitive: false), '[REDACTED]')
        .replaceAll(RegExp(r'pin[^\s]*', caseSensitive: false), '[REDACTED]');
  }

  // Cleanup
  Future<void> clearAllSecurityData() async {
    try {
      await _secureStorage.deleteAll();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_failedAttemptsKey);
      await prefs.remove(_lastLockTimeKey);
      await prefs.remove(_biometricEnabledKey);
      await prefs.remove(_pinEnabledKey);
      await prefs.remove(_backgroundBlurKey);
      await prefs.remove(_twoFactorEnabledKey);
    } catch (error) {
      // Silently handle error
    }
  }
}
