import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class AddLaporanScreen extends StatefulWidget {
  const AddLaporanScreen({Key? key}) : super(key: key);

  @override
  _AddLaporanScreenState createState() => _AddLaporanScreenState();
}

class _AddLaporanScreenState extends State<AddLaporanScreen> {
  final TextEditingController _jamMulaiController = TextEditingController();
  final TextEditingController _jamSelesaiController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  File? _selectedImage;
  bool _isSubmitting = false;

  final Color primaryColor = const Color(0xFF546E7A);
  final Color accentColor = const Color(0xFF00ACC1);

  Future<String?> _getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('token');
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }

  /// Membersihkan token dari SharedPreferences dan mengarahkan pengguna ke halaman login.
  Future<void> _clearTokenAndRedirectToLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token'); // Hapus token dari SharedPreferences
    // Pastikan '/login' adalah route yang benar untuk halaman login Anda di main.dart
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  Future<void> _selectTime(TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        final String formattedHour = picked.hour.toString().padLeft(2, '0');
        final String formattedMinute = picked.minute.toString().padLeft(2, '0');
        controller.text = '$formattedHour:$formattedMinute';
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      final File imageFile = File(pickedFile.path);

      final Directory tempDir = await getTemporaryDirectory();
      final String tempPath = tempDir.path;
      final String targetPath = '$tempPath/${DateTime.now().millisecondsSinceEpoch}.jpeg';

      try {
        final XFile? compressedImage = await FlutterImageCompress.compressAndGetFile(
          imageFile.path,
          targetPath,
          quality: 70, // Sesuaikan kualitas (0-100). 70 adalah nilai yang baik.
          format: CompressFormat.jpeg,
        );

        if (compressedImage != null) {
          setState(() {
            _selectedImage = File(compressedImage.path);
          });
        } else {
          await _showErrorSnackBar("Gagal mengompres gambar: File kosong atau tidak valid.");
        }
      } catch (e) {
        await _showErrorSnackBar("Terjadi kesalahan saat mengompres gambar: ${e.toString()}");
        print("Error during image compression: $e");
      }
    }
  }

  Future<void> _submitLaporan() async {
    if (_jamMulaiController.text.isEmpty ||
        _jamSelesaiController.text.isEmpty ||
        _deskripsiController.text.isEmpty ||
        _selectedImage == null) {
      await _showErrorSnackBar("Harap isi semua bidang dan pilih foto!");
      return;
    }

    final token = await _getToken();
    if (token == null) {
      // Jika token tidak ada sama sekali saat mencoba submit
      await _showErrorSnackBar("Sesi telah habis, silakan login kembali");
      await _clearTokenAndRedirectToLogin(); // Panggil fungsi untuk membersihkan token dan redirect
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final uri = Uri.parse('https://silahar3272.ftp.sh/api/laporan/tambah');
      var request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';

      var imageFile = await http.MultipartFile.fromPath(
        'foto_kegiatan',
        _selectedImage!.path,
        contentType: MediaType('image', 'jpeg'),
      );
      request.files.add(imageFile);
      request.fields['jam_mulai'] = _jamMulaiController.text;
      request.fields['jam_selesai'] = _jamSelesaiController.text;
      request.fields['deskripsi'] = _deskripsiController.text;

      var response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.headers['content-type']?.contains('application/json') == true) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          final jsonResponse = json.decode(responseBody);
          await _showSuccessSnackBar(jsonResponse['message'] ?? "Laporan berhasil ditambahkan!");
          Navigator.pop(context); // Kembali ke halaman sebelumnya setelah berhasil
        } else if (response.statusCode == 401) {
          // Token tidak valid atau kadaluarsa
          await _showErrorSnackBar("Sesi telah habis atau token tidak valid, silakan login kembali");
          await _clearTokenAndRedirectToLogin(); // Panggil fungsi untuk membersihkan token dan redirect
        } else {
          try {
            final jsonError = json.decode(responseBody);
            await _showErrorSnackBar(jsonError['message'] ?? "Gagal menambahkan laporan");
          } catch (e) {
            await _showErrorSnackBar("Gagal menambahkan laporan: Format respons tidak valid.");
            print('Error decoding JSON: $e, Response Body: $responseBody');
          }
        }
      } else {
        // Tangani respons non-JSON
        if (response.statusCode == 413) {
            await _showErrorSnackBar("Gagal mengunggah foto: Ukuran file terlalu besar. (Error 413).");
        } else if (response.statusCode == 401) {
            // Ini penting jika server mengembalikan non-JSON tapi status 401
            await _showErrorSnackBar("Sesi telah habis atau token tidak valid, silakan login kembali");
            await _clearTokenAndRedirectToLogin(); // Panggil fungsi untuk membersihkan token dan redirect
        } else {
            await _showErrorSnackBar("Terjadi kesalahan server: Respon tidak valid. Status: ${response.statusCode}");
        }
        print('Server responded with non-JSON content. Status: ${response.statusCode}, Body: $responseBody');
      }
    } catch (e) {
      await _showErrorSnackBar("Terjadi kesalahan koneksi: ${e.toString()}");
      print('Network error: $e');
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  /// Menampilkan dialog error dengan pesan kustom.
  Future<void> _showErrorSnackBar(String message) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  color: Colors.red.shade600,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Error",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.red.shade700,
                ),
              ),
            ],
          ),
          content: Container(
            width: double.maxFinite,
            child: Text(
              message,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "OK",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
          actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        );
      },
    );
  }

  /// Menampilkan dialog sukses dengan pesan kustom.
  Future<void> _showSuccessSnackBar(String message) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_outline,
                  color: Colors.green.shade600,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Berhasil",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade700,
                ),
              ),
            ],
          ),
          content: Container(
            width: double.maxFinite,
            child: Text(
              message,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "OK",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
          actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          "Tambah Laporan",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader("Waktu Kegiatan"),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildModernTimeField(
                      "Jam Mulai",
                      _jamMulaiController,
                      Icons.access_time_rounded,
                      () => _selectTime(_jamMulaiController),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildModernTimeField(
                      "Jam Selesai",
                      _jamSelesaiController,
                      Icons.access_time_rounded,
                      () => _selectTime(_jamSelesaiController),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSectionHeader("Deskripsi Kegiatan"),
              const SizedBox(height: 16),
              _buildModernDescriptionField(),
              const SizedBox(height: 24),
              _buildSectionHeader("Foto Kegiatan"),
              const SizedBox(height: 16),
              _buildModernImageSection(),
              const SizedBox(height: 32),
              _buildModernSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade800,
      ),
    );
  }

  Widget _buildModernTimeField(
    String label,
    TextEditingController controller,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(icon, size: 20, color: accentColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    controller.text.isEmpty ? "Pilih Waktu" : controller.text,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: controller.text.isEmpty ? Colors.grey.shade400 : Colors.grey.shade800,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernDescriptionField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _deskripsiController,
        maxLines: 5,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Colors.grey.shade800,
        ),
        decoration: InputDecoration(
          hintText: "Masukkan deskripsi kegiatan...",
          hintStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.grey.shade400,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildModernImageSection() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _selectedImage == null ? Colors.grey.shade300 : Colors.transparent,
            width: 1.5,
          ),
          image: _selectedImage != null
              ? DecorationImage(
                  image: FileImage(_selectedImage!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: _selectedImage == null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.camera_alt_rounded,
                        size: 28,
                        color: accentColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Ambil Foto Kegiatan",
                      style: GoogleFonts.poppins(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Ketuk untuk membuka kamera",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildModernSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitLaporan,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                "Kirim Laporan",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
      ),
    );
  }
}
