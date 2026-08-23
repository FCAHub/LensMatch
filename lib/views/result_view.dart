import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'ar_tryon_view.dart';
import '../utils/tflite_face_detector.dart';

class ResultView extends StatefulWidget {
  final String? imagePath;
  final FaceShapeResult? shapeResult;

  const ResultView({super.key, this.imagePath, this.shapeResult});

  @override
  State<ResultView> createState() => _ResultViewState();
}

class _ResultViewState extends State<ResultView> {
  bool _isLoading = false;
  List<String> _recommendedFrames = [];
  List<String> _avoidedFrames = [];
  String? _aiDescription;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.imagePath != null || widget.shapeResult != null) {
      _fetchAIRecommendations();
    }
  }

  @override
  void didUpdateWidget(ResultView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shapeResult != oldWidget.shapeResult || widget.imagePath != oldWidget.imagePath) {
       if (widget.imagePath != null || widget.shapeResult != null) {
        _fetchAIRecommendations();
      }
    }
  }

  Future<void> _fetchAIRecommendations() async {
    // Attempt to load .env again just in case it wasn't loaded at startup
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      debugPrint('Error reloading .env: $e');
    }

    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? 
                   dotenv.env['GOOGLE_API_KEY'] ?? 
                   dotenv.env['API_KEY'] ?? '';
    
    if (apiKey.isEmpty) {
       debugPrint('GEMINI_API_KEY is empty in .env');
       if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'API Key not found. Please ensure you have created a file named ".env" in the root directory (next to pubspec.yaml) and added GEMINI_API_KEY=your_key_here';
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _recommendedFrames = [];
        _avoidedFrames = [];
        _aiDescription = null;
      });
    }

    try {
      final shape = widget.shapeResult?.shape ?? 'Oval';
      debugPrint('Fetching recommendations for shape: $shape');
      
      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
          temperature: 0.1,
        ),
      );

      final prompt = '''You are an expert optical stylist. Given a $shape face shape, return a JSON object with exactly three keys: "recommended", "avoided", and "description". 
The "recommended" and "avoided" values must be arrays of strings. 
You must ONLY choose from this exact list of frame shapes, using these exact spellings: ["Round", "Cat Eye", "Rectangle", "Wayfarer", "Square", "Aviator", "Geometric", "Browline", "Oval"].
The "description" must be a short string (2-3 sentences) explaining why these frames are recommended for this face shape.
Do not output anything else except the raw JSON object.''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      
      final text = response.text;
      debugPrint('Gemini Response: $text');

      if (text == null || text.isEmpty) {
        throw Exception('No response from AI.');
      }

      String cleanJson = text.trim();
      final jsonStartIndex = cleanJson.indexOf('{');
      final jsonEndIndex = cleanJson.lastIndexOf('}');
      
      if (jsonStartIndex != -1 && jsonEndIndex != -1) {
        cleanJson = cleanJson.substring(jsonStartIndex, jsonEndIndex + 1);
      } else {
        throw Exception('Invalid response format from AI.');
      }

      final data = jsonDecode(cleanJson) as Map<String, dynamic>;
      
      final recsRaw = data['recommended'] ?? data['Recommended'] ?? [];
      final avoidsRaw = data['avoided'] ?? data['Avoided'] ?? [];
      final description = data['description'] ?? data['Description'] ?? 'Based on your face shape, these frames will complement your features perfectly.';
      
      final recs = (recsRaw as List<dynamic>).map((e) => e.toString()).toList();
      final avoids = (avoidsRaw as List<dynamic>).map((e) => e.toString()).toList();

      if (mounted) {
        setState(() {
          _recommendedFrames = recs;
          _avoidedFrames = avoids;
          _aiDescription = description.toString();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Gemini API Error: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to get recommendations: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    if (widget.imagePath == null && widget.shapeResult == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.face_unlock_outlined, size: 64, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text('No scan data yet', style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            Text('Please scan your face to see results', style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
          ],
        ),
      );
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Analysis Result', style: textTheme.headlineMedium),
            const SizedBox(height: 32),
            
            Container(
              width: 140,
              height: 180,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF2A2A35)),
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFF0A0A0A),
              ),
              clipBehavior: Clip.antiAlias,
              child: widget.imagePath != null
                  ? Image.file(File(widget.imagePath!), fit: BoxFit.cover)
                  : const Icon(Icons.person, size: 64, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(widget.shapeResult?.shape ?? 'Oval', style: textTheme.displayMedium?.copyWith(color: colorScheme.primary)),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('${((widget.shapeResult?.confidence ?? 0.94) * 100).toInt()}% Match', style: textTheme.labelMedium?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 40),
            
            if (_isLoading)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('AI is calculating your perfect frames...'),
                  ],
                ),
              )
            else if (_errorMessage != null)
              _buildErrorWidget(context)
            else if (_recommendedFrames.isNotEmpty)
              _buildRecommendations(context)
            else
              _buildEmptyState(context),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 32),
          const SizedBox(height: 12),
          Text(_errorMessage!, textAlign: TextAlign.center, style: textTheme.bodyMedium?.copyWith(color: Colors.redAccent)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchAIRecommendations,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            child: const Text('Retry Analysis'),
          )
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Column(
      children: [
        const Text('No recommendations found. Try scanning again.'),
        const SizedBox(height: 16),
        ElevatedButton(onPressed: _fetchAIRecommendations, child: const Text('Refresh'))
      ],
    );
  }

  Widget _buildRecommendations(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              Text('AI Recommended Frames', style: textTheme.titleMedium),
              const SizedBox(width: 8),
              const Icon(Icons.auto_awesome, color: Colors.amber, size: 18),
            ]
          ),
        ),
        if (_aiDescription != null && _aiDescription!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.tips_and_updates_outlined, color: colorScheme.primary, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _aiDescription!,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _recommendedFrames.map((s) => _buildShapeChip(context, s, true)).toList(),
          ),
        ),
        const SizedBox(height: 24),
        
        Align(
          alignment: Alignment.centerLeft,
          child: Text('Frames to avoid', style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _avoidedFrames.map((s) => _buildShapeChip(context, s, false)).toList(),
          ),
        ),
        
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ARTryonView(
                  faceShape: widget.shapeResult?.shape,
                  aiRecommendedFrames: _recommendedFrames,
                )),
              );
            },
            child: Text('Try Frames On', style: textTheme.titleMedium?.copyWith(color: const Color(0xFF141414), fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildShapeChip(BuildContext context, String label, bool isRecommended) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A24),
        border: Border.all(color: isRecommended ? Colors.green.withValues(alpha: 0.3) : Colors.red.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isRecommended ? Icons.check_circle : Icons.cancel, size: 16, color: isRecommended ? Colors.green : Colors.red),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
