import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';


import 'views/home_view.dart';
import 'views/camera_view.dart';
import 'views/result_view.dart';
import 'views/frame_view.dart';
import 'views/profile_view.dart';
import 'utils/face_shape_detector.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  String? _lastImagePath;
  FaceShapeResult? _lastShapeResult;

  Widget _getViewForIndex(int index) {
    switch (index) {
      case 0: return HomeView(onScanPressed: _openCamera);
      case 1: return ResultView(imagePath: _lastImagePath, shapeResult: _lastShapeResult);
      case 2: return const FrameView();
      case 3: return const ProfileView();
      default: return HomeView(onScanPressed: _openCamera);
    }
  }

  Future<void> _openCamera() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CameraView()),
    );
    
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _lastImagePath = result['imagePath'];
        _lastShapeResult = result['shapeResult'];
        _currentIndex = 1; // Switch to Result tab
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _getViewForIndex(_currentIndex),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCamera,
        backgroundColor: Theme.of(context).colorScheme.primary,
        shape: const CircleBorder(),
        elevation: 0,
        child: const Icon(PhosphorIcons.camera, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).colorScheme.surface,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        elevation: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, PhosphorIcons.house, PhosphorIcons.houseFill, 'Home'),
            _buildNavItem(1, PhosphorIcons.scan, PhosphorIcons.scanFill, 'Result'),
            const SizedBox(width: 40), // Empty space for FAB
            _buildNavItem(2, PhosphorIcons.eyeglasses, PhosphorIcons.eyeglassesFill, 'Frame'),
            _buildNavItem(3, PhosphorIcons.user, PhosphorIcons.userFill, 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = _currentIndex == index;
    final colorScheme = Theme.of(context).colorScheme;
    
    return InkWell(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSelected ? activeIcon : icon,
            color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
            size: 24,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
