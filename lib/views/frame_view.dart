import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'frame_detail_view.dart';

class FrameView extends StatelessWidget {
  const FrameView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final frames = [
      {'id': '1', 'name': 'Classic Aviator', 'shape': 'Aviator', 'material': 'Metal', 'price': '\$129.00'},
      {'id': '2', 'name': 'Retro Square', 'shape': 'Square', 'material': 'Acetate', 'price': '\$145.00'},
      {'id': '3', 'name': 'Minimalist Wire', 'shape': 'Round', 'material': 'Titanium', 'price': '\$189.00'},
      {'id': '4', 'name': 'Bold Rectangle', 'shape': 'Rectangle', 'material': 'Acetate', 'price': '\$115.00'},
    ];

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text('Frame Catalog', style: textTheme.headlineMedium),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.65,
              ),
              itemCount: frames.length,
              itemBuilder: (context, index) {
                final frame = frames[index];
                return _buildFrameCard(context, frame);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFrameCard(BuildContext context, Map<String, String> frame) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF2A2A35)),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FrameDetailView(frame: frame),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Placeholder for frame image
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A0A0A),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Icon(PhosphorIcons.eyeglasses, size: 48, color: colorScheme.onSurfaceVariant),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(frame['shape']!, style: textTheme.labelSmall?.copyWith(color: colorScheme.onPrimaryContainer)),
              ),
              const SizedBox(height: 8),
              Text(frame['name']!, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
              Text(frame['material']!, style: textTheme.bodySmall),
              const SizedBox(height: 8),
              Text(frame['price']!, style: textTheme.labelLarge?.copyWith(color: colorScheme.primary)),
            ],
          ),
        ),
      ),
    );
  }
}
