import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../models/bm_activity.dart';
import '../datasource/bm_datasource.dart';

class BmLoginPage extends StatefulWidget {
  const BmLoginPage({super.key});

  @override
  State<BmLoginPage> createState() => _BmLoginPageState();
}

class _BmLoginPageState extends State<BmLoginPage> {
  late BmDataSource _bmDataSource;
  List<BmActivity> _activities = [];
  bool _loading = true;

  Future<void> fetchData() async {
    setState(() {
      _loading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    int userLevel = prefs.getInt('level') ?? 1;
    String userCabang = prefs.getString('asal_cabang') ?? '';
    String userRegion = prefs.getString('region') ?? '';

    final url = Uri.parse("http://103.59.95.71/api_performance/bmactivity.php");
    final response = await http.post(
      url,
      body: {
        "level": userLevel.toString(),
        "asal_cabang": userCabang,
        "region": userRegion,
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse["status"] == "success") {
        final data =
            (jsonResponse["data"] as List)
                .map((e) => BmActivity.fromJson(e))
                .toList();

        setState(() {
          _activities = data;
          _bmDataSource = BmDataSource(_activities);
          _loading = false;
        });
      }
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
          "BM Activity",
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
            onPressed: () async {
              await fetchData();
            },
          ),
        ],
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : SfDataGrid(
                source: _bmDataSource,
                allowSorting: true,
                frozenColumnsCount: 1,
                gridLinesVisibility: GridLinesVisibility.both,
                headerGridLinesVisibility: GridLinesVisibility.both,
                columnWidthMode: ColumnWidthMode.auto,
                columns: [
                  GridColumn(
                    columnName: 'NAMA',
                    width: 120,
                    label: _headerCell("Nama"),
                  ),
                  GridColumn(
                    columnName: 'NAMA_CABANG',
                    width: 140,
                    label: _headerCell("Cabang"),
                  ),
                  // 🔵 LOGIN SECTION (biru)
                  GridColumn(
                    columnName: 'BM_LOGIN_DTD',
                    width: 130,
                    label: _coloredHeader("BM Login Today", Colors.blueAccent),
                  ),
                  GridColumn(
                    columnName: 'RM_LOGIN_DTD',
                    width: 130,
                    label: _coloredHeader(  
                      "RM Activity Today",
                      Colors.blueAccent,
                    ),
                  ),

                  // 🟡 VISIT SECTION (kuning)
                  GridColumn(
                    columnName: 'AVG_VISIT',
                    width: 120,
                    label: _coloredHeader("Avg Visit Today", Colors.amber),
                  ),
                  GridColumn(
                    columnName: 'MTD_VISIT',
                    width: 120,
                    label: _coloredHeader("MTD Visit", Colors.amber),
                  ),

                  // 🟢 CALL SECTION (hijau)
                  GridColumn(
                    columnName: 'AVG_CALL',
                    width: 120,
                    label: _coloredHeader("Avg Call Today", Colors.green),
                  ),
                  GridColumn(
                    columnName: 'MTD_CALL',
                    width: 120,
                    label: _coloredHeader("MTD Call", Colors.green),
                  ),
                ],
              ),
    );
  }

  // Header normal (tanpa warna)
  Widget _headerCell(String text) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Header berwarna
  // Header berwarna — perbaikan: jangan pakai .shade700 pada Color
  Widget _coloredHeader(String text, Color color) {
    final background = color.withOpacity(0.18); // background lembut
    final textColor = _textColorFor(
      color,
    ); // tentukan teks putih/black otomatis

    return Container(
      alignment: Alignment.center,
      color: background,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // Helper: pilih warna teks yang kontras (hitam jika bg terang, putih jika bg gelap)
  Color _textColorFor(Color color) {
    return color.computeLuminance() > 0.5 ? Colors.black : Colors.black;
  }
}
