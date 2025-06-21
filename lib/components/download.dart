import 'dart:io';
import 'dart:math'; // Added import for math functions
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:silahar/helpers/auth_helper.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:device_info_plus/device_info_plus.dart'; // Moved import to the top

class DownloadLaporan extends StatefulWidget {
  const DownloadLaporan({Key? key}) : super(key: key);

  @override
  State<DownloadLaporan> createState() => _DownloadLaporanState();
}

class _DownloadLaporanState extends State<DownloadLaporan> with SingleTickerProviderStateMixin {
  final Color primaryColor = const Color(0xFF546E7A);
  final Color secondaryColor = const Color(0xFF78909C);
  final Color accentColor = const Color(0xFF90A4AE);
  final Color backgroundColor = const Color(0xFFF5F7F8);
  final Color cardColor = Colors.white;

  DateTime _selectedDate = DateTime.now();
  int? _userId;
  bool _isLoading = false;
  String? _errorMessage;
  List<Map<String, dynamic>> _downloadHistory = [];
  late AnimationController _animationController;
  double _downloadProgress = 0.0;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null).then((_) {
      _loadUserId();
      _loadDownloadHistory();
    });

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('user_id');
      if (_userId == null) {
        _errorMessage = "User ID tidak ditemukan. Silakan login kembali.";
      }
    });
  }

  Future<void> _loadDownloadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList('download_history') ?? [];
      setState(() {
        _downloadHistory = historyJson
            .map((item) => {
                  'date': item.split('|')[0],
                  'path': item.split('|')[1],
                })
            .toList();
      });
    } catch (e) {
      print("Error loading download history: $e");
    }
  }

  Future<void> _saveToDownloadHistory(String date, String filePath) async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList('download_history') ?? [];
    historyJson.add("$date|$filePath");
    if (historyJson.length > 10) historyJson.removeAt(0);
    await prefs.setStringList('download_history', historyJson);
    await _loadDownloadHistory();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: primaryColor),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<bool> _requestStoragePermission() async {
    // For Android 13+ (SDK 33+), we need to request specific permissions
    if (Platform.isAndroid) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      
      if (androidInfo.version.sdkInt >= 33) {
        // For Android 13+, request the new permissions
        final status = await Permission.photos.request();
        if (status.isGranted) {
          return true;
        } else if (status.isPermanentlyDenied) {
          _showPermissionDialog();
          return false;
        }
        return false;
      } else {
        // For older Android versions, request storage permission
        final status = await Permission.storage.request();
        if (status.isGranted) {
          return true;
        } else if (status.isPermanentlyDenied) {
          _showPermissionDialog();
          return false;
        }
        return false;
      }
    }
    
    // For iOS or other platforms
    final status = await Permission.storage.request();
    return status.isGranted;
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(
          'Izin Penyimpanan Diperlukan',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        content: Text(
          'Aplikasi memerlukan izin untuk menyimpan laporan di perangkat Anda. Silakan aktifkan izin penyimpanan di pengaturan aplikasi.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Nanti',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Buka Pengaturan',
              style: GoogleFonts.poppins(),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Future<void> _downloadReport() async {
    if (_userId == null) {
      setState(() => _errorMessage = "User ID tidak ditemukan. Silakan login kembali.");
      return;
    }

    setState(() {
      _isLoading = true;
      _isDownloading = true;
      _downloadProgress = 0.0;
      _errorMessage = null;
    });

    try {
      // Request storage permission
      bool hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        setState(() {
          _isLoading = false;
          _isDownloading = false;
          _errorMessage = "Izin penyimpanan diperlukan untuk mengunduh laporan.";
        });
        return;
      }

      final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final token = await AuthHelper.getToken();
      if (token == null) {
        setState(() {
          _isLoading = false;
          _isDownloading = false;
          _errorMessage = "Token tidak ditemukan. Silakan login kembali.";
        });
        return;
      }

      // Simulate download progress for better UX
      for (int i = 1; i <= 10; i++) {
        await Future.delayed(const Duration(milliseconds: 200));
        setState(() {
          _downloadProgress = i / 10;
        });
      }

      final response = await http.get(
        Uri.parse('https://silahar3272.ftp.sh/api/laporan/$_userId/$formattedDate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final fileName = 'laporan_$formattedDate.pdf';
        final filePath = '${directory.path}/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        await _saveToDownloadHistory(formattedDate, filePath);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Laporan berhasil diunduh',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            action: SnackBarAction(
              label: 'Buka',
              textColor: Colors.white,
              onPressed: () => OpenFile.open(filePath),
            ),
          ),
        );
      } else {
        setState(() {
          _errorMessage = response.statusCode == 404
              ? "Laporan tidak ditemukan untuk tanggal yang dipilih."
              : "Gagal mengunduh laporan. Status: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() => _errorMessage = "Terjadi kesalahan: $e");
    }

    setState(() {
      _isLoading = false;
      _isDownloading = false;
    });
  }

  void _openFile(String filePath) async {
    try {
      final result = await OpenFile.open(filePath);
      if (result.type != ResultType.done) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal membuka file: ${result.message}',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal membuka file: $e',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
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
            'Download Laporan',
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
              animation: _animationController,
              builder: (context, child) {
                return CustomPaint(
                  painter: BackgroundPatternPainter(
                    color: accentColor.withOpacity(0.05),
                    animationValue: _animationController.value,
                  ),
                );
              },
            ),
          ),
          
          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date selection card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pilih Tanggal Laporan',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: primaryColor,
                            ),
                          ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.2, end: 0),
                          
                          const SizedBox(height: 16),
                          
                          InkWell(
                            onTap: () => _selectDate(context),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: accentColor.withOpacity(0.5)),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    color: primaryColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    DateFormat('dd MMMM yyyy', 'id_ID').format(_selectedDate),
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const Spacer(),
                                  Icon(
                                    Icons.arrow_drop_down,
                                    color: primaryColor,
                                  ),
                                ],
                              ),
                            ),
                          ).animate().fadeIn(duration: 500.ms, delay: 200.ms).slideY(begin: 0.2, end: 0),
                          
                          const SizedBox(height: 20),
                          
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : _downloadReport,
                              icon: _isLoading
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                        value: _isDownloading ? _downloadProgress : null,
                                      ),
                                    )
                                  : const Icon(Icons.download_rounded),
                              label: Text(
                                _isLoading ? "Mengunduh..." : "Download Laporan",
                                style: GoogleFonts.poppins(),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                            ),
                          ).animate().fadeIn(duration: 500.ms, delay: 400.ms).slideY(begin: 0.2, end: 0),
                        ],
                      ),
                    ),
                  ),
                  
                  if (_errorMessage != null)
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red.shade700,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: GoogleFonts.poppins(
                                color: Colors.red.shade700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().shake(),
                  
                  const SizedBox(height: 24),
                  
                  // Download history section
                  Text(
                    "Riwayat Unduhan",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ).animate().fadeIn(duration: 500.ms, delay: 600.ms),
                  
                  const Divider(height: 24),
                  
                  Expanded(
                    child: _downloadHistory.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.history,
                                  size: 64,
                                  color: accentColor.withOpacity(0.5),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "Belum ada riwayat unduhan",
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ).animate().fadeIn(duration: 500.ms, delay: 800.ms)
                        : ListView.builder(
                            itemCount: _downloadHistory.length,
                            itemBuilder: (context, index) {
                              final item = _downloadHistory[index];
                              final fileName = item['path'].split('/').last;
                              
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 1,
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  leading: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.description,
                                      color: primaryColor,
                                    ),
                                  ),
                                  title: Text(
                                    "Laporan ${item['date']}",
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  subtitle: Text(
                                    fileName,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(
                                      Icons.open_in_new,
                                      color: primaryColor,
                                    ),
                                    onPressed: () => _openFile(item['path']),
                                  ),
                                  onTap: () => _openFile(item['path']),
                                ),
                              ).animate().fadeIn(
                                    duration: 400.ms,
                                    delay: Duration(milliseconds: 800 + (index * 100)),
                                  );
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

class BackgroundPatternPainter extends CustomPainter {
  final Color color;
  final double animationValue;

  BackgroundPatternPainter({required this.color, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    
    // Create a more modern pattern with dots and lines
    final dotSpacing = 30.0;
    final dotRadius = 2.0;
    
    for (double y = 0; y < size.height; y += dotSpacing) {
      for (double x = 0; x < size.width; x += dotSpacing) {
        // Add subtle movement to the dots
        final dx = x + (sin(animationValue * 2 + y * 0.05) * 5);
        final dy = y + (cos(animationValue * 2 + x * 0.05) * 5);
        
        // Draw dots with varying sizes for a more dynamic look
        final radius = dotRadius * (0.8 + (sin(animationValue * 3 + x * 0.1 + y * 0.1) * 0.2));
        canvas.drawCircle(Offset(dx, dy), radius, paint);
        
        // Occasionally draw connecting lines between dots
        if ((x + y) % 90 < 30 && x > 0 && y > 0) {
          final prevX = dx - dotSpacing;
          final prevY = dy - dotSpacing;
          
          final linePaint = Paint()
            ..color = color
            ..strokeWidth = 0.5;
          
          canvas.drawLine(Offset(prevX, prevY), Offset(dx, dy), linePaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant BackgroundPatternPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue || oldDelegate.color != color;
  }
}