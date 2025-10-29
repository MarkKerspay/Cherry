import 'package:flutter/material.dart';

import '../../calculator/presentation/calculator_screen.dart';
import '../../leads/presentation/leads_screen.dart';
import '../../poster/presentation/poster_screen.dart';
import '../../share/presentation/share_hub_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tiles = [
      _HomeTile(
        label: 'Share',
        icon: Icons.share_outlined,
        description: 'Captions, images, and video scripts ready to share.',
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ShareHubScreen()),
        ),
      ),
      _HomeTile(
        label: 'Leads',
        icon: Icons.person_add_alt_1_outlined,
        description: 'Capture POPIA-consent leads and follow up.',
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const LeadsScreen()),
        ),
      ),
      _HomeTile(
        label: 'Calculator',
        icon: Icons.calculate_outlined,
        description: 'Quick monthly instalment estimates.',
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CalculatorScreen()),
        ),
      ),
      _HomeTile(
        label: 'Poster',
        icon: Icons.qr_code_2,
        description: 'Create QR posters that open WhatsApp chats.',
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const PosterScreen()),
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('CheryClose'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tiles.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
        ),
        itemBuilder: (context, index) => tiles[index],
      ),
    );
  }
}

class _HomeTile extends StatelessWidget {
  const _HomeTile({
    required this.label,
    required this.icon,
    required this.description,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Ink(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40),
            const SizedBox(height: 12),
            Text(
              label,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
