import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class NewsCard extends StatelessWidget {
  final String imageUrl;
  final String category;
  final String title;
  final String subtitle;
  final String date;
  final String time;
  final VoidCallback? onTap;

  const NewsCard({
    Key? key,
    required this.imageUrl,
    required this.category,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.time,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get screen width to make responsive decisions
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    
    // Adjust image size based on screen width
    final imageSize = isSmallScreen ? 80.0 : 100.0;
    
    // Calculate max title lines based on title length and screen size
    final int maxTitleLines = title.length > 50 ? 2 : (title.length > 30 ? 2 : 1);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Tooltip(
        message: title, // Show full title on long press
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  width: imageSize,
                  height: imageSize,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade200,
                        child: const Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'News: $category',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: isSmallScreen ? 12 : 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: isSmallScreen ? 16 : 18,
                        fontWeight: FontWeight.bold,
                        height: 1.2, // Tighter line height for better readability
                      ),
                      maxLines: maxTitleLines, // Dynamic based on title length
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    // Wrap date and time in a row that can wrap to next line if needed
                    Wrap(
                      spacing: 16, // Space between date and time
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.calendar_today_outlined, 
                                size: isSmallScreen ? 14 : 16, 
                                color: Colors.grey.shade400),
                            const SizedBox(width: 4),
                            Text(
                              date,
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: isSmallScreen ? 12 : 14,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.access_time, 
                                size: isSmallScreen ? 14 : 16, 
                                color: Colors.grey.shade400),
                            const SizedBox(width: 4),
                            Text(
                              time,
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: isSmallScreen ? 12 : 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NewsListScreen extends StatefulWidget {
  const NewsListScreen({Key? key}) : super(key: key);

  @override
  _NewsListScreenState createState() => _NewsListScreenState();
}

class _NewsListScreenState extends State<NewsListScreen> {
  List<dynamic> newsList = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  Future<void> fetchNews() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    
    try {
      final response = await http.get(Uri.parse('https://192.168.223.151:8080/api/news/'));
      if (response.statusCode == 200) {
        setState(() {
          newsList = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load news. Status code: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('News List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchNews,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: fetchNews,
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: fetchNews,
                  child: newsList.isEmpty
                      ? const Center(child: Text('No news available'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: newsList.length,
                          itemBuilder: (context, index) {
                            final news = newsList[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: NewsCard(
                                imageUrl: 'http://192.168.223.151:8080${news['image_url']}',
                                category: news['category'],
                                title: news['title'],
                                subtitle: news['subtitle'],
                                date: news['date'].split('T')[0],
                                time: news['time'],
                                onTap: () {
                                  // Navigate to detail page
                                  print('Tapped on: ${news['title']}');
                                },
                              ),
                            );
                          },
                        ),
                ),
    );
  }
}
