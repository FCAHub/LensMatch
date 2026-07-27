import 'package:flutter/material.dart';
import 'dart:io';
import 'ar_tryon_view.dart';
import '../utils/face_shape_detector.dart';

class ResultView extends StatelessWidget {
  final String? imagePath;
  final FaceShapeResult? shapeResult;

  const ResultView({super.key, this.imagePath, this.shapeResult});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Analysis Result', style: textTheme.headlineMedium),
            const SizedBox(height: 32),
            
            // Face diagram
            Container(
              width: 140,
              height: 180,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF2A2A35)),
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFF0A0A0A),
              ),
              clipBehavior: Clip.antiAlias,
              child: imagePath != null
                  ? Image.file(File(imagePath!), fit: BoxFit.cover)
                  : const Icon(Icons.person, size: 64, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            
            // Face shape label & confidence
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(shapeResult?.shape ?? 'Oval', style: textTheme.displayMedium?.copyWith(color: colorScheme.primary)),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('${((shapeResult?.confidence ?? 0.94) * 100).toInt()}% Match', style: textTheme.labelMedium?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 40),
            
            // Suitable frames
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Suitable frame shapes', style: textTheme.titleMedium),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (shapeResult?.shape == 'Round' 
                ? ['Rectangle', 'Square', 'Wayfarer']
                : shapeResult?.shape == 'Square'
                ? ['Round', 'Oval', 'Aviator']
                : ['Square', 'Rectangle', 'Aviator']).map((s) => _buildShapeChip(context, s, true)).toList(),
            ),
            const SizedBox(height: 24),
            
            // Frames to avoid
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Frames to avoid', style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (shapeResult?.shape == 'Round' 
                ? ['Round', 'Oversized']
                : shapeResult?.shape == 'Square'
                ? ['Square', 'Geometric']
                : ['Round', 'Oversized']).map((s) => _buildShapeChip(context, s, false)).toList(),
            ),
            
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ARTryonView()),
                  );
                },
                child: Text('Try Frames On', style: textTheme.titleMedium?.copyWith(color: const Color(0xFF141414), fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShapeChip(BuildContext context, String label, bool isSuitable) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSuitable ? colorScheme.primary.withValues(alpha: 0.1) : colorScheme.surface,
        border: Border.all(
          color: isSuitable ? colorScheme.primary : colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isSuitable) ...[
            Icon(Icons.check, size: 16, color: colorScheme.primary),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color: isSuitable ? colorScheme.primary : colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
