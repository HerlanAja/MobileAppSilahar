import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LogoBPS extends StatefulWidget {
  const LogoBPS({Key? key}) : super(key: key);

  @override
  State<LogoBPS> createState() => _LogoBPSState();
}

class _LogoBPSState extends State<LogoBPS> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  // Gray theme colors
  final Color primaryColor = const Color(0xFF546E7A);
  final Color secondaryColor = const Color(0xFF78909C);
  final Color accentColor = const Color(0xFF90A4AE);
  final Color backgroundColor = const Color(0xFFF5F7F8);
  final Color cardColor = Colors.white;
  final Color textColor = const Color(0xFF37474F);
  
  // Logo colors
  final Color logoBlue = const Color(0xFF0D47A1);
  final Color logoGreen = const Color(0xFF2E7D32);
  final Color logoOrange = const Color(0xFFE65100);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            'Logo BPS',
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
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo section - just the logo image
                  Center(
                    child: SizedBox(
                      width: 180,
                      height: 180,
                      child: Image.asset(
                        'assets/image/logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0),
                  
                  const SizedBox(height: 24),
                  
                  // Title
                  Center(
                    child: Text(
                      'Logo Badan Pusat Statistik',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
                  
                  const SizedBox(height: 8),
                  
                  // Subtitle
                  Center(
                    child: Text(
                      'Makna Warna pada Logo BPS',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: secondaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
                  
                  const SizedBox(height: 32),
                  
                  // Introduction text
                  Text(
                    'Logo pada Badan Pusat Statistik memiliki warna biru, hijau dan orange dan disetiap warna memiliki arti khusus:',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: textColor,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
                  
                  const SizedBox(height: 40),
                  
                  // Modern color meaning section
                  _buildModernColorMeaning(
                    color: logoBlue,
                    title: 'Biru',
                    description: 'Melambangkan kegiatan sensus penduduk yang dilakukan sepuluh tahun sekali pada setiap tahun yang berakhiran angka 0 (nol).',
                    icon: Icons.people_alt_outlined,
                    delay: 500,
                  ),
                  
                  const SizedBox(height: 40),
                  
                  _buildModernColorMeaning(
                    color: logoGreen,
                    title: 'Hijau',
                    description: 'Melambangkan kegiatan sensus pertanian yang dilakukan sepuluh tahun sekali pada setiap tahun yang berakhiran angka 3 (tiga).',
                    icon: Icons.agriculture_outlined,
                    delay: 600,
                    isReversed: true,
                  ),
                  
                  const SizedBox(height: 40),
                  
                  _buildModernColorMeaning(
                    color: logoOrange,
                    title: 'Orange',
                    description: 'Melambangkan kegiatan sensus ekonomi yang dilakukan sepuluh tahun sekali pada setiap tahun yang berakhiran angka 6 (enam).',
                    icon: Icons.trending_up_outlined,
                    delay: 700,
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Timeline visualization
                  _buildTimelineVisualization(),
                  
                  const SizedBox(height: 40),
                  
                  // Additional information in a more modern style
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.info_outline,
                          color: primaryColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Ketiga warna pada logo BPS mencerminkan siklus sensus nasional yang dilakukan secara berkala untuk mengumpulkan data statistik yang komprehensif tentang penduduk, pertanian, dan ekonomi Indonesia.',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: textColor,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 800.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernColorMeaning({
    required Color color,
    required String title,
    required String description,
    required IconData icon,
    required int delay,
    bool isReversed = false,
  }) {
    final colorCircle = Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Icon(
          icon,
          color: Colors.white,
          size: 36,
        ),
      ),
    );

    final contentWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: GoogleFonts.poppins(
            fontSize: 15,
            color: textColor,
            height: 1.5,
          ),
        ),
      ],
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: isReversed
          ? [
              Expanded(child: contentWidget),
              const SizedBox(width: 20),
              colorCircle,
            ]
          : [
              colorCircle,
              const SizedBox(width: 20),
              Expanded(child: contentWidget),
            ],
    ).animate().fadeIn(delay: Duration(milliseconds: delay)).slideX(
          begin: isReversed ? -0.2 : 0.2,
          end: 0,
        );
  }

  Widget _buildTimelineVisualization() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Text(
            'Siklus Sensus Nasional',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTimelineItem(
                year: '...0',
                color: logoBlue,
                icon: Icons.people_alt_outlined,
                label: 'Sensus Penduduk',
              ),
              _buildTimelineItem(
                year: '...3',
                color: logoGreen,
                icon: Icons.agriculture_outlined,
                label: 'Sensus Pertanian',
              ),
              _buildTimelineItem(
                year: '...6',
                color: logoOrange,
                icon: Icons.trending_up_outlined,
                label: 'Sensus Ekonomi',
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 750.ms);
  }

  Widget _buildTimelineItem({
    required String year,
    required Color color,
    required IconData icon,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            year,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: textColor,
          ),
          textAlign: TextAlign.center,
        ),
      ],
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