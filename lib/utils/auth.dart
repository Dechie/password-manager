import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'crypto_utils.dart';

/// Result of a PIN check, distinguishing a wrong PIN from a lockout.
enum PinResult { ok, wrong, lockedOut }

class AuthService {
  static const _kPinHash = 'pinHash';
  static const _kPinSalt = 'pinSalt';
  static const _kRegistered = 'registered';
  static const _kFailedAttempts = 'failedAttempts';
  static const _kLockoutUntil = 'lockoutUntil';

  // Allow a few free attempts, then back off exponentially.
  static const _freeAttempts = 5;
  static const _baseLockoutSeconds = 30;
  static const _maxLockoutSeconds = 15 * 60;

  final FlutterSecureStorage _secure = const FlutterSecureStorage();

  Future<SharedPreferences> get _prefs async =>
      SharedPreferences.getInstance();

  Future<bool> checkAuthed() async {
    final prefs = await _prefs;
    return prefs.getBool(_kRegistered) ?? false;
  }

  Future<bool> register(String pinCode) async {
    try {
      final salt = CryptoUtils.randomBytes(16);
      final hash = await CryptoUtils.deriveHashBase64(pinCode, salt);
      await _secure.write(key: _kPinHash, value: hash);
      await _secure.write(key: _kPinSalt, value: base64Encode(salt));

      final prefs = await _prefs;
      await prefs.setBool(_kRegistered, true);
      await prefs.remove(_kFailedAttempts);
      await prefs.remove(_kLockoutUntil);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Seconds remaining on an active lockout, or 0 if not locked out.
  Future<int> lockoutRemaining() async {
    final prefs = await _prefs;
    final until = prefs.getInt(_kLockoutUntil) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (until <= now) return 0;
    return ((until - now) / 1000).ceil();
  }

  /// Verify a PIN. Applies lockout/backoff on repeated failures.
  Future<PinResult> verifyPin(String insertPin) async {
    if (await lockoutRemaining() > 0) return PinResult.lockedOut;

    var storedHash = await _secure.read(key: _kPinHash);
    var storedSaltB64 = await _secure.read(key: _kPinSalt);

    // Migration: users registered under the old plaintext-PIN scheme have no
    // hash yet. Verify against the legacy value once, then upgrade in place.
    if (storedHash == null || storedSaltB64 == null) {
      final migrated = await _migrateLegacyPin(insertPin);
      if (migrated == null) return PinResult.wrong;
      if (!migrated) {
        await _registerFailure();
        return PinResult.wrong;
      }
      storedHash = await _secure.read(key: _kPinHash);
      storedSaltB64 = await _secure.read(key: _kPinSalt);
    }
    if (storedHash == null || storedSaltB64 == null) return PinResult.wrong;

    final candidate = await CryptoUtils.deriveHashBase64(
      insertPin,
      base64Decode(storedSaltB64),
    );

    if (CryptoUtils.constantTimeEquals(candidate, storedHash)) {
      await _resetAttempts();
      return PinResult.ok;
    }
    await _registerFailure();
    return PinResult.wrong;
  }

  /// Backwards-compatible boolean check used by the per-action gate.
  Future<bool> checkPin(String insertPin) async =>
      (await verifyPin(insertPin)) == PinResult.ok;

  /// Returns null if there's no legacy PIN to migrate, false if it doesn't
  /// match, true if it matched and was upgraded to a salted hash.
  Future<bool?> _migrateLegacyPin(String insertPin) async {
    final prefs = await _prefs;
    final legacy = prefs.getString('PIN');
    if (legacy == null) return null;

    if (!CryptoUtils.constantTimeEquals(insertPin, legacy)) return false;

    final salt = CryptoUtils.randomBytes(16);
    final hash = await CryptoUtils.deriveHashBase64(insertPin, salt);
    await _secure.write(key: _kPinHash, value: hash);
    await _secure.write(key: _kPinSalt, value: base64Encode(salt));
    await prefs.remove('PIN');
    return true;
  }

  Future<void> _resetAttempts() async {
    final prefs = await _prefs;
    await prefs.remove(_kFailedAttempts);
    await prefs.remove(_kLockoutUntil);
  }

  Future<void> _registerFailure() async {
    final prefs = await _prefs;
    final attempts = (prefs.getInt(_kFailedAttempts) ?? 0) + 1;
    await prefs.setInt(_kFailedAttempts, attempts);

    if (attempts >= _freeAttempts) {
      final over = (attempts - _freeAttempts).clamp(0, 20);
      final seconds =
          (_baseLockoutSeconds << over).clamp(0, _maxLockoutSeconds).toInt();
      final until =
          DateTime.now().millisecondsSinceEpoch + seconds * 1000;
      await prefs.setInt(_kLockoutUntil, until);
    }
  }
}
