import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../models/rmconsumer_activity.dart';
import '../datasource/rmconsumer_datasource.dart';

class RmConsumerPage extends StatefulWidget {
  const RmConsumerPage({super.key});

  @override
  State<RmConsumerPage> createState() => _RmConsumerPageState();
}

class _RmConsumerPageState extends State<RmConsumerPage> {
  late RmConsumerDataSource _rmDataSource;
  List<RmConsumerActivity> _activities = [];
  bool _loading = true;
  int _level = 4;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() => _loading = true);
    final prefs = await SharedPreferences.getInstance();

    _level = prefs.getInt('level') ?? 4;
    final String cabang = prefs.getString('kode_cabang') ?? '';
    final String region = prefs.getString('region') ?? '';

    final url = Uri.parse(
      "http://103.59.95.71/api_performance/rmactivity.php"
      "?level=$_level"
      "&cabang=${Uri.encodeComponent(cabang)}"
      "&region=${Uri.encodeComponent(region)}"
      "&posisi=consumer",
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
                  .map((e) => RmConsumerActivity.fromJson(e))
                  .toList();

          setState(() {
            _activities = data;
            _rmDataSource = RmConsumerDataSource(_activities, level: _level);
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

  ///  Warna header per *section group*
  Color _getSectionColor(String columnName) {
    switch (columnName) {
      case 'TODAY_ACTIVITY':
      case 'STATUS_ACTIVITY':
        return const Color(0xFF1976D2); // biru
      case 'TOT_VISIT':
      case 'MTD_AVG_VISIT':
        return const Color.fromARGB(255, 248, 211, 28); // kuning
      case 'TOT_CALL':
      case 'MTD_AVG_CALL':
        return const Color.fromARGB(255, 129, 220, 49); // oranye
      case 'MTD_SUBMISSION':
        return const Color.fromARGB(255, 47, 189, 211); // merah
      case 'MTD_NTB':
        return const Color(0xFF7B1FA2); // ungu
      default:
        return Colors.transparent; // abu tua default
    }
  }

  ///    Widget header cell dengan warna background per section
  Widget _headerCell(String text, String columnName, {bool alignLeft = false}) {
    final color = _getSectionColor(columnName);
    return Container(
      alignment: alignLeft ? Alignment.centerLeft : Alignment.center,
      color: color,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: color == Colors.transparent ? Colors.black : Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  List<GridColumn> _buildColumns() {
    final allColumns = <GridColumn>[
      GridColumn(
        columnName: 'NAMA',
        width: 120,
        label: _headerCell("Nama", 'NAMA', alignLeft: true),
      ),
      GridColumn(
        columnName: 'NAMA_CABANG',
        width: 120,
        label: _headerCell("Cabang", 'NAMA_CABANG'),
      ),
      GridColumn(
        columnName: 'TODAY_ACTIVITY',
        width: 110,
        label: _headerCell("Today Activity", 'TODAY_ACTIVITY'),
      ),
      GridColumn(
        columnName: 'STATUS_ACTIVITY',
        width: 110,
        label: _headerCell("Status", 'STATUS_ACTIVITY'),
      ),
      GridColumn(
        columnName: 'TOT_VISIT',
        width: 110,
        label: _headerCell("Total Visit Today", 'TOT_VISIT'),
      ),
      GridColumn(
        columnName: 'MTD_AVG_VISIT',
        width: 110,
        label: _headerCell("MTD Avg Visit", 'MTD_AVG_VISIT'),
      ),
      GridColumn(
        columnName: 'TOT_CALL',
        width: 110,
        label: _headerCell("Total Call Today", 'TOT_CALL'),
      ),
      GridColumn(
        columnName: 'MTD_AVG_CALL',
        width: 110,
        label: _headerCell("MTD Avg Call", 'MTD_AVG_CALL'),
      ),
      GridColumn(
        columnName: 'MTD_SUBMISSION',
        width: 130,
        label: _headerCell("MTD Dropping", 'MTD_SUBMISSION'),
      ),
      GridColumn(
        columnName: 'MTD_NTB',
        width: 110,
        label: _headerCell("MTD NTB", 'MTD_NTB'),
      ),
    ];

    return allColumns;
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
          "RM Consumer Activity",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
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
                frozenColumnsCount: 1,
                gridLinesVisibility: GridLinesVisibility.both,
                headerGridLinesVisibility: GridLinesVisibility.both,
                columns: _buildColumns(),
              ),
    );
  }
}
