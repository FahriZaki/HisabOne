import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import '../models/rmpriority_activity.dart';
import '../datasource/rmpriority_datasource.dart';

class RmPriorityPage extends StatefulWidget {
  const RmPriorityPage({super.key});

  @override
  State<RmPriorityPage> createState() => _RmPriorityPageState();
}

class _RmPriorityPageState extends State<RmPriorityPage> {
  late RmPriorityDataSource _rmDataSource;
  List<RmPriorityActivity> _activities = [];
  bool _loading = true;
  int _level = 4;

  Future<void> fetchData() async {
    setState(() => _loading = true);

    final prefs = await SharedPreferences.getInstance();
    final int level = prefs.getInt('level') ?? 4;
    final String cabang = prefs.getString('kode_cabang') ?? '';
    final String region = prefs.getString('region') ?? '';

    _level = level;

    final url = Uri.parse(
      "http://103.59.95.71/api_performance/rmactivity.php"
      "?level=$level"
      "&cabang=${Uri.encodeComponent(cabang)}"
      "&region=${Uri.encodeComponent(region)}"
      "&posisi=priority",
    ); 

    try {
      final response = await http.get(url);
      //debugPrint("API URL: $url");
      //debugPrint("Response: ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse["status"] == "success") {
          final data =
              (jsonResponse["data"] as List)
                  .map((e) => RmPriorityActivity.fromJson(e))
                  .toList();

          final visibleColumns = _getVisibleColumns();

          setState(() {
            _activities = data;
            _rmDataSource = RmPriorityDataSource(_activities, visibleColumns);
            _loading = false;
          });
        } else {
          setState(() => _loading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: ${jsonResponse['message']}")),
          );
        }
      } else {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal mengambil data dari server")),
        );
      }
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Exception: $e")));
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 4,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF05A3F9), Color(0xFF0288D1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          "RM Priority Activity",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 1.2,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: "Refresh Data",
            onPressed: fetchData,
          ),
        ],
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : SfDataGrid(
                source: _rmDataSource,
                allowSorting: true,
                allowFiltering: true,
                frozenColumnsCount: 1,
                gridLinesVisibility: GridLinesVisibility.both,
                headerGridLinesVisibility: GridLinesVisibility.both,
                columns: _buildColumns(),
              ),
    );
  }

  ///  Buat daftar kolom
  List<GridColumn> _buildColumns() {
    final List<GridColumn> allColumns = [
      _col('NAMA', 'Nama', 120),
      _col('NAMA_CABANG', 'Cabang', 120),
      _col('TODAY_ACTIVITY', 'Today Activity', 100),
      _col('STATUS_ACTIVITY', 'Status', 110),
      _col('TOT_VISIT', 'Total Visit Today', 120),
      _col('MTD_AVG_VISIT', 'MTD Avg Visit', 120),
      _col('TOT_CALL', 'Total Call Today', 120),
      _col('MTD_AVG_CALL', 'MTD Avg Call', 120),
      _col('MTD_NTB', 'MTD NTB', 120),
      _col('FUND_GROWTH', 'Fund Growth', 130),
    ];

    return allColumns;
  }

  ///  builder kolom dengan warna header per section
  GridColumn _col(
    String name,
    String label,
    double width, {
    bool filter = false,
  }) {
    final bgColor = _getSectionColor(name);

    return GridColumn(
      columnName: name,
      allowFiltering: filter,
      width: width,
      label: Container(
        alignment: Alignment.center,
        color: bgColor,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: _textColorFor(bgColor),
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  ///  Warna header per *section group*
  Color _getSectionColor(String columnName) {
    switch (columnName) {
      case 'TODAY_ACTIVITY':
      case 'STATUS_ACTIVITY':
        return const Color(0xFF1976D2); //  biru
      case 'TOT_VISIT':
      case 'MTD_AVG_VISIT':
        return const Color.fromARGB(255, 248, 211, 28); //  kuning
      case 'TOT_CALL':
      case 'MTD_AVG_CALL':
        return const Color.fromARGB(255, 129, 220, 49); // hijau
      case 'MTD_SUBMISSION':
        return const Color.fromARGB(255, 47, 189, 211); //  biru muda
      case 'MTD_NTB':
        return const Color(0xFF7B1FA2); //  ungu
      case 'FUND_GROWTH':
        return const Color(0xFFD32F2F); //  merah gelap
      default:
        return Colors.transparent; //  abu terang
    }
  }

  /// Hitung warna teks otomatis (biar kontras)
  Color _textColorFor(Color bg) {
    // Kalau background transparan → teks hitam
    if (bg == Colors.transparent) {
      return Colors.black;
    }

    // Kalau background terang → teks hitam, kalau gelap → teks putih
    return bg.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }

  /// Dapatkan daftar kolom yang ditampilkan sesuai level
  List<String> _getVisibleColumns() {
    final all = [
      'NAMA',
      'NAMA_CABANG',
      'TODAY_ACTIVITY',
      'STATUS_ACTIVITY',
      'TOT_VISIT',
      'MTD_AVG_VISIT',
      'TOT_CALL',
      'MTD_AVG_CALL',
      'MTD_NTB',
      'FUND_GROWTH',
    ];

    return all;
  }
}
