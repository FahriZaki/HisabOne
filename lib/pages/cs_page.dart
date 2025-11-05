import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../models/cs_activity.dart';
import '../datasource/cs_datasource.dart';

class CsPage extends StatefulWidget {
  const CsPage({super.key});

  @override
  State<CsPage> createState() => _CsPageState();
}

class _CsPageState extends State<CsPage> {
  late CsDataSource _csDataSource;
  List<CsActivity> _activities = [];
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
      "&posisi=cs",
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
                  .map((e) => CsActivity.fromJson(e))
                  .toList();

          final visibleColumns = _getVisibleColumns();

          setState(() {
            _activities = data;
            _csDataSource = CsDataSource(_activities, visibleColumns);
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
          "CS Activity",
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
                source: _csDataSource,
                allowSorting: true,
                frozenColumnsCount: 1,
                gridLinesVisibility: GridLinesVisibility.both,
                headerGridLinesVisibility: GridLinesVisibility.both,
                columns: _buildColumns(),
              ),
    );
  }

  List<GridColumn> _buildColumns() {
    final allColumns = [
      _col('NAMA', 'Nama', 120, Colors.transparent),
      _col('NAMA_CABANG', 'Cabang', 120, Colors.transparent),
      //  Today Activity & Status
      _col('TODAY_ACTIVITY', 'Today Activity', 130, Colors.blueAccent),
      _col('STATUS_ACTIVITY', 'Status', 100, Colors.blueAccent),

      // Visit Section
      _col('TOT_VISIT', 'Total Visit Today', 130, Colors.amberAccent),
      _col('MTD_AVG_VISIT', 'MTD Avg Visit', 130, Colors.amberAccent),

      //  Call Section
      _col('TOT_CALL', 'Total Call Today', 130, Colors.lightGreen),
      _col('MTD_AVG_CALL', 'MTD Avg Call', 130, Colors.lightGreen),
    ];

    return allColumns;
  }

  GridColumn _col(String name, String label, double width, Color bgColor) {
    return GridColumn(
      columnName: name,
      width: width,
      label: Container(
        alignment: Alignment.center,
        color: bgColor, //  warna background section
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: bgColor == Colors.transparent ? Colors.black : Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

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
    ];

    return all;
  }
}
