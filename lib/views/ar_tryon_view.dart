import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:flutter/foundation.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'dart:io';

import '../main.dart'; // Access global 'cameras' list
import 'frame_painter.dart';

class ARTryonView extends StatefulWidget {
  const ARTryonView({super.key});

  @override
  State<ARTryonView> createState() => _ARTryonViewState();
}

class _ARTryonViewState extends State<ARTryonView> {
  CameraController? _controller;
  bool _isCameraInitialized = false;

  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: false,
      enableLandmarks: true,
      enableTracking: true,
      performanceMode: FaceDetectorMode.fast,
    ),
  );

  bool _isProcessing = false;
  List<Face> _faces = [];
  Size? _imageSize;
  InputImageRotation? _rotation;
  
  FrameStyle _selectedFrame = FrameStyle.none;
  int _selectedTabIndex = 0; // 0 for Recommended, 1 for All Frames

  final List<FrameStyle> _recommendedFrames = [
    FrameStyle.none,
    FrameStyle.classicRectangular,
    FrameStyle.aviators,
  ];

  final List<FrameStyle> _allFrames = [
    FrameStyle.none,
    FrameStyle.classicRectangular,
    FrameStyle.retroRound,
    FrameStyle.aviators,
    FrameStyle.catEye,
    FrameStyle.wayfarer,
  ];

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

      final faces = await _faceDetector.processImage(inputImage);
      
      if (mounted) {
        setState(() {
          _faces = faces;
          _imageSize = Size(image.width.toDouble(), image.height.toDouble());
          _rotation = rotation;
        });
      }
    } catch (e) {
      debugPrint("Error processing image: $e");
    } finally {
      _isProcessing = false;
    }
  }

  @override
  void dispose() {
    _faceDetector.close();
    _controller?.stopImageStream();
    _controller?.dispose();
    super.dispose();
  }

  String _getFrameName(FrameStyle style) {
    switch (style) {
      case FrameStyle.none: return 'None';
      case FrameStyle.classicRectangular: return 'Rectangular';
      case FrameStyle.retroRound: return 'Round';
      case FrameStyle.aviators: return 'Aviator';
      case FrameStyle.catEye: return 'Cat Eye';
      case FrameStyle.wayfarer: return 'Wayfarer';
    }
  }

  Widget _buildFilterItem(FrameStyle style) {
    final isSelected = _selectedFrame == style;
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFrame = style;
        });
      },
      child: Container(
        width: 80,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? theme.colorScheme.primary : Colors.white30,
                  width: isSelected ? 3 : 1,
                ),
                color: Colors.black45,
              ),
              child: Center(
                child: style == FrameStyle.none
                    ? const Icon(PhosphorIcons.prohibit, color: Colors.white, size: 28)
                    : const Icon(PhosphorIcons.sunglasses, color: Colors.white, size: 28),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getFrameName(style),
              style: theme.textTheme.labelSmall?.copyWith(
                color: isSelected ? theme.colorScheme.primary : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentFramesList = _selectedTabIndex == 0 ? _recommendedFrames : _allFrames;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera feed & AR Overlay
          if (_isCameraInitialized)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller!.value.previewSize?.height ?? 1,
                height: _controller!.value.previewSize?.width ?? 1,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CameraPreview(_controller!),
                    if (_faces.isNotEmpty && _imageSize != null && _rotation != null && _selectedFrame != FrameStyle.none)
                      CustomPaint(
                        painter: FramePainter(
                          faces: _faces,
                          imageSize: _imageSize!,
                          rotation: _rotation!,
                          selectedFrame: _selectedFrame,
                        ),
                      ),
                  ],
                ),
              ),
            )
          else
            const Center(child: CircularProgressIndicator(color: Colors.white)),

          // Top Gradient & Back Button
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 120,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black87, Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            top: 48,
            left: 16,
            child: IconButton(
              icon: const Icon(PhosphorIcons.caretLeft, color: Colors.white, size: 32),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          
          // Filter Selector (Bottom)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(top: 16, bottom: 32),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black87, Colors.black54, Colors.transparent],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Tabs
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _selectedTabIndex = 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: _selectedTabIndex == 0 ? theme.colorScheme.primary : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                          child: Text(
                            'Recommended',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: _selectedTabIndex == 0 ? theme.colorScheme.primary : Colors.white70,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () => setState(() => _selectedTabIndex = 1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: _selectedTabIndex == 1 ? theme.colorScheme.primary : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                          child: Text(
                            'All Frames',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: _selectedTabIndex == 1 ? theme.colorScheme.primary : Colors.white70,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Filter List
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: currentFramesList.length,
                      itemBuilder: (context, index) {
                        return _buildFilterItem(currentFramesList[index]);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
