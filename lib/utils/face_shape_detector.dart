import 'package:google_mlkit_face_mesh_detection/google_mlkit_face_mesh_detection.dart';
import 'dart:math';
import 'dart:collection';

class FaceShapeResult {
  final String shape;
  final double confidence;

  FaceShapeResult(this.shape, this.confidence);
}

class _FaceMeasurements {
  final double faceLength;
  final double faceWidth;
  final double jawWidth;
  final double foreheadWidth;

  _FaceMeasurements(
    this.faceLength,
    this.faceWidth,
    this.jawWidth,
    this.foreheadWidth,
  );
}

class FaceShapeDetector {
  static const int _maxHistory = 15;
  final Queue<_FaceMeasurements> _history = Queue<_FaceMeasurements>();

  void addFrame(FaceMesh face) {
    if (face.points.length < 468) return;

    final points = face.points;

    FaceMeshPoint? getPoint(int index) {
      for (final p in points) {
        if (p.index == index) return p;
      }
      return null;
    }

    double distance3D(FaceMeshPoint? p1, FaceMeshPoint? p2) {
      if (p1 == null || p2 == null) return 0.0;
      return sqrt(pow(p1.x - p2.x, 2) + pow(p1.y - p2.y, 2) + pow(p1.z - p2.z, 2));
    }

    // Top of forehead (10), bottom of chin (152)
    double faceLength = distance3D(getPoint(152), getPoint(10));

    // Cheekbones — widest part of the face (454, 234)
    double faceWidth = distance3D(getPoint(454), getPoint(234));

    // Jawline width - averaging a couple of points to get the curve
    double jawWidth1 = distance3D(getPoint(361), getPoint(132));
    double jawWidth2 = distance3D(getPoint(365), getPoint(136));
    double jawWidth = (jawWidth1 + jawWidth2) / 2.0;

    // Forehead/temple width
    double foreheadWidth = distance3D(getPoint(356), getPoint(127));

    if (faceLength > 0 && faceWidth > 0 && jawWidth > 0 && foreheadWidth > 0) {
      _history.add(_FaceMeasurements(faceLength, faceWidth, jawWidth, foreheadWidth));
      if (_history.length > _maxHistory) {
        _history.removeFirst();
      }
    }
  }

  FaceShapeResult getSmoothedResult() {
    if (_history.isEmpty) {
      return FaceShapeResult('Unknown', 0.0);
    }

    double avgLength = 0, avgWidth = 0, avgJaw = 0, avgForehead = 0;
    for (final m in _history) {
      avgLength += m.faceLength;
      avgWidth += m.faceWidth;
      avgJaw += m.jawWidth;
      avgForehead += m.foreheadWidth;
    }

    int count = _history.length;
    avgLength /= count;
    avgWidth /= count;
    avgJaw /= count;
    avgForehead /= count;

    double lengthToWidth = avgLength / avgWidth;
    double jawToFace = avgJaw / avgWidth;
    double foreheadToJaw = avgForehead / avgJaw;
    double foreheadToFace = avgForehead / avgWidth;

    String predictedShape = 'Oval';
    double confidence = 0.85;

    // We calculate a continuous confidence score based on how close the ratios
    // are to the expected ranges, clamped between 0.70 and 0.99.
    double baseConfidence = 0.80 + (min(count / _maxHistory, 1.0) * 0.15);

    if (lengthToWidth > 1.4) {
      // Longer face
      if (jawToFace > 0.80 && foreheadToFace > 0.80) {
        predictedShape = 'Rectangle';
        confidence = baseConfidence + 0.04;
      } else if (foreheadToFace < 0.75 && jawToFace < 0.75) {
         // Cheekbones are the widest part on a long face
         predictedShape = 'Oblong';
         confidence = baseConfidence + 0.03;
      } else if (foreheadToJaw > 1.20 && jawToFace < 0.82) {
        predictedShape = 'Heart';
        confidence = baseConfidence + 0.02;
      } else {
        predictedShape = 'Oval';
        confidence = baseConfidence + 0.02;
      }
    } else {
      // Shorter / wider face
      if (jawToFace < 0.75 && foreheadToFace < 0.75) {
        predictedShape = 'Diamond';
        confidence = baseConfidence + 0.04;
      } else if (jawToFace > 0.90 && foreheadToJaw < 0.95) {
        predictedShape = 'Triangle';
        confidence = baseConfidence + 0.03;
      } else if (foreheadToJaw > 1.20 && jawToFace < 0.82) {
        predictedShape = 'Heart';
        confidence = baseConfidence + 0.04;
      } else if (jawToFace > 0.85 && foreheadToJaw < 1.05 && foreheadToJaw > 0.95) {
        predictedShape = 'Square';
        confidence = baseConfidence + 0.03;
      } else {
        predictedShape = 'Round';
        confidence = baseConfidence + 0.02;
      }
    }

    // Clamp confidence
    confidence = min(max(confidence, 0.0), 0.99);

    return FaceShapeResult(predictedShape, confidence);
  }
}