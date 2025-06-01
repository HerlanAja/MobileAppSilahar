import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import 'dart:ui';

class VisiMisi extends StatefulWidget {
  const VisiMisi({Key? key}) : super(key: key);

  @override
  State<VisiMisi> createState() => _VisiMisiState();
}

class _VisiMisiState extends State<VisiMisi> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isLoading = true;
  String? _imageUrl;
  String? _errorMessage;
  final double _scale = 1.0;
  
  // Base URL for the API
  final String _baseUrl = 'http://silahar3272.ftp.sh:3000';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    
    _fetchVisiMisi();
  }

  Future<void> _fetchVisiMisi() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/api/profile/visi-misi'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Debug print to see the actual response
        print('API Response: $data');
        
        // Extract the image path using the correct key 'visi_misi_image'
        final imagePath = data['visi_misi_image'];
        
        if (imagePath != null) {
          // Construct the full URL by combining base URL with the image path
          setState(() {
            _imageUrl = '$_baseUrl/$imagePath';
            _isLoading = false;
          });
          
          // Debug print to see the constructed image URL
          print('Image URL: $_imageUrl');
        } else {
          setState(() {
            _errorMessage = 'Image path not found in API response';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to load data: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Modern color theme
    final Color primaryColor = const Color(0xFF546E7A);
    final Color accentColor = const Color(0xFF90A4AE);
    final Color backgroundColor = const Color(0xFFF5F7F8);
    
    return Scaffold(
      backgroundColor: backgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.arrow_back_rounded,
              color: primaryColor,
              size: 20,
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            'Visi & Misi',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: primaryColor,
              fontSize: 18,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Animated background pattern
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: BackgroundPatternPainter(
                    color: accentColor.withOpacity(0.05),
                    animation: _controller.value,
                  ),
                );
              },
            ),
          ),
          
          // Main content
          Center(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return _buildLoadingState();
    } else if (_errorMessage != null) {
      return _buildErrorState();
    } else if (_imageUrl != null) {
      return _buildImageView();
    } else {
      return _buildErrorState(message: 'No image data available');
    }
  }

  Widget _buildLoadingState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator()
            .animate(onPlay: (controller) => controller.repeat())
            .shimmer(duration: 1200.ms, color: Colors.white)
            .animate()
            .scale(
              begin: const Offset(0.8, 0.8),
              end: const Offset(1.2, 1.2),
              duration: 1000.ms,
            )
            .then()
            .scale(
              begin: const Offset(1.2, 1.2),
              end: const Offset(0.8, 0.8),
              duration: 1000.ms,
            ),
        const SizedBox(height: 24),
        Text(
          'Memuat Visi & Misi...',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.5, end: 0),
      ],
    );
  }

  Widget _buildErrorState({String? message}) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.shade300,
          ).animate().shake(duration: 700.ms),
          const SizedBox(height: 16),
          Text(
            message ?? _errorMessage ?? 'An error occurred',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2, end: 0),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _isLoading = true;
                _errorMessage = null;
              });
              _fetchVisiMisi();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.5, end: 0),
        ],
      ),
    );
  }

  Widget _buildImageView() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 100),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Title with animation
          Text(
            'Visi & Misi',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF37474F),
            ),
          ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0),
          
          const SizedBox(height: 8),
          
          // Subtitle with animation
          Text(
            'Badan Pusat Statistik Kota Sukabumi',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF546E7A),
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideY(begin: -0.2, end: 0),
          
          const SizedBox(height: 24),
          
          // Image container with shadow and rounded corners
          Expanded(
            child: Hero(
              tag: 'visi_misi_image',
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 3.0,
                    child: Stack(
                      children: [
                        // Image with loading and error handling
                        Image.network(
                          _imageUrl!,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) {
                              return child.animate().fadeIn(duration: 800.ms);
                            }
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded / 
                                          loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Loading image...',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            print('Image loading error: $error');
                            return _buildErrorState(message: 'Failed to load image: $error');
                          },
                        ),
                        
                        // Zoom hint overlay that fades out after a few seconds
                        Positioned(
                          bottom: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.zoom_out_map,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Pinch to zoom',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ).animate().fadeIn().then(delay: 2.seconds).fadeOut(),
                      ],
                    ),
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 400.ms, duration: 800.ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
          ),
          
          const SizedBox(height: 24),
          
          // Caption with animation
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              'Swipe dan zoom untuk melihat detail',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF546E7A),
              ),
              textAlign: TextAlign.center,
            ),
          ).animate().fadeIn(delay: 600.ms, duration: 600.ms).slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }
}

// Custom painter for animated background pattern
class BackgroundPatternPainter extends CustomPainter {
  final Color color;
  final double animation;

  BackgroundPatternPainter({required this.color, required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final double tileSize = 30;
    final double offset = animation * tileSize;

    for (double x = -tileSize; x < size.width + tileSize; x += tileSize) {
      for (double y = -tileSize; y < size.height + tileSize; y += tileSize) {
        final path = Path();
        path.moveTo(x + offset, y);
        path.lineTo(x + tileSize / 2 + offset, y + tileSize / 2);
        path.lineTo(x + offset, y + tileSize);
        path.lineTo(x - tileSize / 2 + offset, y + tileSize / 2);
        path.close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(BackgroundPatternPainter oldDelegate) =>
      oldDelegate.animation != animation;
}