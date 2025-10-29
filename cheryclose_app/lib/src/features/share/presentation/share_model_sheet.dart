import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/entities.dart';
import '../controllers/share_controller.dart';

class ShareModelSheet extends ConsumerStatefulWidget {
  const ShareModelSheet({
    required this.model,
    required this.captions,
    super.key,
  });

  final VehicleModel model;
  final List<CaptionTemplate> captions;

  @override
  ConsumerState<ShareModelSheet> createState() => _ShareModelSheetState();
}

class _ShareModelSheetState extends ConsumerState<ShareModelSheet> {
  CaptionTemplate? selectedCaption;

  @override
  void initState() {
    super.initState();
    selectedCaption = widget.captions.isNotEmpty ? widget.captions.first : null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.model.name,
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            if (widget.captions.isEmpty)
              const Text('No captions found for this model')
            else ...[
              DropdownButton<CaptionTemplate>(
                isExpanded: true,
                value: selectedCaption,
                onChanged: (value) => setState(() => selectedCaption = value),
                items: [
                  for (final caption in widget.captions)
                    DropdownMenuItem(
                      value: caption,
                      child: Text(caption.title),
                    )
                ],
              ),
              const SizedBox(height: 12),
              if (selectedCaption != null)
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: theme.colorScheme.surfaceVariant,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      _resolveTemplate(
                        selectedCaption!.body,
                        widget.model,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: selectedCaption == null
                    ? null
                    : () async {
                        final caption = _resolveTemplate(
                          selectedCaption!.body,
                          widget.model,
                        );
                        await shareCaption(
                          caption: caption,
                          subject: widget.model.name,
                        );
                        if (mounted) Navigator.of(context).pop();
                      },
                icon: const Icon(Icons.whatsapp),
                label: const Text('Share caption'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _resolveTemplate(String template, VehicleModel model) {
    return template
        .replaceAll('{{model}}', model.name)
        .replaceAll('{{fromPrice}}', model.basePrice.toStringAsFixed(0))
        .replaceAll('{{warranty}}', model.warranty);
  }
}
