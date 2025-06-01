import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class TaskCard extends StatelessWidget {
  final String title;
  final String description;
  final String tanggalDeadline;
  final String status;
  final Color primaryColor;

  const TaskCard({
    Key? key,
    required this.title,
    required this.description,
    required this.tanggalDeadline,
    required this.status,
    this.primaryColor = const Color(0xFF546E7A),
  }) : super(key: key);

  String _formatDeadline(String dateTimeStr) {
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return DateFormat('dd MMM yyyy').format(dateTime); // Changed format to be more readable
    } catch (e) {
      debugPrint("Error formatting deadline: $e");
      return "Invalid date";
    }
  }

  bool _isDeadlineApproaching(String deadlineStr) {
    try {
      final deadline = DateTime.parse(deadlineStr);
      final now = DateTime.now();
      final tomorrow = DateTime(now.year, now.month, now.day + 1);
      
      // Check if deadline is today or tomorrow
      final isToday = deadline.year == now.year && 
                      deadline.month == now.month && 
                      deadline.day == now.day;
                      
      final isTomorrow = deadline.year == tomorrow.year && 
                         deadline.month == tomorrow.month && 
                         deadline.day == tomorrow.day;
                         
      return isToday || isTomorrow;
    } catch (e) {
      return false;
    }
  }

  bool _isDeadlineToday(String deadlineStr) {
    try {
      final deadline = DateTime.parse(deadlineStr);
      final now = DateTime.now();
      return deadline.year == now.year && 
             deadline.month == now.month && 
             deadline.day == now.day;
    } catch (e) {
      return false;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'selesai':
        return 'Selesai';
      case 'dalam_pengerjaan':
        return 'Dalam Pengerjaan';
      case 'belum_dikerjakan':
        return 'Belum Dikerjakan';
      default:
        return status.replaceAll('_', ' ');
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'selesai':
        return Colors.green.shade600;
      case 'dalam_pengerjaan':
        return Colors.amber.shade700;
      case 'belum_dikerjakan':
      default:
        return Colors.blueGrey.shade600;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'selesai':
        return Icons.check_circle_outline;
      case 'dalam_pengerjaan':
        return Icons.pending_outlined;
      case 'belum_dikerjakan':
      default:
        return Icons.assignment_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDeadline = _formatDeadline(tanggalDeadline);
    final isApproaching = _isDeadlineApproaching(tanggalDeadline);
    final isToday = _isDeadlineToday(tanggalDeadline);
    final statusColor = _getStatusColor(status);
    final statusIcon = _getStatusIcon(status);
    final statusText = _getStatusText(status);

    return Container(
      width: 250, // Slightly wider for better content display
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 5),
            spreadRadius: 1,
          ),
        ],
        border: Border.all(
          color: isApproaching ? 
            (isToday ? Colors.red.shade200 : Colors.orange.shade200) : 
            Colors.grey.shade200,
          width: isApproaching ? 1.5 : 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status indicator at the top
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
          ),
          
          // Title section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          // Description
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(
              description,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
          
          // Footer with deadline and status
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Deadline section
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isApproaching ? 
                            (isToday ? Colors.red.shade50 : Colors.orange.shade50) : 
                            Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.event_note_rounded,
                          size: 16,
                          color: isApproaching ? 
                            (isToday ? Colors.red.shade700 : Colors.orange.shade700) : 
                            primaryColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              formattedDeadline,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: isApproaching ? FontWeight.w600 : FontWeight.w500,
                                color: isApproaching ? 
                                  (isToday ? Colors.red.shade700 : Colors.orange.shade700) : 
                                  Colors.grey[800],
                              ),
                            ),
                            if (isApproaching)
                              Text(
                                isToday ? "Hari ini!" : "Besok!",
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isToday ? Colors.red.shade700 : Colors.orange.shade700,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: statusColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        statusIcon,
                        size: 14,
                        color: statusColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}