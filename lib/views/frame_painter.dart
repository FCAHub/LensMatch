import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:camera/camera.dart';
import 'dart:math';
import 'dart:io';

enum FrameStyle { none, classicRectangular, retroRound, aviators, catEye, wayfarer }

class FramePainter extends CustomPainter {
  final List<Face> faces;
  final Size imageSize;
  final InputImageRotation rotation;
  final FrameStyle selectedFrame;
  final CameraLensDirection cameraLensDirection;

  FramePainter({
    required this.faces,
    required this.imageSize,
    required this.rotation,
    required this.selectedFrame,
    this.cameraLensDirection = CameraLensDirection.front,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (selectedFrame == FrameStyle.none || faces.isEmpty) return;


    for (final face in faces) {
      final leftEye = face.landmarks[FaceLandmarkType.leftEye];
      final rightEye = face.landmarks[FaceLandmarkType.rightEye];

      if (leftEye != null && rightEye != null) {
        // Adjust for screen orientation and camera scaling
        // ML Kit face coordinates:
        // x goes left-to-right on image
        // y goes top-to-bottom on image
        // For front camera, we need to mirror X.

        double lx = translateX(leftEye.position.x.toDouble(), rotation, imageSize, size, cameraLensDirection);
        double ly = translateY(leftEye.position.y.toDouble(), rotation, imageSize, size, cameraLensDirection);
        
        double rx = translateX(rightEye.position.x.toDouble(), rotation, imageSize, size, cameraLensDirection);
        double ry = translateY(rightEye.position.y.toDouble(), rotation, imageSize, size, cameraLensDirection);

        // Center between eyes
        double centerX = (lx + rx) / 2;
        double centerY = (ly + ry) / 2;

        // Distance between eyes to scale glasses
        double dx = rx - lx;
        double dy = ry - ly;
        double eyeDistance = sqrt(dx * dx + dy * dy);
        
        // Glasses width is typically about 2.2 to 2.5 times the distance between the pupils
        double glassesWidth = eyeDistance * 2.3; 
        
        // Angle of tilt
        double angle = atan2(dy, dx);

        canvas.save();
        canvas.translate(centerX, centerY);
        canvas.rotate(angle);

        _drawFrame(canvas, glassesWidth, selectedFrame);

        canvas.restore();
      }
    }
  }

  void _drawFrame(Canvas canvas, double width, FrameStyle style) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0;

    double lensWidth = width * 0.40;
    double bridgeWidth = width * 0.15;
    double height = lensWidth * 0.7; // default aspect ratio

    switch (style) {
      case FrameStyle.classicRectangular:
        paint.color = Colors.black87;
        height = lensWidth * 0.6;
        // Left lens
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(-lensWidth / 2 - bridgeWidth / 2, 0), width: lensWidth, height: height),
            const Radius.circular(8),
          ),
          paint,
        );
        // Right lens
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(lensWidth / 2 + bridgeWidth / 2, 0), width: lensWidth, height: height),
            const Radius.circular(8),
          ),
          paint,
        );
        // Bridge
        canvas.drawLine(Offset(-bridgeWidth / 2, -height * 0.2), Offset(bridgeWidth / 2, -height * 0.2), paint);
        break;

      case FrameStyle.retroRound:
        paint.color = Colors.amber.shade700;
        paint.strokeWidth = 4.0;
        height = lensWidth; // Circle
        // Left lens
        canvas.drawCircle(Offset(-lensWidth / 2 - bridgeWidth / 2, 0), lensWidth / 2, paint);
        // Right lens
        canvas.drawCircle(Offset(lensWidth / 2 + bridgeWidth / 2, 0), lensWidth / 2, paint);
        // Bridge
        canvas.drawLine(Offset(-bridgeWidth / 2, 0), Offset(bridgeWidth / 2, 0), paint);
        break;

      case FrameStyle.aviators:
        paint.color = Colors.blueGrey;
        paint.strokeWidth = 3.0;
        height = lensWidth * 0.85;
        // Left lens (simplified teardrop - using path)
        Path leftLens = Path()
          ..addOval(Rect.fromCenter(center: Offset(-lensWidth / 2 - bridgeWidth / 2, height * 0.1), width: lensWidth, height: height));
        canvas.drawPath(leftLens, paint);
        // Right lens
        Path rightLens = Path()
          ..addOval(Rect.fromCenter(center: Offset(lensWidth / 2 + bridgeWidth / 2, height * 0.1), width: lensWidth, height: height));
        canvas.drawPath(rightLens, paint);
        // Double bridge
        canvas.drawLine(Offset(-bridgeWidth / 2, -height * 0.2), Offset(bridgeWidth / 2, -height * 0.2), paint);
        canvas.drawLine(Offset(-bridgeWidth / 2, -height * 0.4), Offset(bridgeWidth / 2, -height * 0.4), paint);
        break;

      case FrameStyle.catEye:
        paint.color = Colors.red.shade800;
        paint.strokeWidth = 7.0;
        height = lensWidth * 0.65;
        
        // Left lens
        Path leftCatEye = Path()
          ..moveTo(-bridgeWidth / 2, 0)
          ..quadraticBezierTo(-lensWidth * 0.8 - bridgeWidth / 2, height * 0.6, -lensWidth - bridgeWidth / 2, -height * 0.5) // bottom & outer tip
          ..quadraticBezierTo(-lensWidth * 0.4 - bridgeWidth / 2, -height * 0.6, -bridgeWidth / 2, -height * 0.2) // top & inner
          ..close();
        canvas.drawPath(leftCatEye, paint);

        // Right lens
        Path rightCatEye = Path()
          ..moveTo(bridgeWidth / 2, 0)
          ..quadraticBezierTo(lensWidth * 0.8 + bridgeWidth / 2, height * 0.6, lensWidth + bridgeWidth / 2, -height * 0.5) // bottom & outer tip
          ..quadraticBezierTo(lensWidth * 0.4 + bridgeWidth / 2, -height * 0.6, bridgeWidth / 2, -height * 0.2) // top & inner
          ..close();
        canvas.drawPath(rightCatEye, paint);
        
        // Bridge
        canvas.drawLine(Offset(-bridgeWidth / 2, -height * 0.1), Offset(bridgeWidth / 2, -height * 0.1), paint);
        break;
        
      case FrameStyle.wayfarer:
        paint.color = Colors.indigo.shade900;
        paint.strokeWidth = 8.0;
        height = lensWidth * 0.7;
        // Left lens
        canvas.drawRRect(
          RRect.fromRectAndCorners(
             Rect.fromCenter(center: Offset(-lensWidth / 2 - bridgeWidth / 2, 0), width: lensWidth, height: height),
             topLeft: const Radius.circular(8),
             topRight: const Radius.circular(20),
             bottomLeft: const Radius.circular(12),
             bottomRight: const Radius.circular(4),
          ),
          paint,
        );
        // Right lens
        canvas.drawRRect(
          RRect.fromRectAndCorners(
             Rect.fromCenter(center: Offset(lensWidth / 2 + bridgeWidth / 2, 0), width: lensWidth, height: height),
             topLeft: const Radius.circular(20),
             topRight: const Radius.circular(8),
             bottomLeft: const Radius.circular(4),
             bottomRight: const Radius.circular(12),
          ),
          paint,
        );
        // Bridge
        canvas.drawLine(Offset(-bridgeWidth / 2, -height * 0.2), Offset(bridgeWidth / 2, -height * 0.2), paint);
        break;
      default:
        break;
    }
  }

  double translateX(
    double x,
    InputImageRotation rotation,
    Size size,
    Size absoluteImageSize,
    CameraLensDirection cameraLensDirection,
  ) {
    switch (rotation) {
      case InputImageRotation.rotation90deg:
        return x * absoluteImageSize.width / (Platform.isIOS ? size.width : size.height);
      case InputImageRotation.rotation270deg:
        return size.width - x * absoluteImageSize.width / (Platform.isIOS ? size.width : size.height);
      case InputImageRotation.rotation0deg:
      case InputImageRotation.rotation180deg:
        switch (cameraLensDirection) {
          case CameraLensDirection.back:
            return x * absoluteImageSize.width / size.width;
          default:
            return absoluteImageSize.width - x * absoluteImageSize.width / size.width;
        }
    }
  }

  double translateY(
    double y,
    InputImageRotation rotation,
    Size size,
    Size absoluteImageSize,
    CameraLensDirection cameraLensDirection,
  ) {
    switch (rotation) {
      case InputImageRotation.rotation90deg:
      case InputImageRotation.rotation270deg:
        return y * absoluteImageSize.height / (Platform.isIOS ? size.height : size.width);
      case InputImageRotation.rotation0deg:
      case InputImageRotation.rotation180deg:
        return y * absoluteImageSize.height / size.height;
    }
  }

  @override
  bool shouldRepaint(FramePainter oldDelegate) {
    return oldDelegate.imageSize != imageSize ||
        oldDelegate.faces != faces ||
        oldDelegate.rotation != rotation ||
        oldDelegate.selectedFrame != selectedFrame;
  }
}
