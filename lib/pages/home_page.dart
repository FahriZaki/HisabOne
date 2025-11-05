import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'menu_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = true;
  int level = 1;
  String username = 'User';
  String asalCabang = '';
  String kodeCabang = '';
  String region = '';
  String posisi = '';
  String _notifikasiText = "Mengambil data pengguna...";
  Timer? _notifTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startFakeNotifikasi(); // tampilkan notif sementara
      _loadUserData();
    });
  }

  void _startFakeNotifikasi() {
    final messages = [
      "🔔 Mengecek notifikasi terbaru...",
      "📡 Menyambungkan ke server...",
      "🧠 Memuat profil pengguna...",
      "📨 Menyiapkan data menu...",
    ];
    int index = 0;

    _notifTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!mounted) return;
      setState(() {
        _notifikasiText = messages[index];
        index = (index + 1) % messages.length;
      });
    });
  }

  Future<void> _loadUserData() async {
    try {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
              {};

      SharedPreferences prefs = await SharedPreferences.getInstance();

      level = int.tryParse(
            args['level']?.toString() ?? prefs.getInt('level')?.toString() ?? '1',
          ) ??
          1;

      username = args['username'] ?? prefs.getString('username') ?? 'User';
      asalCabang = args['asal_cabang'] ?? prefs.getString('asal_cabang') ?? '';
      kodeCabang = args['kode_cabang'] ?? prefs.getString('kode_cabang') ?? '';
      region = args['region'] ?? prefs.getString('region') ?? '';
      posisi = args['posisi'] ?? prefs.getString('posisi') ?? '';

      await prefs.setInt('level', level);
      await prefs.setString('username', username);
      await prefs.setString('asal_cabang', asalCabang);
      await prefs.setString('kode_cabang', kodeCabang);
      await prefs.setString('region', region);
      await prefs.setString('posisi', posisi);

      await _fetchNotifikasiCount();

      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      _notifTimer?.cancel();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MenuPage(
            level: level,
            region: region,
            cabang: asalCabang,
          ),
        ),
      );
    } catch (e) {
      debugPrint("❌ Error load user data: $e");
      if (mounted) {
        _notifTimer?.cancel();
        setState(() {
          _isLoading = false;
          _notifikasiText = "Gagal memuat data pengguna.";
        });
      }
    }
  }

  Future<void> _fetchNotifikasiCount() async {
    try {
      final response = await http.get(
        Uri.parse("http://103.59.95.71/api_performance/get_notifikasi.php"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          final count = (data['data'] as List).length;
          setState(() {
            _notifikasiText = "🔔 Anda punya $count notifikasi baru.";
          });
        }
      }
    } catch (e) {
      debugPrint("Gagal ambil notifikasi: $e");
    }
  }

  @override
  void dispose() {
    _notifTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: _isLoading
              ? Column(
                  key: const ValueKey("loading"),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 🔹 Animasi loading menarik
                    Container(
                      width: 80,
                      height: 80,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xff05a3f9), Color(0xff4a6cf7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: const CircularProgressIndicator(
                        strokeWidth: 4,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _notifikasiText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                )
              : const Text(
                  "❌ Gagal memuat data pengguna.",
                  key: ValueKey("error"),
                  style: TextStyle(color: Colors.redAccent, fontSize: 14),
                ),
        ),
      ),
    );
  }
}
