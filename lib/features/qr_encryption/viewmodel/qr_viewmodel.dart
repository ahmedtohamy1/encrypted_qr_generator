import 'package:encrypted_qr_generator/core/model/encrypted_payload.dart';
import 'package:encrypted_qr_generator/core/utils/crypto_helper.dart';
import 'package:encrypted_qr_generator/features/qr_encryption/provider/qr_providers.dart'
    as qr_providers;
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
      final text = ref.read(qr_providers.textToEncryptProvider);
      final key = ref.read(qr_providers.encryptionKeyProvider);
      final algorithm = ref.read(qr_providers.encryptionAlgorithmProvider);

      if (text.isEmpty || key.isEmpty) {
        return false;
      }

      final encryptedData = _encryptData(text, key, algorithm);
      final payload = EncryptedPayload(algo: algorithm, data: encryptedData);

      ref
          .read(qr_providers.encryptedQrDataProvider.notifier)
          .setQrData(payload);
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
      return CryptoHelper.encryptWithAES(text, key);
    } else if (algorithm == 'DES') {
      return CryptoHelper.encryptWithDES(text, key);
    }
    // Default to AES
    return CryptoHelper.encryptWithAES(text, key);
  }

  String? _decryptData(String encryptedData, String key, String algorithm) {
    if (algorithm == 'AES') {
      return CryptoHelper.decryptWithAES(encryptedData, key);
    } else if (algorithm == 'DES') {
      return CryptoHelper.decryptWithDES(encryptedData, key);
    }
    return null;
  }
}
