import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../provider/qr_providers.dart' as qr_providers;
import '../viewmodel/qr_viewmodel.dart';
import 'qr_style_dialog.dart';

class EncryptScreen extends ConsumerStatefulWidget {
  const EncryptScreen({super.key});

  @override
  ConsumerState<EncryptScreen> createState() => _EncryptScreenState();
}

class _EncryptScreenState extends ConsumerState<EncryptScreen> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _keyController = TextEditingController();
  bool _isProcessing = false;
  bool _isSharing = false;

  // Key for capturing QR code as image
  final GlobalKey _qrKey = GlobalKey();

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
    ref
        .read(qr_providers.textToEncryptProvider.notifier)
        .setText(_textController.text);
    ref
        .read(qr_providers.encryptionKeyProvider.notifier)
        .setKey(_keyController.text);

    // Perform encryption
    final success = await ref.read(qrViewModelProvider.notifier).encryptText();

    setState(() {
      _isProcessing = false;
    });

    if (!success) {
      _showToast('Failed to encrypt text');
    }
  }

  Future<void> _shareQrCodeAsImage() async {
    final qrData = ref.read(qr_providers.encryptedQrDataProvider);
    if (qrData == null) return;

    setState(() {
      _isSharing = true;
    });

    try {
      // Capture QR code as image
      final boundary =
          _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      // Save to temporary file
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/qr_code.png');
      await file.writeAsBytes(pngBytes);

      // Share the file
      await Share.shareXFiles([XFile(file.path)], text: 'Encrypted QR Code');
    } catch (e) {
      _showToast('Error sharing QR code: ${e.toString()}');
    } finally {
      setState(() {
        _isSharing = false;
      });
    }
  }

  void _copyQrCode() {
    final qrData = ref.read(qr_providers.encryptedQrDataProvider);
    if (qrData == null) return;

    final jsonStr = jsonEncode(qrData.toJson());

    FlutterClipboard.copy(jsonStr).then((_) {
      _showToast('QR data copied to clipboard');
    });
  }

  void _showQrStyleDialog() {
    showDialog(context: context, builder: (context) => const QrStyleDialog());
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
    final qrData = ref.watch(qr_providers.encryptedQrDataProvider);
    final encryptionAlgorithm = ref.watch(
      qr_providers.encryptionAlgorithmProvider,
    );

    // QR styling options
    final foregroundColor = ref.watch(qr_providers.qrForegroundColorProvider);
    final backgroundColor = ref.watch(qr_providers.qrBackgroundColorProvider);
    final qrSize = ref.watch(qr_providers.qrSizeProvider);
    final errorCorrectionLevel = ref.watch(
      qr_providers.qrErrorCorrectionLevelProvider,
    );
    final showLogo = ref.watch(qr_providers.qrShowLogoProvider);
    final logoImagePath = ref.watch(qr_providers.qrLogoImagePathProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Encrypt Message'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () {
              ref.read(qr_providers.appThemeProvider.notifier).toggleTheme();
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
                    .read(qr_providers.encryptionAlgorithmProvider.notifier)
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Generated QR Code:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.palette),
                    tooltip: 'Style QR Code',
                    onPressed: _showQrStyleDialog,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: RepaintBoundary(
                  key: _qrKey,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: backgroundColor,
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
                      size: qrSize,
                      backgroundColor: backgroundColor,
                      foregroundColor: foregroundColor,
                      errorCorrectionLevel: errorCorrectionLevel,
                      gapless: true,
                      embeddedImage:
                          showLogo && logoImagePath != null
                              ? FileImage(File(logoImagePath))
                              : null,
                      embeddedImageStyle: const QrEmbeddedImageStyle(
                        size: Size(50, 50),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FilledButton.icon(
                    onPressed: _isSharing ? null : _shareQrCodeAsImage,
                    icon:
                        _isSharing
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : const Icon(Icons.share),
                    label: const Text('Share QR'),
                    style: FilledButton.styleFrom(backgroundColor: Colors.blue),
                  ),
                  const SizedBox(width: 16),
                  FilledButton.icon(
                    onPressed: _copyQrCode,
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy Data'),
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
