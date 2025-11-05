import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class DashboardRegionPage extends StatefulWidget {
  const DashboardRegionPage({super.key});

  @override
  State<DashboardRegionPage> createState() => _DashboardRegionPageState();
}

class _DashboardRegionPageState extends State<DashboardRegionPage> {
  bool isLoading = true;
  List<dynamic> regionData = [];
  int level = 0;
  String region = "";

  late RegionDataSource _regionDataSource = RegionDataSource(
    [],
    NumberFormat.decimalPattern('id'),
  );

  final NumberFormat numberFormat = NumberFormat.decimalPattern('id');

  @override
  void initState() {
    super.initState();
    _loadUserAndFetchData();
  }

  Future<void> _loadUserAndFetchData() async {
    final prefs = await SharedPreferences.getInstance();
    level = prefs.getInt("level") ?? 0;
    region = prefs.getString("region") ?? "";

    if (level == 3 || level == 4) {
      await fetchRegionData();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchRegionData() async {
    const url = "http://103.59.95.71/api_performance/dashboard_branch.php";

    try {
      final body = {"level": level.toString()};
      if (level == 3) {
        body["region"] = region;
      }

      final response = await http.post(Uri.parse(url), body: body);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse["status"] == "success") {
          setState(() {
            regionData = jsonResponse["data"];
            _regionDataSource = RegionDataSource(regionData, numberFormat);
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(jsonResponse["message"])));
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal mengambil data: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (level != 3 && level != 4) {
      return const Scaffold(
        body: Center(child: Text("Anda tidak memiliki akses ke halaman ini")),
      );
    }

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
          "Plan Today Per Cabang",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: 1.1,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: "Refresh Data",
            onPressed: () async {
              await fetchRegionData();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child:
            regionData.isEmpty
                ? const Center(child: Text("Tidak ada data"))
                : SfDataGrid(
                  source: _regionDataSource,
                  allowSorting: true,
                  allowFiltering: true,
                  allowTriStateSorting: true,
                  columnWidthMode: ColumnWidthMode.auto,
                  gridLinesVisibility: GridLinesVisibility.both,
                  headerGridLinesVisibility: GridLinesVisibility.both,
                  frozenColumnsCount: 1,
                  columns: [
                    GridColumn(
                      columnName: 'NAMA_KANTOR',
                      width: 120,
                      allowSorting: false,
                      allowFiltering: true,
                      label: _headerCell(
                        "Cabang",
                        alignLeft: true,
                        color: null,
                      ), // transparan
                    ),
                    GridColumn(
                      columnName: 'FUNDING_GROWTH',
                      allowFiltering: false,
                      width: 100,
                      label: _headerCell(
                        "Funding Growth Yesterday",
                        color: const Color.fromARGB(255, 163, 211, 250),
                      ),
                    ),
                    GridColumn(
                      columnName: 'FC_FUNDING_GROWTH',
                      allowFiltering: false,
                      width: 100,
                      label: _headerCell(
                        "FC Funding Growth",
                        color: const Color.fromARGB(255, 163, 211, 250),
                      ),
                    ),
                    GridColumn(
                      columnName: 'NTB_CA_NOC',
                      width: 100,
                      allowFiltering: false,
                      label: _headerCell(
                        "NTB CA NOC Yesterday",
                        color: const Color.fromARGB(255, 254, 210, 144),
                      ),
                    ),
                    GridColumn(
                      columnName: 'FC_NTB_CA_NOC',
                      allowFiltering: false,
                      width: 100,
                      label: _headerCell(
                        "FC NTB CA NOC",
                        color: const Color.fromARGB(255, 254, 210, 144),
                      ),
                    ),
                    GridColumn(
                      columnName: 'NTB_CA_OS',
                      width: 100,
                      allowFiltering: false,
                      label: _headerCell(
                        "NTB CA OS Yesterday",
                        color: const Color.fromARGB(255, 254, 210, 144),
                      ),
                    ),
                    GridColumn(
                      columnName: 'FC_NTB_CA_OS',
                      allowFiltering: false,
                      width: 100,
                      label: _headerCell(
                        "FC NTB CA OS",
                        color: const Color.fromARGB(255, 254, 210, 144),
                      ),
                    ),
                    GridColumn(
                      columnName: 'NTB_PRIORITY_NOC',
                      allowFiltering: false,
                      width: 130,
                      label: _headerCell(
                        "NTB Priority NOC Yesterday",
                        color: const Color.fromARGB(255, 252, 150, 142),
                      ),
                    ),
                    GridColumn(
                      columnName: 'FC_NTB_PRIO_NOC',
                      allowFiltering: false,
                      width: 100,
                      label: _headerCell(
                        "FC NTB Priority NOC",
                        color: const Color.fromARGB(255, 252, 150, 142),
                      ),
                    ),
                    GridColumn(
                      columnName: 'NTB_PRIORITY_OS',
                      allowFiltering: false,
                      width: 130,
                      label: _headerCell(
                        "NTB Priority OS Yesterday",
                        color: const Color.fromARGB(255, 252, 150, 142),
                      ),
                    ),
                    GridColumn(
                      columnName: 'FC_NTB_PRIO_OS',
                      allowFiltering: false,
                      width: 100,
                      label: _headerCell(
                        "FC NTB Priority OS",
                        color: const Color.fromARGB(255, 252, 150, 142),
                      ),
                    ),
                    GridColumn(
                      columnName: 'BOOKING_NOC',
                      width: 100,
                      allowFiltering: false,
                      label: _headerCell(
                        "Booking NOC Yesterday",
                        color: const Color.fromARGB(255, 237, 144, 254),
                      ),
                    ),
                    GridColumn(
                      columnName: 'FC_BOOK_NOC',
                      width: 100,
                      allowFiltering: false,
                      label: _headerCell(
                        "FC Booking NOC",
                        color: const Color.fromARGB(255, 237, 144, 254),
                      ),
                    ),
                    GridColumn(
                      columnName: 'BOOKING_OS',
                      width: 100,
                      allowFiltering: false,
                      label: _headerCell(
                        "Booking OS Yesterday",
                        color: const Color.fromARGB(255, 237, 144, 254),
                      ),
                    ),
                    GridColumn(
                      columnName: 'FC_BOOK_OS',
                      allowFiltering: false,
                      width: 100,
                      label: _headerCell(
                        "FC Booking OS",
                        color: const Color.fromARGB(255, 237, 144, 254),
                      ),
                    ),
                    GridColumn(
                      columnName: 'SUBMISSION_NOC',
                      width: 110,
                      allowFiltering: false,
                      label: _headerCell(
                        "Submission NOC Yesterday",
                        color: const Color.fromARGB(255, 116, 152, 124),
                      ),
                    ),
                    GridColumn(
                      columnName: 'FC_SUBMIS_NOC',
                      allowFiltering: false,
                      width: 110,
                      label: _headerCell(
                        "FC Submission NOC",
                        color: const Color.fromARGB(255, 116, 152, 124),
                      ),
                    ),
                    GridColumn(
                      columnName: 'SUBMISSION_OS',
                      width: 130,
                      allowFiltering: false,
                      label: _headerCell(
                        "Submission OS Yesterday",
                        color: const Color.fromARGB(255, 116, 152, 124),
                      ),
                    ),
                    GridColumn(
                      columnName: 'FC_SUBMIS_OS',
                      width: 120,
                      allowFiltering: false,
                      label: _headerCell(
                        "FC Submission OS",
                        color: const Color.fromARGB(255, 116, 152, 124),
                      ),
                    ),
                    GridColumn(
                      columnName: 'BOOKING_SLI',
                      width: 130,
                      allowFiltering: false,
                      label: _headerCell(
                        "Booking SLI Yesterday",
                        color: const Color.fromARGB(255, 94, 235, 221),
                      ),
                    ),
                    GridColumn(
                      columnName: 'FC_BOOK_SLI',
                      allowFiltering: false,
                      width: 100,
                      label: _headerCell(
                        "FC Booking SLI",
                        color: const Color.fromARGB(255, 94, 235, 221),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  /// Header cell dengan warna background custom
  Widget _headerCell(String text, {bool alignLeft = false, Color? color}) {
    return Container(
      alignment: alignLeft ? Alignment.centerLeft : Alignment.center,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color, // null = transparan
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
          color: (color == null) ? Colors.black : Colors.white,
        ),
        textAlign: TextAlign.center,
        softWrap: true, //  biar teks bisa ke bawah
        maxLines: 3, //  maksimal 3 baris biar rapi
        overflow: TextOverflow.visible, //  biar gak jadi “...”
      ),
    );
  }
}

class RegionDataSource extends DataGridSource {
  RegionDataSource(this.data, this.formatter) {
    _rows =
        data.map<DataGridRow>((row) {
          return DataGridRow(
            cells: [
              DataGridCell<String>(
                columnName: 'NAMA_KANTOR',
                value: row['NAMA_KANTOR'],
              ),
              DataGridCell<double>(
                columnName: 'FUNDING_GROWTH',
                value: (row['FUNDING_GROWTH'] ?? 0).toDouble(),
              ),
              DataGridCell<double>(
                columnName: 'FC_FUNDING_GROWTH',
                value: (row['FC_FUNDING_GROWTH'] ?? 0).toDouble(),
              ),
              DataGridCell<double>(
                columnName: 'NTB_CA_NOC',
                value: (row['NTB_CA_NOC'] ?? 0).toDouble(),
              ),
              DataGridCell<double>(
                columnName: 'FC_NTB_CA_NOC',
                value: (row['FC_NTB_CA_NOC'] ?? 0).toDouble(),
              ),
              DataGridCell<double>(
                columnName: 'NTB_CA_OS',
                value: (row['NTB_CA_OS'] ?? 0).toDouble(),
              ),
              DataGridCell<double>(
                columnName: 'FC_NTB_CA_OS',
                value: (row['FC_NTB_CA_OS'] ?? 0).toDouble(),
              ),
              DataGridCell<double>(
                columnName: 'NTB_PRIORITY_NOC',
                value: (row['NTB_PRIORITY_NOC'] ?? 0).toDouble(),
              ),
              DataGridCell<double>(
                columnName: 'FC_NTB_PRIO_NOC',
                value: (row['FC_NTB_PRIO_NOC'] ?? 0).toDouble(),
              ),
              DataGridCell<double>(
                columnName: 'NTB_PRIORITY_OS',
                value: (row['NTB_PRIORITY_OS'] ?? 0).toDouble(),
              ),
              DataGridCell<double>(
                columnName: 'FC_NTB_PRIO_OS',
                value: (row['FC_NTB_PRIO_OS'] ?? 0).toDouble(),
              ),
              DataGridCell<double>(
                columnName: 'BOOKING_NOC',
                value: (row['BOOKING_NOC'] ?? 0).toDouble(),
              ),
              DataGridCell<double>(
                columnName: 'FC_BOOK_NOC',
                value: (row['FC_BOOK_NOC'] ?? 0).toDouble(),
              ),
              DataGridCell<double>(
                columnName: 'BOOKING_OS',
                value: (row['BOOKING_OS'] ?? 0).toDouble(),
              ),
              DataGridCell<double>(
                columnName: 'FC_BOOK_OS',
                value: (row['FC_BOOK_OS'] ?? 0).toDouble(),
              ),
              DataGridCell<double>(
                columnName: 'SUBMISSION_NOC',
                value: (row['SUBMISSION_NOC'] ?? 0).toDouble(),
              ),
              DataGridCell<double>(
                columnName: 'FC_SUBMIS_NOC',
                value: (row['FC_SUBMIS_NOC'] ?? 0).toDouble(),
              ),
              DataGridCell<double>(
                columnName: 'SUBMISSION_OS',
                value: (row['SUBMISSION_OS'] ?? 0).toDouble(),
              ),
              DataGridCell<double>(
                columnName: 'FC_SUBMIS_OS',
                value: (row['FC_SUBMIS_OS'] ?? 0).toDouble(),
              ),
              DataGridCell<double>(
                columnName: 'BOOKING_SLI',
                value: (row['BOOKING_SLI'] ?? 0).toDouble(),
              ),
              DataGridCell<double>(
                columnName: 'FC_BOOK_SLI',
                value: (row['FC_BOOK_SLI'] ?? 0).toDouble(),
              ),
            ],
          );
        }).toList();
  }

  final List<dynamic> data;
  final NumberFormat formatter;
  late List<DataGridRow> _rows;

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells:
          row.getCells().map((cell) {
            final value = cell.value;
            final display =
                value is double
                    ? formatter.format(double.parse(value.toStringAsFixed(2)))
                    : (value?.toString() ?? '-');

            Alignment align = Alignment.centerRight;

            return Container(
              alignment: align,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Text(
                display,
                style: TextStyle(
                  fontSize: 11,
                  color:
                      (value is double && value < 0)
                          ? Colors.red
                          : Colors.black,
                  fontWeight:
                      (value is double && value < 0)
                          ? FontWeight.bold
                          : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
    );
  }
}
