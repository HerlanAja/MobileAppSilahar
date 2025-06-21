import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:silahar/helpers/auth_helper.dart'; // Assuming you have this helper

class DetailTugasScreen extends StatefulWidget {
  final dynamic task;

  const DetailTugasScreen({Key? key, required this.task}) : super(key: key);

  @override
  State<DetailTugasScreen> createState() => _DetailTugasScreenState();
}

class _DetailTugasScreenState extends State<DetailTugasScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isUpdatingStatus = false;
  String _currentStatus = '';
  
  // Blue-Gray Theme Colors
  final Color primaryColor = const Color(0xFF546E7A); // The requested blue-gray
  final Color accentColor = const Color(0xFF78909C); // Lighter blue-gray
  final Color darkColor = const Color(0xFF37474F); // Darker blue-gray
  final Color backgroundColor = const Color(0xFFF5F7F9); // Very light blue-gray
  final Color cardColor = Colors.white;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    
    // Initialize current status
    _currentStatus = widget.task['status'] ?? 'belum_dikerjakan';
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Method to update task status - Using the exact format from Postman
  Future<void> _updateTaskStatus(String newStatus) async {
    if (_isUpdatingStatus) return;
    
    setState(() {
      _isUpdatingStatus = true;
    });
    
    try {
      final userId = await AuthHelper.getUserId();
      final token = await AuthHelper.getToken(); // Get the authentication token
      
      if (userId == null) {
        _showErrorSnackBar('User ID tidak ditemukan');
        return;
      }
      
      if (token == null) {
        _showErrorSnackBar('Token tidak ditemukan. Silakan login kembali.');
        return;
      }
      
      // Using the specified API endpoint with the exact format from Postman
      final url = Uri.parse('https://silahar3272.ftp.sh/api/tugas/user/tugas/${widget.task['id']}/status');
      
      // Request body - exactly as shown in Postman
      final body = {
        'status': newStatus,
      };
      
      debugPrint('Updating status with URL: $url');
      debugPrint('Request body: ${jsonEncode(body)}');
      
      // Make PUT request to update status with the token in the Authorization header
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token' // Add the token here
        },
        body: jsonEncode(body),
      );
      
      debugPrint('Response status code: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Success
        setState(() {
          _currentStatus = newStatus;
        });
        _showSuccessSnackBar('Status berhasil diperbarui');
      } else {
        // Error
        final errorData = jsonDecode(response.body);
        _showErrorSnackBar('Gagal memperbarui status: ${errorData['error'] ?? response.statusCode}');
        debugPrint('Error response: ${response.body}');
        
        // If token is invalid, you might want to redirect to login
        if (response.statusCode == 401) {
          // Handle token expiration - maybe navigate to login screen
          // Navigator.of(context).pushReplacementNamed('/login');
        }
      }
    } catch (e) {
      _showErrorSnackBar('Terjadi kesalahan: $e');
      debugPrint('Error updating status: $e');
    } finally {
      setState(() {
        _isUpdatingStatus = false;
      });
    }
  }
  
  void _showStatusUpdateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Perbarui Status',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: darkColor,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusOption('belum_dikerjakan', 'Belum Dikerjakan'),
            const SizedBox(height: 8),
            _buildStatusOption('sedang_dikerjakan', 'Sedang Dikerjakan'),
            const SizedBox(height: 8),
            _buildStatusOption('selesai', 'Selesai'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
  
  Widget _buildStatusOption(String status, String label) {
    final bool isSelected = _currentStatus == status;
    
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        _updateTaskStatus(status);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? primaryColor : Colors.grey[600],
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? primaryColor : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: Colors.green[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(10),
      ),
    );
  }
  
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // For responsive design
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: backgroundColor,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.white),
                onPressed: () {
                  // Edit functionality
                },
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // Header with gradient - FIXED HEIGHT INCREASED
            Container(
              height: 220, // Increased from 200 to accommodate longer titles
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [darkColor, primaryColor],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: darkColor.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(20, 100, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: FadeTransition(
                      opacity: _animationController,
                      child: Text(
                        widget.task['judul'] ?? 'No Title',
                        style: GoogleFonts.poppins(
                          fontSize: isTablet ? 26 : 20, // Slightly reduced font size
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2, // Tighter line height
                        ),
                        maxLines: 3, // Allow up to 3 lines for long titles
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: Colors.white.withOpacity(0.9)),
                      const SizedBox(width: 8),
                      Text(
                        _formatDeadline(widget.task['tanggal_deadline']),
                        style: GoogleFonts.poppins(
                          fontSize: isTablet ? 16 : 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Status indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Transform.translate(
                offset: const Offset(0, -20),
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.5),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _animationController,
                    curve: Curves.easeOutQuad,
                  )),
                  child: Card(
                    elevation: 4,
                    shadowColor: Colors.black26,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Status:',
                            style: GoogleFonts.poppins(
                              fontSize: isTablet ? 16 : 14,
                              fontWeight: FontWeight.w500,
                              color: darkColor,
                            ),
                          ),
                          _buildStatusChip(_currentStatus),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // Content
            Expanded(
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.2),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _animationController,
                  curve: Curves.easeOutQuad,
                )),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailSection(
                        title: 'Deskripsi Tugas',
                        content: widget.task['deskripsi'] ?? 'Tidak ada deskripsi',
                        icon: Icons.description_outlined,
                        isTablet: isTablet,
                      ),
                      const SizedBox(height: 16),
                      
                      if (widget.task['catatan'] != null && widget.task['catatan'].isNotEmpty)
                        Column(
                          children: [
                            _buildDetailSection(
                              title: 'Catatan',
                              content: widget.task['catatan'],
                              icon: Icons.note_outlined,
                              isTablet: isTablet,
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                        
                      // Additional information section
                      _buildInfoCard(isTablet),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _isUpdatingStatus ? null : _showStatusUpdateDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: _isUpdatingStatus
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Memperbarui...',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : Text(
                    'Perbarui Status',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection({
    required String title, 
    required String content, 
    required IconData icon,
    required bool isTablet,
  }) {
    return Card(
      elevation: 1,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 20, color: primaryColor),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: isTablet ? 18 : 16,
                    fontWeight: FontWeight.bold,
                    color: darkColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              content,
              style: GoogleFonts.poppins(
                fontSize: isTablet ? 16 : 14,
                color: Colors.black87,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(bool isTablet) {
    return Card(
      elevation: 1,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informasi Tambahan',
              style: GoogleFonts.poppins(
                fontSize: isTablet ? 18 : 16,
                fontWeight: FontWeight.bold,
                color: darkColor,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              icon: Icons.person_outline,
              label: 'Dibuat oleh',
              value: widget.task['created_by'] ?? 'Admin',
              isTablet: isTablet,
            ),
            const Divider(height: 24),
            _buildInfoRow(
              icon: Icons.access_time_outlined,
              label: 'Dibuat pada',
              value: _formatDate(widget.task['created_at'] ?? DateTime.now().toString()),
              isTablet: isTablet,
            ),
            if (widget.task['priority'] != null) ...[
              const Divider(height: 24),
              _buildInfoRow(
                icon: Icons.flag_outlined,
                label: 'Prioritas',
                value: _getPriorityText(widget.task['priority']),
                isTablet: isTablet,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isTablet,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: accentColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: isTablet ? 14 : 12,
                  color: accentColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: isTablet ? 16 : 14,
                  fontWeight: FontWeight.w500,
                  color: darkColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    // Using variations of the blue-gray color for status
    Color chipColor;
    IconData statusIcon;
    String statusText;

    switch (status) {
      case 'sedang_dikerjakan':
        chipColor = const Color(0xFF546E7A); // The primary blue-gray
        statusIcon = Icons.timelapse;
        statusText = 'Sedang Dikerjakan';
        break;
      case 'selesai':
        chipColor = const Color(0xFF455A64); // Darker blue-gray
        statusIcon = Icons.check_circle;
        statusText = 'Selesai';
        break;
      default:
        chipColor = const Color(0xFF78909C); // Lighter blue-gray
        statusIcon = Icons.pending_outlined;
        statusText = 'Belum Dikerjakan';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: chipColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 16, color: chipColor),
          const SizedBox(width: 6),
          Text(
            statusText,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: chipColor,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDeadline(String? deadline) {
    if (deadline == null || deadline.isEmpty) return 'Tidak ada deadline';
    
    try {
      final dateTime = DateTime.parse(deadline);
      // Format: 2025-08-01
      return DateFormat('yyyy - MM - dd').format(dateTime);
    } catch (e) {
      return deadline;
    }
  }
  
  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return '-';
    
    try {
      final dateTime = DateTime.parse(date);
      // Format: 2025-08-01 10:00
      return DateFormat('yyyy - MM - dd').format(dateTime) + ' ' + DateFormat('HH:mm').format(dateTime);
    } catch (e) {
      return date;
    }
  }
  
  String _getPriorityText(String priority) {
    switch (priority) {
      case 'high':
        return 'Tinggi';
      case 'medium':
        return 'Sedang';
      case 'low':
        return 'Rendah';
      default:
        return priority;
    }
  }
}
