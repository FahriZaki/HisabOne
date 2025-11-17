import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class DashboardBookconPage extends StatefulWidget {
  final int level;
  final String region;
  final String cabang;

  const DashboardBookconPage({
    super.key,
    required this.level,
    required this.region,
    required this.cabang,
  });

  @override
  State<DashboardBookconPage> createState() => _DashboardBookconPageState();
}

class _DashboardBookconPageState extends State<DashboardBookconPage> {
  late BookingConsumerDataSource regionSource;
  late BookingConsumerDataSource cabangSource;

  String headerYesterday = "Yesterday";
  String headerToday = "Today";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    regionSource = BookingConsumerDataSource([], showCabang: false);
    cabangSource = BookingConsumerDataSource([], showCabang: true);
    fetchHeaderDate();
    fetchRegionData();
    fetchCabangData();
  }

  // ======================================================
  // Fetch header date (Today & Yesterday)
  // ======================================================
  Future<void> fetchHeaderDate() async {
    try {
      final url = Uri.parse(
        "http://103.59.95.71/api_performance/dashboard_bookingcon.php?level=${widget.level}&region=${widget.region}&cabang=${widget.cabang}",
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["status"] == "success") {
          setState(() {
            headerToday = data["header"]["today"] ?? "Today";
            headerYesterday = data["header"]["yesterday"] ?? "Yesterday";
            isLoading = false;
          });
        }
      } else {
        throw Exception("Failed to load header date");
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("Error fetching date: $e");
    }
  }

  // ======================================================
  // Fetch data REGION
  // ======================================================
  Future<void> fetchRegionData() async {
    try {
      final url = Uri.parse(
        "http://103.59.95.71/api_performance/dashboard_bookingcon.php?level=${widget.level}&region=${widget.region}&cabang=${widget.cabang}",
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData["status"] == "success") {
          List<dynamic> data = jsonData["data"];
          final regionList =
              data.map((item) {
                return BookingConsumerModel(
                  region: item["code"],
                  oct10: (item["conb_ld"] ?? 0).toDouble(),
                  oct13: (item["conb_today"] ?? 0).toDouble(),
                  mtd: (item["conb_mtd"] ?? 0).toDouble(),
                  ytd: (item["conb_ytd"] ?? 0).toDouble(),
                  soleh: (item["conb_soleh"] ?? 0).toDouble(),
                  prohajj: (item["conb_prohajj"] ?? 0).toDouble(),
                  mg: (item["conb_mg"] ?? 0).toDouble(),
                  kpr: (item["conb_kpr"] ?? 0).toDouble(),
                );
              }).toList();

          setState(() {
            regionSource = BookingConsumerDataSource(
              regionList,
              showCabang: false,
            );
          });
        }
      }
    } catch (e) {
      debugPrint("⚠️ Error fetch region data: $e");
    }
  }

  Future<void> fetchCabangData() async {
    final url = Uri.parse(
      "http://103.59.95.71/api_performance/dashboard_bookingcon_cabang.php?level=${widget.level}&region=${widget.region}&cabang=${widget.cabang}",
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      if (jsonData["status"] == "success") {
        List<dynamic> data = jsonData["data"];
        final cabangList =
            data.map((item) {
              return BookingConsumerModel(
                cabang: item["nama_cabang"],
                region: item["region"],
                oct10: (item["ld"] ?? 0).toDouble(),
                oct13: (item["today"] ?? 0).toDouble(),
                mtd: (item["mtd"] ?? 0).toDouble(),
                ytd: (item["ytd"] ?? 0).toDouble(),
                soleh: (item["soleh"] ?? 0).toDouble(),
                prohajj: (item["prohajj"] ?? 0).toDouble(),
                mg: (item["mg"] ?? 0).toDouble(),
                kpr: (item["kpr"] ?? 0).toDouble(),
              );
            }).toList();

        setState(() {
          cabangSource = BookingConsumerDataSource(
            cabangList,
            showCabang: true,
          );
        });
      }
    }
  }

  // ======================================================
  // Fungsi REFRESH Data
  // ======================================================
  Future<void> _fetchData() async {
    setState(() {
      isLoading = true;
    });

    await Future.wait([
      fetchHeaderDate(),
      fetchRegionData(),
      fetchCabangData(),
    ]);

    setState(() {
      isLoading = false;
    });
  }

  // ======================================================
  // UI
  // ======================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Dashboard Booking Consumer",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              // Panggil fungsi refresh data
              _fetchData();
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
                    _sectionTitle("Dashboard Booking Consumer by Region"),
                    const SizedBox(height: 10),
                    _buildRegionTable(
                      regionSource,
                      headerYesterday,
                      headerToday,
                    ),
                    const SizedBox(height: 30),
                    _sectionTitle("Dashboard Booking Consumer by Cabang"),
                    const SizedBox(height: 10),
                    _buildCabangTable(
                      cabangSource,
                      headerYesterday,
                      headerToday,
                    ),
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
        borderRadius: BorderRadius.circular(6),
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

// ======================================================
// MODEL
// ======================================================
class BookingConsumerModel {
  final String region;
  final String? cabang;
  final double oct10, oct13;
  final double mtd, ytd;
  final double kpr, mg, soleh, prohajj;

  BookingConsumerModel({
    required this.region,
    this.cabang,
    required this.oct10,
    required this.oct13,
    required this.mtd,
    required this.ytd,
    required this.kpr,
    required this.mg,
    required this.soleh,
    required this.prohajj,
  });
}

// ======================================================
// DATASOURCE
// ======================================================
class BookingConsumerDataSource extends DataGridSource {
  final List<BookingConsumerModel> data;
  final bool showCabang;

  BookingConsumerDataSource(this.data, {this.showCabang = false}) {
    buildDataGridRows();
  }

  late List<DataGridRow> dataGridRows;

  void buildDataGridRows() {
    dataGridRows =
        data.map<DataGridRow>((item) {
          final cells = <DataGridCell>[];

          if (showCabang) {
            // Urutan untuk table CABANG
            cells.add(
              DataGridCell<String>(columnName: 'cabang', value: item.cabang),
            );
            cells.add(
              DataGridCell<String>(columnName: 'region', value: item.region),
            );
          } else {
            // Urutan untuk table REGION
            cells.add(
              DataGridCell<String>(columnName: 'region', value: item.region),
            );
          }

          // Kolom angka tetap sama
          cells.addAll([
            DataGridCell<double>(columnName: 'oct10', value: item.oct10),
            DataGridCell<double>(columnName: 'oct13', value: item.oct13),
            DataGridCell<double>(columnName: 'mtd', value: item.mtd),
            DataGridCell<double>(columnName: 'ytd', value: item.ytd),
            DataGridCell<double>(columnName: 'soleh', value: item.soleh),
            DataGridCell<double>(columnName: 'prohajj', value: item.prohajj),
            DataGridCell<double>(columnName: 'mg', value: item.mg),
            DataGridCell<double>(columnName: 'kpr', value: item.kpr),
          ]);

          return DataGridRow(cells: cells);
        }).toList();
  }

  @override
  List<DataGridRow> get rows => dataGridRows;
  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final NumberFormat currencyFormat = NumberFormat.decimalPattern('id');
    final rowIndex = dataGridRows.indexOf(row);

    return DataGridRowAdapter(
      color: rowIndex.isEven ? Colors.grey[100] : Colors.white,
      cells:
          row.getCells().map<Widget>((cell) {
            final value = cell.value;
            String displayValue;

            if (value is double) {
              displayValue = currencyFormat.format(value);
            } else {
              displayValue = value?.toString() ?? '';
            }

            return Container(
              alignment:
                  (cell.columnName == 'region' || cell.columnName == 'cabang')
                      ? Alignment.centerLeft
                      : Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Text(displayValue, style: const TextStyle(fontSize: 11)),
            );
          }).toList(),
    );
  }
}

// ======================================================
// HEADER WIDGETS 
// ======================================================
Widget _headerBookingCell(String text, {Color color = Colors.brown}) {
  return Container(
    alignment: Alignment.center,
    padding: const EdgeInsets.all(8),
    color: color,
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

Widget _stackedHeaderBookingCell(String text, {Color color = Colors.grey}) {
  return Container(
    alignment: Alignment.center,
    padding: const EdgeInsets.all(6),
    color: color,
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

// ======================================================
// TABLE BUILDER KHUSUS REGION
// ======================================================
Widget _buildRegionTable(
  BookingConsumerDataSource source,
  String headerYesterday,
  String headerToday,
) {
  return Padding(
    padding: const EdgeInsets.only(right: 30.0),
    child: SizedBox(
      height: 350,
      child: SfDataGrid(
        source: source,
        gridLinesVisibility: GridLinesVisibility.both,
        headerGridLinesVisibility: GridLinesVisibility.both,
        frozenColumnsCount: 1,
        allowSorting: true,
        headerRowHeight: 42,
        rowHeight: 35,
        columnWidthMode: ColumnWidthMode.auto,
        columns: [
          GridColumn(
            columnName: 'region',
            width: 130,
            allowSorting: false,
            label: _headerBookingCell('REGION'),
          ),
          GridColumn(
            columnName: 'oct10',
            width: 102,
            label: _headerBookingCell(headerYesterday, color: Colors.orange),
          ),
          GridColumn(
            columnName: 'oct13',
            width: 102,
            label: _headerBookingCell(headerToday, color: Colors.green),
          ),
          GridColumn(
            columnName: 'mtd',
            width: 104,
            label: _headerBookingCell('MTD', color: Colors.blue[900]!),
          ),
          GridColumn(
            columnName: 'ytd',
            width: 104,
            label: _headerBookingCell('YTD', color: Colors.blue[900]!),
          ),
          GridColumn(
            columnName: 'soleh',
            label: _headerBookingCell('Soleh', color: Colors.brown),
          ),
          GridColumn(
            columnName: 'prohajj',
            label: _headerBookingCell('Prohajj', color: Colors.brown),
          ),
          GridColumn(
            columnName: 'mg',
            label: _headerBookingCell('MG', color: Colors.brown),
          ),
          GridColumn(
            columnName: 'kpr',
            label: _headerBookingCell('KPR', color: Colors.brown),
          ),
        ],

        stackedHeaderRows: [
          StackedHeaderRow(
            cells: [
              StackedHeaderCell(
                columnNames: ['oct10', 'oct13'],
                child: _stackedHeaderBookingCell(
                  'Last Day',
                  color: Colors.orange,
                ),
              ),
              StackedHeaderCell(
                columnNames: ['soleh', 'prohajj', 'mg', 'kpr'],
                child: _stackedHeaderBookingCell(
                  'MTD (IDR Mio)',
                  color: Colors.brown,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

// ======================================================
// TABLE BUILDER KHUSUS CABANG
// ======================================================
Widget _buildCabangTable(
  BookingConsumerDataSource source,
  String headerYesterday,
  String headerToday,
) {
  return Padding(
    padding: const EdgeInsets.only(right: 30.0),
    child: SizedBox(
      height: 350,
      child: SfDataGrid(
        source: source,
        gridLinesVisibility: GridLinesVisibility.both,
        headerGridLinesVisibility: GridLinesVisibility.both,
        frozenColumnsCount: 1,
        allowSorting: true,
        allowFiltering: true,
        headerRowHeight: 42,
        rowHeight: 35,
        columnWidthMode: ColumnWidthMode.auto,
        columns: [
          GridColumn(
            columnName: 'cabang',
            allowSorting: false,
            allowFiltering: false,
            width: 130,
            label: _headerBookingCell('CABANG'),
          ),
          GridColumn(
            columnName: 'region',
            allowSorting: false,
            width: 130,
            label: _headerBookingCell('REGION'),
          ),
          GridColumn(
            columnName: 'oct10',
            allowFiltering: false,
            width: 102,
            label: _headerBookingCell(headerYesterday, color: Colors.orange),
          ),
          GridColumn(
            columnName: 'oct13',
            allowFiltering: false,
            width: 102,
            label: _headerBookingCell(headerToday, color: Colors.green),
          ),
          GridColumn(
            columnName: 'mtd',
            allowFiltering: false,
            width: 104,
            label: _headerBookingCell('MTD', color: Colors.blue[900]!),
          ),
          GridColumn(
            columnName: 'ytd',
            allowFiltering: false,
            width: 104,
            label: _headerBookingCell('YTD', color: Colors.blue[900]!),
          ),
          GridColumn(
            columnName: 'soleh',
            allowFiltering: false,
            label: _headerBookingCell('Soleh', color: Colors.brown),
          ),
          GridColumn(
            columnName: 'prohajj',
            allowFiltering: false,
            label: _headerBookingCell('Prohajj', color: Colors.brown),
          ),
          GridColumn(
            columnName: 'mg',
            allowFiltering: false,
            label: _headerBookingCell('MG', color: Colors.brown),
          ),
          GridColumn(
            columnName: 'kpr',
            allowFiltering: false,
            label: _headerBookingCell('KPR', color: Colors.brown),
          ),
        ],

        stackedHeaderRows: [
          StackedHeaderRow(
            cells: [
              StackedHeaderCell(
                columnNames: ['oct10', 'oct13'],
                child: _stackedHeaderBookingCell(
                  'Last Day',
                  color: Colors.orange,
                ),
              ),
              StackedHeaderCell(
                columnNames: ['soleh', 'prohajj', 'mg', 'kpr'],
                child: _stackedHeaderBookingCell(
                  'MTD (IDR Mio)',
                  color: Colors.brown,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
