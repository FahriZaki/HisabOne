import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:intl/intl.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool isLoading = true;
  List<dynamic> dashboardData = [];
  List<Map<String, dynamic>> forecastRegionData = [];
  Map<String, dynamic>? kpnoData;

  Map<String, dynamic>? quickCountDataYesterday;
  Map<String, dynamic>? quickCountDataPlan;
  Map<String, dynamic>? quickCountDataToday;

  String sortedForecastColumn = "";
  bool forecastAscending = true;

  String? userRegion;
  int userLevel = 1;
  String? userCode;
  String sortedColumn = "";
  bool isAscending = true;

  List<dynamic> activityData = [];

  String formatNumber(dynamic number) {
    if (number == null) return "0";
    final parsed = num.tryParse(number.toString()) ?? 0;
    return NumberFormat.decimalPattern("id_ID").format(parsed);
  }

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int level = prefs.getInt('level') ?? 1;
    String region = prefs.getString('region') ?? '';
    String code = prefs.getString('kode_cabang') ?? '';

    if (mounted) {
      setState(() {
        userRegion = region;
        userLevel = level;
        userCode = code;
      });
    }

    final urlDashboard = Uri.parse(
      "http://103.59.95.71/api_performance/dashboard.php",
    );

    final urlActivity = Uri.parse(
      "http://103.59.95.71/api_performance/segmentasi_activity.php?level=$level&region=${Uri.encodeComponent(region)}",
    );

    final responseActivity = await http.get(urlActivity);
    if (responseActivity.statusCode == 200) {
      final jsonActivity = json.decode(responseActivity.body);
      if (jsonActivity["status"] == "success") {
        if (mounted) {
          setState(() {
            activityData = jsonActivity["data"];
          });
        }
      }
    }

    Uri urlSummaryQC;

    if (level == 2) {
      urlSummaryQC = Uri.parse(
        "http://103.59.95.71/api_performance/dataactual.php?level=2&code=${Uri.encodeComponent(code)}",
      );
    } else if (level == 3) {
      urlSummaryQC = Uri.parse(
        "http://103.59.95.71/api_performance/dataactual.php?level=3&region=${Uri.encodeComponent(region)}",
      );
    } else if (level == 4) {
      urlSummaryQC = Uri.parse(
        "http://103.59.95.71/api_performance/dataactual.php?level=4",
      );
    } else {
      throw Exception("Level tidak dikenali: $level");
    }

    final urlForecastRegion = Uri.parse(
      "http://103.59.95.71/api_performance/forecast_region.php",
    );

    final responseForecast = await http.get(urlForecastRegion);
    if (responseForecast.statusCode == 200) {
      final jsonFR = json.decode(responseForecast.body);
      if (jsonFR["status"] == "success" && jsonFR["data"] != null) {
        final raw = jsonFR["data"];
        dynamic parsed;

        if (raw is String) {
          parsed = json.decode(raw);
        } else {
          parsed = raw;
        }

        if (parsed is List) {
          setState(() {
            forecastRegionData = List<Map<String, dynamic>>.from(parsed);
          });
        } else if (parsed is Map) {
          setState(() {
            forecastRegionData = [Map<String, dynamic>.from(parsed)];
          });
        } else {
          print("❌ Unexpected data type: ${parsed.runtimeType}");
        }
      }
    }

    try {
      // --- Dashboard ---
      Map<String, String> body = {"level": "$level"};

      if (level == 2) {
        body["cabang"] = code; // kirim kode cabang
      } else if (level == 3) {
        body["region"] = region; // kirim region
      }

      // Level 4 cukup kirim level aja

      final response = await http.post(urlDashboard, body: body);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse["status"] == "success") {
          final List<dynamic> data = jsonResponse["data"];
          if (mounted) {
            setState(() {
              if (level == 2) {
                // Ambil data cabang langsung
                kpnoData =
                    data.isNotEmpty
                        ? Map<String, dynamic>.from(data.first)
                        : null;
                dashboardData = [];
              } else if (level == 3) {
                // Ambil data region
                kpnoData =
                    data.isNotEmpty
                        ? Map<String, dynamic>.from(data.first)
                        : null;
                dashboardData = [];
              } else if (level == 4) {
                // Ambil semua region
                final kpno = data.firstWhere(
                  (e) => e["REGION"] == "KPNO",
                  orElse: () => <String, dynamic>{},
                );
                kpnoData =
                    kpno.isNotEmpty ? Map<String, dynamic>.from(kpno) : null;
                dashboardData =
                    data.where((e) => e["REGION"] != "KPNO").toList();
              }
            });
          }
        }

        // --- Quick Count (GET) ---
        final responseQC = await http.get(urlSummaryQC);
        if (responseQC.statusCode == 200) {
          final jsonQC = json.decode(responseQC.body);

          if (jsonQC["status"] == "success") {
            if (mounted) {
              setState(() {
                quickCountDataYesterday =
                    jsonQC["yesterday"] != null
                        ? Map<String, dynamic>.from(jsonQC["yesterday"])
                        : null;
                quickCountDataPlan =
                    jsonQC["plan"] != null
                        ? Map<String, dynamic>.from(jsonQC["plan"])
                        : null;
                quickCountDataToday =
                    jsonQC["today"] != null
                        ? Map<String, dynamic>.from(jsonQC["today"])
                        : null;
              });
            }
          } else {
            if (mounted && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    jsonQC["message"] ?? "Tidak bisa akses Quick Count",
                  ),
                ),
              );
            }
          }
        }

        if (mounted) {
          setState(() => isLoading = false);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
      }
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Terjadi error: $e")));
      }
    }
  }

  double spacing(BuildContext context, {double factor = 0.015}) {
    final height = MediaQuery.of(context).size.height;
    return height * factor;
  }

@override
Widget build(BuildContext context) {
  if (isLoading) {
    return const Center(child: CircularProgressIndicator());
  }

  if (!isLoading && kpnoData == null && dashboardData.isEmpty) {
    return const Center(child: Text("Data tidak tersedia"));
  }

  return Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.blue[900],
      title: const Text(
        "Dashboard",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    ),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== JUDUL 1 =====
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
            SizedBox(height: spacing(context, factor: 0.012)),

            if (kpnoData != null) _buildKpnoSummary(kpnoData!),

            // ===== JUDUL 2 =====
            if (userLevel == 4 && dashboardData.isNotEmpty) ...[
              SizedBox(height: spacing(context, factor: 0.012)),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.blue[900],
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(8),
                child: _buildSectionTitle(
                  title: "Summary Activity M-Direct Per Region",
                  color: Colors.white,
                ),
              ),
              SizedBox(height: spacing(context, factor: 0.008)),
              _buildRegionTable(),
            ],

            // ===== JUDUL 3 =====
            SizedBox(height: spacing(context, factor: 0.012)),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.blue[900],
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(8),
              child: _buildSectionTitle(
                title: "Segmentasi Activity M-Direct",
                color: Colors.white,
              ),
            ),
            SizedBox(height: spacing(context, factor: 0.008)),
            _buildActivityTable(),

            // ===== JUDUL 4 =====
            SizedBox(height: spacing(context, factor: 0.012)),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.blue[900],
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(8),
              child: _buildSectionTitle(
                title: "Summary Plan Today (MTD)"
                    "${userLevel == 2 && kpnoData?['NAMA_KANTOR'] != null
                        ? " - ${kpnoData?['NAMA_KANTOR']}"
                        : userLevel == 3 && userRegion != null && userRegion!.isNotEmpty
                        ? " - $userRegion"
                        : userLevel == 4
                        ? " - Nasional"
                        : ""}",
                color: Colors.white,
              ),
            ),
            SizedBox(height: spacing(context, factor: 0.008)),
            _buildQuickCountCards(),

            // ===== JUDUL 5 =====
            if (userLevel == 4) ...[
              SizedBox(height: spacing(context, factor: 0.012)),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.blue[900],
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(8),
                child: _buildSectionTitle(
                  title: "Plan Today Per Region",
                  color: Colors.white,
                ),
              ),
              SizedBox(height: spacing(context, factor: 0.008)),
              buildForecastRegionGrid(forecastRegionData),
            ],
          ],
        ),
      ),
    ),
  );
}


  Widget _buildActivityTable() {
    if (activityData.isEmpty) {
      return const Text("Data Activity belum tersedia");
    }

    // Atur tinggi tabel berdasarkan userLevel
    double tableHeight;
    if (userLevel == 4) {
      tableHeight = 300; // banyak region
    } else if (userLevel == 3) {
      tableHeight = 70; // hanya 1 region
    } else {
      tableHeight = 400; // default
    }

    return SizedBox(
      height: tableHeight,
      child: SfDataGrid(
        source: ActivityDataSource(activityData),
        frozenColumnsCount: 1, // kolom REGION tetap di kiri
        allowSorting: true,
        gridLinesVisibility: GridLinesVisibility.both,
        headerGridLinesVisibility: GridLinesVisibility.both,
        columnWidthMode: ColumnWidthMode.none,
        headerRowHeight: 34,
        rowHeight: 30,
        columns: [
          GridColumn(
            columnName: 'REGION',
            width: 150,
            label: Container(
              alignment: Alignment.centerLeft,
              color: const Color(0xFFE0E0E0),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: const Text(
                'REGION',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
              ),
            ),
          ),
          _buildActivityColumn('BPR_BPRS_LKS', 'BPR/BPRS/LKS'),
          _buildActivityColumn('BUMN', 'BUMN'),
          _buildActivityColumn('DEVELOPER', 'DEVELOPER'),
          _buildActivityColumn('ISLAMIC_ECOSYSTEM', 'ISLAMIC ECOSYSTEM'),
          _buildActivityColumn('KESEHATAN', 'KESEHATAN'),
          _buildActivityColumn('LEADS_HO', 'LEADS HO'),
          _buildActivityColumn('LEMBAGA_NEGARA', 'LEMBAGA NEGARA'),
          _buildActivityColumn('OTHERS', 'OTHERS'),
          _buildActivityColumn('PAYROLL_PERUSAHAAN', 'PAYROLL (PERUSAHAAN)'),
          _buildActivityColumn('PENDIDIKAN', 'PENDIDIKAN'),
          _buildActivityColumn('PIHK_TRAVEL', 'PIHK/TRAVEL'),
          _buildActivityColumn('PROPERTY_AGENT', 'PROPERTY AGENT'),
          _buildActivityColumn('SATKER', 'SATKER'),
        ],
      ),
    );
  }

  GridColumn _buildActivityColumn(String columnName, String title) {
    return GridColumn(
      columnName: columnName,
      width: 95,
      label: Container(
        alignment: Alignment.center,
        color: const Color(0xFFE0E0E0),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10.5),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildSectionTitle({required String title, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.blue.shade900)],
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildKpnoSummary(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          data["REGION"] ?? "KPNO",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildClickableCard(
                title: "Total RM",
                value: data["TOT_RM"].toString(),
                extraValue: data["TOT_RM_AKTIF"].toString(),
                percent: "${data["RM_AKTIF"]}%",
                color: Colors.blue,
                context: context,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildClickableCard(
                title: "RM Funding",
                value: data["TOT_RM_FUN"].toString(),
                extraValue: data["TOT_FUN_AKTIF"].toString(),
                percent: "${data["RM_FUN_AKTIF"]}%",
                color: Colors.orange,
                context: context,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildClickableCard(
                title: "RM Consumer",
                value: data["TOT_RM_CON"].toString(),
                extraValue: data["TOT_CON_AKTIF"].toString(),
                percent: "${data["RM_CON_AKTIF"]}%",
                color: Colors.purple,
                context: context,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildClickableCard(
                title: "RM Priority",
                value: data["TOT_RM_PRIO"].toString(),
                extraValue: data["TOT_PRIO_AKTIF"].toString(),
                percent: "${data["RM_PRIO_AKTIF"]}%",
                color: Colors.red,
                context: context,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildClickableCard({
    required String title,
    required String value, // TOT_RM
    required String extraValue, // TOT_RM_AKTIF (baru)
    required String percent, // RM_AKTIF%
    required Color color,
    required BuildContext context,
  }) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: color.withOpacity(0.9),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (ctx) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Total RM: $value",
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                  ),
                  Text(
                    "Total RM Aktif: $extraValue",
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                  ),
                  Text(
                    "Persentase RM Aktif: $percent",
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: color,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("Tutup"),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      child: _buildStatCard(title, value, extraValue, percent, color),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    String extraValue,
    String percent,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$title : $value", // contoh: Total RM : 574
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Total RM Aktif : $extraValue ($percent)", // contoh: Total RM Aktif : 346
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildRegionTable() {
    return SfDataGrid(
      source: RegionDataSource(dashboardData),
      columnWidthMode: ColumnWidthMode.auto,
      allowSorting: true,
      frozenColumnsCount: 1,
      gridLinesVisibility: GridLinesVisibility.both,
      headerGridLinesVisibility: GridLinesVisibility.both,
      rowHeight: 32,
      headerRowHeight: 34,
      columns: [
        GridColumn(
          columnName: 'REGION',
          allowSorting: false,
          width: 150, // Tambahkan di sini untuk atur lebar kolom Region
          label: Container(
            alignment: Alignment.centerLeft,
            color: const Color(0xFFE0E0E0),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: const Text(
              'Region',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
            ),
          ),
        ),
        GridColumn(
          columnName: 'TOT_RM',
          width: 100,
          label: _buildHeaderCell('TOT RM', Colors.blue[200]),
        ),
        GridColumn(
          columnName: 'TOT_RM_AKTIF',
          width: 100,
          label: _buildHeaderCell('RM AKTIF', Colors.blue[200]),
        ),
        GridColumn(
          columnName: 'TOT_RM_FUN',
          width: 100,
          label: _buildHeaderCell('RM FUNDING', Colors.orange[200]),
        ),
        GridColumn(
          columnName: 'TOT_FUN_AKTIF',
          width: 100,
          label: _buildHeaderCell('FUN AKTIF', Colors.orange[200]),
        ),
        GridColumn(
          columnName: 'TOT_RM_CON',
          width: 100,
          label: _buildHeaderCell('RM CONSUMER', Colors.purple[200]),
        ),
        GridColumn(
          columnName: 'TOT_CON_AKTIF',
          width: 100,
          label: _buildHeaderCell('CON AKTIF', Colors.purple[200]),
        ),
        GridColumn(
          columnName: 'TOT_RM_PRIO',
          width: 100,
          label: _buildHeaderCell('RM PRIORITY', Colors.red[200]),
        ),
        GridColumn(
          columnName: 'TOT_PRIO_AKTIF',
          width: 100,
          label: _buildHeaderCell('PRIO AKTIF', Colors.red[200]),
        ),
      ],
    );
  }

  Widget _buildHeaderCell(String text, Color? bgColor) {
    return Container(
      alignment: Alignment.center,
      color: bgColor ?? const Color(0xFFE0E0E0),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );
  }

  // --- Quick Count Cards ---
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
            height: (rows.length * 55) + 60,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: QuickCountTable(
              rows: rows,
              formatAngka: formatNumber, // <-- pastikan koma di sini
            ),
          ),
        ],
      ),
    );
  }

  Widget buildForecastRegionGrid(
    List<Map<String, dynamic>> forecastRegionData,
  ) {
    final dataSource = ForecastRegionDataSource(forecastRegionData);

    Color? _getHeaderColor(String columnName) {
      if (columnName.contains("FUNDING")) {
        return const Color.fromARGB(255, 163, 211, 250); // biru muda
      } else if (columnName.contains("NTB_CA")) {
        return const Color.fromARGB(255, 254, 210, 144); // oranye
      } else if (columnName.contains("NTB_PRIORITY") ||
          columnName.contains("FC_NTB_PRIO")) {
        return const Color.fromARGB(255, 252, 150, 142); // merah muda
      } else if ((columnName.contains("BOOKING") &&
              !columnName.contains("SLI")) ||
          (columnName.contains("FC_BOOK") && !columnName.contains("SLI"))) {
        return const Color.fromARGB(255, 237, 144, 254); // ungu
      } else if (columnName.contains("SUBMIS")) {
        return const Color.fromARGB(255, 116, 152, 124); // hijau
      } else if (columnName.contains("SLI") ||
          columnName.contains("FC_BOOK_SLI")) {
        return const Color.fromARGB(255, 94, 235, 221); // toska
      }
      return const Color(0xFFE0E0E0);
    }

    List<GridColumn> _buildColumns() {
      final columns = [
        GridColumn(
          columnName: 'REGION',
          label: Container(
            color: Colors.grey.shade300,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(8.0),
            child: const Text(
              'Region',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          width: 150,
        ),
      ];

      final columnNames = [
        'FUNDING_GROWTH',
        'FC_FUNDING_GROWTH',
        'NTB_CA_NOC',
        'FC_NTB_CA_NOC',
        'NTB_CA_OS',
        'FC_NTB_CA_OS',
        'NTB_PRIORITY_NOC',
        'FC_NTB_PRIO_NOC',
        'NTB_PRIORITY_OS',
        'FC_NTB_PRIO_OS',
        'BOOKING_NOC',
        'FC_BOOK_NOC',
        'BOOKING_OS',
        'FC_BOOK_OS',
        'SUBMISSION_NOC',
        'FC_SUBMIS_NOC',
        'SUBMISSION_OS',
        'FC_SUBMIS_OS',
        'BOOKING_SLI',
        'FC_BOOK_SLI',
      ];

      for (final name in columnNames) {
        columns.add(
          GridColumn(
            columnName: name,
            width: 100,
            label: Container(
              color: _getHeaderColor(name),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Container(
                color: _getHeaderColor(name),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Text(
                  name.replaceAll('_', ' '),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                    color: Colors.black87,
                  ),
                  softWrap: true, // biar bisa pindah baris
                  overflow: TextOverflow.visible, // jangan potong jadi "..."
                  maxLines: 2, // batasi maksimal 2 baris (bisa 3 kalau mau)
                ),
              ),
            ),
          ),
        );
      }

      return columns;
    }

    return SfDataGrid(
      source: dataSource,
      frozenColumnsCount: 1,
      headerRowHeight: 37, // tinggi baris header
      rowHeight: 37, // tinggi baris data
      allowSorting: true,
      gridLinesVisibility: GridLinesVisibility.both,
      headerGridLinesVisibility: GridLinesVisibility.both,
      columnWidthMode: ColumnWidthMode.none,
      columns: _buildColumns(),
    );
  }
}

class RegionDataSource extends DataGridSource {
  RegionDataSource(List<dynamic> data) {
    _rows =
        data.map<DataGridRow>((region) {
          return DataGridRow(
            cells: [
              DataGridCell(columnName: 'REGION', value: region['REGION']),
              DataGridCell(columnName: 'TOT_RM', value: region['TOT_RM']),
              DataGridCell(
                columnName: 'TOT_RM_AKTIF',
                value: region['TOT_RM_AKTIF'],
              ),
              DataGridCell(
                columnName: 'TOT_RM_FUN',
                value: region['TOT_RM_FUN'],
              ),
              DataGridCell(
                columnName: 'TOT_FUN_AKTIF',
                value: region['TOT_FUN_AKTIF'],
              ),
              DataGridCell(
                columnName: 'TOT_RM_CON',
                value: region['TOT_RM_CON'],
              ),
              DataGridCell(
                columnName: 'TOT_CON_AKTIF',
                value: region['TOT_CON_AKTIF'],
              ),
              DataGridCell(
                columnName: 'TOT_RM_PRIO',
                value: region['TOT_RM_PRIO'],
              ),
              DataGridCell(
                columnName: 'TOT_PRIO_AKTIF',
                value: region['TOT_PRIO_AKTIF'],
              ),
            ],
          );
        }).toList();
  }

  late List<DataGridRow> _rows;
  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final rowIndex = _rows.indexOf(row);

    return DataGridRowAdapter(
      color: rowIndex.isEven ? Colors.grey[50] : Colors.white,
      cells:
          row.getCells().map<Widget>((cell) {
            final isRegion = cell.columnName == 'REGION';
            final isNumeric = !isRegion;

            return Container(
              alignment: isNumeric ? Alignment.center : Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              child: Text(
                cell.value.toString(),
                style: TextStyle(
                  fontSize:
                      isRegion ? 10.5 : 10, // kecilin font region & angka
                  fontWeight: isRegion ? FontWeight.w600 : FontWeight.normal,
                  color: isRegion ? Colors.black87 : Colors.grey[800],
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1, // biar gak turun ke baris bawah
              ),
            );
          }).toList(),
    );
  }
}

class ActivityDataSource extends DataGridSource {
  ActivityDataSource(List<dynamic> data) {
    _rows =
        data.map<DataGridRow>((activity) {
          return DataGridRow(
            cells: [
              DataGridCell(columnName: 'REGION', value: activity['REGION']),
              DataGridCell(
                columnName: 'BPR_BPRS_LKS',
                value: activity['BPR_BPRS_LKS'],
              ),
              DataGridCell(columnName: 'BUMN', value: activity['BUMN']),
              DataGridCell(
                columnName: 'DEVELOPER',
                value: activity['DEVELOPER'],
              ),
              DataGridCell(
                columnName: 'ISLAMIC_ECOSYSTEM',
                value: activity['ISLAMIC_ECOSYSTEM'],
              ),
              DataGridCell(
                columnName: 'KESEHATAN',
                value: activity['KESEHATAN'],
              ),
              DataGridCell(columnName: 'LEADS_HO', value: activity['LEADS_HO']),
              DataGridCell(
                columnName: 'LEMBAGA_NEGARA',
                value: activity['LEMBAGA_NEGARA'],
              ),
              DataGridCell(columnName: 'OTHERS', value: activity['OTHERS']),
              DataGridCell(
                columnName: 'PAYROLL_PERUSAHAAN',
                value: activity['PAYROLL_PERUSAHAAN'],
              ),
              DataGridCell(
                columnName: 'PENDIDIKAN',
                value: activity['PENDIDIKAN'],
              ),
              DataGridCell(
                columnName: 'PIHK_TRAVEL',
                value: activity['PIHK_TRAVEL'],
              ),
              DataGridCell(
                columnName: 'PROPERTY_AGENT',
                value: activity['PROPERTY_AGENT'],
              ),
              DataGridCell(columnName: 'SATKER', value: activity['SATKER']),
            ],
          );
        }).toList();
  }

  late List<DataGridRow> _rows;
  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final rowIndex = _rows.indexOf(row);

    return DataGridRowAdapter(
      color: rowIndex.isEven ? Colors.grey[50] : Colors.white,
      cells:
          row.getCells().map<Widget>((cell) {
            final isRegion = cell.columnName == 'REGION';
            final value = cell.value;
            final displayValue =
                (value is num)
                    ? (value % 1 == 0
                        ? value.toInt().toString()
                        : value.toString())
                    : value.toString();

            return Container(
              alignment: isRegion ? Alignment.centerLeft : Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Text(
                isRegion ? displayValue : "$displayValue %",
                style: TextStyle(
                  fontSize: isRegion ? 10.5 : 10,
                  fontWeight: isRegion ? FontWeight.w600 : FontWeight.normal,
                  color: Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
    );
  }
}

// class forecast
class ForecastRegionDataSource extends DataGridSource {
  List<DataGridRow> _rows = [];

  ForecastRegionDataSource(List<Map<String, dynamic>> forecastRegionData) {
    _rows =
        forecastRegionData.map((data) {
          num parseNum(dynamic v) {
            if (v == null) return 0;
            if (v is num) return v;
            return num.tryParse(v.toString()) ?? 0;
          }

          return DataGridRow(
            cells: [
              DataGridCell<String>(
                columnName: 'REGION',
                value: data['REGION'] ?? '-',
              ),
              DataGridCell<num>(
                columnName: 'FUNDING_GROWTH',
                value: parseNum(data['FUNDING_GROWTH']),
              ),
              DataGridCell<num>(
                columnName: 'FC_FUNDING_GROWTH',
                value: parseNum(data['FC_FUNDING_GROWTH']),
              ),
              DataGridCell<num>(
                columnName: 'NTB_CA_NOC',
                value: parseNum(data['NTB_CA_NOC']),
              ),
              DataGridCell<num>(
                columnName: 'FC_NTB_CA_NOC',
                value: parseNum(data['FC_NTB_CA_NOC']),
              ),
              DataGridCell<num>(
                columnName: 'NTB_CA_OS',
                value: parseNum(data['NTB_CA_OS']),
              ),
              DataGridCell<num>(
                columnName: 'FC_NTB_CA_OS',
                value: parseNum(data['FC_NTB_CA_OS']),
              ),
              DataGridCell<num>(
                columnName: 'NTB_PRIORITY_NOC',
                value: parseNum(data['NTB_PRIORITY_NOC']),
              ),
              DataGridCell<num>(
                columnName: 'FC_NTB_PRIO_NOC',
                value: parseNum(data['FC_NTB_PRIO_NOC']),
              ),
              DataGridCell<num>(
                columnName: 'NTB_PRIORITY_OS',
                value: parseNum(data['NTB_PRIORITY_OS']),
              ),
              DataGridCell<num>(
                columnName: 'FC_NTB_PRIO_OS',
                value: parseNum(data['FC_NTB_PRIO_OS']),
              ),
              DataGridCell<num>(
                columnName: 'BOOKING_NOC',
                value: parseNum(data['BOOKING_NOC']),
              ),
              DataGridCell<num>(
                columnName: 'FC_BOOK_NOC',
                value: parseNum(data['FC_BOOK_NOC']),
              ),
              DataGridCell<num>(
                columnName: 'BOOKING_OS',
                value: parseNum(data['BOOKING_OS']),
              ),
              DataGridCell<num>(
                columnName: 'FC_BOOK_OS',
                value: parseNum(data['FC_BOOK_OS']),
              ),
              DataGridCell<num>(
                columnName: 'SUBMISSION_NOC',
                value: parseNum(data['SUBMISSION_NOC']),
              ),
              DataGridCell<num>(
                columnName: 'FC_SUBMIS_NOC',
                value: parseNum(data['FC_SUBMIS_NOC']),
              ),
              DataGridCell<num>(
                columnName: 'SUBMISSION_OS',
                value: parseNum(data['SUBMISSION_OS']),
              ),
              DataGridCell<num>(
                columnName: 'FC_SUBMIS_OS',
                value: parseNum(data['FC_SUBMIS_OS']),
              ),
              DataGridCell<num>(
                columnName: 'BOOKING_SLI',
                value: parseNum(data['BOOKING_SLI']),
              ),
              DataGridCell<num>(
                columnName: 'FC_BOOK_SLI',
                value: parseNum(data['FC_BOOK_SLI']),
              ),
            ],
          );
        }).toList();
  }

  @override
  List<DataGridRow> get rows => _rows;

  @override
DataGridRowAdapter buildRow(DataGridRow row) {
  final formatter = NumberFormat.decimalPattern("id_ID");

  return DataGridRowAdapter(
    cells: row.getCells().map((cell) {
      final isNumeric = cell.value is num;
      final value = cell.value ?? '-';

      // 🔹 Deteksi nilai negatif
      final numValue = isNumeric ? (cell.value as num) : 0;
      final isNegative = isNumeric && numValue < 0;

      // 🔹 Format angka agar tetap pakai ribuan
      final displayValue = isNumeric
          ? formatter.format(numValue)
          : value.toString();

      return Container(
        alignment: isNumeric ? Alignment.center : Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Text(
          displayValue,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w400,
            height: 1.1,
            color: isNegative ? Colors.red : Colors.black87, // Merah kalau negatif
          ),
          overflow: TextOverflow.ellipsis,
        ),
      );
    }).toList(),
  );
}

}

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
          label: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: const Text(
              'Section',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        GridColumn(
          columnName: 'yesterday',
          label: Center(
            child: const Text(
              'Yesterday',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        GridColumn(
          columnName: 'plan',
          label: Center(
            child: const Text(
              'Plan',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        GridColumn(
          columnName: 'today',
          label: Center(
            child: const Text(
              'Today',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
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
    _dataGridRows = rawRows.map((row) {
      return DataGridRow(
        cells: [
          DataGridCell<String>(
            columnName: 'title',
            value: row[0].toString(),
          ),
          DataGridCell<dynamic>(
            columnName: 'yesterday',
            value: row[1],
          ),
          DataGridCell<dynamic>(
            columnName: 'plan',
            value: row[2],
          ),
          DataGridCell<dynamic>(
            columnName: 'today',
            value: row[3],
          ),
        ],
      );
    }).toList();
  }

  @override
  List<DataGridRow> get rows => _dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map((cell) {
        final isTitle = cell.columnName == 'title';
        final alignment = isTitle ? Alignment.centerLeft : Alignment.center;

        // 🔹 Deteksi angka negatif
        final dynamic rawValue = cell.value;
        final num? numericValue = (rawValue is num)
            ? rawValue
            : num.tryParse(rawValue.toString().replaceAll(',', ''));
        final bool isNegative = (numericValue != null && numericValue < 0);

        // 🔹 Format tampilan angka
        final displayValue = isTitle
            ? cell.value?.toString() ?? ''
            : formatAngka(cell.value);

        final textStyle = TextStyle(
          fontSize: isTitle ? 12 : 8.5,
          fontWeight: isTitle ? FontWeight.bold : FontWeight.normal,
          color: isNegative ? Colors.red : Colors.black87, // 🔴 merah kalau negatif
        );

        Color bg = Colors.white;
        if (isTitle) {
          bg = _getHeaderColors(cell.value?.toString() ?? '') ?? Colors.white;
        }

        return Container(
          alignment: alignment,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: isTitle ? bg : Colors.white,
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade300),
              right: BorderSide(color: Colors.grey.shade200),
            ),
          ),
          child: Text(displayValue, style: textStyle),
        );
      }).toList(),
    );
  }
}

Color? _getHeaderColors(String columnName) {
  final s = columnName.toUpperCase();
  if (s.contains("FUNDING")) return const Color(0xFFA3D3FA);
  if (s.contains("NTB CA") || s.contains("NTB_CA")) {
    return const Color(0xFFFED290);
  }
  if (s.contains("NTB PRIORITY") ||
      s.contains("NTB_PRIORITY") ||
      s.contains("FC_NTB_PRIO")) {
    return const Color(0xFFF8968E);
  }
  if ((s.contains("BOOKING") && !s.contains("SLI")) ||
      (s.contains("FC_BOOK") && !s.contains("SLI"))) {
    return const Color(0xFFED90FE);
  }
  if (s.contains("SUBMIS")) return const Color(0xFF74987C);
  if (s.contains("SLI") || s.contains("FC_BOOK_SLI")) {
    return const Color(0xFF5EEBDD);
  }
  return const Color(0xFFE0E0E0);
}

