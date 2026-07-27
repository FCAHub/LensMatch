import 'package:flutter/material.dart';
import '../utils/app_state.dart';
import 'frame_detail_view.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class ReservationsView extends StatelessWidget {
  const ReservationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('My', style: textTheme.titleLarge?.copyWith(letterSpacing: 1.2, color: colorScheme.onSurfaceVariant)),
            Text('Reservations', style: textTheme.headlineLarge?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.w800, height: 1.1)),
            const SizedBox(height: 32),
            
            Expanded(
              child: ValueListenableBuilder<List<Map<String, dynamic>>>(
                valueListenable: AppState.reservedFrames,
                builder: (context, reservedList, child) {
                  if (reservedList.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.bookmark_outline, size: 64, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                          const SizedBox(height: 16),
                          Text('No reservations yet', style: textTheme.titleMedium),
                          const SizedBox(height: 8),
                          Text(
                            'Frames you reserve will appear here so you can try them on in-store.',
                            style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: reservedList.length,
                    itemBuilder: (context, index) {
                      final frame = reservedList[index];
                      // Cast to Map<String, String> because FrameDetailView expects it
                      final Map<String, String> typedFrame = Map<String, String>.from(frame);
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Color(0xFF2A2A35)),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0A0A0A),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(PhosphorIcons.eyeglasses, color: colorScheme.onSurfaceVariant),
                          ),
                          title: Text(typedFrame['name'] ?? '', style: textTheme.titleMedium),
                          subtitle: Text(typedFrame['price'] ?? '', style: textTheme.bodyMedium?.copyWith(color: colorScheme.primary)),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FrameDetailView(frame: typedFrame),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}
