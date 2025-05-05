import 'dart:convert';

import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/model/encrypted_payload.dart';
import '../viewmodel/qr_viewmodel.dart';

class DecryptScreen extends ConsumerStatefulWidget {
  const DecryptScreen({super.key});

  @override
  ConsumerState<DecryptScreen> createState() => _DecryptScreenState();
}

class _DecryptScreenState extends ConsumerState<DecryptScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool _isScanning = true;
  bool _isDecrypting = false;

  EncryptedPayload? _scannedPayload;
  String? _decryptedText;

  final TextEditingController _keyController = TextEditingController();

  @override
  void dispose() {
    controller?.dispose();
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

  void _shareText() async {
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
      appBar: AppBar(title: const Text('Decrypt QR Code')),
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
              child: Center(
                child: const Text(
                  'Scan a QR code containing encrypted data',
                  style: TextStyle(fontSize: 16),
                ),
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
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey.shade50,
                        ),
                        child: Text(
                          _decryptedText!,
                          style: const TextStyle(fontSize: 16),
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
                          FilledButton.icon(
                            onPressed: _shareText,
                            icon: const Icon(Icons.share),
                            label: const Text('Share'),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.blue,
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
