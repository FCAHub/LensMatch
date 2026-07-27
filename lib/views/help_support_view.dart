import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class HelpSupportView extends StatelessWidget {
  const HelpSupportView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          Text('Frequently Asked Questions', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildFaqItem(
            context,
            'How does the face scan work?',
            'Our app uses advanced ML models to analyze your facial landmarks and proportions. Based on this, it determines your face shape (Oval, Round, Square, etc.) and recommends frame styles that will complement your features perfectly.',
          ),
          _buildFaqItem(
            context,
            'How accurate is the AR Try-On?',
            'The AR try-on feature maps 3D glasses models onto your face in real-time. While it gives a highly accurate representation of how the frames will look and fit, slight variations might exist compared to trying them on in a physical store.',
          ),
          _buildFaqItem(
            context,
            'How do I reserve a frame?',
            'Once you find a frame you love, tap on it to view details, then press the "Reserve" button. You can manage your reservations in your Profile under "My Reservations".',
          ),
          _buildFaqItem(
            context,
            'Can I buy the frames directly?',
            'Currently, LensMatch allows you to discover and reserve frames. You can visit one of our partner optical stores to complete your purchase using your reservation code.',
          ),
          const SizedBox(height: 32),
          Text('Still need help?', style: textTheme.titleMedium),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Implement contact support action
            },
            icon: const Icon(PhosphorIcons.envelopeSimple),
            label: const Text('Contact Support'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(BuildContext context, String question, String answer) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF2A2A35)),
      ),
      color: colorScheme.surface,
      elevation: 0,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(question, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          iconColor: colorScheme.primary,
          collapsedIconColor: colorScheme.onSurfaceVariant,
          childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          children: [
            Text(
              answer,
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
