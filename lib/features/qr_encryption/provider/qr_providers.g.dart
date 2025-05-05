// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qr_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$encryptionAlgorithmHash() =>
    r'e9ddfa39cecc92340290050d5bc2b9091ba0176a';

/// See also [EncryptionAlgorithm].
@ProviderFor(EncryptionAlgorithm)
final encryptionAlgorithmProvider =
    NotifierProvider<EncryptionAlgorithm, String>.internal(
      EncryptionAlgorithm.new,
      name: r'encryptionAlgorithmProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$encryptionAlgorithmHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$EncryptionAlgorithm = Notifier<String>;
String _$textToEncryptHash() => r'1657f2321eadd160088bb7c4232dab8649171245';

/// See also [TextToEncrypt].
@ProviderFor(TextToEncrypt)
final textToEncryptProvider = NotifierProvider<TextToEncrypt, String>.internal(
  TextToEncrypt.new,
  name: r'textToEncryptProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$textToEncryptHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TextToEncrypt = Notifier<String>;
String _$encryptionKeyHash() => r'23c06645874ade19ce51fd451782cbb462f176d0';

/// See also [EncryptionKey].
@ProviderFor(EncryptionKey)
final encryptionKeyProvider = NotifierProvider<EncryptionKey, String>.internal(
  EncryptionKey.new,
  name: r'encryptionKeyProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$encryptionKeyHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$EncryptionKey = Notifier<String>;
String _$encryptedQrDataHash() => r'9ec0e52fa60d7f43ce115d572dfc18e1c6704cf0';

/// See also [EncryptedQrData].
@ProviderFor(EncryptedQrData)
final encryptedQrDataProvider =
    NotifierProvider<EncryptedQrData, EncryptedPayload?>.internal(
      EncryptedQrData.new,
      name: r'encryptedQrDataProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$encryptedQrDataHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$EncryptedQrData = Notifier<EncryptedPayload?>;
String _$appThemeHash() => r'1cd2a986075b1175c8c7c2363d59185cd3763672';

/// See also [AppTheme].
@ProviderFor(AppTheme)
final appThemeProvider = NotifierProvider<AppTheme, ThemeData>.internal(
  AppTheme.new,
  name: r'appThemeProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$appThemeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AppTheme = Notifier<ThemeData>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
