import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../routes.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'dashboard_page.dart';
import 'detailactivity_page.dart';
import 'bmlogin_page.dart';
import 'pipelinetoday_page.dart';
import 'rmfunding_page.dart';
import 'rmconsumer_page.dart';
import 'rmpriority_page.dart';
import 'pipeline_page.dart';
import 'send_notification_page.dart';
import 'dashboard_page_v2.dart';
import 'dashboard_region_page.dart';
import 'snapshot_page.dart';
import 'snapshot_cabang_page.dart';
import 'snapshot_produk_page.dart';
import 'profil_page.dart';
import 'topbottom_branch_page.dart';
import 'cs_page.dart';

class MenuPage extends StatefulWidget {
  final int level;
  final String region;
  final String cabang;

  const MenuPage({
    super.key,
    required this.level,
    required this.region,
    required this.cabang,
  });

  @override
  State<MenuPage> createState() => _MenuPageState();
}

int unreadCount = 3; // contoh, nanti bisa diganti dengan data asli dari API

class _MenuPageState extends State<MenuPage> {
  int _selectedIndex = 0;

  String username = '';
  String asalCabang = '';
  String kodeCabang = '';
  String region = '';
  String posisi = '';
  String sessionToken = '';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? 'User';
      asalCabang = prefs.getString('asal_cabang') ?? widget.cabang;
      kodeCabang = prefs.getString('kode_cabang') ?? '';
      region = prefs.getString('region') ?? widget.region;
      posisi = prefs.getString('posisi') ?? '';
      sessionToken = prefs.getString('session_token') ?? '';
    });
  }

  late final List<Widget> _bottomPages = [
    const SizedBox(), // menu utama
    SendNotificationPage(level: widget.level),
    const ProfilePage(), // profil
  ];

  @override
  Widget build(BuildContext context) {
    // Semua menu
    final List<Map<String, dynamic>> allMenus = [
      {
        "key": "snapshot",
        "title": "Snapshot Region",
        "icon": Icons.dashboard_customize_rounded,
        "color": Colors.lime[100],
        "page": const SnapshotPage(),
      },
      {
        "key": "snapshotcabang",
        "title": "Snapshot Cabang",
        "icon": Icons.apartment,
        "color": Colors.lightGreen[100],
        "page": const SnapshotcabangPage(),
      },
      {
        "key": "snapshotproduk",
        "title": "Snapshot Produk",
        "icon": Icons.data_exploration_sharp,
        "color": Colors.lightGreen[100],
        "page": const SnapshotProdukPage(),
      },
      {
        "key": "dashboard",
        "title": "Dashboard Region",
        "icon": Icons.dashboard,
        "color": Colors.blue[100],
        "page": const DashboardPage(),
      },
      {
        "key": "dashboardv2",
        "title": "Dashboard Cabang",
        "icon": Icons.dashboard_customize,
        "color": Colors.lightBlue[100],
        "page": const DashboardPageV2(),
      },
      {
        "key": "dashboardregion",
        "title": "Actual Vs Forecast",
        "icon": Icons.bar_chart,
        "color": Colors.indigo[100],
        "page": const DashboardRegionPage(),
      },
      {
        "key": "pipeline",
        "title": "Pipeline",
        "icon": Icons.insert_chart_outlined,
        "color": Colors.cyan[100],
        "page": PipelinePage(
          level: widget.level,
          region: widget.region,
          cabang: widget.cabang,
        ),
      },
      {
        "key": "pipelinetoday",
        "title": "Plan Hari Ini",
        "icon": Icons.post_add_rounded,
        "color": Colors.amber[100],
        "page": const PipelineTodayPage(),
      },
      {
        "key": "topbottombranch",
        "title": "Top-Bottom Branch",
        "icon": Icons.timeline,
        "color": Colors.amber[100],
        "page": const TopBottomBranchPage(),
      },
      {
        "key": "bmlogin",
        "title": "BM Activity",
        "icon": Icons.login,
        "color": Colors.pink[100],
        "page": const BmLoginPage(),
      },
      {
        "key": "rmfunding",
        "title": "RM Funding",
        "icon": Icons.account_balance_wallet,
        "color": Colors.teal[100],
        "page": const RmFundingPage(),
      },
      {
        "key": "rmconsumer",
        "title": "RM Consumer",
        "icon": Icons.people,
        "color": Colors.orange[100],
        "page": const RmConsumerPage(),
      },
      {
        "key": "rmpriority",
        "title": "RM Priority",
        "icon": Icons.star,
        "color": Colors.deepPurple[100],
        "page": const RmPriorityPage(),
      },
      {
        "key": "csactivity",
        "title": "CS Activity",
        "icon": Icons.pending_actions_sharp,
        "color": Colors.deepPurple[100],
        "page": const CsPage(),
      },
      {
        "key": "detailactivity",
        "title": "Detail Activity",
        "icon": Icons.list_alt,
        "color": Colors.green[100],
        "page": const DetailActivityPage(),
      },
      {
        "key": "notification",
        "title": "Send Notification",
        "icon": Icons.notifications_active,
        "color": Colors.red[100],
        "page": SendNotificationPage(level: widget.level),
      },
    ];

    // Menu per level
    final Map<int, List<String>> levelMenus = {
      1: [
        "pipelinetoday",
        "topbottombranch",
        "rmfunding",
        "rmconsumer",
        "rmpriority",
        "csactivity",
        "detailactivity",
      ],
      2: [
        "dashboardv2",
        "pipelinetoday",
        "topbottombranch",
        "rmfunding",
        "rmconsumer",
        "rmpriority",
        "csactivity",
        "detailactivity",
      ],
      3: [
        "snapshotcabang",
        "snapshotproduk",
        "dashboard",
        "dashboardregion",
        "pipeline",
        "topbottombranch",
        "bmlogin",
        "rmfunding",
        "rmconsumer",
        "rmpriority",
        "csactivity",
        "detailactivity",
      ],
      4: [
        "snapshot",
        "snapshotproduk",
        "dashboard",
        "dashboardregion",
        "pipeline",
        "topbottombranch",
        "bmlogin",
        "rmfunding",
        "rmconsumer",
        "rmpriority",
        "csactivity",
        "detailactivity",
      ],
    };

    final userMenus =
        allMenus
            .where((m) => levelMenus[widget.level]?.contains(m["key"]) ?? false)
            .toList();

    // Bagi menjadi 2 section
    final performanceMenus =
        userMenus
            .where(
              (m) => [
                "snapshot",
                "snapshotcabang",
                "snapshotproduk",
                "dashboard",
                "dashboardv2",
                "dashboardregion",
                "topbottombranch",
                "pipeline",
                "pipelinetoday",
              ].contains(m["key"]),
            )
            .toList();

    final activityMenus =
        userMenus
            .where(
              (m) => [
                "bmlogin",
                "rmfunding",
                "rmconsumer",
                "rmpriority",
                "csactivity",
                "detailactivity",
              ].contains(m["key"]),
            )
            .toList();

    return Scaffold(
      appBar: _buildAppBar(),
      body:
          _selectedIndex == 0
              ? _buildSectionedMenu(performanceMenus, activityMenus)
              : _bottomPages[_selectedIndex],

      bottomNavigationBar: _buildBottomBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 4,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff05a3f9), Color(0xff4a6cf7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      titleSpacing: 12,
      title: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Assalamualaikum, $username 👋',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Cabang $asalCabang ${kodeCabang.isNotEmpty ? "($kodeCabang)" : ""}',
                  style: const TextStyle(fontSize: 10, color: Colors.white70),
                ),
                if (region.isNotEmpty)
                  Text(
                    'Region $region',
                    style: const TextStyle(fontSize: 10, color: Colors.white70),
                  ),
                if (posisi.isNotEmpty)
                  Text(
                    'Posisi $posisi',
                    style: const TextStyle(fontSize: 10, color: Colors.white70),
                  ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: "Logout",
          icon: const Icon(
            Icons.logout_rounded,
            size: 26,
            color: Colors.redAccent,
          ),
          onPressed: () async {
            final bool? confirmLogout = await showDialog<bool>(
              context: context,
              barrierDismissible: false,
              builder:
                  (context) => Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 🔹 Icon Logout di atas
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.logout_rounded,
                              color: Colors.redAccent,
                              size: 48,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // 🔹 Judul
                          const Text(
                            "Konfirmasi Logout",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),

                          const SizedBox(height: 10),
                          const Text(
                            "Apakah Anda yakin ingin keluar dari aplikasi?",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // 🔹 Tombol aksi
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Tombol Batal
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    side: const BorderSide(color: Colors.grey),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed:
                                      () => Navigator.pop(context, false),
                                  child: const Text(
                                    "Batal",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Tombol Logout
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    backgroundColor: Colors.redAccent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text(
                                    "Ya, Logout",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
            );

            if (confirmLogout == true) {
              final prefs = await SharedPreferences.getInstance();

              // Ambil session_token yang disimpan saat login
              final sessionToken = prefs.getString('session_token') ?? '';

              // Tampilkan loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder:
                    (_) => const Center(
                      child: CircularProgressIndicator(color: Colors.redAccent),
                    ),
              );

              try {
                // 🔥 Panggil API logout.php
                final response = await http.post(
                  Uri.parse("http://103.59.95.71/api_performance/logout.php"),
                  body: {'SESSION_TOKEN': sessionToken},
                );

                final result = jsonDecode(response.body);

                // Tutup loading
                Navigator.pop(context);

                if (result['status'] == 'success') {
                  // Hapus semua data lokal
                  await prefs.clear();

                  if (!mounted) return;

                  // Arahkan ke login
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    MyRoute.login.name,
                    (route) => false,
                  );
                } else {
                  // Kalau gagal logout (misal token nggak valid)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result['message'] ?? 'Gagal logout'),
                    ),
                  );
                }
              } catch (e) {
                Navigator.pop(context); // tutup loading
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Error logout: $e')));
              }
            }
          },
        ),
      ],
    );
  }

  Widget _buildSectionedMenu(
    List<Map<String, dynamic>> performanceMenus,
    List<Map<String, dynamic>> activityMenus,
  ) {
    return Container(
      decoration: const BoxDecoration(
        //image: DecorationImage(
        //image: AssetImage("assets/images/bg_biru.jpeg"),
        //fit: BoxFit.cover,
        //),
      ),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMenuSection("Performance", performanceMenus),
          const SizedBox(height: 16),
          _buildMenuSection("Activity M-Direct", activityMenus),
        ],
      ),
    );
  }

  Widget _buildMenuSection(String title, List<Map<String, dynamic>> menus) {
    // warna dasar per section
    final Color sectionColor =
        title == "Performance" ? Colors.lightBlue[100]! : Colors.green[100]!;

    final Color headerColor =
        title == "Performance" ? Colors.blue[900]! : Colors.green[900]!;

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Header section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
              decoration: BoxDecoration(
                color: headerColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Grid menu
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: menus.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.0,
              ),
              itemBuilder: (context, index) {
                final menu = menus[index];

                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => menu["page"]),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  splashColor: Colors.blue.withOpacity(0.15), // efek tap halus
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      color: sectionColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.black12, // garis halus
                        width: 0.8,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 4,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(menu["icon"], size: 36, color: Colors.black54),
                        const SizedBox(height: 8),
                        Text(
                          menu["title"],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            color: Color.fromARGB(221, 33, 30, 30),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF1976D2), // biru tua
            Color(0xFF42A5F5), // biru muda
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: [
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color:
                    _selectedIndex == 0
                        ? Colors.white.withOpacity(0.3)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.apps),
            ),
            label: "Menu",
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color:
                    _selectedIndex == 1
                        ? Colors.white.withOpacity(0.3)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.notifications),
            ),
            label: "Notifikasi",
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color:
                    _selectedIndex == 2
                        ? Colors.white.withOpacity(0.3)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.person),
            ),
            label: "Profil",
          ),
        ],
      ),
    );
  }
}
