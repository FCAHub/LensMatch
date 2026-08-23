import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_mesh_detection/google_mlkit_face_mesh_detection.dart';
import 'dart:io';
import '../main.dart';

import '../utils/tflite_face_detector.dart';

class CameraView extends StatefulWidget {
  const CameraView({super.key});

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  CameraController? _controller;
  bool _isCameraInitialized = false;

  final FaceMeshDetector _faceDetector = FaceMeshDetector(
    option: FaceMeshDetectorOptions.faceMesh,
  );

  bool _isProcessing = false;
  String _instructionText = 'Position face in frame';
  bool _isAligned = false;
  FaceMesh? _latestFace;
  Size? _imageSize;
  final TFLiteFaceDetector _tfliteDetector = TFLiteFaceDetector();

  @override
  void initState() {
    super.initState();
    _tfliteDetector.loadModel();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    if (cameras.isEmpty) return;

    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      frontCamera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888,
    );

    try {
      await _controller!.initialize();
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
        _controller!.startImageStream(_processCameraImage);
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
    }
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      final camera = cameras.firstWhere((c) => c.lensDirection == CameraLensDirection.front);
      final sensorOrientation = camera.sensorOrientation;
      final rotation = InputImageRotationValue.fromRawValue(sensorOrientation) ?? InputImageRotation.rotation0deg;
      final format = InputImageFormatValue.fromRawValue(image.format.raw) ?? InputImageFormat.nv21;

      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      final inputImage = InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: format,
          bytesPerRow: image.planes.isNotEmpty ? image.planes[0].bytesPerRow : 0,
        ),
      );

      bool isPortrait = rotation == InputImageRotation.rotation90deg || rotation == InputImageRotation.rotation270deg;
      Size rotatedSize = isPortrait 
          ? Size(image.height.toDouble(), image.width.toDouble()) 
          : Size(image.width.toDouble(), image.height.toDouble());

      final faces = await _faceDetector.processImage(inputImage);
      _evaluateFaces(faces, rotatedSize);
    } catch (e) {
      debugPrint("Error processing image: $e");
    } finally {
      _isProcessing = false;
    }
  }

  void _evaluateFaces(List<FaceMesh> faces, Size imageSize) {
    if (faces.isEmpty) {
      if (mounted) {
        setState(() {
          _latestFace = null;
        });
      }
      _setInstruction('Position face in frame', false);
      return;
    }

    final face = faces.first;
    if (mounted) {
      setState(() {
        _latestFace = face;
        _imageSize = imageSize;
      });
    }

    if (face.points.length < 468) {
      _setInstruction('Detecting...', false);
      return;
    }

    FaceMeshPoint getPoint(int index) => face.points.firstWhere((p) => p.index == index, orElse: () => face.points.first);
    
    final noseTip = getPoint(1);
    final leftCheek = getPoint(234);
    final rightCheek = getPoint(454);
    
    // 1. Size check: face must be a reasonable size in the frame
    final faceWidth = (rightCheek.x - leftCheek.x).abs();
    if (faceWidth < imageSize.width * 0.40) {
      _setInstruction('Move closer', false);
      return;
    }
    if (faceWidth > imageSize.width * 0.70) {
      _setInstruction('Move further away', false);
      return;
    }

    // 2. Center check: face must be near the middle horizontally and vertically
    final centerX = (leftCheek.x + rightCheek.x) / 2;
    if ((centerX - imageSize.width / 2).abs() > imageSize.width * 0.12) {
      _setInstruction('Center your face', false);
      return;
    }

    final centerY = noseTip.y;
    if ((centerY - imageSize.height / 2).abs() > imageSize.height * 0.15) {
      _setInstruction('Center your face', false);
      return;
    }

    // 3. Pose check: looking straight ahead
    // Compare horizontal distance from nose to cheeks
    final distLeft = (noseTip.x - leftCheek.x).abs();
    final distRight = (rightCheek.x - noseTip.x).abs();
    
    if (distRight == 0) return; // prevent division by zero
    
    final poseRatio = distLeft / distRight;
    if (poseRatio < 0.65 || poseRatio > 1.35) {
      _setInstruction('Look straight ahead', false);
      return;
    }

    _setInstruction('Face Aligned! Ready to scan.', true);
  }

  void _setInstruction(String text, bool aligned) {
    if (_instructionText == text && _isAligned == aligned) return;

    if (mounted) {
      setState(() {
        _instructionText = text;
        _isAligned = aligned;
      });
    }
  }

  Future<void> _captureAndNavigate() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (_isProcessing) return;
    
    try {
      setState(() {
        _isProcessing = true;
        _instructionText = "Analyzing face shape...";
      });
      
      await _controller!.stopImageStream();
      final XFile file = await _controller!.takePicture();
      
      FaceShapeResult? shapeResult;
      if (_latestFace != null) {
        shapeResult = await _tfliteDetector.processImage(file.path, _latestFace!);
      }
      
      if (!mounted) return;
      Navigator.pop(context, <String, dynamic>{
        'imagePath': file.path,
        'shapeResult': shapeResult,
      });
    } catch (e) {
      debugPrint("Capture error: $e");
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _instructionText = "Capture failed. Try again.";
        });
      }
    }
  }

  @override
  void dispose() {
    _faceDetector.close();
    _tfliteDetector.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera feed
          if (_isCameraInitialized)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller!.value.previewSize?.height ?? 1,
                height: _controller!.value.previewSize?.width ?? 1,
                child: CameraPreview(_controller!),
              ),
            )
          else
            Container(
              color: Colors.black,
              child: const Center(child: CircularProgressIndicator(color: Colors.white)),
            ),

          // Face Mesh Overlay
          if (_isCameraInitialized && _imageSize != null)
            Positioned.fill(
              child: CustomPaint(
                painter: FaceMeshPainter(_latestFace, _imageSize!, _isAligned),
              ),
            ),

          // Back button
          Positioned(
            top: 48,
            left: 16,
            child: IconButton(
              icon: const Icon(PhosphorIcons.x, color: Colors.white, size: 32),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Dynamic instruction pill
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Container(
                  key: ValueKey<String>(_instructionText),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: _isAligned ? Colors.greenAccent : Colors.white38,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    _instructionText,
                    textAlign: TextAlign.center,
                    style: textTheme.titleMedium?.copyWith(
                      color: _isAligned ? Colors.greenAccent : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Capture Button
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: ElevatedButton(
              onPressed: (_isAligned && !_isProcessing) ? _captureAndNavigate : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).colorScheme.primary,
                disabledBackgroundColor: Colors.grey.shade800,
              ),
              child: _isProcessing 
                ? const SizedBox(
                    height: 20, 
                    width: 20, 
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                  )
                : Text(
                    'Capture & Scan', 
                    style: textTheme.titleMedium?.copyWith(
                      color: _isAligned ? const Color(0xFF141414) : Colors.grey.shade500, 
                      fontWeight: FontWeight.bold
                    )
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class FaceMeshPainter extends CustomPainter {
  final FaceMesh? faceMesh;
  final Size imageSize;
  final bool isAligned;

  FaceMeshPainter(this.faceMesh, this.imageSize, this.isAligned);

  @override
  void paint(Canvas canvas, Size size) {
    if (faceMesh == null) return;

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = isAligned ? Colors.greenAccent.withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.5);

    // Calculate scale between camera image and screen canvas
    // Wait, the camera preview might be cropped (BoxFit.cover). 
    // We assume the aspect ratio matches closely enough for a simple UI mesh.
    // If it's a FittedBox with BoxFit.cover, we need to map correctly.
    // The parent of this CustomPaint is Positioned.fill over the Stack.
    // The camera is FittedBox(fit: BoxFit.cover, SizedBox(width: previewHeight, height: previewWidth))
    // We'll calculate simple X and Y scale based on the screen size.
    final double scaleX = size.width / imageSize.width;
    final double scaleY = size.height / imageSize.height;

    // Draw the 468 mesh points
    for (final point in faceMesh!.points) {
      // The image from front camera might need flipping horizontally.
      // We will flip X so it mirrors the preview.
      final double x = size.width - (point.x * scaleX);
      final double y = point.y * scaleY;
      
      canvas.drawCircle(Offset(x, y), 1.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant FaceMeshPainter oldDelegate) {
    return oldDelegate.faceMesh != faceMesh || oldDelegate.isAligned != isAligned;
  }
}
