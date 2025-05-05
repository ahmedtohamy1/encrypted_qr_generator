import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart'
    as ml_kit;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/model/encrypted_payload.dart';
import '../provider/qr_providers.dart' as qr_providers;
import '../viewmodel/qr_viewmodel.dart';

class DecryptScreen extends ConsumerStatefulWidget {
  const DecryptScreen({super.key});

  @override
  ConsumerState<DecryptScreen> createState() => _DecryptScreenState();
}

class _DecryptScreenState extends ConsumerState<DecryptScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  final GlobalKey _textKey = GlobalKey();
  QRViewController? controller;
  bool _isScanning = true;
  bool _isDecrypting = false;
  bool _isSharing = false;

  EncryptedPayload? _scannedPayload;
  String? _decryptedText;

  final TextEditingController _keyController = TextEditingController();

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (!_isScanning) return;

      if (scanData.code != null) {
        _processQrData(scanData.code!);
      }
    });
  }

  Future<void> _pickImageAndScan() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _isScanning = false;
      });

      try {
        // Create barcode scanner with QR code format
        final barcodeScanner = ml_kit.BarcodeScanner(
          formats: [ml_kit.BarcodeFormat.qrCode],
        );

        // Process the image
        final inputImage = ml_kit.InputImage.fromFilePath(pickedFile.path);
        final barcodes = await barcodeScanner.processImage(inputImage);

        if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
          _processQrData(barcodes.first.rawValue!);
        } else {
          _showToast('No QR code found in image');
          setState(() {
            _isScanning = true;
          });
        }

        // Close scanner
        barcodeScanner.close();
      } catch (e) {
        _showToast('Error scanning image: ${e.toString()}');
        setState(() {
          _isScanning = true;
        });
      }
    }
  }

  void _processQrData(String data) {
    try {
      setState(() {
        _isScanning = false;
      });

      final Map<String, dynamic> jsonData = jsonDecode(data);
      final payload = EncryptedPayload.fromJson(jsonData);

      setState(() {
        _scannedPayload = payload;
      });

      _showToast('QR code scanned successfully');
    } catch (e) {
      _showToast('Invalid QR code format');
      setState(() {
        _isScanning = true;
      });
    }
  }

  void _decryptData() async {
    if (_keyController.text.isEmpty) {
      _showToast('Please enter decryption key');
      return;
    }

    if (_scannedPayload == null) {
      _showToast('No data to decrypt');
      return;
    }

    setState(() {
      _isDecrypting = true;
      _decryptedText = null;
    });

    final result = await ref
        .read(qrViewModelProvider.notifier)
        .decryptQrData(_scannedPayload!, _keyController.text);

    setState(() {
      _isDecrypting = false;
      _decryptedText = result;
    });

    if (result == null) {
      _showToast('Failed to decrypt. Incorrect key?');
    }
  }

  void _resetScan() {
    setState(() {
      _isScanning = true;
      _scannedPayload = null;
      _decryptedText = null;
      _keyController.clear();
    });
  }

  void _copyToClipboard() {
    if (_decryptedText == null) return;

    FlutterClipboard.copy(_decryptedText!).then((_) {
      _showToast('Text copied to clipboard');
    });
  }

  Future<void> _shareDecryptedTextAsImage() async {
    if (_decryptedText == null) return;

    setState(() {
      _isSharing = true;
    });

    try {
      // Capture the text container as an image
      final boundary =
          _textKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      // Save to temporary file
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/decrypted_text.png');
      await file.writeAsBytes(pngBytes);

      // Share the file
      await Share.shareXFiles([XFile(file.path)], text: 'Decrypted Message');
    } catch (e) {
      _showToast('Error sharing text as image: ${e.toString()}');
    } finally {
      setState(() {
        _isSharing = false;
      });
    }
  }

  void _shareTextAsText() async {
    if (_decryptedText == null) return;

    await Share.share(_decryptedText!, subject: 'Decrypted Message');
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Decrypt QR Code'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () {
              ref.read(qr_providers.appThemeProvider.notifier).toggleTheme();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isScanning) ...[
            Expanded(
              flex: 5,
              child: QRView(
                key: qrKey,
                onQRViewCreated: _onQRViewCreated,
                overlay: QrScannerOverlayShape(
                  borderColor: Colors.blue,
                  borderRadius: 10,
                  borderLength: 30,
                  borderWidth: 10,
                  cutOutSize: 300,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Scan a QR code containing encrypted data',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _pickImageAndScan,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Pick Image from Gallery'),
                  ),
                ],
              ),
            ),
          ] else if (_scannedPayload != null) ...[
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.info_outline,
                                  color: Colors.blue,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Encrypted with ${_scannedPayload!.algo}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Enter decryption key:',
                              style: TextStyle(fontSize: 16),
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
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: FilledButton.icon(
                                    onPressed:
                                        _isDecrypting ? null : _decryptData,
                                    icon:
                                        _isDecrypting
                                            ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            )
                                            : const Icon(Icons.lock_open),
                                    label: const Text('Decrypt'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  onPressed: _resetScan,
                                  icon: const Icon(Icons.refresh),
                                  tooltip: 'Scan again',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_decryptedText != null) ...[
                      const SizedBox(height: 24),
                      const Text(
                        'Decrypted Message:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      RepaintBoundary(
                        key: _textKey,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                          ),
                          child: Text(
                            _decryptedText!,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FilledButton.icon(
                            onPressed: _copyToClipboard,
                            icon: const Icon(Icons.copy),
                            label: const Text('Copy'),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 16),
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'text') {
                                _shareTextAsText();
                              } else if (value == 'image') {
                                _shareDecryptedTextAsImage();
                              }
                            },
                            itemBuilder:
                                (context) => [
                                  const PopupMenuItem(
                                    value: 'text',
                                    child: Row(
                                      children: [
                                        Icon(Icons.text_fields),
                                        SizedBox(width: 8),
                                        Text('Share as Text'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'image',
                                    child: Row(
                                      children: [
                                        Icon(Icons.image),
                                        SizedBox(width: 8),
                                        Text('Share as Image'),
                                      ],
                                    ),
                                  ),
                                ],
                            child: FilledButton.icon(
                              onPressed: null,
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
                              label: const Text('Share'),
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
