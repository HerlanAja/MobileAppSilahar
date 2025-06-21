import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart'; // <<< PERBAIKAN: Hapus .h di sini
import 'package:silahar/components/download.dart';
import 'package:silahar/components/visi_misi.dart';
import 'package:silahar/components/berakhlak.dart';
import 'package:silahar/components/logo_bps.dart';
import 'package:silahar/components/team_developer.dart'; // Import the new TeamDeveloper component
import 'login_screen.dart';
import 'home_screen.dart'; 

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // --- PALET WARNA DISELARASKAN DENGAN LOGINSCREEN ---
  final Color _primaryThemeColor = const Color(0xFF546E7A); // Main blue-gray
  final Color _darkestThemeColor = const Color(0xFF263238); // Very dark blue-gray (background gradient end)
  final Color _darkThemeColor = const Color(0xFF455A64); // Darker blue-gray (background gradient start, some text)
  final Color _mediumAccentColor = const Color(0xFF78909C); // Medium blue-gray (secondary accents, hint text in login)
  final Color _lightHintColor = const Color(0xFFB0BEC5); // Lightest hint color
  final Color _backgroundGeneralColor = const Color(0xFFF5F7F9); // Light background for body
  final Color _whiteColor = Colors.white; // Umumnya untuk latar belakang card/putih
  // --- AKHIR PALET WARNA ---

  String _userName = "User";
  String _userNip = "NIP tidak tersedia"; // Variabel baru untuk NIP
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
      final prefs = await SharedPreferences.getInstance(); // <<< SharedPreferences akan dikenali setelah import diperbaiki
      setState(() {
        _userName = prefs.getString('nama_lengkap') ?? "User";
        _userNip = prefs.getString('nip') ?? "NIP tidak tersedia"; // Muat NIP
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

  void _navigateToVisiMisi(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const VisiMisi()),
    );
  }

  void _navigateToDownloadLaporan(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DownloadLaporan()),
    );
  }

  void _navigateToBerakhlak(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Berakhlak()),
    );
  }

  void _navigateToLogoBPS(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LogoBPS()),
    );
  }

  void _navigateToTeamDeveloper(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TeamDeveloper()),
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
      SharedPreferences prefs = await SharedPreferences.getInstance(); // <<< SharedPreferences akan dikenali
      await prefs.remove('token');
      await prefs.remove('user_id'); 
      await prefs.remove('nama_lengkap');
      await prefs.remove('nip'); 
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Berhasil logout'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: _primaryThemeColor,
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
              color: _darkThemeColor,
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
                backgroundColor: _primaryThemeColor,
                foregroundColor: _whiteColor,
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
      backgroundColor: _backgroundGeneralColor,
      drawer: _buildDrawer(),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100.0),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'Menu',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: _whiteColor,
            ),
          ),
          iconTheme: IconThemeData(color: _whiteColor),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_darkThemeColor, _primaryThemeColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: _darkThemeColor.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
          ),
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: Icon(Icons.menu, color: _whiteColor, size: 30),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              );
            },
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.settings_outlined, color: _whiteColor, size: 26),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Tombol Pengaturan diklik!'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: _primaryThemeColor))
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: _mediumAccentColor.withOpacity(0.1),
                      child: Icon(
                        Icons.person_outline_rounded,
                        size: 70,
                        color: _mediumAccentColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Halo, ${_userName}!',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _darkThemeColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Selamat datang di aplikasi pelaporan kegiatan SILAHAR.',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        Scaffold.of(context).openDrawer(); // Membuka drawer
                      },
                      icon: Icon(Icons.menu_book_outlined, color: _whiteColor),
                      label: Text(
                        'Jelajahi Menu',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _whiteColor,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryThemeColor,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      elevation: 0,
      backgroundColor: _backgroundGeneralColor,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_darkThemeColor, _primaryThemeColor],
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
                            color: _whiteColor,
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: _whiteColor.withOpacity(0.3),
                          child: const Icon(
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
                                color: _whiteColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              _userNip, 
                              style: GoogleFonts.poppins(
                                color: _whiteColor.withOpacity(0.9),
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
                      color: _whiteColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Menu Navigasi',
                      style: GoogleFonts.poppins(
                        color: _whiteColor,
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
                    icon: Icons.badge_outlined,
                    text: 'Logo',
                    onTap: () => _navigateToLogoBPS(context),
                  ),
                  _buildDrawerItem(
                    icon: Icons.flag_outlined,
                    text: 'Visi dan Misi',
                    onTap: () => _navigateToVisiMisi(context),
                  ),
                  _buildDrawerItem(
                    icon: Icons.verified_user_outlined,
                    text: 'Core Values ASN', 
                    onTap: () => _navigateToBerakhlak(context),
                  ),
                  _buildDrawerItem(
                    icon: Icons.download_outlined,
                    text: 'Download Laporan',
                    onTap: () => _navigateToDownloadLaporan(context),
                  ),
                  _buildDrawerItem(
                    icon: Icons.people_outline, 
                    text: 'Team Developer',
                    onTap: () => _navigateToTeamDeveloper(context),
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
          color: isLogout ? Colors.red : _primaryThemeColor,
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
        tileColor: const Color.fromARGB(0, 0, 0, 0),
        hoverColor: _primaryThemeColor.withOpacity(0.05),
        dense: true,
      ),
    );
  }
}