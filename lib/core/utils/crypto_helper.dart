import 'dart:convert';

import 'package:encrypt/encrypt.dart' as encrypt;

/// A utility class that provides encryption and decryption operations.
///
/// This class offers static methods to encrypt and decrypt text using
/// industry-standard algorithms (AES-256 and Salsa20 as a DES alternative).
/// All methods handle the necessary key padding, initialization vectors,
/// and proper encoding/decoding of the encrypted data.
class CryptoHelper {
  /// Encrypts plaintext using AES-256 algorithm.
  ///
  /// The method performs the following steps:
  /// 1. Pads the encryption key to 32 bytes (256 bits)
  /// 2. Creates an initialization vector (IV) of 16 bytes
  /// 3. Encrypts the plaintext with AES-256
  /// 4. Returns a JSON string containing both the encrypted data and IV
  ///
  /// Example usage:
  /// ```dart
  /// final encryptedData = CryptoHelper.encryptWithAES('Hello world', 'my-secret-key');
  /// ```
  ///
  /// [plaintext] The text to be encrypted
  /// [encryptionKey] The secret key used for encryption
  /// [returns] A JSON string containing the encrypted data and IV
  static String encryptWithAES(String plaintext, String encryptionKey) {
    // Pad key to 32 bytes (256 bits) for AES-256
    final paddedKey = encryptionKey.padRight(32, '0').substring(0, 32);

    // Create key and initialization vector
    final keyObject = encrypt.Key.fromUtf8(paddedKey);
    final initVector = encrypt.IV.fromLength(16); // AES uses 16 byte IV

    // Create encrypter and encrypt the plaintext
    final encrypter = encrypt.Encrypter(encrypt.AES(keyObject));
    final encryptedResult = encrypter.encrypt(plaintext, iv: initVector);

    // Store IV and encrypted data in a structured format
    final resultPayload = {
      'iv': base64.encode(initVector.bytes),
      'encrypted': encryptedResult.base64,
    };

    // Return as JSON string
    return jsonEncode(resultPayload);
  }

  /// Decrypts AES-256 encrypted data.
  ///
  /// This method attempts to:
  /// 1. Parse the JSON string containing encrypted data and IV
  /// 2. Pad the decryption key to 32 bytes (256 bits)
  /// 3. Recreate the initialization vector from the stored data
  /// 4. Decrypt the data using AES-256
  ///
  /// Example usage:
  /// ```dart
  /// final decryptedText = CryptoHelper.decryptWithAES(encryptedJsonData, 'my-secret-key');
  /// if (decryptedText != null) {
  ///   print('Decrypted: $decryptedText');
  /// }
  /// ```
  ///
  /// [encryptedJsonData] A JSON string containing the encrypted data and IV
  /// [decryptionKey] The secret key used for decryption
  /// [returns] The decrypted plaintext or null if decryption fails
  static String? decryptWithAES(
    String encryptedJsonData,
    String decryptionKey,
  ) {
    try {
      // Parse the JSON data
      final encryptedPayload =
          jsonDecode(encryptedJsonData) as Map<String, dynamic>;

      // Pad key to 32 bytes (256 bits) for AES-256
      final paddedKey = decryptionKey.padRight(32, '0').substring(0, 32);

      // Create key and initialization vector from stored data
      final keyObject = encrypt.Key.fromUtf8(paddedKey);
      final initVector = encrypt.IV.fromBase64(
        encryptedPayload['iv'] as String,
      );

      // Create encrypter and decrypt the data
      final encrypter = encrypt.Encrypter(encrypt.AES(keyObject));
      final decryptedText = encrypter.decrypt64(
        encryptedPayload['encrypted'] as String,
        iv: initVector,
      );

      return decryptedText;
    } catch (error) {
      // Return null if any error occurs during decryption
      return null;
    }
  }

  /// Encrypts plaintext using Salsa20 as a DES alternative.
  ///
  /// Since the original DES algorithm is considered insecure for modern use,
  /// this implementation uses Salsa20 stream cipher as a more secure alternative
  /// while maintaining the same interface.
  ///
  /// The method performs the following steps:
  /// 1. Pads the encryption key to 32 bytes (256 bits) for Salsa20
  /// 2. Creates an initialization vector (IV) of 8 bytes
  /// 3. Encrypts the plaintext with Salsa20
  /// 4. Returns a JSON string containing both the encrypted data and IV
  ///
  /// Example usage:
  /// ```dart
  /// final encryptedData = CryptoHelper.encryptWithDES('Hello world', 'key8chr');
  /// ```
  ///
  /// [plaintext] The text to be encrypted
  /// [encryptionKey] The secret key used for encryption
  /// [returns] A JSON string containing the encrypted data and IV
  static String encryptWithDES(String plaintext, String encryptionKey) {
    // Pad key to 32 bytes (256 bits) for Salsa20 instead of 8 bytes
    // The encrypt package's Salsa20 implementation requires a 32-byte key
    final paddedKey = encryptionKey.padRight(32, '0').substring(0, 32);

    // Create key and initialization vector
    final keyObject = encrypt.Key.fromUtf8(paddedKey);
    final initVector = encrypt.IV.fromLength(8); // 8 byte IV for Salsa20

    // Create encrypter and encrypt the plaintext
    final encrypter = encrypt.Encrypter(encrypt.Salsa20(keyObject));
    final encryptedResult = encrypter.encrypt(plaintext, iv: initVector);

    // Store IV and encrypted data in a structured format
    final resultPayload = {
      'iv': base64.encode(initVector.bytes),
      'encrypted': encryptedResult.base64,
    };

    // Return as JSON string
    return jsonEncode(resultPayload);
  }

  /// Decrypts data encrypted with Salsa20 (DES alternative).
  ///
  /// This method attempts to:
  /// 1. Parse the JSON string containing encrypted data and IV
  /// 2. Pad the decryption key to 32 bytes (256 bits) for Salsa20
  /// 3. Recreate the initialization vector from the stored data
  /// 4. Decrypt the data using Salsa20
  ///
  /// Example usage:
  /// ```dart
  /// final decryptedText = CryptoHelper.decryptWithDES(encryptedJsonData, 'key8chr');
  /// if (decryptedText != null) {
  ///   print('Decrypted: $decryptedText');
  /// }
  /// ```
  ///
  /// [encryptedJsonData] A JSON string containing the encrypted data and IV
  /// [decryptionKey] The secret key used for decryption
  /// [returns] The decrypted plaintext or null if decryption fails
  static String? decryptWithDES(
    String encryptedJsonData,
    String decryptionKey,
  ) {
    try {
      // Parse the JSON data
      final encryptedPayload =
          jsonDecode(encryptedJsonData) as Map<String, dynamic>;

      // Pad key to 32 bytes (256 bits) for Salsa20 instead of 8 bytes
      final paddedKey = decryptionKey.padRight(32, '0').substring(0, 32);

      // Create key and initialization vector from stored data
      final keyObject = encrypt.Key.fromUtf8(paddedKey);
      final initVector = encrypt.IV.fromBase64(
        encryptedPayload['iv'] as String,
      );

      // Create encrypter and decrypt the data
      final encrypter = encrypt.Encrypter(encrypt.Salsa20(keyObject));
      final decryptedText = encrypter.decrypt64(
        encryptedPayload['encrypted'] as String,
        iv: initVector,
      );

      return decryptedText;
    } catch (error) {
      // Return null if any error occurs during decryption
      return null;
    }
  }
}
