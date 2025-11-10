import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class PipelinemtdPage extends StatefulWidget {
  final int level;
  final String region;
  final String cabang;

  const PipelinemtdPage({
    super.key,
    required this.level,
    required this.region,
    required this.cabang,
  });

  @override
  State<PipelinemtdPage> createState() => _PipelinemtdPageState();
}

class _PipelinemtdPageState extends State<PipelinemtdPage> {
  bool isLoading = true;
  List<dynamic> regionData = [];
  List<dynamic> cabangData = [];

  final NumberFormat formatter = NumberFormat("#,###", "id_ID");

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => isLoading = true);

    try {
      final String region = widget.region;
      final String cabang = widget.cabang;
      final int level = widget.level;

      Uri regionUrl = Uri.parse(
        "http://103.59.95.71/api_performance/pipeline_region.php?region=${Uri.encodeComponent(region)}&level=$level",
      );

      Uri cabangUrl = Uri.parse(
        "http://103.59.95.71/api_performance/pipeline_cabang.php?cabang=${Uri.encodeComponent(cabang)}&region=${Uri.encodeComponent(region)}&level=$level",
      );

      final regionRes = await http.get(regionUrl);
      final cabangRes = await http.get(cabangUrl);

      if (regionRes.statusCode == 200 && cabangRes.statusCode == 200) {
        final regionJson = jsonDecode(regionRes.body);
        final cabangJson = jsonDecode(cabangRes.body);

        if (regionJson['status'] == 'success') {
          regionData = regionJson['data'];
        }
        if (cabangJson['status'] == 'success') {
          cabangData = cabangJson['data'];
        }
      }
    } catch (e) {
      debugPrint("Error fetch pipeline: $e");
    }

    setState(() => isLoading = false);
  }

  Widget _buildDataGrid(List<dynamic> data, {bool isRegion = true}) {
    if (data.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            "No Data",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      );
    }

    const double rowHeight = 49;
    const double headerHeight = 56;
    const double minHeight = 200;
    const double maxHeight = 500;

    double totalHeight = headerHeight + (data.length * rowHeight);
    totalHeight += 10;
    double gridHeight = totalHeight.clamp(minHeight, maxHeight);

    return SizedBox(
      height: gridHeight,
      child: SfDataGrid(
        source: PipelineDataSource(data, formatter, isRegion: isRegion),
        columnWidthMode: ColumnWidthMode.fitByCellValue,
        gridLinesVisibility: GridLinesVisibility.both,
        headerGridLinesVisibility: GridLinesVisibility.both,
        frozenColumnsCount: 1,
        allowSorting: true,
        allowFiltering: true,
        allowTriStateSorting: true,

        columns: [
          if (isRegion)
            GridColumn(
              columnName: 'REGION',
              width: 90,
              allowSorting: false,
              allowFiltering: false,
              label: _headerCell("Region", alignLeft: false),
            )
          else ...[
            GridColumn(
              columnName: 'NAMA_KANTOR',
              width: 110,
              allowSorting: false,
              allowFiltering: false,
              label: _headerCell("Cabang", alignLeft: false),
            ),
            GridColumn(
              columnName: 'REGION',
              width: 100,
              allowSorting: false,
              label: _headerCell("Region", alignLeft: false),
            ),
          ],

          //  Funding dibuat auto width
          GridColumn(
            columnName: 'FUNDING_IN',
            allowFiltering: false,
            columnWidthMode: ColumnWidthMode.auto,
            label: _headerCell("In"),
          ),
          GridColumn(
            columnName: 'FUNDING_OUT',
            allowFiltering: false,
            columnWidthMode: ColumnWidthMode.auto,
            label: _headerCell("Out"),
          ),
          GridColumn(
            columnName: 'FUNDING_NET',
            allowFiltering: false,
            columnWidthMode: ColumnWidthMode.auto,
            label: _headerCell("NET"),
          ),
          GridColumn(
            columnName: 'CA_NOC',
            allowFiltering: false,
            width: 80,
            label: _headerCell("CIF"),
          ),
          GridColumn(
            columnName: 'CA_OS',
            allowFiltering: false,
            width: 100,
            label: _headerCell("Vol"),
          ),
          GridColumn(
            columnName: 'PRIO_NOC',
            allowFiltering: false,
            width: 80,
            label: _headerCell("CIF"),
          ),
          GridColumn(
            columnName: 'PRIO_OS',
            allowFiltering: false,
            width: 100,
            label: _headerCell("Vol"),
          ),
          // --- Booking Consumer ---
          GridColumn(
            columnName: 'BOOK_NOC',
            allowFiltering: false,
            width: 80,
            label: _headerCell("NOA"),
          ),
          GridColumn(
            columnName: 'BOOK_OS',
            allowFiltering: false,
            width: 100,
            label: _headerCell("Vol"),
          ),

          // --- Booking KPR ---
          GridColumn(
            columnName: 'BOOK_KPR_NOC',
            allowFiltering: false,
            width: 80,
            label: _headerCell("NOA"),
          ),
          GridColumn(
            columnName: 'BOOK_KPR_OS',
            allowFiltering: false,
            width: 100,
            label: _headerCell("Vol"),
          ),

          // --- Booking MG ---
          GridColumn(
            columnName: 'BOOK_MG_NOC',
            allowFiltering: false,
            width: 80,
            label: _headerCell("NOA"),
          ),
          GridColumn(
            columnName: 'BOOK_MG_OS',
            allowFiltering: false,
            width: 100,
            label: _headerCell("Vol"),
          ),

          // --- Booking Soleh ---
          GridColumn(
            columnName: 'BOOK_SOLEH_NOC',
            allowFiltering: false,
            width: 80,
            label: _headerCell("NOA"),
          ),
          GridColumn(
            columnName: 'BOOK_SOLEH_OS',
            allowFiltering: false,
            width: 100,
            label: _headerCell("Vol"),
          ),

          // --- Booking Prohaj ---
          GridColumn(
            columnName: 'BOOK_PROHAJ_NOC',
            allowFiltering: false,
            width: 80,
            label: _headerCell("NOA"),
          ),
          GridColumn(
            columnName: 'BOOK_PROHAJ_OS',
            allowFiltering: false,
            width: 100,
            label: _headerCell("Vol"),
          ),

          GridColumn(
            columnName: 'SUBMISSION_NOC',
            allowFiltering: false,
            width: 80,
            label: _headerCell("NOA"),
          ),
          GridColumn(
            columnName: 'SUBMISSION_OS',
            allowFiltering: false,
            width: 100,
            label: _headerCell("Vol"),
          ),
          GridColumn(
            columnName: 'BOOKINGSLI_OS',
            allowFiltering: false,
            width: 100,
            label: _headerCell("Vol"),
          ),
        ],
        // Stacked header
        stackedHeaderRows: [
          StackedHeaderRow(
            cells: [
              StackedHeaderCell(
                columnNames: ['FUNDING_IN', 'FUNDING_OUT', 'FUNDING_NET'],
                child: _stackedHeaderCell("Funding"),
              ),
              StackedHeaderCell(
                columnNames: ['CA_NOC', 'CA_OS'],
                child: _stackedHeaderCell("NTB CA"),
              ),
              StackedHeaderCell(
                columnNames: ['PRIO_NOC', 'PRIO_OS'],
                child: _stackedHeaderCell("NTB Priority"),
              ),
              StackedHeaderCell(
                columnNames: ['BOOK_NOC', 'BOOK_OS'],
                child: _stackedHeaderCell("Booking Consumer"),
              ),
              StackedHeaderCell(
                columnNames: ['BOOK_KPR_NOC', 'BOOK_KPR_OS'],
                child: _stackedHeaderCell("Booking KPR"),
              ),
              StackedHeaderCell(
                columnNames: ['BOOK_MG_NOC', 'BOOK_MG_OS'],
                child: _stackedHeaderCell("Booking MG"),
              ),
              StackedHeaderCell(
                columnNames: ['BOOK_SOLEH_NOC', 'BOOK_SOLEH_OS'],
                child: _stackedHeaderCell("Booking Soleh"),
              ),
              StackedHeaderCell(
                columnNames: ['BOOK_PROHAJ_NOC', 'BOOK_PROHAJ_OS'],
                child: _stackedHeaderCell("Booking Prohajj"),
              ),
              StackedHeaderCell(
                columnNames: ['SUBMISSION_NOC', 'SUBMISSION_OS'],
                child: _stackedHeaderCell("Submission Consumer"),
              ),
              StackedHeaderCell(
                columnNames: ['BOOKINGSLI_OS'],
                child: _stackedHeaderCell("Booking SLI"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerCell(String text, {bool alignLeft = false}) {
    return Container(
      padding: const EdgeInsets.all(8),
      alignment: alignLeft ? Alignment.centerLeft : Alignment.center,
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
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
        title: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: 1),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOut,
          builder:
              (context, value, child) => Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, (1 - value) * -10),
                  child: child,
                ),
              ),
          child: Text(
            "Plan (${widget.region}) MTD",
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
              color: Colors.white,
            ),
          ),
        ),

        // Tambahkan actions
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: "Refresh Data",
            onPressed: () async {
              // panggil fungsi untuk ambil data terbaru
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
                    Container(
                      width: double.infinity, // full lebar
                      decoration: BoxDecoration(
                        color: Colors.blue[900], // biru gelap
                        borderRadius: BorderRadius.circular(
                          8,
                        ), // rounded optional
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Text(
                        "Data by Region",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, 
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildDataGrid(regionData, isRegion: true),
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity, // full lebar
                      decoration: BoxDecoration(
                        color: Colors.blue[900], // biru gelap
                        borderRadius: BorderRadius.circular(
                          8,
                        ), // rounded optional
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Text(
                        "Data by Cabang",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, 
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildDataGrid(cabangData, isRegion: false),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
    );
  }

  Widget _stackedHeaderCell(String title) {
    final bgColor = _getHeaderColors(title);
    return Container(
      color: bgColor,
      padding: const EdgeInsets.symmetric(vertical: 6),
      alignment: Alignment.center,
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
          color: Colors.black,
        ),
      ),
    );
  }

  Color? _getHeaderColors(String columnName) {
    final s = columnName.toUpperCase();

    if (s.contains("FUNDING")) {
      return const Color(0xFFA3D3FA); //  biru muda
    }

    if (s.contains("NTB CA") || s.contains("NTB_CA")) {
      return const Color(0xFFFED290); //  oranye
    }

    if (s.contains("NTB PRIORITY") ||
        s.contains("NTB_PRIORITY") ||
        s.contains("FC_NTB_PRIO")) {
      return const Color(0xFFF8968E); //  merah muda
    }

    if ((s.contains("BOOK") && !s.contains("SLI")) ||
        (s.contains("FC_BOOK") && !s.contains("SLI"))) {
      return const Color(0xFFED90FE); //  ungu
    }

    if (s.contains("SUBMIS")) {
      return const Color(0xFF74987C); //  hijau lembut
    }

    if (s.contains("SLI") || s.contains("FC_BOOK_SLI")) {
      return const Color(0xFF5EEBDD); //  toska
    }

    return const Color(0xFFE0E0E0); //  abu default
  }
}

class PipelineDataSource extends DataGridSource {
  PipelineDataSource(this.data, this.formatter, {this.isRegion = true}) {
    _rows =
        data.map<DataGridRow>((row) {
          final cells = <DataGridCell>[];

          // Kolom pertama (Region / Cabang + Region)
          if (isRegion) {
            cells.add(
              DataGridCell<String>(
                columnName: 'REGION',
                value: row['REGION']?.toString() ?? '-',
              ),
            );
          } else {
            cells.add(
              DataGridCell<String>(
                columnName: 'NAMA_KANTOR',
                value: row['NAMA_KANTOR']?.toString() ?? '-',
              ),
            );
            cells.add(
              DataGridCell<String>(
                columnName: 'REGION',
                value: row['REGION']?.toString() ?? '-',
              ),
            );
          }

          // Hitung funding
          final fundingIn =
              double.tryParse(row['FUNDING_IN']?.toString() ?? '0') ?? 0;
          final fundingOut =
              double.tryParse(row['FUNDING_OUT']?.toString() ?? '0') ?? 0;
          final fundingNet = fundingIn - fundingOut;

          //  Funding (urutan sesuai GridColumn)
          cells.add(
            DataGridCell<double>(columnName: 'FUNDING_IN', value: fundingIn),
          );
          cells.add(
            DataGridCell<double>(columnName: 'FUNDING_OUT', value: fundingOut),
          );
          cells.add(
            DataGridCell<double>(columnName: 'FUNDING_NET', value: fundingNet),
          );

          //  NTB CA
          cells.add(
            DataGridCell<double>(
              columnName: 'CA_NOC',
              value: double.tryParse(row['CA_NOC']?.toString() ?? '0') ?? 0,
            ),
          );
          cells.add(
            DataGridCell<double>(
              columnName: 'CA_OS',
              value: double.tryParse(row['CA_OS']?.toString() ?? '0') ?? 0,
            ),
          );

          //  NTB Priority
          cells.add(
            DataGridCell<double>(
              columnName: 'PRIO_NOC',
              value: double.tryParse(row['PRIO_NOC']?.toString() ?? '0') ?? 0,
            ),
          );
          cells.add(
            DataGridCell<double>(
              columnName: 'PRIO_OS',
              value: double.tryParse(row['PRIO_OS']?.toString() ?? '0') ?? 0,
            ),
          );

          //  Book
          cells.add(
            DataGridCell<double>(
              columnName: 'BOOK_NOC',
              value: double.tryParse(row['BOOK_NOC']?.toString() ?? '0') ?? 0,
            ),
          );
          cells.add(
            DataGridCell<double>(
              columnName: 'BOOK_OS',
              value: double.tryParse(row['BOOK_OS']?.toString() ?? '0') ?? 0,
            ),
          );

          // --- Booking KPR ---
          cells.add(
            DataGridCell<double>(
              columnName: 'BOOK_KPR_NOC',
              value:
                  double.tryParse(row['BOOK_KPR_NOC']?.toString() ?? '0') ?? 0,
            ),
          );
          cells.add(
            DataGridCell<double>(
              columnName: 'BOOK_KPR_OS',
              value:
                  double.tryParse(row['BOOK_KPR_OS']?.toString() ?? '0') ?? 0,
            ),
          );

          // --- Booking MG ---
          cells.add(
            DataGridCell<double>(
              columnName: 'BOOK_MG_NOC',
              value:
                  double.tryParse(row['BOOK_MG_NOC']?.toString() ?? '0') ?? 0,
            ),
          );
          cells.add(
            DataGridCell<double>(
              columnName: 'BOOK_MG_OS',
              value: double.tryParse(row['BOOK_MG_OS']?.toString() ?? '0') ?? 0,
            ),
          );

          // --- Booking Soleh ---
          cells.add(
            DataGridCell<double>(
              columnName: 'BOOK_SOLEH_NOC',
              value:
                  double.tryParse(row['BOOK_SOLEH_NOC']?.toString() ?? '0') ??
                  0,
            ),
          );
          cells.add(
            DataGridCell<double>(
              columnName: 'BOOK_SOLEH_OS',
              value:
                  double.tryParse(row['BOOK_SOLEH_OS']?.toString() ?? '0') ?? 0,
            ),
          );

          // --- Booking Prohaj ---
          cells.add(
            DataGridCell<double>(
              columnName: 'BOOK_PROHAJ_NOC',
              value:
                  double.tryParse(row['BOOK_PROHAJ_NOC']?.toString() ?? '0') ??
                  0,
            ),
          );
          cells.add(
            DataGridCell<double>(
              columnName: 'BOOK_PROHAJ_OS',
              value:
                  double.tryParse(row['BOOK_PROHAJ_OS']?.toString() ?? '0') ??
                  0,
            ),
          );

          // Submission
          cells.add(
            DataGridCell<double>(
              columnName: 'SUBMISSION_NOC',
              value:
                  double.tryParse(row['SUBMISSION_NOC']?.toString() ?? '0') ??
                  0,
            ),
          );
          cells.add(
            DataGridCell<double>(
              columnName: 'SUBMISSION_OS',
              value:
                  double.tryParse(row['SUBMISSION_OS']?.toString() ?? '0') ?? 0,
            ),
          );

          //  Booking SLI
          cells.add(
            DataGridCell<double>(
              columnName: 'BOOKINGSLI_OS',
              value:
                  double.tryParse(row['BOOKINGSLI_OS']?.toString() ?? '0') ?? 0,
            ),
          );

          return DataGridRow(cells: cells);
        }).toList();
  }

  final List<dynamic> data;
  final NumberFormat formatter;
  final bool isRegion;
  late List<DataGridRow> _rows;

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells:
          row.getCells().map((cell) {
            Alignment align =
                (cell.columnName == 'NAMA_KANTOR' ||
                        cell.columnName == 'REGION')
                    ? Alignment.centerLeft
                    : Alignment.center;

            final value = cell.value;
            final display =
                value is double
                    ? formatter.format(value)
                    : (value?.toString() ?? '-');

            //  Default warna teks
            Color textColor = Colors.black;

            //  Kolom NET warna dinamis
            if (cell.columnName == 'FUNDING_NET' && value is double) {
              if (value < 0) {
                textColor = Colors.red;
              } else if (value > 0) {
                textColor = Colors.green;
              } else {
                textColor = Colors.grey;
              }
            }

            return Container(
              alignment: align,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Text(
                display,
                style: TextStyle(fontSize: 11, color: textColor),
              ),
            );
          }).toList(),
    );
  }
}
