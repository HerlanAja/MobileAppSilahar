import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:silahar/components/card_news.dart';
import 'package:silahar/components/task_card.dart';
import 'package:silahar/components/detail_news.dart';
import 'package:silahar/components/detail_tugas.dart';
import 'package:silahar/components/riwayat.dart'; 
import 'package:silahar/screens/laporan.dart';
import 'package:silahar/screens/profile_screen.dart';
import 'package:silahar/helpers/auth_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  List<dynamic> _newsList = [];
  List<dynamic> _tasksList = [];
  List<dynamic> _activeTasks = [];
  bool _isLoadingTasks = true;
  bool _isLoadingNews = true;
  String _userName = "User";
  bool _isLoadingUserName = true;
  final Color primaryColor = const Color(0xFF546E7A);
  final Color backgroundColor = Colors.white;
  bool _hasShownNotification = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      fetchNews(),
      fetchUserTasks(),
      fetchUserName(),
    ]);
  }

  void _checkApproachingDeadlines() {
    if (_hasShownNotification) return;

    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    bool hasApproachingDeadline = false;

    for (final task in _tasksList) {
      final deadlineStr = task['tanggal_deadline'];
      if (deadlineStr == null || deadlineStr.isEmpty) continue;

      try {
        final deadlineDate = DateTime.parse(deadlineStr);
        final deadlineDateOnly = DateTime(deadlineDate.year, deadlineDate.month, deadlineDate.day);
        final tomorrowDateOnly = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);

        if (deadlineDateOnly.isAtSameMomentAs(tomorrowDateOnly)) {
          hasApproachingDeadline = true;
          _showDeadlineNotification(task['judul'] ?? 'Tugas Tanpa Judul');
        }
      } catch (e) {
        debugPrint("Error checking deadline: $e");
      }
    }

    if (hasApproachingDeadline) {
      _hasShownNotification = true;
    }
  }

  void _showDeadlineNotification(String taskTitle) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.notifications_active, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Deadline "$taskTitle" besok!',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.orange[800],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(10),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'TUTUP',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    });
  }

  Future<void> fetchUserName() async {
    setState(() => _isLoadingUserName = true);
    try {
      final namaLengkap = await AuthHelper.getNamaLengkap();
      setState(() {
        _userName = namaLengkap ?? "User";
        _isLoadingUserName = false;
      });
    } catch (e) {
      setState(() => _isLoadingUserName = false);
    }
  }

  void _filterActiveTasks() {
    // Temporarily disable filtering to see all tasks
    _activeTasks = _tasksList;
    
    // Log all tasks for debugging
    for (var i = 0; i < _tasksList.length; i++) {
      debugPrint("Task ${i+1}: ${_tasksList[i]['judul']} - Status: ${_tasksList[i]['status']}");
      debugPrint("Deadline: ${_tasksList[i]['tanggal_deadline']}");
    }
    
    // Original filtering logic (commented out for now)
    
    final now = DateTime.now();
    _activeTasks = _tasksList.where((task) {
      final status = task['status'];
      final deadlineStr = task['tanggal_deadline'];
      
      if (status == 'selesai' || deadlineStr == null) return false;

      try {
        final deadlineDate = DateTime.parse(deadlineStr);
        return deadlineDate.isAfter(now.subtract(const Duration(days: 1)));
      } catch (e) {
        debugPrint("Error parsing date: $e");
        return false;
      }
    }).toList();
  }

  Future<void> fetchUserTasks() async {
    setState(() => _isLoadingTasks = true);
    try {
      final userId = await AuthHelper.getUserId();
      debugPrint("Current user ID: $userId");
      
      final url = 'http://silahar3272.ftp.sh:3000/api/tugas/user/$userId/tugas';
      debugPrint("Fetching tasks from URL: $url");
      
      final response = await http.get(Uri.parse(url));
      debugPrint("API response status code: ${response.statusCode}");
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint("Received ${data.length} tasks from API");
        
        setState(() {
          _tasksList = data;
          _filterActiveTasks();
          _isLoadingTasks = false;
        });
        
        debugPrint("After filtering: ${_activeTasks.length} active tasks");
        _checkApproachingDeadlines();
      } else {
        debugPrint("API error: ${response.statusCode} - ${response.body}");
        setState(() => _isLoadingTasks = false);
      }
    } catch (e) {
      debugPrint("Error fetching tasks: $e");
      setState(() => _isLoadingTasks = false);
    }
  }

  Future<void> fetchNews() async {
    setState(() => _isLoadingNews = true);
    try {
      final response = await http.get(
        Uri.parse("http://silahar3272.ftp.sh:3000/api/berita/"),
      );
      if (response.statusCode == 200) {
        setState(() {
          _newsList = json.decode(response.body);
          _isLoadingNews = false;
        });
      } else {
        setState(() => _isLoadingNews = false);
      }
    } catch (e) {
      debugPrint("Error fetching news: $e");
      setState(() => _isLoadingNews = false);
    }
  }

  void _onItemTapped(int index) {
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AddLaporanScreen()),
      );
    } else if (index == 3) {
      setState(() => _selectedIndex = 2);
    } else {
      setState(() => _selectedIndex = index);
    }
  }

  // Helper method to get display name (main name without credentials)
  String _getDisplayName(String fullName) {
    // Split by comma and take the first part (main name)
    final parts = fullName.split(',');
    return parts[0].trim();
  }

  // Helper method to check if name has credentials
  bool _hasCredentials(String fullName) {
    return fullName.contains(',') && fullName.split(',').length > 1;
  }

  // Helper method to get credentials part
  String _getCredentials(String fullName) {
    final parts = fullName.split(',');
    if (parts.length > 1) {
      // Join all credential parts with comma
      return parts.skip(1).map((part) => part.trim()).join(', ');
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildHomePage(),
            const RiwayatScreen(),
            const ProfileScreen(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: BottomAppBar(
            elevation: 0,
            color: Colors.white,
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItemNew(Icons.home_rounded, "Home", 0),
                _buildNavItemNew(Icons.history_rounded, "Riwayat", 1),
                _buildNavItemNew(Icons.add_rounded, "Add Laporan", 2),
                _buildNavItemNew(Icons.person_rounded, "Profile BPS", 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItemNew(IconData icon, String label, int index) {
    final isSelected = index != 2 && _selectedIndex == (index == 3 ? 2 : index);
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onItemTapped(index),
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: BoxDecoration(
              color: isSelected ? primaryColor.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon, 
                  color: isSelected ? primaryColor : Colors.grey.shade500,
                  size: 26,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    color: isSelected ? primaryColor : Colors.grey.shade600,
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (isSelected)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    height: 4,
                    width: 20,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHomePage() {
    return RefreshIndicator(
      onRefresh: () async {
        _hasShownNotification = false;
        await Future.wait([fetchNews(), fetchUserTasks(), fetchUserName()]);
      },
      color: primaryColor,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            sliver: SliverToBoxAdapter(child: _buildHeader()),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
            sliver: SliverToBoxAdapter(child: _buildWelcomeCard()),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
            sliver: SliverToBoxAdapter(child: _buildTasksSection()),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            sliver: SliverToBoxAdapter(
              child: Text(
                "Berita Terbaru",
                style: GoogleFonts.poppins(
                  fontSize: 20, 
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ),
          ),
          _buildNewsList(),
          const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Username section with flexible layout
        Expanded(
          child: _isLoadingUserName
              ? Container(
                  width: double.infinity,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main username display - always visible
                    Text(
                      _getDisplayName(_userName),
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Secondary line for titles/credentials if needed
                    if (_hasCredentials(_userName))
                      Text(
                        _getCredentials(_userName),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: primaryColor.withOpacity(0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
        ),
        // Spacing between username and notification
        const SizedBox(width: 12),
        // Notification button - fixed width
        Container(
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: () => showDialog(
              context: context,
              builder: (context) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Text(
                  'Notifikasi',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                content: Text(
                  'Belum ada notifikasi baru.',
                  style: GoogleFonts.poppins(),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Tutup',
                      style: GoogleFonts.poppins(color: primaryColor),
                    ),
                  ),
                ],
              ),
            ),
            icon: Icon(
              Icons.notifications_rounded, 
              color: primaryColor,
              size: 24,
            ),
            padding: const EdgeInsets.all(12),
            constraints: const BoxConstraints(
              minWidth: 48,
              minHeight: 48,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Selamat Datang!",
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Semoga hari Anda menyenangkan!",
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildStatCard("Tugas Aktif", _activeTasks.length.toString(), Icons.task_alt_rounded)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard("Berita", _newsList.length.toString(), Icons.article_rounded)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Tugas Aktif Anda",
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            IconButton(
              onPressed: fetchUserTasks,
              icon: Icon(Icons.refresh_rounded, color: primaryColor),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _isLoadingTasks
            ? _buildLoadingIndicator()
            : _activeTasks.isEmpty
                ? _buildEmptyTaskIndicator()
                : SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: _activeTasks.length,
                      itemBuilder: (context, index) {
                        final task = _activeTasks[index];
                        return Padding(
                          padding: EdgeInsets.only(right: index == _activeTasks.length - 1 ? 0 : 16),
                          child: Container(
                            width: 280,
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailTugasScreen(task: task),
                                  ),
                                );
                              },
                              child: TaskCard(
                                title: task['judul'] ?? 'No Title',
                                description: task['deskripsi'] ?? 'No Description',
                                tanggalDeadline: task['tanggal_deadline'],
                                status: task['status'] ?? 'belum_dikerjakan',
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return SizedBox(
      height: 150,
      child: Center(
        child: CircularProgressIndicator(color: primaryColor),
      ),
    );
  }

  Widget _buildEmptyTaskIndicator() {
    return Container(
      height: 150,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.task_alt_rounded, color: Colors.grey[400], size: 40),
            const SizedBox(height: 12),
            Text(
              "Tidak ada tugas aktif saat ini",
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsList() {
    if (_isLoadingNews) {
      return SliverToBoxAdapter(
        child: SizedBox(
          height: 200,
          child: Center(
            child: CircularProgressIndicator(color: primaryColor),
          ),
        ),
      );
    }

    if (_newsList.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          height: 200,
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[300]!, width: 1),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.article_rounded, color: Colors.grey[400], size: 40),
                const SizedBox(height: 12),
                Text(
                  "Tidak ada berita saat ini",
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final news = _newsList[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: NewsCard(
                imageUrl: "http://silahar3272.ftp.sh:3000${news["image_url"]}",
                category: news["category"],
                title: news["title"],
                subtitle: news["subtitle"],
                date: news["date"].toString().substring(0, 10),
                time: _formatTime(news["time"]),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailNewsScreen(news: news),
                  ),
                ),
              ),
            );
          },
          childCount: _newsList.length,
        ),
      ),
    );
  }

  String _formatTime(String time) {
    try {
      DateTime parsedTime = DateFormat("HH:mm:ss").parse(time);
      return DateFormat("h:mm a").format(parsedTime);
    } catch (e) {
      return time;
    }
  }
}