import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';

class PosterScreen extends StatefulWidget {
  const PosterScreen({super.key});

  @override
  State<PosterScreen> createState() => _PosterScreenState();
}

class _PosterScreenState extends State<PosterScreen> {
  final controller = ScreenshotController();
  final headlineController = TextEditingController(text: 'Test drive the Tiggo 4 Pro');
  final offerController = TextEditingController(text: '10-yr/1M km engine warranty included');
  final phoneController = TextEditingController(text: '+27720000000');
  bool showWarrantyBadge = true;

  @override
  void dispose() {
    headlineController.dispose();
    offerController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final qrText =
        'https://wa.me/${phoneController.text.replaceAll('+', '')}?text=Hi%20there!';
    return Scaffold(
      appBar: AppBar(title: const Text('QR poster builder')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: headlineController,
                    decoration: const InputDecoration(labelText: 'Headline'),
                  ),
                  TextField(
                    controller: offerController,
                    decoration: const InputDecoration(labelText: 'Offer copy'),
                  ),
                  TextField(
                    decoration: const InputDecoration(labelText: 'WhatsApp phone'),
                    controller: phoneController,
                    onChanged: (value) => setState(() {}),
                  ),
                  SwitchListTile(
                    value: showWarrantyBadge,
                    onChanged: (value) => setState(() => showWarrantyBadge = value),
                    title: const Text('Show warranty badge'),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () async {
                      final image = await controller.captureFromWidget(
                        Material(
                          child: _PosterPreview(
                            headline: headlineController.text,
                            offer: offerController.text,
                            qrText: qrText,
                            showWarranty: showWarrantyBadge,
                          ),
                        ),
                        pixelRatio: 3,
                      );
                      await _savePoster(image);
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('Export PNG'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Preview', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          AspectRatio(
            aspectRatio: 1080 / 1920,
            child: Screenshot(
              controller: controller,
              child: _PosterPreview(
                headline: headlineController.text,
                offer: offerController.text,
                qrText: qrText,
                showWarranty: showWarrantyBadge,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _savePoster(Uint8List bytes) async {
    await FileSaver.instance.saveFile(
      name: 'chery_poster',
      file: bytes,
      ext: 'png',
      mimeType: MimeType.png,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Poster saved to downloads.')),
    );
  }
}

class _PosterPreview extends StatelessWidget {
  const _PosterPreview({
    required this.headline,
    required this.offer,
    required this.qrText,
    required this.showWarranty,
  });

  final String headline;
  final String offer;
  final String qrText;
  final bool showWarranty;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0A0A0A), Color(0xFFED1C24)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            headline,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            offer,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
          const Spacer(),
          if (showWarranty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Text(
                '10-yr / 1M km engine warranty',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(12),
              child: QrImageView(
                data: qrText,
                version: QrVersions.auto,
                size: 160,
                backgroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
