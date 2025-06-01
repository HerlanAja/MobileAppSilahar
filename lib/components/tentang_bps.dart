import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart'; // Add this package to pubspec.yaml

class TentangBPS extends StatefulWidget {
  const TentangBPS({Key? key}) : super(key: key);

  @override
  State<TentangBPS> createState() => _TentangBPSState();
}

class _TentangBPSState extends State<TentangBPS> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final ScrollController _scrollController = ScrollController();
  bool _showFloatingButton = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _scrollController.addListener(() {
      if (_scrollController.offset > 300 && !_showFloatingButton) {
        setState(() {
          _showFloatingButton = true;
        });
      } else if (_scrollController.offset <= 300 && _showFloatingButton) {
        setState(() {
          _showFloatingButton = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Modern gray and white theme
    final Color primaryColor = const Color(0xFF546E7A);
    final Color secondaryColor = const Color(0xFF78909C);
    final Color accentColor = const Color(0xFF90A4AE);
    final Color backgroundColor = const Color(0xFFF5F7F8);
    final Color cardColor = Colors.white;
    final Color textColor = const Color(0xFF37474F);
    
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
            'Tentang BPS',
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
          SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.only(top: 100, bottom: 32, left: 16, right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with logo
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: cardColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        "BPS",
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ),
                ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0),
                
                const SizedBox(height: 24),
                
                // Title
                Center(
                  child: Text(
                    'Badan Pusat Statistik (BPS)',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
                
                const SizedBox(height: 24),
                
                // Introduction card
                _buildCard(
                  child: Text(
                    'Badan Pusat Statistik adalah Lembaga Pemerintah Non Kementerian yang bertanggung jawab langsung kepada Presiden. Sebelumnya, BPS merupakan Biro Pusat Statistik, yang dibentuk berdasarkan UU Nomor 6 Tahun 1960 tentang Sensus dan UU Nomer 7 Tahun 1960 tentang Statistik. Sebagai pengganti kedua UU tersebut ditetapkan UU Nomor 16 Tahun 1997 tentang Statistik. Berdasarkan UU ini yang ditindaklanjuti dengan peraturan perundangan dibawahnya, secara formal nama Biro Pusat Statistik diganti menjadi Badan Pusat Statistik.',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: textColor,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
                
                const SizedBox(height: 24),
                
                // Section title
                _buildSectionTitle(
                  'Materi muatan baru dalam UU Nomor 16 Tahun 1997:',
                  primaryColor,
                  Icons.article_rounded,
                ).animate().fadeIn(delay: 600.ms),
                
                const SizedBox(height: 16),
                
                // Bullet points
                _buildBulletPointCard(
                  'Jenis statistik berdasarkan tujuan pemanfaatannya terdiri atas statistik dasar yang sepenuhnya diselenggarakan oleh BPS, statistik sektoral yang dilaksanakan oleh instansi Pemerintah secara mandiri atau bersama dengan BPS, serta statistik khusus yang diselenggarakan oleh lembaga, organisasi, perorangan, dan atau unsur masyarakat lainnya secara mandiri atau bersama dengan BPS.',
                  primaryColor,
                  secondaryColor,
                  cardColor,
                  textColor,
                  1,
                ).animate().fadeIn(delay: 700.ms).slideX(begin: 0.2, end: 0),
                
                _buildBulletPointCard(
                  'Hasil statistik yang diselenggarakan oleh BPS diumumkan dalam Berita Resmi Statistik (BRS) secara teratur dan transparan agar masyarakat dengan mudah mengetahui dan atau mendapatkan data yang diperlukan.',
                  primaryColor,
                  secondaryColor,
                  cardColor,
                  textColor,
                  2,
                ).animate().fadeIn(delay: 800.ms).slideX(begin: 0.2, end: 0),
                
                _buildBulletPointCard(
                  'Sistem Statistik Nasional yang andal, efektif, dan efisien.',
                  primaryColor,
                  secondaryColor,
                  cardColor,
                  textColor,
                  3,
                ).animate().fadeIn(delay: 900.ms).slideX(begin: 0.2, end: 0),
                
                _buildBulletPointCard(
                  'Dibentuknya Forum Masyarakat Statistik sebagai wadah untuk menampung aspirasi masyarakat statistik, yang bertugas memberikan saran dan pertimbangan kepada BPS.',
                  primaryColor,
                  secondaryColor,
                  cardColor,
                  textColor,
                  4,
                ).animate().fadeIn(delay: 1000.ms).slideX(begin: 0.2, end: 0),
                
                const SizedBox(height: 24),
                
                // Section title
                _buildSectionTitle(
                  'Peranan BPS:',
                  primaryColor,
                  Icons.bar_chart_rounded,
                ).animate().fadeIn(delay: 1100.ms),
                
                const SizedBox(height: 16),
                
                // Bullet points
                _buildBulletPointCard(
                  'Menyediakan kebutuhan data bagi pemerintah dan masyarakat. Data ini didapatkan dari sensus atau survey yang dilakukan sendiri dan juga dari departemen atau lembaga pemerintahan lainnya sebagai data sekunder',
                  primaryColor,
                  secondaryColor,
                  cardColor,
                  textColor,
                  1,
                ).animate().fadeIn(delay: 1200.ms).slideX(begin: 0.2, end: 0),
                
                _buildBulletPointCard(
                  'Membantu kegiatan statistik di kementrian, lembaga pemerintah atau institusi lainnya, dalam membangun sistem perstatistikan nasional.',
                  primaryColor,
                  secondaryColor,
                  cardColor,
                  textColor,
                  2,
                ).animate().fadeIn(delay: 1300.ms).slideX(begin: 0.2, end: 0),
                
                _buildBulletPointCard(
                  'Mengembangkan dan mempromosikan standar teknik dan metodologi statistik, dan menyediakan pelayanan pada bidang pendidikan dan pelatihan statistik.',
                  primaryColor,
                  secondaryColor,
                  cardColor,
                  textColor,
                  3,
                ).animate().fadeIn(delay: 1400.ms).slideX(begin: 0.2, end: 0),
                
                _buildBulletPointCard(
                  'Membangun kerjasama dengan institusi internasional dan negara lain untuk kepentingan perkembangan statistik Indonesia.',
                  primaryColor,
                  secondaryColor,
                  cardColor,
                  textColor,
                  4,
                ).animate().fadeIn(delay: 1500.ms).slideX(begin: 0.2, end: 0),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _showFloatingButton
          ? FloatingActionButton(
              backgroundColor: primaryColor,
              mini: true,
              onPressed: () {
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              },
              child: const Icon(Icons.arrow_upward_rounded),
            ).animate().fadeIn()
          : null,
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSectionTitle(String title, Color color, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBulletPointCard(
    String text,
    Color primaryColor,
    Color secondaryColor,
    Color cardColor,
    Color textColor,
    int number,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    number.toString(),
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: textColor,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
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