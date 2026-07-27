import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_mesh_detection/google_mlkit_face_mesh_detection.dart';
import 'dart:io';
import '../main.dart'; // Access global 'cameras' list
import 'result_view.dart'; // To navigate after capture
import '../utils/face_shape_detector.dart';

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
  String _instructionText = 'Align face within oval';
  bool _isAligned = false;
  FaceMesh? _latestFace;

  @override
  void initState() {
    super.initState();
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
      _setInstruction('Align face within oval', false);
      _latestFace = null;
      return;
    }

    final face = faces.first;
    _latestFace = face;
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
    try {
      FaceShapeResult? shapeResult;
      if (_latestFace != null) {
        shapeResult = FaceShapeDetector.detectShape(_latestFace!);
      }

      await _controller!.stopImageStream();
      final XFile file = await _controller!.takePicture();
      
      if (!mounted) return;
      Navigator.pop(context, {
        'imagePath': file.path,
        'shapeResult': shapeResult,
      });
    } catch (e) {
      debugPrint("Capture error: $e");
    }
  }

  @override
  void dispose() {
    _faceDetector.close();
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

          // Face scanner overlay mask
          if (_isCameraInitialized)
            Positioned.fill(
              child: CustomPaint(
                painter: _ScannerOverlayPainter(),
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

          // Face scanner oval guide outline & instructions
          Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 250,
              height: 360,
              decoration: BoxDecoration(
                border: Border.all(
                  color: _isAligned ? Colors.greenAccent : Colors.white70,
                  width: _isAligned ? 4 : 2,
                ),
                borderRadius: const BorderRadius.all(Radius.elliptical(250, 360)),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      PhosphorIcons.faceMask,
                      color: _isAligned ? Colors.transparent : Colors.white54,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        key: ValueKey<String>(_instructionText),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _instructionText,
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium?.copyWith(
                            color: _isAligned ? Colors.greenAccent : Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
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
              onPressed: _isAligned ? _captureAndNavigate : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).colorScheme.primary,
                disabledBackgroundColor: Colors.grey.shade800,
              ),
              child: Text(
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

class _ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;
      
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addOval(Rect.fromCenter(
          center: Offset(size.width / 2, size.height / 2), 
          width: 250, 
          height: 360))
      ..fillType = PathFillType.evenOdd;
      
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
