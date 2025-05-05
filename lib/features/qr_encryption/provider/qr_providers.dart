import 'package:encrypted_qr_generator/core/model/encrypted_payload.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'qr_providers.g.dart';

// Encryption algorithm provider
@Riverpod(keepAlive: true)
class EncryptionAlgorithm extends _$EncryptionAlgorithm {
  @override
  String build() {
    // Default to AES
    return 'AES';
  }

  void setAlgorithm(String algorithm) {
    state = algorithm;
  }
}

// Text to encrypt provider
@Riverpod(keepAlive: true)
class TextToEncrypt extends _$TextToEncrypt {
  @override
  String build() {
    return '';
  }

  void setText(String text) {
    state = text;
  }
}

// Encryption key provider
@Riverpod(keepAlive: true)
class EncryptionKey extends _$EncryptionKey {
  @override
  String build() {
    return '';
  }

  void setKey(String key) {
    state = key;
  }
}

// Generated QR data provider
@Riverpod(keepAlive: true)
class EncryptedQrData extends _$EncryptedQrData {
  @override
  EncryptedPayload? build() {
    return null;
  }

  void setQrData(EncryptedPayload data) {
    state = data;
  }

  void clearData() {
    state = null;
  }
}

// Theme mode provider
@Riverpod(keepAlive: true)
class AppTheme extends _$AppTheme {
  @override
  ThemeData build() {
    // Default to light theme
    return ThemeData.light();
  }

  void toggleTheme() {
    state =
        state.brightness == Brightness.light
            ? ThemeData.dark()
            : ThemeData.light();
  }
}
