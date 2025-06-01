import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:silahar/screens/home_screen.dart';
import 'package:silahar/screens/login_screen.dart';
import 'package:silahar/screens/profile_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Fungsi untuk memeriksa apakah ada token yang tersimpan
  Future<String> checkToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');  // Cek apakah token ada
    if (token != null && token.isNotEmpty) {
      return '/home';  // Jika token ada, arahkan ke HomeScreen
    } else {
      return '/login';  // Jika token tidak ada, arahkan ke LoginScreen
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Silahar App',
      debugShowCheckedModeBanner: false,
      // Gunakan FutureBuilder untuk memeriksa token terlebih dahulu
      home: FutureBuilder<String>(
        future: checkToken(),  // Panggil fungsi untuk cek token
        builder: (context, snapshot) {
          // Cek status koneksi
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());  // Tampilkan loading
          } else if (snapshot.hasData) {
            // Setelah mendapatkan data, navigasi ke halaman yang sesuai
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacementNamed(context, snapshot.data!);
            });
            return const SizedBox();  // Kembalikan widget kosong sementara navigasi terjadi
          } else {
            // Jika tidak ada data atau terjadi error, arahkan ke login
            return const LoginScreen();
          }
        },
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
