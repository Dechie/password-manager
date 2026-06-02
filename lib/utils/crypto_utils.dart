import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';

/// Shared cryptographic primitives: PBKDF2 key derivation, constant-time
/// comparison, and authenticated (AES-GCM) encryption used for the PIN hash
/// and the encrypted backup export.
class CryptoUtils {
  static const int pbkdf2Iterations = 120000;
  static const int keyBits = 256;

  static final _pbkdf2 = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: pbkdf2Iterations,
    bits: keyBits,
  );
  static final _aesGcm = AesGcm.with256bits();

  /// Derive a 256-bit key from [secret] (PIN or passphrase) and [salt].
  static Future<SecretKey> deriveKey(String secret, List<int> salt) {
    return _pbkdf2.deriveKey(
      secretKey: SecretKey(utf8.encode(secret)),
      nonce: salt,
    );
  }

  /// Derive raw key bytes, base64-encoded — used to store the PIN hash.
  static Future<String> deriveHashBase64(String secret, List<int> salt) async {
    final key = await deriveKey(secret, salt);
    final bytes = await key.extractBytes();
    return base64Encode(bytes);
  }

  /// Timing-safe equality for two base64 strings.
  static bool constantTimeEquals(String a, String b) {
    final ab = utf8.encode(a);
    final bb = utf8.encode(b);
    if (ab.length != bb.length) return false;
    var diff = 0;
    for (var i = 0; i < ab.length; i++) {
      diff |= ab[i] ^ bb[i];
    }
    return diff == 0;
  }

  static List<int> randomBytes(int length) {
    return SecretKeyData.random(length: length).bytes;
  }

  /// Encrypt [plaintext] with a key derived from [passphrase].
  /// Returns a self-describing JSON envelope that records every KDF parameter
  /// needed for decryption, so backups remain readable even if the defaults
  /// change in future app versions.
  static Future<String> encryptWithPassphrase(
      String plaintext, String passphrase) async {
    final salt = randomBytes(16);
    final key = await deriveKey(passphrase, salt);
    final secretBox = await _aesGcm.encrypt(
      utf8.encode(plaintext),
      secretKey: key,
    );
    return jsonEncode({
      'v': 1,
      'kdf': 'pbkdf2-sha256',
      'iterations': pbkdf2Iterations,
      'bits': keyBits,
      'salt': base64Encode(salt),
      'nonce': base64Encode(secretBox.nonce),
      'ciphertext': base64Encode(secretBox.cipherText),
      'mac': base64Encode(secretBox.mac.bytes),
    });
  }

  /// Decrypt an envelope produced by [encryptWithPassphrase].
  /// Reads KDF parameters from the envelope itself, not from the current
  /// defaults, so v1 backups remain decryptable after future parameter bumps.
  static Future<String> decryptWithPassphrase(
      String envelope, String passphrase) async {
    final map = jsonDecode(envelope) as Map<String, dynamic>;

    final version = (map['v'] as num?)?.toInt() ?? 1;
    if (version != 1) {
      throw UnsupportedError(
          'Backup format v$version is not supported by this app version.');
    }

    final salt = base64Decode(map['salt'] as String);
    final iterations =
        (map['iterations'] as num?)?.toInt() ?? pbkdf2Iterations;
    final bits = (map['bits'] as num?)?.toInt() ?? keyBits;

    // Reconstruct the exact KDF that was used when this backup was created.
    final kdf = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: iterations,
      bits: bits,
    );
    final key = await kdf.deriveKey(
      secretKey: SecretKey(utf8.encode(passphrase)),
      nonce: salt,
    );

    final secretBox = SecretBox(
      base64Decode(map['ciphertext'] as String),
      nonce: base64Decode(map['nonce'] as String),
      mac: Mac(base64Decode(map['mac'] as String)),
    );
    final clear = await _aesGcm.decrypt(secretBox, secretKey: key);
    return utf8.decode(clear);
  }

  /// Build a non-growable copy of bytes (defensive helper).
  static Uint8List copyBytes(List<int> bytes) =>
      Uint8List.fromList(bytes);

  @visibleForTesting
  static List<int> debugSalt() => randomBytes(16);
}
