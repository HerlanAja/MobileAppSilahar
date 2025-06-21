// lib/components/team_developer.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TeamDeveloper extends StatefulWidget {
  const TeamDeveloper({Key? key}) : super(key: key);

  @override
  State<TeamDeveloper> createState() => _TeamDeveloperState();
}

class _TeamDeveloperState extends State<TeamDeveloper> {
  // Define a new light gray and white color palette
  final Color _primaryTextColor = Colors.grey.shade800;
  final Color _secondaryTextColor = Colors.grey.shade600;
  final Color _cardBackgroundColor = Colors.white;
  final Color _pageBackgroundColorLight = Colors.grey.shade50;
  final Color _pageBackgroundColorDark = Colors.grey.shade100;
  final Color _connectorColor = Colors.grey.shade300;
  final Color _avatarBaseColor = Colors.blueGrey.shade200; // Base for subtle avatar colors
  final Color _shadowColor = Colors.grey.withOpacity(0.1);

  Widget _buildAnimatedTeamMemberCard({
    required String name,
    required String role,
    required Color avatarColor,
    required int delay,
  }) {
    return Animate(
      delay: Duration(milliseconds: delay * 200),
      effects: [
        FadeEffect(duration: 800.ms, curve: Curves.easeOutQuart),
        SlideEffect(begin: const Offset(0, 0.3), end: Offset.zero, duration: 1000.ms, curve: Curves.elasticOut),
        ScaleEffect(begin: const Offset(0.8, 0.8), duration: 800.ms, curve: Curves.bounceOut),
        ShimmerEffect(duration: 1500.ms, color: Colors.grey.shade200),
      ],
      child: Card(
        elevation: 8, // Adjusted elevation for softer shadow
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // Slightly less rounded for a cleaner look
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _cardBackgroundColor,
                _pageBackgroundColorLight,
                _pageBackgroundColorDark,
              ],
            ),
            border: Border.all(
              color: Colors.grey.shade200,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _shadowColor,
                blurRadius: 15, // Softer blur
                offset: const Offset(0, 6), // Softer offset
                spreadRadius: 1,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              splashColor: Colors.grey.shade100,
              highlightColor: Colors.grey.shade50,
              onTap: () {
                HapticFeedback.lightImpact();
              },
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Hero(
                      tag: 'avatar_$name',
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2), // Softer avatar shadow
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: avatarColor,
                          child: Text(
                            name[0].toUpperCase(),
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 32,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      name,
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: _primaryTextColor,
                        letterSpacing: -0.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (role.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _pageBackgroundColorLight,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          role,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _secondaryTextColor,
                            letterSpacing: 0.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedConnector({bool isVertical = true, double length = 30, int delay = 0}) {
    return Animate(
      delay: Duration(milliseconds: 500 + delay),
      effects: [
        FadeEffect(duration: 1000.ms),
        ScaleEffect(
          begin: isVertical ? const Offset(1, 0) : const Offset(0, 1),
          duration: 1200.ms,
          curve: Curves.easeInOut,
        ),
        ShimmerEffect(duration: 2000.ms, color: Colors.grey.shade100),
      ],
      child: Container(
        width: isVertical ? 4 : length,
        height: isVertical ? length : 4,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _connectorColor.withOpacity(0.8),
              _connectorColor,
              _connectorColor.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(2),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        margin: const EdgeInsets.symmetric(vertical: 5), // Adjusted vertical margin
      ),
    );
  }

  Widget _buildBranchingConnector() {
    return Animate(
      delay: 600.ms, // Delay for the entire branching connector to appear
      effects: [
        FadeEffect(duration: 800.ms),
      ],
      child: Column(
        children: [
          Container(
            width: 4,
            height: 30, // Vertical line coming down to the branch
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_connectorColor.withOpacity(0.8), _connectorColor],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ).animate().scaleY(begin: 0, duration: 800.ms, curve: Curves.easeOutCubic),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, _connectorColor],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  margin: const EdgeInsets.only(right: 2), // Small gap to central vertical line
                ).animate().scaleX(begin: 0, duration: 800.ms, delay: 200.ms, curve: Curves.easeOutCubic),
              ),
              Container(
                width: 4,
                height: 20, // Central vertical line of the T-junction
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [_connectorColor, _connectorColor.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ).animate().scaleY(begin: 0, duration: 600.ms, delay: 400.ms, curve: Curves.easeOutCubic),
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_connectorColor, Colors.transparent],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  margin: const EdgeInsets.only(left: 2), // Small gap to central vertical line
                ).animate().scaleX(begin: 0, duration: 800.ms, delay: 200.ms, curve: Curves.easeOutCubic),
              ),
            ],
          ).animate().fadeIn(duration: 500.ms, delay: 500.ms), // Animate horizontal lines after vertical
        ],
      ),
    );
  }


  Widget _buildSectionHeader({
    required String title,
    required List<Color> gradientColors,
    required int delay,
  }) {
    return Animate(
      delay: Duration(milliseconds: delay * 200),
      effects: [
        FadeEffect(duration: 600.ms),
        SlideEffect(begin: const Offset(0, -0.3), duration: 800.ms, curve: Curves.bounceOut),
        ShimmerEffect(duration: 2000.ms, color: Colors.white.withOpacity(0.3)),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradientColors),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.3,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Define the primary color (darker grey for text/main elements)
    final Color primaryColor = Colors.grey.shade800;

    return Scaffold(
      backgroundColor: _pageBackgroundColorLight, // Set base background
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _pageBackgroundColorLight,
              _pageBackgroundColorDark,
              Colors.grey.shade200, // Slightly darker at the bottom for depth
            ],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 140,
              floating: false,
              pinned: true,
              elevation: 4, // Added slight elevation for app bar
              backgroundColor: _cardBackgroundColor.withOpacity(0.95), // White with slight opacity
              surfaceTintColor: Colors.transparent, // To remove default tint on scroll
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true, // Center app bar title
                title: Text(
                  'Team Developer',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w800,
                    color: primaryColor,
                    fontSize: 18,
                  ),
                ).animate().fadeIn(duration: 800.ms, delay: 200.ms).slideX(begin: -0.2, duration: 600.ms),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _cardBackgroundColor,
                        _pageBackgroundColorLight,
                        _pageBackgroundColorDark,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Header Section
                    Column(
                      children: [
                        Text(
                          'Struktur Tim Pengembang',
                          style: GoogleFonts.inter(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: primaryColor,
                            letterSpacing: -0.5,
                          ),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn(duration: 800.ms).slideY(begin: -0.3, duration: 1000.ms, curve: Curves.elasticOut).shimmer(duration: 2000.ms, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.grey.shade700,
                                Colors.grey.shade800,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            'Aplikasi SILAHAR',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ).animate().fadeIn(duration: 600.ms, delay: 400.ms).scale(begin: const Offset(0.8, 0.8), duration: 800.ms, curve: Curves.bounceOut).shimmer(duration: 2500.ms, color: Colors.white.withOpacity(0.3)),
                      ],
                    ).animate().fadeIn(duration: 1000.ms).slideY(begin: 0.3, duration: 1200.ms, curve: Curves.easeOutQuart).scale(begin: const Offset(0.9, 0.9), duration: 1000.ms),

                    const SizedBox(height: 40),
                    Text(
                      'Berikut adalah individu-individu di balik pengembangan aplikasi ini:',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: _secondaryTextColor,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(duration: 800.ms, delay: 500.ms).slideY(begin: 0.2, duration: 800.ms),
                    const SizedBox(height: 40),

                    // Team Structure
                    _buildAnimatedTeamMemberCard(
                      name: 'Delia Akmalia',
                      role: 'Ketua',
                      avatarColor: Colors.teal.shade300, // Adjusted color to be softer
                      delay: 0,
                    ),
                    _buildAnimatedConnector(delay: 0),

                    _buildAnimatedTeamMemberCard(
                      name: 'Vivi Safira',
                      role: 'Perancangan Sistem',
                      avatarColor: Colors.blue.shade300, // Adjusted color to be softer
                      delay: 1,
                    ),
                    _buildBranchingConnector(), // The branching connector now includes its own vertical line

                    // Vertical lines down to Frontend/Backend and UI/UX groups
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Vertical line to Frontend/Backend
                        Container(
                          width: 4,
                          height: 20,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [_connectorColor, _connectorColor.withOpacity(0.8)],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ).animate().scaleY(begin: 0, duration: 800.ms, delay: 800.ms, curve: Curves.easeOutCubic),
                        // Vertical line to UI/UX
                        Container(
                          width: 4,
                          height: 20,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [_connectorColor, _connectorColor.withOpacity(0.8)],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ).animate().scaleY(begin: 0, duration: 800.ms, delay: 1000.ms, curve: Curves.easeOutCubic),
                      ],
                    ),
                    const SizedBox(height: 10),

                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                _buildSectionHeader(
                                  title: 'Frontend & Backend',
                                  gradientColors: [
                                    Colors.grey.shade600,
                                    Colors.grey.shade700,
                                  ],
                                  delay: 2,
                                ),
                                const SizedBox(height: 24),
                                _buildAnimatedTeamMemberCard(
                                  name: 'Ujang Herlan',
                                  role: '',
                                  avatarColor: Colors.orange.shade200, // Softer orange
                                  delay: 3,
                                ),
                                _buildAnimatedTeamMemberCard(
                                  name: 'Syarifudin Fajar S',
                                  role: '',
                                  avatarColor: Colors.purple.shade200, // Softer purple
                                  delay: 4,
                                ),
                              ],
                            ),
                          ),
                          // Visual separator line between Frontend/Backend and UI/UX
                          Container(
                            width: 4,
                            color: Colors.grey.shade300,
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                          ).animate().scaleY(begin: 0, duration: 1500.ms, delay: 1200.ms, curve: Curves.easeInOut),
                          Expanded(
                            child: Column(
                              children: [
                                _buildSectionHeader(
                                  title: 'UI / UX',
                                  gradientColors: [
                                    Colors.grey.shade600,
                                    Colors.grey.shade700,
                                  ],
                                  delay: 5,
                                ),
                                const SizedBox(height: 24),
                                _buildAnimatedTeamMemberCard(
                                  name: 'Taufik Faturahman',
                                  role: '',
                                  avatarColor: Colors.red.shade200, // Softer red
                                  delay: 6,
                                ),
                                _buildAnimatedTeamMemberCard(
                                  name: 'Asril Hidayat',
                                  role: '',
                                  avatarColor: Colors.amber.shade200, // Softer amber
                                  delay: 7,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}