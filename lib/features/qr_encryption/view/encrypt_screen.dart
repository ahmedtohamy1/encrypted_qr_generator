import 'dart:convert';

import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../provider/qr_providers.dart';
import '../viewmodel/qr_viewmodel.dart';

class EncryptScreen extends ConsumerStatefulWidget {
  const EncryptScreen({super.key});

  @override
  ConsumerState<EncryptScreen> createState() => _EncryptScreenState();
}

class _EncryptScreenState extends ConsumerState<EncryptScreen> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _keyController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _textController.dispose();
    _keyController.dispose();
    super.dispose();
  }

  void _encryptAndGenerateQR() async {
    if (_textController.text.isEmpty) {
      _showToast('Please enter text to encrypt');
      return;
    }

    if (_keyController.text.isEmpty) {
      _showToast('Please enter encryption key');
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    // Set values in providers
    ref.read(textToEncryptProvider.notifier).setText(_textController.text);
    ref.read(encryptionKeyProvider.notifier).setKey(_keyController.text);

    // Perform encryption
    final success = await ref.read(qrViewModelProvider.notifier).encryptText();

    setState(() {
      _isProcessing = false;
    });

    if (!success) {
      _showToast('Failed to encrypt text');
    }
  }

  void _shareQrCode() async {
    final qrData = ref.read(encryptedQrDataProvider);
    if (qrData == null) return;

    final jsonStr = jsonEncode(qrData.toJson());

    await Share.share(
      'Encrypted QR Data: $jsonStr',
      subject: 'Encrypted QR Data',
    );
  }

  void _copyQrCode() {
    final qrData = ref.read(encryptedQrDataProvider);
    if (qrData == null) return;

    final jsonStr = jsonEncode(qrData.toJson());

    FlutterClipboard.copy(jsonStr).then((_) {
      _showToast('QR data copied to clipboard');
    });
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    final qrData = ref.watch(encryptedQrDataProvider);
    final encryptionAlgorithm = ref.watch(encryptionAlgorithmProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Encrypt Message'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () {
              ref.read(appThemeProvider.notifier).toggleTheme();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Enter text to encrypt:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Your message here...',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            const Text(
              'Select encryption algorithm:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment<String>(
                  value: 'AES',
                  label: Text('AES'),
                  icon: Icon(Icons.security),
                ),
                ButtonSegment<String>(
                  value: 'DES',
                  label: Text('DES'),
                  icon: Icon(Icons.lock),
                ),
              ],
              selected: {encryptionAlgorithm},
              onSelectionChanged: (Set<String> newSelection) {
                ref
                    .read(encryptionAlgorithmProvider.notifier)
                    .setAlgorithm(newSelection.first);
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Enter encryption key:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _keyController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Secret key',
                prefixIcon: Icon(Icons.key),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _isProcessing ? null : _encryptAndGenerateQR,
              icon:
                  _isProcessing
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                      : const Icon(Icons.lock),
              label: const Text('Encrypt & Generate QR'),
            ),
            const SizedBox(height: 24),
            if (qrData != null) ...[
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'Generated QR Code:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: QrImageView(
                    data: jsonEncode(qrData.toJson()),
                    version: QrVersions.auto,
                    size: 200,
                    backgroundColor: Colors.white,
                    errorCorrectionLevel: QrErrorCorrectLevel.H,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FilledButton.icon(
                    onPressed: _shareQrCode,
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                    style: FilledButton.styleFrom(backgroundColor: Colors.blue),
                  ),
                  const SizedBox(width: 16),
                  FilledButton.icon(
                    onPressed: _copyQrCode,
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
