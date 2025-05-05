import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../provider/qr_providers.dart' as qr_providers;

class QrStyleDialog extends ConsumerWidget {
  const QrStyleDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get current values from providers
    final foregroundColor = ref.watch(qr_providers.qrForegroundColorProvider);
    final backgroundColor = ref.watch(qr_providers.qrBackgroundColorProvider);
    final qrSize = ref.watch(qr_providers.qrSizeProvider);
    final errorCorrectionLevel = ref.watch(
      qr_providers.qrErrorCorrectionLevelProvider,
    );
    final showLogo = ref.watch(qr_providers.qrShowLogoProvider);
    final logoImagePath = ref.watch(qr_providers.qrLogoImagePathProvider);

    // Predefined colors for selection
    final colorOptions = [
      Colors.black,
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.indigo,
    ];

    return AlertDialog(
      title: const Text('QR Code Style'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Foreground color selection
            const Text(
              'Foreground Color',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: colorOptions.length,
                itemBuilder: (context, index) {
                  final color = colorOptions[index];
                  final isSelected = foregroundColor.value == color.value;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        ref
                            .read(
                              qr_providers.qrForegroundColorProvider.notifier,
                            )
                            .setColor(color);
                      },
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: color,
                        child:
                            isSelected
                                ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 18,
                                )
                                : null,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Background color selection
            const Text(
              'Background Color',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: colorOptions.length,
                itemBuilder: (context, index) {
                  final color = colorOptions[index];
                  final isSelected = backgroundColor.value == color.value;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        ref
                            .read(
                              qr_providers.qrBackgroundColorProvider.notifier,
                            )
                            .setColor(color);
                      },
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: color,
                        child:
                            isSelected
                                ? Icon(
                                  Icons.check,
                                  color:
                                      color == Colors.black
                                          ? Colors.white
                                          : Colors.black,
                                  size: 18,
                                )
                                : null,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // QR size slider
            const Text(
              'QR Code Size',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Slider(
              value: qrSize,
              min: 150,
              max: 300,
              divisions: 15,
              label: qrSize.toStringAsFixed(0),
              onChanged: (value) {
                ref.read(qr_providers.qrSizeProvider.notifier).setSize(value);
              },
            ),

            const SizedBox(height: 16),

            // Error correction level
            const Text(
              'Error Correction Level',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment<int>(
                  value: 0,
                  label: Text('L'),
                  tooltip: 'Low - 7% error recovery',
                ),
                ButtonSegment<int>(
                  value: 1,
                  label: Text('M'),
                  tooltip: 'Medium - 15% error recovery',
                ),
                ButtonSegment<int>(
                  value: 2,
                  label: Text('Q'),
                  tooltip: 'Quality - 25% error recovery',
                ),
                ButtonSegment<int>(
                  value: 3,
                  label: Text('H'),
                  tooltip: 'High - 30% error recovery',
                ),
              ],
              selected: {errorCorrectionLevel},
              onSelectionChanged: (Set<int> newSelection) {
                ref
                    .read(qr_providers.qrErrorCorrectionLevelProvider.notifier)
                    .setLevel(newSelection.first);
              },
            ),

            const SizedBox(height: 16),

            // Custom logo toggle and selection
            Row(
              children: [
                const Text(
                  'Add Custom Logo',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Switch(
                  value: showLogo,
                  onChanged: (value) {
                    ref
                        .read(qr_providers.qrShowLogoProvider.notifier)
                        .setShowLogo(value);
                    if (!value) {
                      ref
                          .read(qr_providers.qrLogoImagePathProvider.notifier)
                          .setImagePath(null);
                    }
                  },
                ),
              ],
            ),
            if (showLogo) ...[
              const SizedBox(height: 8),
              Center(
                child: Column(
                  children: [
                    if (logoImagePath != null)
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(logoImagePath),
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    else
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Icon(Icons.image, color: Colors.grey),
                        ),
                      ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () async {
                        // Pick image from gallery
                        final imagePicker = ImagePicker();
                        final pickedFile = await imagePicker.pickImage(
                          source: ImageSource.gallery,
                          maxWidth: 300,
                          maxHeight: 300,
                        );

                        if (pickedFile != null) {
                          ref
                              .read(
                                qr_providers.qrLogoImagePathProvider.notifier,
                              )
                              .setImagePath(pickedFile.path);
                        }
                      },
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Choose Logo'),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Preview of QR style
            const Text(
              'Preview',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Center(
              child: Container(
                width: 100,
                height: 100,
                color: backgroundColor,
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(width: 60, height: 60, color: foregroundColor),
                      if (showLogo && logoImagePath != null)
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: Image.file(
                              File(logoImagePath),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
      ],
    );
  }
}
