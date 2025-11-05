import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../routes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  bool isObscure = true;
  bool isLoading = false;

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    final url = Uri.parse("http://103.59.95.71/api_performance/login.php");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'USERNAME': usernameController.text.trim(),
          'PASSWORD': passwordController.text.trim(),
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data['status'] == 'success') {
          final String username =
              data['data']['username'] ?? usernameController.text;
          final String asalCabang = data['data']['asal_cabang'] ?? '';
          final String kodeCabang = data['data']['kode_cabang'] ?? '';
          final int level =
              int.tryParse(data['data']['level']?.toString() ?? '1') ?? 1;
          final String region = data['data']['region'] ?? '';
          final String parent = data['data']['parent'] ?? '';
          final String posisi = data['data']['posisi'] ?? '';
          final String sessionToken = data['session_token'] ?? '';
          
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('username', username);
          await prefs.setString('asal_cabang', asalCabang);
          await prefs.setString('kode_cabang', kodeCabang);
          await prefs.setInt('level', level);
          await prefs.setString('region', region);
          await prefs.setString('parent', parent);
          await prefs.setString('posisi', posisi);
          await prefs.setString('session_token', sessionToken);

          if (!mounted) return;
          Navigator.pushReplacementNamed(
            context,
            MyRoute.home.name,
            arguments: {
              'username': username,
              'asal_cabang': asalCabang,
              'kode_cabang': kodeCabang,
              'level': level,
              'region': region,
              'parent': parent,
              'posisi': posisi,
            },
          );
        } else {
          if (!mounted) return;
          _showMessage(data['message']);
        }
      } else {
        if (!mounted) return;
        _showMessage('Terjadi kesalahan server');
      }
    } catch (e) {
      if (!mounted) return;

      String errorMsg = "Terjadi kesalahan, periksa koneksi internet Anda.";

      if (e.toString().contains("Failed host lookup") ||
          e.toString().contains("SocketException")) {
        errorMsg = "Tidak ada koneksi internet. Silakan periksa jaringan Anda.";
      } else if (e.toString().contains("Connection refused")) {
        errorMsg = "Server tidak dapat dihubungi. Coba lagi nanti.";
      }

      _showMessage(errorMsg);
    }

    setState(() => isLoading = false);
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffdf6ec),
      body: Stack(
        children: [
          // Background atas
          Container(
            height: MediaQuery.of(context).size.height * 0.45,
            decoration: const BoxDecoration(
              color: Color(0xff4a6cf7),
              image: DecorationImage(
                image: AssetImage("assets/images/bg_biru.jpg"),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black26, BlendMode.darken),
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
          ),
          // Card login (logo dipindah ke sini)
          Align(
            alignment: Alignment.center,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // LOGO di dalam Card
                        Image.asset("assets/images/logo_apk1.png", height: 70),
                        const SizedBox(height: 16),
                        const Text(
                          "Assalamualaikum, Silahkan Login",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff05a3f9),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Username
                        TextFormField(
                          controller: usernameController,
                          decoration: _inputDecoration(
                            label: "Username",
                            icon: Icons.email_outlined,
                          ),
                          validator:
                              (value) =>
                                  value == null || value.isEmpty
                                      ? 'Username wajib diisi'
                                      : null,
                        ),
                        const SizedBox(height: 16),

                        // Password
                        TextFormField(
                          controller: passwordController,
                          obscureText: isObscure,
                          decoration: _inputDecoration(
                            label: "Password",
                            icon: Icons.lock_outline,
                            suffix: IconButton(
                              icon: Icon(
                                isObscure
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() => isObscure = !isObscure);
                              },
                            ),
                          ),
                          validator:
                              (value) =>
                                  value == null || value.isEmpty
                                      ? 'Password wajib diisi'
                                      : null,
                        ),
                        const SizedBox(height: 24),

                        // Tombol login
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : login,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              backgroundColor: const Color(0xff05a3f9),
                              foregroundColor: Colors.white,
                              elevation: 5,
                            ),
                            child:
                                isLoading
                                    ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : const Text(
                                      "LOGIN",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      prefixIcon: Icon(icon, color: const Color(0xff05a3f9)),
      suffixIcon: suffix,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
        borderRadius: BorderRadius.circular(30),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xff05a3f9), width: 2.0),
        borderRadius: BorderRadius.circular(30),
      ),
      labelStyle: const TextStyle(color: Colors.black54),
      floatingLabelStyle: const TextStyle(color: Color(0xff05a3f9)),
    );
  }
}
