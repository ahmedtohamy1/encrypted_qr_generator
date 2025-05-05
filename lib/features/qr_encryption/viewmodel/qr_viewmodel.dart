import 'dart:convert';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:encrypted_qr_generator/core/model/encrypted_payload.dart';
import 'package:encrypted_qr_generator/features/qr_encryption/provider/qr_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'qr_viewmodel.g.dart';

@Riverpod(keepAlive: true)
class QrViewModel extends _$QrViewModel {
  @override
  bool build() {
    // Initial state - indicates whether operation was successful
    return true;
  }

  Future<bool> encryptText() async {
    try {
      final text = ref.read(textToEncryptProvider);
      final key = ref.read(encryptionKeyProvider);
      final algorithm = ref.read(encryptionAlgorithmProvider);

      if (text.isEmpty || key.isEmpty) {
        return false;
      }

      final encryptedData = _encryptData(text, key, algorithm);
      final payload = EncryptedPayload(algo: algorithm, data: encryptedData);

      ref.read(encryptedQrDataProvider.notifier).setQrData(payload);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String?> decryptQrData(EncryptedPayload payload, String key) async {
    try {
      final algorithm = payload.algo;
      final encryptedData = payload.data;

      return _decryptData(encryptedData, key, algorithm);
    } catch (e) {
      return null;
    }
  }

  String _encryptData(String text, String key, String algorithm) {
    if (algorithm == 'AES') {
      return _encryptWithAES(text, key);
    } else if (algorithm == 'DES') {
      return _encryptWithDES(text, key);
    }
    // Default to AES
    return _encryptWithAES(text, key);
  }

  String? _decryptData(String encryptedData, String key, String algorithm) {
    if (algorithm == 'AES') {
      return _decryptWithAES(encryptedData, key);
    } else if (algorithm == 'DES') {
      return _decryptWithDES(encryptedData, key);
    }
    return null;
  }

  String _encryptWithAES(String text, String key) {
    // Pad key to 32 bytes (256 bits) for AES-256
    final paddedKey = key.padRight(32, '0').substring(0, 32);

    final keyObj = encrypt.Key.fromUtf8(paddedKey);
    final iv = encrypt.IV.fromLength(16); // AES uses 16 byte IV

    final encrypter = encrypt.Encrypter(encrypt.AES(keyObj));
    final encrypted = encrypter.encrypt(text, iv: iv);

    // Store IV and encrypted data
    final data = {'iv': base64.encode(iv.bytes), 'encrypted': encrypted.base64};

    return jsonEncode(data);
  }

  String? _decryptWithAES(String encryptedJson, String key) {
    try {
      final data = jsonDecode(encryptedJson) as Map<String, dynamic>;

      // Pad key to 32 bytes (256 bits) for AES-256
      final paddedKey = key.padRight(32, '0').substring(0, 32);

      final keyObj = encrypt.Key.fromUtf8(paddedKey);
      final iv = encrypt.IV.fromBase64(data['iv'] as String);

      final encrypter = encrypt.Encrypter(encrypt.AES(keyObj));
      final decrypted = encrypter.decrypt64(
        data['encrypted'] as String,
        iv: iv,
      );

      return decrypted;
    } catch (e) {
      return null;
    }
  }

  String _encryptWithDES(String text, String key) {
    // Pad key to 8 bytes (64 bits) for DES
    final paddedKey = key.padRight(8, '0').substring(0, 8);

    final keyObj = encrypt.Key.fromUtf8(paddedKey);
    final iv = encrypt.IV.fromLength(8); // DES uses 8 byte IV

    final encrypter = encrypt.Encrypter(encrypt.Salsa20(keyObj));
    final encrypted = encrypter.encrypt(text, iv: iv);

    // Store IV and encrypted data
    final data = {'iv': base64.encode(iv.bytes), 'encrypted': encrypted.base64};

    return jsonEncode(data);
  }

  String? _decryptWithDES(String encryptedJson, String key) {
    try {
      final data = jsonDecode(encryptedJson) as Map<String, dynamic>;

      // Pad key to 8 bytes (64 bits) for DES
      final paddedKey = key.padRight(8, '0').substring(0, 8);

      final keyObj = encrypt.Key.fromUtf8(paddedKey);
      final iv = encrypt.IV.fromBase64(data['iv'] as String);

      final encrypter = encrypt.Encrypter(encrypt.Salsa20(keyObj));
      final decrypted = encrypter.decrypt64(
        data['encrypted'] as String,
        iv: iv,
      );

      return decrypted;
    } catch (e) {
      return null;
    }
  }
}
