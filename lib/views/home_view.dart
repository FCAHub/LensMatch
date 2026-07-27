import 'package:flutter/material.dart';


import 'camera_view.dart';
import 'reservations_view.dart';
import '../utils/app_state.dart';

class HomeView extends StatelessWidget {
  final VoidCallback? onScanPressed;

  const HomeView({super.key, this.onScanPressed});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome to', style: textTheme.titleLarge?.copyWith(letterSpacing: 1.2, color: colorScheme.onSurfaceVariant)),
            Text('LensMatch', style: textTheme.headlineLarge?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.w800, height: 1.1)),
            const SizedBox(height: 32),
            
            // Hero Scan Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Text('Find your perfect frame', style: textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(
                      'Scan your face to get AI-powered eyewear recommendations tailored to your face shape.',
                      style: textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: onScanPressed ?? () {
                           Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const CameraView()),
                          );
                        },
                        child: Text('Scan your face', style: textTheme.titleMedium?.copyWith(color: const Color(0xFF141414), fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        const SizedBox(height: 32),
            Text('Quick Links', style: textTheme.titleMedium),
            const SizedBox(height: 16),
            _buildQuickLink(context, 'Last result', 'Oval shape - 3 recommendations'),
            const SizedBox(height: 12),
            ValueListenableBuilder<List<Map<String, dynamic>>>(
              valueListenable: AppState.reservedFrames,
              builder: (context, reservedList, child) {
                return _buildQuickLink(
                  context, 
                  'My Reservations', 
                  '${reservedList.length} items reserved',
                  onTap: () {
                    // We wrap it in a Scaffold so it has a back button if pushed over Home
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ReservationsView(),
                      ),
                    );
                  }
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickLink(BuildContext context, String title, String subtitle, {VoidCallback? onTap}) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2A2A35)),
        ),
        child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: textTheme.bodyLarge),
              const SizedBox(height: 4),
              Text(subtitle, style: textTheme.bodySmall),
            ],
          ),
          Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
        ],
      ),
      ),
    );
  }
}
