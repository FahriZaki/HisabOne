import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class DashboardPageV2 extends StatefulWidget {
  const DashboardPageV2({super.key});

  @override
  State<DashboardPageV2> createState() => _DashboardPageV2State();
}

class _DashboardPageV2State extends State<DashboardPageV2> {
  int userLevel = 0;
  String? userCode;
  String? userCabangName;

  Map<String, dynamic>? kpnoData;
  Map<String, dynamic>? quickCountDataYesterday;
  Map<String, dynamic>? quickCountDataPlan;
  Map<String, dynamic>? quickCountDataToday;

  List<Map<String, dynamic>> segmentasiActivityData = [];
  List<Map<String, dynamic>> activityData = [];

  String sortedColumn = '';
  bool isAscending = true;

  String formatAngka(dynamic value) {
    if (value == null) return "-";
    final number = num.tryParse(value.toString()) ?? 0;
    return NumberFormat.decimalPattern('id_ID').format(number);
  }

  @override
  void initState() {
    super.initState();
    fetchUserData().then((_) {
      if (userLevel == 2 && userCode != null && userCode!.isNotEmpty) {
        fetchQuickCountData();
        fetchSegmentasiActivity();
        fetchActivityInputData();
      } else {
        // untuk testing pakai dummy
        _loadDummyData();
      }
    });
  }

  // Ambil data user login
  Future<void> fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int level = prefs.getInt('level') ?? 1;
    String code = prefs.getString('kode_cabang') ?? '';
    String cabangName = prefs.getString('asal_cabang') ?? '';

    if (mounted) {
      setState(() {
        userLevel = level;
        userCode = code;
        userCabangName = cabangName;
      });
    }
  }

  // Ambil data activity input dari API
  Future<void> fetchActivityInputData() async {
    if (userCode == null || userCode!.isEmpty) return;

    final url = Uri.parse(
      "http://103.59.95.71/api_performance/dashboard_cabang.php",
    );

    try {
      final response = await http.post(url, body: {"cabang": userCode!});

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["status"] == "success" &&
            data["data"] != null &&
            data["data"].isNotEmpty) {
          if (mounted) {
            setState(() {
              kpnoData = data["data"][0]; // ambil row pertama
            });
          }
        } else {
          debugPrint("No data for cabang: $userCode");
        }
      } else {
        debugPrint(
          "Failed to load activity input data: ${response.statusCode}",
        );
      }
    } catch (e) {
      debugPrint("Error fetchActivityInputData: $e");
    }
  }

  Future<void> fetchSegmentasiActivity() async {
    if (userCode == null || userCode!.isEmpty) return;

    final url = Uri.parse(
      "http://103.59.95.71/api_performance/segmentasi_activity2.php?level=2&code=${Uri.encodeComponent(userCode!)}",
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final raw = jsonDecode(response.body);

        dynamic extractedData;
        if (raw is Map<String, dynamic>) {
          // Jika formatnya punya key "data"
          extractedData = raw["data"];
        } else if (raw is List) {
          // Jika langsung list
          extractedData = raw;
        }

        if (extractedData != null && extractedData.isNotEmpty) {
          if (mounted) {
            setState(() {
              segmentasiActivityData = List<Map<String, dynamic>>.from(
                extractedData,
              );
            });
          }
          debugPrint(
            "✅ Segmentasi data loaded: ${segmentasiActivityData.length} baris",
          );
        } else {
          debugPrint("⚠️ Data segmentasi kosong untuk $userCode");
        }
      } else {
        debugPrint("❌ Gagal load data segmentasi: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("💥 Error fetchSegmentasiActivity: $e");
    }
  }

  // Ambil data Quick Count dari API
  Future<void> fetchQuickCountData() async {
    if (userCode == null || userCode!.isEmpty) return;

    final url = Uri.parse(
      "http://103.59.95.71/api_performance/dataactual.php?level=2&code=${Uri.encodeComponent(userCode!)}",
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            quickCountDataYesterday = data["yesterday"];
            quickCountDataPlan = data["plan"];
            quickCountDataToday = data["today"];
          });
        }
      } else {
        debugPrint("Failed to load data: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error fetchQuickCountData: $e");
    }
  }

  // Dummy data untuk testing
  void _loadDummyData() {
    kpnoData = {
      "REGION": "Cabang $userCode",
      "TOT_RM": 20,
      "RM_AKTIF": 75,
      "TOT_RM_FUN": 10,
      "RM_FUN_AKTIF": 60,
      "TOT_RM_CON": 5,
      "RM_CON_AKTIF": 40,
      "TOT_RM_PRIO": 5,
      "RM_PRIO_AKTIF": 30,
      "NAMA_KANTOR": "Cabang $userCode",
    };

    quickCountDataYesterday = {
      "FUNDING_GROWTH": 1000,
      "NTB_CA_NOC": 15,
      "NTB_CA_OS": 300,
      "NTB_PRIORITY_NOC": 5,
      "NTB_PRIORITY_OS": 150,
      "BOOKING_NOC": 12,
      "BOOKING_OS": 500,
      "SUBMISSION_NOC": 8,
      "SUBMISSION_OS": 200,
      "BOOKING_SLI": 100,
    };

    quickCountDataToday = {
      "FC_FUNDING_GROWTH": 1200,
      "FC_NTB_CA_NOC": 20,
      "FC_NTB_CA_OS": 400,
      "FC_NTB_PRIO_NOC": 7,
      "FC_NTB_PRIO_OS": 250,
      "FC_BOOK_NOC": 15,
      "FC_BOOK_OS": 600,
      "FC_SUBMIS_NOC": 10,
      "FC_SUBMIS_OS": 220,
      "FC_BOOK_SLI": 120,
    };

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
              "Dashboard - ${userCabangName ?? userCode}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1.2,
                color: Colors.white,
              ),
            ),
          ),
          actions: [
            // bisa tambahin refresh button di sini kalau mau
          ],
        ), // ← ini koma, bukan titik koma

        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === SECTION 1: ACTIVITY INPUT ===
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.blue[900],
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(8),
                child: _buildSectionTitle(
                  title: "Summary Activity Input M-Direct Today",
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              if (kpnoData != null) _buildKpnoSummary(kpnoData!),

              const SizedBox(height: 24),

              // === SECTION 2: SEGMENTASI ACTIVITY ===
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.indigo[900],
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(8),
                child: _buildSectionTitle(
                  title: "Summary Segmentasi Activity",
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              _buildActivityTable(), // <— tabel dari kode kamu

              const SizedBox(height: 1),

              // === SECTION 3: PLAN TODAY ===
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.blue[900],
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(8),
                child: _buildSectionTitle(
                  title:
                      "Summary Plan Today (MTD)"
                      "${userLevel == 2 && kpnoData?['NAMA_KANTOR'] != null ? " - ${kpnoData?['NAMA_KANTOR']}" : ""}",
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              _buildQuickCountCards(),
            ],
          ),
        ),
      ),
    );
  }

  // === UI Helpers ===
  Widget _buildSectionTitle({required String title, required Color color}) {
    return Text(
      title,
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color),
    );
  }

  Widget _buildKpnoSummary(Map<String, dynamic> data) {
    return Column(
      children: [
        _buildClickableCard(
          title: "Total RM",
          value: "${data['TOT_RM'] ?? '-'}",
          subtitle:
              "Aktif: ${data['TOT_RM_AKTIF'] ?? '-'} (${data['RM_AKTIF'] ?? '-'}%)",
          color: Colors.blue,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: "Funding",
                total: "${data['TOT_RM_FUN'] ?? '-'}",
                aktif:
                    "${data['TOT_FUN_AKTIF'] ?? '-'} (${data['RM_FUN_AKTIF'] ?? '-'}%)",
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: "Consumer",
                total: "${data['TOT_RM_CON'] ?? '-'}",
                aktif:
                    "${data['TOT_CON_AKTIF'] ?? '-'} (${data['RM_CON_AKTIF'] ?? '-'}%)",
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: "Priority",
                total: "${data['TOT_RM_PRIO'] ?? '-'}",
                aktif:
                    "${data['TOT_PRIO_AKTIF'] ?? '-'} (${data['RM_PRIO_AKTIF'] ?? '-'}%)",
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildClickableCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(backgroundColor: color, radius: 24),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(value, style: const TextStyle(fontSize: 18)),
                Text(subtitle, style: const TextStyle(color: Colors.black)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- Card untuk Activity Input (RM) ---
  Widget _buildStatCard({
    required String title,
    required String total,
    required String aktif,
    required Color color,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        height: 180, // tinggi seragam
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(backgroundColor: color, radius: 16),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text("Total: $total", style: const TextStyle(fontSize: 11)),
            Text("Aktif: $aktif", style: const TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTable() {
    if (segmentasiActivityData.isEmpty) {
      return const Text("Data Activity belum tersedia");
    }

    final dataSource = SegmentasiActivityDataSource(segmentasiActivityData);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: SizedBox(
          height: 70, // <— batasi tinggi tabel (atur sesuai kebutuhan)
          child: SfDataGrid(
            source: dataSource,
            allowSorting: true,
            frozenColumnsCount: 1,
            gridLinesVisibility: GridLinesVisibility.both,
            headerGridLinesVisibility: GridLinesVisibility.both,
            columnWidthMode: ColumnWidthMode.auto,
            rowHeight: 30,
            headerRowHeight: 34,
            columns: [
              GridColumn(
                columnName: 'CODE',
                allowSorting: false,
                label: Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  child: const Text(
                    'CODE',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
              ),
              ...[
                'BPR_BPRS_LKS',
                'BUMN',
                'DEVELOPER',
                'ISLAMIC_ECOSYSTEM',
                'KESEHATAN',
                'LEADS_HO',
                'LEMBAGA_NEGARA',
                'OTHERS',
                'PAYROLL_PERUSAHAAN',
                'PENDIDIKAN',
                'PIHK_TRAVEL',
                'PROPERTY_AGENT',
                'SATKER',
              ].map((col) {
                return GridColumn(
                  columnName: col,
                  label: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    child: Text(
                      col.replaceAll('_', ' '),
                      textAlign: TextAlign.center,
                      softWrap: true,
                      overflow: TextOverflow.visible,
                      maxLines: 2,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  //tabel
  Widget _buildQuickCountCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTable(
          title: "Funding",
          rows: [
            [
              "Funding Growth",
              quickCountDataYesterday?['FUNDING_GROWTH'],
              quickCountDataPlan?['P_FUNDING_NET'],
              quickCountDataToday?['FC_FUNDING_GROWTH'],
            ],
            [
              "NTB CA",
              quickCountDataYesterday?['NTB_CA_OS'],
              quickCountDataPlan?['P_CA_OS'],
              quickCountDataToday?['FC_NTB_CA_OS'],
            ],
            [
              "NTB Priority",
              quickCountDataYesterday?['NTB_PRIORITY_OS'],
              quickCountDataPlan?['P_PRIO_OS'],
              quickCountDataToday?['FC_NTB_PRIO_OS'],
            ],
          ],
        ),
        _buildSectionTable(
          title: "Financing",
          rows: [
            [
              "Booking KPR",
              quickCountDataYesterday?['BOOK_KPR_OS'],
              quickCountDataPlan?['P_BOOK_KPR_OS'],
              quickCountDataToday?['FC_BOOK_KPR_OS'],
            ],
            [
              "Booking MG",
              quickCountDataYesterday?['BOOK_MG_OS'],
              quickCountDataPlan?['P_BOOK_MG_OS'],
              quickCountDataToday?['FC_BOOK_MG_OS'],
            ],
            [
              "Booking Soleh",
              quickCountDataYesterday?['BOOK_SOLEH_OS'],
              quickCountDataPlan?['P_BOOK_SOLEH_OS'],
              quickCountDataToday?['FC_BOOK_SOLEH_OS'],
            ],
            [
              "Booking Prohajj",
              quickCountDataYesterday?['BOOK_PROHAJ_OS'],
              quickCountDataPlan?['P_BOOK_PROHAJ_OS'],
              quickCountDataToday?['FC_BOOK_PROHAJ_OS'],
            ],
            [
              "Total Booking",
              quickCountDataYesterday?['BOOKING_OS'],
              quickCountDataPlan?['P_BOOK_OS'],
              quickCountDataToday?['FC_BOOK_OS'],
            ],
            [
              "Submission",
              quickCountDataYesterday?['SUBMISSION_OS'],
              quickCountDataPlan?['P_BOOK_SUBMISSION_OS'],
              quickCountDataToday?['FC_SUBMIS_OS'],
            ],
          ],
        ),
        _buildSectionTable(
          title: "SLI",
          rows: [
            [
              "Booking SLI",
              quickCountDataYesterday?['BOOKING_SLI'],
              quickCountDataPlan?['P_BOOKINGSLI_OS'],
              quickCountDataToday?['FC_BOOK_SLI'],
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTable({
    required String title,
    required List<List<dynamic>> rows,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height:
                (rows.length * 55) + 60, // otomatis menyesuaikan tinggi tabel
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: QuickCountTable(rows: rows, formatAngka: formatAngka),
          ),
        ],
      ),
    );
  }
} // ← ini penutup class _DashboardPageV2State

class SegmentasiActivityDataSource extends DataGridSource {
  List<DataGridRow> _rows = [];

  SegmentasiActivityDataSource(List<Map<String, dynamic>> data) {
    _rows =
        data.map((item) {
          return DataGridRow(
            cells: [
              DataGridCell(columnName: 'CODE', value: item['CODE']),
              DataGridCell(
                columnName: 'BPR_BPRS_LKS',
                value: item['BPR_BPRS_LKS'],
              ),
              DataGridCell(columnName: 'BUMN', value: item['BUMN']),
              DataGridCell(columnName: 'DEVELOPER', value: item['DEVELOPER']),
              DataGridCell(
                columnName: 'ISLAMIC_ECOSYSTEM',
                value: item['ISLAMIC_ECOSYSTEM'],
              ),
              DataGridCell(columnName: 'KESEHATAN', value: item['KESEHATAN']),
              DataGridCell(columnName: 'LEADS_HO', value: item['LEADS_HO']),
              DataGridCell(
                columnName: 'LEMBAGA_NEGARA',
                value: item['LEMBAGA_NEGARA'],
              ),
              DataGridCell(columnName: 'OTHERS', value: item['OTHERS']),
              DataGridCell(
                columnName: 'PAYROLL_PERUSAHAAN',
                value: item['PAYROLL_PERUSAHAAN'],
              ),
              DataGridCell(columnName: 'PENDIDIKAN', value: item['PENDIDIKAN']),
              DataGridCell(
                columnName: 'PIHK_TRAVEL',
                value: item['PIHK_TRAVEL'],
              ),
              DataGridCell(
                columnName: 'PROPERTY_AGENT',
                value: item['PROPERTY_AGENT'],
              ),
              DataGridCell(columnName: 'SATKER', value: item['SATKER']),
            ],
          );
        }).toList();
  }

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells:
          row.getCells().map<Widget>((cell) {
            final isCodeColumn = cell.columnName == 'CODE';

            // Kalau bukan kolom CODE → tambahkan tanda %
            final value = cell.value;
            final displayValue =
                isCodeColumn
                    ? value.toString()
                    : "${value ?? 0}%"; // <-- tambahkan tanda %

            return Container(
              alignment: isCodeColumn ? Alignment.centerLeft : Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Text(
                displayValue,
                textAlign: isCodeColumn ? TextAlign.left : TextAlign.center,
                style: const TextStyle(fontSize: 10),
              ),
            );
          }).toList(),
    );
  }
}

// jangan sampai class QuickCountTable di dalam _DashboardPageV2State
// harus berada di luar
class QuickCountTable extends StatelessWidget {
  final List<List<dynamic>> rows;
  final String Function(dynamic) formatAngka;

  const QuickCountTable({
    super.key,
    required this.rows,
    required this.formatAngka,
  });

  @override
  Widget build(BuildContext context) {
    final dataSource = _QuickCountDataSource(rows, formatAngka);

    return SfDataGrid(
      source: dataSource,
      columnWidthMode: ColumnWidthMode.fill,
      headerGridLinesVisibility: GridLinesVisibility.both,
      gridLinesVisibility: GridLinesVisibility.both,
      columns: [
        GridColumn(
          columnName: 'title',
          label: Center(
            child: Text(
              'Section',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        GridColumn(
          columnName: 'yesterday',
          label: Center(
            child: Text(
              'Yesterday',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        GridColumn(
          columnName: 'plan',
          label: Center(
            child: Text('Plan', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        GridColumn(
          columnName: 'today',
          label: Center(
            child: Text('Today', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}

class _QuickCountDataSource extends DataGridSource {
  final List<List<dynamic>> rawRows;
  final String Function(dynamic) formatAngka;
  late final List<DataGridRow> _dataGridRows;

  _QuickCountDataSource(this.rawRows, this.formatAngka) {
    _dataGridRows =
        rawRows.map((row) {
          return DataGridRow(
            cells: [
              DataGridCell<String>(
                columnName: 'title',
                value: row[0].toString(),
              ),
              DataGridCell<String>(
                columnName: 'yesterday',
                value: formatAngka(row[1]),
              ),
              DataGridCell<String>(
                columnName: 'plan',
                value: formatAngka(row[2]),
              ),
              DataGridCell<String>(
                columnName: 'today',
                value: formatAngka(row[3]),
              ),
            ],
          );
        }).toList();
  }

  // getter yang benar → harus kembalikan List<DataGridRow>
  @override
  List<DataGridRow> get rows => _dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells:
          row.getCells().map((cell) {
            // Alignment per kolom
            Alignment alignment =
                cell.columnName == 'title'
                    ? Alignment.centerLeft
                    : Alignment.center;

            // Style per kolom
            TextStyle textStyle = TextStyle(
              fontSize: cell.columnName == 'title' ? 11 : 8,
              fontWeight:
                  cell.columnName == 'title'
                      ? FontWeight.bold
                      : FontWeight.normal,
              color: Colors.black87,
            );

            // Dapatkan warna background hanya untuk kolom section
            Color? bgColor;
            if (cell.columnName == 'title') {
              bgColor = _getHeaderColor(cell.value.toString().toUpperCase());
            }

            return Container(
              alignment: alignment,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: bgColor ?? Colors.white, // warna hanya untuk kolom title
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade300),
                  right: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Text(cell.value?.toString() ?? '', style: textStyle),
            );
          }).toList(),
    );
  }

  //warna section
  Color? _getHeaderColor(String columnName) {
    columnName = columnName.toUpperCase();

    if (columnName.contains("FUNDING")) {
      return const Color(0xFFA3D3FA); // biru muda
    } else if (columnName.contains("NTB CA") || columnName.contains("NTB_CA")) {
      return const Color(0xFFFED290); // oranye
    } else if (columnName.contains("NTB PRIORITY") ||
        columnName.contains("NTB_PRIORITY") ||
        columnName.contains("FC_NTB_PRIO")) {
      return const Color(0xFFF8968E); // merah muda
    } else if ((columnName.contains("BOOKING") &&
            !columnName.contains("SLI")) ||
        (columnName.contains("FC BOOK") && !columnName.contains("SLI"))) {
      return const Color(0xFFED90FE); // ungu
    } else if (columnName.contains("SUBMIS")) {
      return const Color(0xFF74987C); // hijau
    } else if (columnName.contains("SLI") ||
        columnName.contains("FC BOOK SLI")) {
      return const Color(0xFF5EEBDD); // toska
    }
    return const Color(0xFFE0E0E0); // default abu2
  }
}
