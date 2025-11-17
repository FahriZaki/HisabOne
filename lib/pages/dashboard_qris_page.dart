import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class DashboardQrisPage extends StatefulWidget {
  final int level;
  final String region;
  final String cabang;

  const DashboardQrisPage({
    super.key,
    required this.level,
    required this.region,
    required this.cabang,
  });

  @override
  State<DashboardQrisPage> createState() => _DashboardQrisPageState();
}

class _DashboardQrisPageState extends State<DashboardQrisPage> {
  bool isLoading = true;
  List<dynamic> regionData = [];
  List<dynamic> cabangData = [];
  String headerLm = '';
  String headerToday = '';
  final NumberFormat formatter = NumberFormat.decimalPattern('id');

  @override
  void initState() {
    super.initState();
    _fetchHeader();
    _fetchData();
  }

  // Ambil header tanggal (LM & Today)
  Future<void> _fetchHeader() async {
    try {
      final url = Uri.parse(
        "http://103.59.95.71/api_performance/dashboard_qris.php",
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final header = jsonData["header"];
        setState(() {
          headerLm = header["lm"] ?? "LM";
          headerToday = header["today"] ?? "Today";
        });
      }
    } catch (e) {
      debugPrint("Error fetchHeaderDates: $e");
    }
  }

  // Ambil data region & cabang
  Future<void> _fetchData() async {
    setState(() => isLoading = true);
    try {
      // Ambil data REGION
      final regionUrl = Uri.parse(
        "http://103.59.95.71/api_performance/dashboard_qris.php"
        "?level=${widget.level}"
        "&region=${Uri.encodeComponent(widget.region)}",
      );

      final regionResponse = await http.get(regionUrl);
      if (regionResponse.statusCode == 200) {
        final jsonData = json.decode(regionResponse.body);
        if (jsonData["status"] == "success") {
          setState(() {
            regionData = jsonData["data"] ?? [];
          });
        }
      }

      // Ambil data CABANG (khusus level 4 atau ada region)
      if (widget.level == 4 || widget.level == 5 || widget.region.isNotEmpty) {
        final cabangUrl = Uri.parse(
          "http://103.59.95.71/api_performance/dashboard_qris_cabang.php"
          "?level=${widget.level}"
          "&region=${Uri.encodeComponent(widget.region)}",
        );

        final cabangResponse = await http.get(cabangUrl);
        if (cabangResponse.statusCode == 200) {
          final jsonData = json.decode(cabangResponse.body);
          if (jsonData["status"] == "success") {
            setState(() {
              cabangData = jsonData["data"] ?? [];
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetchData: $e");
    }
    setState(() => isLoading = false);
  }

  // Header cell
  Widget _headerCell(String text, {Color color = Colors.blueGrey}) {
    return Container(
      alignment: Alignment.center,
      color: color,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  // Stacked header cell
  Widget _stackedHeaderCell(String text, {required Color color}) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 6),
      color: color,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  // Grid untuk REGION (ada filter)
  Widget _buildRegionGrid() {
    if (regionData.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: Center(child: Text("No Data", style: TextStyle(fontSize: 14))),
      );
    }

    return SizedBox(
      height: 350,
      child: SfDataGrid(
        source: QrisDataSource(regionData, formatter, isCabang: false),
        gridLinesVisibility: GridLinesVisibility.both,
        headerGridLinesVisibility: GridLinesVisibility.both,
        frozenColumnsCount: 1,
        allowFiltering: true,
        allowSorting: true,
        columnWidthMode: ColumnWidthMode.auto,
        headerRowHeight: 42,
        rowHeight: 36,
        columns: [
          GridColumn(
            columnName: 'region',
            allowFiltering: false,
            allowSorting: false,
            label: _headerCell('REGION', color: Colors.indigo),
            width: 140,
          ),
          GridColumn(
            columnName: 'lastMonthMTD',
            allowFiltering: false,
            width: 80,
            label: _headerCell('MTD', color: Colors.purple),
          ),
          GridColumn(
            columnName: 'lastMonthYTD',
            allowFiltering: false,
            width: 80,
            label: _headerCell('YTD', color: Colors.purple),
          ),
          GridColumn(
            columnName: 'actualMTD',
            allowFiltering: false,
            width: 80,
            label: _headerCell('MTD', color: Colors.blue),
          ),
          GridColumn(
            columnName: 'actualYTD',
            allowFiltering: false,
            width: 80,
            label: _headerCell('YTD', color: Colors.blue),
          ),
          GridColumn(
            columnName: 'active',
            allowFiltering: false,
            width: 80,
            label: _headerCell('Active', color: Colors.green),
          ),
          GridColumn(
            columnName: 'nonActive',
            allowFiltering: false,
            width: 80,
            label: _headerCell('Non Active', color: Colors.green),
          ),
          GridColumn(
            columnName: 'target',
            allowFiltering: false,
            width: 80,
            label: _headerCell('Target', color: Colors.orange),
          ),
          GridColumn(
            columnName: 'diff',
            allowFiltering: false,
            width: 80,
            label: _headerCell('%', color: Colors.redAccent),
          ),
        ],
        stackedHeaderRows: _stackedHeaders(),
      ),
    );
  }

  // Grid untuk CABANG (tanpa filter & sorting)
  Widget _buildCabangGrid() {
    if (cabangData.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: Center(child: Text("No Data", style: TextStyle(fontSize: 14))),
      );
    }

    return SizedBox(
      height: 350,
      child: SfDataGrid(
        source: QrisDataSource(cabangData, formatter, isCabang: true),
        gridLinesVisibility: GridLinesVisibility.both,
        headerGridLinesVisibility: GridLinesVisibility.both,
        frozenColumnsCount: 1,
        allowFiltering: true,
        allowSorting: true,
        columnWidthMode: ColumnWidthMode.auto,
        headerRowHeight: 42,
        rowHeight: 36,
        columns: [
          GridColumn(
            columnName: 'cabang',
            allowSorting: false,
            allowFiltering: false,
            label: _headerCell('CABANG', color: Colors.indigo),
            width: 140,
          ),
          GridColumn(
            columnName: 'region',
            allowSorting: false,
            label: _headerCell('REGION', color: Colors.teal),
            width: 120,
          ),
          GridColumn(
            columnName: 'lastMonthMTD',
            allowFiltering: false,
            width: 80,
            label: _headerCell('MTD', color: Colors.purple),
          ),
          GridColumn(
            columnName: 'lastMonthYTD',
            allowFiltering: false,
            width: 80,
            label: _headerCell('YTD', color: Colors.purple),
          ),
          GridColumn(
            columnName: 'actualMTD',
            allowFiltering: false,
            width: 80,
            label: _headerCell('MTD', color: Colors.blue),
          ),
          GridColumn(
            columnName: 'actualYTD',
            allowFiltering: false,
            width: 80,
            label: _headerCell('YTD', color: Colors.blue),
          ),
          GridColumn(
            columnName: 'active',
            allowFiltering: false,
            width: 80,
            label: _headerCell('Active', color: Colors.green),
          ),
          GridColumn(
            columnName: 'nonActive',
            allowFiltering: false,
            width: 80,
            label: _headerCell('Non Active', color: Colors.green),
          ),
          GridColumn(
            columnName: 'target',
            allowFiltering: false,
            width: 80,
            label: _headerCell('Target', color: Colors.orange),
          ),
          GridColumn(
            columnName: 'diff',
            allowFiltering: false,
            width: 80,
            label: _headerCell('%', color: Colors.redAccent),
          ),
        ],
        stackedHeaderRows: _stackedHeaders(),
      ),
    );
  }

  // Header bertumpuk
  List<StackedHeaderRow> _stackedHeaders() {
    return [
      StackedHeaderRow(
        cells: [
          StackedHeaderCell(
            columnNames: ['lastMonthMTD', 'lastMonthYTD'],
            child: _stackedHeaderCell('LAST MONTH', color: Colors.purple),
          ),
          StackedHeaderCell(
            columnNames: ['actualMTD', 'actualYTD'],
            child: _stackedHeaderCell('ACTUAL', color: Colors.blue),
          ),
          StackedHeaderCell(
            columnNames: ['active', 'nonActive'],
            child: _stackedHeaderCell('STATUS MTD', color: Colors.green),
          ),
          StackedHeaderCell(
            columnNames: ['target', 'diff'],
            child: _stackedHeaderCell('TARGET', color: Colors.orange),
          ),
        ],
      ),
      StackedHeaderRow(
        cells: [
          StackedHeaderCell(
            columnNames: ['lastMonthMTD', 'lastMonthYTD'],
            child: _headerCell(headerLm.isNotEmpty ? headerLm : 'LM'),
          ),
          StackedHeaderCell(
            columnNames: ['actualMTD', 'actualYTD'],
            child: _headerCell(headerToday. isNotEmpty ? headerToday : 'Today'),
          ),
        ],
      ),
    ];
  }

  // UI utama
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Dashboard QRIS",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0288D1),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () async {
              await _fetchHeader();
              await _fetchData();
            },
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "Muamalat Merchant App",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Image.asset(
                              'assets/images/menu_qris.jpg',
                              height: 45,
                              fit: BoxFit.contain,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    _sectionTitle("Dashboard QRIS by Region"),
                    const SizedBox(height: 10),
                    _buildRegionGrid(),
                    const SizedBox(height: 24),
                    _sectionTitle("Dashboard QRIS by Cabang"),
                    const SizedBox(height: 10),
                    _buildCabangGrid(),
                  ],
                ),
              ),
    );
  }

  Widget _sectionTitle(String title) {
    return Container(
      padding: const EdgeInsets.all(8),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.blue[900],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ====================== DataSource ======================
class QrisDataSource extends DataGridSource {
  QrisDataSource(this.data, this.formatter, {this.isCabang = false}) {
    _rows =
        data.map<DataGridRow>((e) {
          return DataGridRow(
            cells: [
              if (isCabang) ...[
                //  Section CABANG: tampilkan CABANG dan REGION
                DataGridCell<String>(
                  columnName: 'cabang',
                  value: e['cabang']?.toString() ?? '-',
                ),
                DataGridCell<String>(
                  columnName: 'region',
                  value: e['region']?.toString() ?? '-',
                ),
              ] else
                //  Section REGION: tampilkan REGION saja
                DataGridCell<String>(
                  columnName: 'region',
                  value: e['region']?.toString() ?? '-',
                ),

              //  Kolom lainnya
              DataGridCell<double>(
                columnName: 'lastMonthMTD',
                value: double.tryParse(e['lastMonthMTD'].toString()) ?? 0,
              ),
              DataGridCell<double>(
                columnName: 'lastMonthYTD',
                value: double.tryParse(e['lastMonthYTD'].toString()) ?? 0,
              ),
              DataGridCell<double>(
                columnName: 'actualMTD',
                value: double.tryParse(e['actualMTD'].toString()) ?? 0,
              ),
              DataGridCell<double>(
                columnName: 'actualYTD',
                value: double.tryParse(e['actualYTD'].toString()) ?? 0,
              ),
              DataGridCell<int>(
                columnName: 'active',
                value: int.tryParse(e['active'].toString()) ?? 0,
              ),
              DataGridCell<int>(
                columnName: 'nonActive',
                value: int.tryParse(e['nonActive'].toString()) ?? 0,
              ),
              DataGridCell<double>(
                columnName: 'target',
                value: double.tryParse(e['target'].toString()) ?? 0,
              ),
              DataGridCell<double>(
                columnName: 'diff',
                value: double.tryParse(e['diff'].toString()) ?? 0,
              ),
            ],
          );
        }).toList();
  }

  final List<dynamic> data;
  final NumberFormat formatter;
  final bool isCabang;
  late List<DataGridRow> _rows;

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      color: Colors.white,
      cells:
          row.getCells().map<Widget>((cell) {
            Color textColor = Colors.black;

            //  Warnai kolom 'diff'
            if (cell.columnName == 'diff' && (cell.value is num)) {
              textColor = (cell.value as num) < 0 ? Colors.red : Colors.green;
            }

            //  Alignment kiri untuk kolom teks
            Alignment alignment =
                (cell.columnName == 'region' || cell.columnName == 'cabang')
                    ? Alignment.centerLeft
                    : Alignment.center;

            return Container(
              alignment: alignment,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                cell.value is num
                    ? formatter.format(cell.value)
                    : cell.value.toString(),
                style: TextStyle(fontSize: 12, color: textColor),
              ),
            );
          }).toList(),
    );
  }
}
