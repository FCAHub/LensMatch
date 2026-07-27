import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../utils/app_state.dart';

class FrameDetailView extends StatelessWidget {
  final Map<String, String> frame;

  const FrameDetailView({super.key, required this.frame});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Big image placeholder
            Container(
              height: 400,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF0A0A0A),
              ),
              child: SafeArea(
                child: Center(
                  child: Icon(
                    PhosphorIcons.eyeglasses,
                    size: 120,
                    color: colorScheme.primary.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(frame['name']!, style: textTheme.headlineMedium),
                            const SizedBox(height: 8),
                            Text(frame['price']!, style: textTheme.headlineSmall?.copyWith(color: colorScheme.primary)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
                        ),
                        child: Text(frame['shape']!, style: textTheme.labelMedium?.copyWith(color: colorScheme.primary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text('Details', style: textTheme.titleLarge),
                  const SizedBox(height: 12),
                  _buildDetailRow(context, 'Material', frame['material']!),
                  _buildDetailRow(context, 'Shape', frame['shape']!),
                  _buildDetailRow(context, 'Fit', 'Standard'),
                  
                  const SizedBox(height: 32),
                  Text('Description', style: textTheme.titleLarge),
                  const SizedBox(height: 12),
                  Text(
                    'Elevate your look with the ${frame['name']}. Crafted from premium ${frame['material'].toString().toLowerCase()}, these frames offer a perfect blend of durability and luxury style. Ideal for all-day comfort.',
                    style: textTheme.bodyMedium?.copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: const Border(top: BorderSide(color: Color(0xFF2A2A35))),
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: ValueListenableBuilder<List<Map<String, dynamic>>>(
              valueListenable: AppState.reservedFrames,
              builder: (context, reservedList, child) {
                final isReserved = reservedList.any((item) => item['id'] == frame['id']);
                
                return ElevatedButton(
                  onPressed: isReserved ? null : () {
                    AppState.addReservation(frame);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${frame['name']} reserved successfully!'),
                        backgroundColor: colorScheme.primary,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    disabledBackgroundColor: colorScheme.surface.withValues(alpha: 0.5),
                  ),
                  child: Text(
                    isReserved ? 'Already Reserved' : 'Reserve Now',
                    style: textTheme.titleMedium?.copyWith(
                      color: isReserved ? colorScheme.onSurfaceVariant : const Color(0xFF141414),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
