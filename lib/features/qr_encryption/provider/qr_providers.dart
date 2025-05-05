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

// QR Code foreground color provider
@Riverpod(keepAlive: true)
class QrForegroundColor extends _$QrForegroundColor {
  @override
  Color build() {
    // Default to black
    return Colors.black;
  }

  void setColor(Color color) {
    state = color;
  }
}

// QR Code background color provider
@Riverpod(keepAlive: true)
class QrBackgroundColor extends _$QrBackgroundColor {
  @override
  Color build() {
    // Default to white
    return Colors.white;
  }

  void setColor(Color color) {
    state = color;
  }
}

// QR Code size provider
@Riverpod(keepAlive: true)
class QrSize extends _$QrSize {
  @override
  double build() {
    // Default size in logical pixels
    return 200.0;
  }

  void setSize(double size) {
    state = size;
  }
}

// QR Code error correction level provider
@Riverpod(keepAlive: true)
class QrErrorCorrectionLevel extends _$QrErrorCorrectionLevel {
  @override
  int build() {
    // Default to high (H) error correction
    return 3; // QrErrorCorrectLevel.H
  }

  void setLevel(int level) {
    if (level >= 0 && level <= 3) {
      state = level;
    }
  }
}

// QR Code logo provider
@Riverpod(keepAlive: true)
class QrShowLogo extends _$QrShowLogo {
  @override
  bool build() {
    // Default to no logo
    return false;
  }

  void setShowLogo(bool show) {
    state = show;
  }
}

// QR Code logo image path provider
@Riverpod(keepAlive: true)
class QrLogoImagePath extends _$QrLogoImagePath {
  @override
  String? build() {
    // Default to no image
    return null;
  }

  void setImagePath(String? path) {
    state = path;
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
