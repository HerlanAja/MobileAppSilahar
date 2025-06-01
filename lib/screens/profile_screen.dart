import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:silahar/components/tentang_bps.dart';
import 'package:silahar/components/download.dart';
import 'package:silahar/components/visi_misi.dart';
import 'package:silahar/components/berakhlak.dart';
import 'package:silahar/components/logo_bps.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final Color primaryColor = const Color(0xFF546E7A);
  final Color backgroundColor = Colors.white;
  String _userName = "User";
  String _userEmail = "user@example.com";
  String _userRole = "Staff";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _userName = prefs.getString('nama_lengkap') ?? "User";
        _userEmail = prefs.getString('email') ?? "user@example.com";
        _userRole = prefs.getString('role') ?? "Staff";
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading user data: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToTentangBPS(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TentangBPS()),
    );
  }

  // Add navigation method for VisiMisi
  void _navigateToVisiMisi(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const VisiMisi()),
    );
  }

  // New method to navigate to DownloadLaporan
  void _navigateToDownloadLaporan(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DownloadLaporan()),
    );
  }

  // Method to navigate to Berakhlak - fixed the missing closing brace
  void _navigateToBerakhlak(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Berakhlak()),
    );
  }

  // Method to navigate to LogoBPS - now properly defined as a separate method
  void _navigateToLogoBPS(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LogoBPS()),
    );
  }

  void _navigateTo(BuildContext context, String title) {
    Navigator.pop(context); // Close drawer
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigasi ke: $title'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    bool? isConfirmed = await _showLogoutDialog(context);
    if (isConfirmed != null && isConfirmed) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Berhasil logout'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  Future<bool?> _showLogoutDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Konfirmasi Logout',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          content: Text(
            'Apakah Anda yakin ingin keluar?',
            style: GoogleFonts.poppins(),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text(
                'Batal',
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Keluar',
                style: GoogleFonts.poppins(),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      drawer: _buildDrawer(),
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          'Menu',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      // You can keep this empty or display TentangBPS by default
      body: const TentangBPS(),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      elevation: 0,
      backgroundColor: backgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, primaryColor.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          child: Icon(
                            Icons.person_outline_rounded, 
                            size: 40, 
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _userName,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              _userEmail,
                              style: GoogleFonts.poppins(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12, 
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Menu Navigasi',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildDrawerItem(
                    icon: Icons.analytics_outlined,
                    text: 'Tentang BPS',
                    onTap: () => _navigateToTentangBPS(context),
                  ),
                  _buildDrawerItem(
                    icon: Icons.flag_outlined,
                    text: 'Visi dan Misi',
                    onTap: () => _navigateToVisiMisi(context),
                  ),
                  _buildDrawerItem(
                    icon: Icons.verified_user_outlined,
                    text: 'Berakhlak',
                    onTap: () => _navigateToBerakhlak(context),
                  ),
                  _buildDrawerItem(
                    icon: Icons.download_outlined,
                    text: 'Download Laporan',
                    onTap: () => _navigateToDownloadLaporan(context),
                  ),
                  _buildDrawerItem(
                    icon: Icons.badge_outlined,
                    text: 'Logo',
                    onTap: () => _navigateToLogoBPS(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1),
            _buildDrawerItem(
              icon: Icons.exit_to_app_rounded,
              text: 'Logout',
              onTap: () => _logout(context),
              isLogout: true,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: Icon(
          icon, 
          color: isLogout ? Colors.red : primaryColor, 
          size: 24,
        ),
        title: Text(
          text, 
          style: GoogleFonts.poppins(
            fontSize: 15,
            color: isLogout ? Colors.red : Colors.black87,
            fontWeight: isLogout ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        tileColor: Colors.transparent,
        hoverColor: primaryColor.withOpacity(0.05),
        dense: true,
      ),
    );
  }
}