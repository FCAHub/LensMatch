import 'package:google_mlkit_face_mesh_detection/google_mlkit_face_mesh_detection.dart';
import 'dart:math';

class FaceShapeResult {
  final String shape;
  final double confidence;

  FaceShapeResult(this.shape, this.confidence);
}

class FaceShapeDetector {
  static FaceShapeResult detectShape(FaceMesh face) {
    if (face.points.length < 468) {
      return FaceShapeResult('Unknown', 0.0);
    }

    final points = face.points;
    
    FaceMeshPoint getPoint(int index) {
      return points.firstWhere((p) => p.index == index, orElse: () => points.first);
    }

    double distance(FaceMeshPoint p1, FaceMeshPoint p2) {
      return sqrt(pow(p1.x - p2.x, 2) + pow(p1.y - p2.y, 2) + pow(p1.z - p2.z, 2));
    }

    // MediaPipe Face Mesh Key Points (Anatomically accurate landmarks)
    // Top of forehead: 10, Bottom of chin: 152
    double faceLength = distance(getPoint(152), getPoint(10));

    // Left cheek edge: 234, Right cheek edge: 454 (widest part of face)
    double faceWidth = distance(getPoint(454), getPoint(234));

    // Jaw edge left: 177, Jaw edge right: 401 (mid-lower jawline)
    double jawWidth = distance(getPoint(401), getPoint(177));
    
    // Forehead temple left: 70, Forehead temple right: 300 (outer brow/temples)
    double foreheadWidth = distance(getPoint(300), getPoint(70));

    double lengthToWidth = faceWidth > 0 ? faceLength / faceWidth : 1.0;
    double jawToForehead = foreheadWidth > 0 ? jawWidth / foreheadWidth : 1.0;
    
    String predictedShape = 'Oval';
    double confidence = 0.85;

    // Refined heuristic rules for face shape determination
    // Typical length/width ratio is ~1.3. >1.35 is long, <1.25 is short.
    if (lengthToWidth > 1.35) {
      // Long faces: Oval or Rectangle
      if (jawWidth > foreheadWidth * 0.95) {
        predictedShape = 'Rectangle';
        confidence = 0.90;
      } else {
        predictedShape = 'Oval';
        confidence = 0.95;
      }
    } else {
      // Shorter/Wider faces: Square, Round, or Heart
      // If jaw is almost as wide as the cheek width, it's square
      if (jawWidth > faceWidth * 0.85) {
        predictedShape = 'Square';
        confidence = 0.88;
      } else if (jawToForehead < 0.80) { // Narrow jaw compared to forehead
        predictedShape = 'Heart';
        confidence = 0.91;
      } else {
        predictedShape = 'Round';
        confidence = 0.89;
      }
    }

    return FaceShapeResult(predictedShape, confidence);
  }
}
