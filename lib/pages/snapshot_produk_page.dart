import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class SnapshotProdukPage extends StatefulWidget {
  const SnapshotProdukPage({super.key});

  @override
  State<SnapshotProdukPage> createState() => _SnapshotProdukPageState();
}

class _SnapshotProdukPageState extends State<SnapshotProdukPage> {
  String username = "";
  String headerLy = '';
  String headerLm = '';
  String headerYesterday = '';
  String headerToday = '';

  //Tabungan All
  SnapshotDataSource? _fundingDataSource;
  bool _isLoading = true;

  //Tabungan Haji (S09)
  CasaOnlyDataSource? _casaOnlyDataSource;
  bool _isCasaLoading = true;

  //TPB
  ConsumerOnlyDataSource? _consumerOnlyDataSource;
  bool _isConsumerOnlyLoading = true;

  //PAYROLL
  SmeOnlyDataSource? _smeOnlyDataSource;
  bool _isSmeOnlyLoading = true;

  //HIJRAH
  HijrahDataSource? _hijrahDataSource;
  bool _isHijrahLoading = true;

  // OTHERS SA
  OthersSaDataSource? _othersSaDataSource;
  bool _isOthersSaLoading = true;

  //FORMAT NOMOR
  final numberFormat = NumberFormat.decimalPattern('id');

  String formatNumber(dynamic value) {
    if (value == null) return "-";
    if (value is num) return NumberFormat.decimalPattern('id').format(value);
    return value.toString();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await fetchUserData();
      await fetchCasaOnlyData();
      await fetchConsumerOnlyData();
      await fetchSmeOnlyData();
      await fetchHijrahData();
      await fetchOthersSaData();
    });
  }

  Future<void> fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    username = prefs.getString("username") ?? "";

    await fetchDummyData();
  }

  // ALL TABUNGAN
  Future<void> fetchDummyData() async {
    try {
      final url = Uri.parse(
        "http://103.59.95.71/api_performance/snapshot_product_allsa.php",
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData["status"] == "success") {
          final List<dynamic> data = jsonData["data"];
          final header = jsonData["header"]; // 🔹 ambil header dari API

          // 🔹 Update header biar GridColumn ikut berubah
          setState(() {
            headerLy = header["ly"] ?? '';
            headerLm = header["lm"] ?? '';
            headerToday = header["today"] ?? '';
          });

          // 🔹 Mapping JSON ke model
          final fundingList =
              data.map((item) {
                return SnapshotModel(
                  region: item["region"],
                  dec24: double.tryParse(item["dec24"].toString()) ?? 0,
                  sep25: double.tryParse(item["sep25"].toString()) ?? 0,
                  oct13: double.tryParse(item["oct13"].toString()) ?? 0,
                  dtd: double.tryParse(item["dtd"].toString()) ?? 0,
                  mtd: double.tryParse(item["mtd"].toString()) ?? 0,
                  ytd: double.tryParse(item["ytd"].toString()) ?? 0,
                  vol: double.tryParse(item["vol"].toString()) ?? 0,
                  noa: double.tryParse(item["noa"].toString()) ?? 0,
                );
              }).toList();

          setState(() {
            _fundingDataSource = SnapshotDataSource(fundingList);
            _isLoading = false;
          });
        } else {
          setState(() => _isLoading = false);
          debugPrint("All Tabungan data kosong");
        }
      } else {
        setState(() => _isLoading = false);
        debugPrint("Gagal request All Tabungan: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("Error All Tabungan: $e");
    }
  }

  //TABUNGAN HAJI S09
  Future<void> fetchCasaOnlyData() async {
    try {
      final url = Uri.parse(
        "http://103.59.95.71/api_performance/snapshot_product_s09.php",
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData["status"] == "success") {
          final List<dynamic> data = jsonData["data"];
          final header = jsonData["header"]; // ambil header dari API

          // 🔹 Update header agar grid ikut berubah
          setState(() {
            headerLy = header["ly"] ?? '';
            headerLm = header["lm"] ?? '';
            headerToday = header["today"] ?? '';
          });

          // 🔹 Mapping data JSON ke model
          final casaList =
              data.map((item) {
                return CasaOnlyModel(
                  region: item["region"],
                  dec24: double.tryParse(item["dec24"].toString()) ?? 0,
                  sep25: double.tryParse(item["sep25"].toString()) ?? 0,
                  oct13: double.tryParse(item["oct13"].toString()) ?? 0,
                  dtd: double.tryParse(item["dtd"].toString()) ?? 0,
                  mtd: double.tryParse(item["mtd"].toString()) ?? 0,
                  ytd: double.tryParse(item["ytd"].toString()) ?? 0,
                  vol: double.tryParse(item["vol"].toString()) ?? 0,
                  noa: double.tryParse(item["noa"].toString()) ?? 0,
                );
              }).toList();

          setState(() {
            _casaOnlyDataSource = CasaOnlyDataSource(casaList);
            _isCasaLoading = false;
          });
        } else {
          setState(() => _isCasaLoading = false);
          debugPrint("Tabungan Haji (S09) data kosong");
        }
      } else {
        setState(() => _isCasaLoading = false);
        debugPrint("Gagal request Tabungan Haji (S09): ${response.statusCode}");
      }
    } catch (e) {
      setState(() => _isCasaLoading = false);
      debugPrint("Error Tabungan Haji (S09): $e");
    }
  }

  // PRODUCT TPB
  Future<void> fetchConsumerOnlyData() async {
    try {
      final url = Uri.parse(
        "http://103.59.95.71/api_performance/snapshot_product_tpb.php",
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData["status"] == "success") {
          final List<dynamic> data = jsonData["data"];
          final header = jsonData["header"]; // 🔹 ambil header dari API

          // 🔹 Update header untuk grid
          setState(() {
            headerLy = header["ly"] ?? '';
            headerLm = header["lm"] ?? '';
            headerToday = header["today"] ?? '';
          });

          // 🔹 Mapping data ke model
          final consumerList =
              data.map((item) {
                return ConsumerOnlyModel(
                  region: item["region"],
                  dec24: double.tryParse(item["dec24"].toString()) ?? 0,
                  sep25: double.tryParse(item["sep25"].toString()) ?? 0,
                  oct13: double.tryParse(item["oct13"].toString()) ?? 0,
                  dtd: double.tryParse(item["dtd"].toString()) ?? 0,
                  mtd: double.tryParse(item["mtd"].toString()) ?? 0,
                  ytd: double.tryParse(item["ytd"].toString()) ?? 0,
                  vol: double.tryParse(item["vol"].toString()) ?? 0,
                  noa: double.tryParse(item["noa"].toString()) ?? 0,
                );
              }).toList();

          setState(() {
            _consumerOnlyDataSource = ConsumerOnlyDataSource(consumerList);
            _isConsumerOnlyLoading = false;
          });
        } else {
          setState(() => _isConsumerOnlyLoading = false);
          debugPrint("TPB data kosong");
        }
      } else {
        setState(() => _isConsumerOnlyLoading = false);
        debugPrint("Gagal request TPB: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => _isConsumerOnlyLoading = false);
      debugPrint("Error TPB: $e");
    }
  }

  // PAYROLL
  Future<void> fetchSmeOnlyData() async {
    try {
      final url = Uri.parse(
        "http://103.59.95.71/api_performance/snapshot_product_payroll.php",
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData["status"] == "success") {
          final List<dynamic> data = jsonData["data"];
          final header = jsonData["header"]; // Ambil header dari API

          // 🔹 Update header untuk grid (sama dengan consumer)
          setState(() {
            headerLy = header["ly"] ?? '';
            headerLm = header["lm"] ?? '';
            headerToday = header["today"] ?? '';
          });

          // 🔹 Mapping data ke model
          final smeList =
              data.map((item) {
                return SmeOnlyModel(
                  region: item["region"],
                  dec24: double.tryParse(item["dec24"].toString()) ?? 0,
                  sep25: double.tryParse(item["sep25"].toString()) ?? 0,
                  oct13: double.tryParse(item["oct13"].toString()) ?? 0,
                  dtd: double.tryParse(item["dtd"].toString()) ?? 0,
                  mtd: double.tryParse(item["mtd"].toString()) ?? 0,
                  ytd: double.tryParse(item["ytd"].toString()) ?? 0,
                  vol: double.tryParse(item["vol"].toString()) ?? 0,
                  noa: double.tryParse(item["noa"].toString()) ?? 0,
                );
              }).toList();

          setState(() {
            _smeOnlyDataSource = SmeOnlyDataSource(smeList);
            _isSmeOnlyLoading = false;
          });
        } else {
          setState(() => _isSmeOnlyLoading = false);
          debugPrint("Payroll data kosong");
        }
      } else {
        setState(() => _isSmeOnlyLoading = false);
        debugPrint("❌ Gagal request Payroll: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => _isSmeOnlyLoading = false);
      debugPrint("❌ Error Payroll: $e");
    }
  }

  // PRODUCT HIJRAH
  Future<void> fetchHijrahData() async {
    try {
      final url = Uri.parse(
        "http://103.59.95.71/api_performance/snapshot_product_hijrah.php",
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData["status"] == "success") {
          final List<dynamic> data = jsonData["data"];
          final header = jsonData["header"];

          // 🔹 Update header grid
          setState(() {
            headerLy = header["ly"] ?? '';
            headerLm = header["lm"] ?? '';
            headerToday = header["today"] ?? '';
          });

          // 🔹 Mapping data API ke model
          final hijrahList =
              data.map((item) {
                return HijrahModel(
                  region: item["region"],
                  dec24: double.tryParse(item["dec24"].toString()) ?? 0,
                  sep25: double.tryParse(item["sep25"].toString()) ?? 0,
                  oct13: double.tryParse(item["oct13"].toString()) ?? 0,
                  dtd: double.tryParse(item["dtd"].toString()) ?? 0,
                  mtd: double.tryParse(item["mtd"].toString()) ?? 0,
                  ytd: double.tryParse(item["ytd"].toString()) ?? 0,
                  vol: double.tryParse(item["vol"].toString()) ?? 0,
                  noa: double.tryParse(item["noa"].toString()) ?? 0,
                );
              }).toList();

          // 🔹 Update DataGrid
          setState(() {
            _hijrahDataSource = HijrahDataSource(hijrahList);
            _isHijrahLoading = false;
          });
        } else {
          setState(() => _isHijrahLoading = false);
          debugPrint("⚠️ Data HIJRAH kosong");
        }
      } else {
        setState(() => _isHijrahLoading = false);
        debugPrint("❌ Gagal request HIJRAH: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => _isHijrahLoading = false);
      debugPrint("❌ Error HIJRAH: $e");
    }
  }

  // PRODUCT OTHERS SA
  Future<void> fetchOthersSaData() async {
    try {
      final url = Uri.parse(
        "http://103.59.95.71/api_performance/snapshot_product_othersa.php",
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData["status"] == "success") {
          final List<dynamic> data = jsonData["data"];
          final header = jsonData["header"];

          // 🔹 Update header grid
          setState(() {
            headerLy = header["ly"] ?? '';
            headerLm = header["lm"] ?? '';
            headerToday = header["today"] ?? '';
          });

          // 🔹 Mapping data API ke model
          final othersSaList =
              data.map((item) {
                return OthersSaModel(
                  region: item["region"],
                  dec24: double.tryParse(item["dec24"].toString()) ?? 0,
                  sep25: double.tryParse(item["sep25"].toString()) ?? 0,
                  oct13: double.tryParse(item["oct13"].toString()) ?? 0,
                  dtd: double.tryParse(item["dtd"].toString()) ?? 0,
                  mtd: double.tryParse(item["mtd"].toString()) ?? 0,
                  ytd: double.tryParse(item["ytd"].toString()) ?? 0,
                  vol: double.tryParse(item["vol"].toString()) ?? 0,
                  noa: double.tryParse(item["noa"].toString()) ?? 0,
                );
              }).toList();

          // 🔹 Update DataGrid
          setState(() {
            _othersSaDataSource = OthersSaDataSource(othersSaList);
            _isOthersSaLoading = false;
          });
        } else {
          setState(() => _isOthersSaLoading = false);
          debugPrint("⚠️ Data OTHERS SA kosong");
        }
      } else {
        setState(() => _isOthersSaLoading = false);
        debugPrint("❌ Gagal request OTHERS SA: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => _isOthersSaLoading = false);
      debugPrint("❌ Error OTHERS SA: $e");
    }
  }

  Future<void> fetchHeaderDate() async {
    const url = "http://103.59.95.71/api_performance/get_perioddate.php";
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData["status"] == "success" && jsonData["data"] != null) {
          final header = jsonData["data"];

          setState(() {
            headerToday = header["TODAY"] ?? "";
            headerYesterday = header["YESTERDAY"] ?? "";
            headerLm = header["LM"] ?? "";
            headerLy = header["LY"] ?? "";
          });

          debugPrint(
            "Header berhasil diupdate: $headerToday | $headerYesterday | $headerLm | $headerLy",
          );
        } else {
          debugPrint("Header kosong atau gagal parsing");
        }
      } else {
        debugPrint("❌ Gagal request header: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint(" Gagal ambil header date: $e");
    }
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _isCasaLoading = true;
      _isConsumerOnlyLoading = true;
      _isSmeOnlyLoading = true;
    });

    await fetchHeaderDate();
    await Future.wait([
      fetchUserData(),
      fetchCasaOnlyData(),
      fetchConsumerOnlyData(),
      fetchSmeOnlyData(),
      fetchHijrahData(),
      fetchOthersSaData(),
    ]);

    setState(() {
      _isLoading = false;
      _isCasaLoading = false;
      _isConsumerOnlyLoading = false;
      _isSmeOnlyLoading = false;
    });
  }

  // Helper widget: header teks
  Widget _headerCell(String text, {Color? color, Color? textColor}) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      color: color ?? Colors.purple[800], // default ungu tua
      child: Text(
        text,
        style: TextStyle(
          color: textColor ?? Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  // Helper widget: stacked header
  Widget _stackedHeaderCell(String text, {required Color color}) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(6),
          topRight: Radius.circular(6),
        ),
      ),
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

  // Widget reusable untuk setiap tabel
  Widget _buildSnapshotTable(SnapshotDataSource source, Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: 30.0),
      child: SizedBox(
        height: 350,
        child: SfDataGrid(
          source: source,
          gridLinesVisibility: GridLinesVisibility.both,
          headerGridLinesVisibility: GridLinesVisibility.both,
          columnWidthMode: ColumnWidthMode.auto,
          allowSorting: true,
          frozenColumnsCount: 1,
          headerRowHeight: 43,
          rowHeight: 35,
          columns: [
            // REGION
            GridColumn(
              columnName: 'region',
              width: 115,
              allowSorting: false,
              label: Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromRGBO(74, 20, 140, 1),
                      Color.fromRGBO(74, 20, 140, 1),
                    ], // kuning → ungu tua
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: const Text(
                  'REGION',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),

            // KOLOM BIASA
            GridColumn(
              columnName: 'dec24',
              width: 78,
              label: _headerCell(headerLy.isNotEmpty ? headerLy : 'Dec-24'),
            ),
            GridColumn(
              columnName: 'sep25',
              width: 75,
              label: _headerCell(headerLm.isNotEmpty ? headerLm : 'Sep-25'),
            ),
            GridColumn(
              columnName: 'oct13',
              width: 75,
              label: _headerCell(
                headerToday.isNotEmpty ? headerToday : 'Today',
                color: Colors.green[700]!,
              ),
            ),

            GridColumn(
              columnName: 'dtd',
              label: _headerCell('DTD', color: Colors.green[800]!),
            ),
            GridColumn(
              columnName: 'mtd',
              label: _headerCell('MTD', color: Colors.green[800]!),
            ),
            GridColumn(
              columnName: 'ytd',
              label: _headerCell('YTD', color: Colors.green[900]!),
            ),
            GridColumn(
              columnName: 'vol',
              label: _headerCell('Vol', color: Colors.purple[700]!),
            ),
            GridColumn(
              columnName: 'noa',
              label: _headerCell('NoA', color: Colors.purple[700]!),
            ),
          ],

          // STACKED HEADER
          stackedHeaderRows: [
            StackedHeaderRow(
              cells: [
                StackedHeaderCell(
                  columnNames: ['dec24', 'sep25', 'oct13'],
                  child: _stackedHeaderCell(
                    'ACTUAL (IDR Bio)',
                    color: Colors.purple[800]!,
                  ),
                ),
                StackedHeaderCell(
                  columnNames: ['dtd', 'mtd', 'ytd'],
                  child: _stackedHeaderCell(
                    'GROWTH',
                    color: Colors.green[800]!,
                  ),
                ),
                StackedHeaderCell(
                  columnNames: ['vol', 'noa'],
                  child: _stackedHeaderCell(
                    'New Rek HIJRAH MTD',
                    color: Colors.purple[700]!,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 4,
        title: const Text(
          "Snapshot Product Region",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF05A3F9), Color(0xFF0288D1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              _fetchData();
            },
            tooltip: 'Refresh',
          ),
        ],
      ),

      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 5),

                    // ALL TABUNGAN SUM
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue[800],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "ALL TABUNGAN",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _buildSnapshotTable(
                          _fundingDataSource!,
                          Colors.blueAccent,
                        ),

                    const SizedBox(height: 10),

                    // TABUNGAN HAJI (S09)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue[50], // background lembut
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[200]!, width: 1),
                      ),
                      child: const Text(
                        "TABUNGAN HAJI (S09)",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),
                    _isCasaLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _casaOnlyDataSource == null
                        ? const Text("Data TABUNGAN HAJI (S09) belum tersedia")
                        : _buildCasaOnlyTable(
                          _casaOnlyDataSource!,
                          headerLy,
                          headerLm,
                          headerToday,
                        ),

                    const SizedBox(height: 10),

                    // TPB
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(
                          255,
                          253,
                          241,
                          227,
                        ), // background lembut
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color.fromARGB(255, 249, 205, 144),
                          width: 1,
                        ),
                      ),
                      child: const Text(
                        "TPB",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 251, 189, 32),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),
                    _isConsumerOnlyLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _consumerOnlyDataSource == null
                        ? const Text("Data TPB belum tersedia")
                        : _buildConsumerOnlyTable(
                          _consumerOnlyDataSource!,
                          headerLy,
                          headerLm,
                          headerToday,
                        ),
                    const SizedBox(height: 10),

                    // PAYROLL
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(
                          255,
                          253,
                          230,
                          227,
                        ), // background lembut
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color.fromARGB(255, 249, 161, 144),
                          width: 1,
                        ),
                      ),
                      child: const Text(
                        "PAYROLL",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 251, 90, 32),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _isSmeOnlyLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _smeOnlyDataSource == null
                        ? const Text("Data Sunlife belum tersedia")
                        : _buildSmeOnlyTable(
                          _smeOnlyDataSource!,
                          headerLy,
                          headerLm,
                          headerToday,
                        ),
                    const SizedBox(height: 10),

                    // HIJRAH
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(
                          255,
                          253,
                          230,
                          227,
                        ), // background lembut
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color.fromARGB(255, 249, 161, 144),
                          width: 1,
                        ),
                      ),
                      child: const Text(
                        "HIJRAH",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 251, 90, 32),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _isHijrahLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _hijrahDataSource == null
                        ? const Text("Data Hijrah belum tersedia")
                        : buildHijrahTable(
                          _hijrahDataSource!,
                          headerLy,
                          headerLm,
                          headerToday,
                        ),
                    const SizedBox(height: 10),

                    // OTHERS SA
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 253, 230, 227),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color.fromARGB(255, 249, 161, 144),
                          width: 1,
                        ),
                      ),
                      child: const Text(
                        "OTHERS SA",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 251, 90, 32),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _isOthersSaLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _othersSaDataSource == null
                        ? const Text("Data Others SA belum tersedia")
                        : buildOthersSaTable(
                          _othersSaDataSource!,
                          headerLy,
                          headerLm,
                          headerToday,
                        ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
    );
  }
}

// =======================================================
// CLASS TABUNGAN ALL
// =======================================================
class SnapshotModel {
  final String region;
  final double dec24, sep25, oct13, dtd, mtd, ytd, vol, noa;

  SnapshotModel({
    required this.region,
    required this.dec24,
    required this.sep25,
    required this.oct13,
    required this.dtd,
    required this.mtd,
    required this.ytd,
    required this.vol,
    required this.noa,
  });
}

// =======================================================
//  Data Source untuk Grid
// =======================================================
class SnapshotDataSource extends DataGridSource {
  List<DataGridRow> _rows = [];

  SnapshotDataSource(List<SnapshotModel> data) {
    _rows =
        data
            .map(
              (d) => DataGridRow(
                cells: [
                  DataGridCell(columnName: 'region', value: d.region),
                  DataGridCell(columnName: 'dec24', value: d.dec24),
                  DataGridCell(columnName: 'sep25', value: d.sep25),
                  DataGridCell(columnName: 'oct13', value: d.oct13),
                  DataGridCell(columnName: 'dtd', value: d.dtd),
                  DataGridCell(columnName: 'mtd', value: d.mtd),
                  DataGridCell(columnName: 'ytd', value: d.ytd),
                  DataGridCell(columnName: 'vol', value: d.vol),
                  DataGridCell(columnName: 'noa', value: d.noa),
                ],
              ),
            )
            .toList();
  }

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final NumberFormat numberFormat = NumberFormat("#,##0.00", "id");

    final rowIndex = _rows.indexOf(row);

    return DataGridRowAdapter(
      color: rowIndex.isEven ? Colors.grey[50] : Colors.white,
      cells:
          row.getCells().map((cell) {
            final value = cell.value;
            final isNumeric = value is num;
            final isNegative = isNumeric && value < 0;

            String displayValue;
            if (isNumeric) {
              displayValue = numberFormat.format(value);
            } else {
              displayValue = value.toString();
            }

            return Container(
              alignment:
                  cell.columnName == 'region'
                      ? Alignment.centerLeft
                      : Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Text(
                displayValue,
                style: TextStyle(
                  fontSize: 9.5,
                  color:
                      isNegative
                          ? Colors.red[700]
                          : Colors.grey[800], // Merah jika negatif
                  fontWeight: FontWeight.w400,
                ),
              ),
            );
          }).toList(),
    );
  }
}

// ======================================================
//  CLASS TABUNGAN HAJI (S09)
// ======================================================
class CasaOnlyModel {
  final String region;
  final double dec24, sep25, oct13;
  final double dtd, mtd, ytd;
  final double vol, noa;

  CasaOnlyModel({
    required this.region,
    required this.dec24,
    required this.sep25,
    required this.oct13,
    required this.dtd,
    required this.mtd,
    required this.ytd,
    required this.vol,
    required this.noa,
  });
}

class CasaOnlyDataSource extends DataGridSource {
  List<DataGridRow> _rows = [];

  CasaOnlyDataSource(List<CasaOnlyModel> data) {
    _rows =
        data
            .map(
              (d) => DataGridRow(
                cells: [
                  DataGridCell(columnName: 'region', value: d.region),
                  DataGridCell(columnName: 'dec24', value: d.dec24),
                  DataGridCell(columnName: 'sep25', value: d.sep25),
                  DataGridCell(columnName: 'oct13', value: d.oct13),
                  DataGridCell(columnName: 'dtd', value: d.dtd),
                  DataGridCell(columnName: 'mtd', value: d.mtd),
                  DataGridCell(columnName: 'ytd', value: d.ytd),
                  DataGridCell(columnName: 'vol', value: d.vol),
                  DataGridCell(columnName: 'noa', value: d.noa),
                ],
              ),
            )
            .toList();
  }

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final NumberFormat numberFormat = NumberFormat("#,##0.00", "id");
    final rowIndex = _rows.indexOf(row);

    return DataGridRowAdapter(
      color: rowIndex.isEven ? Colors.grey[50] : Colors.white,
      cells:
          row.getCells().map((cell) {
            final value = cell.value;
            final isDouble = value is double;

            final isNegativeGap =
                cell.columnName == 'noa' && isDouble && value < 0;
            final isNegativeGrowth =
                ['dtd', 'mtd', 'ytd'].contains(cell.columnName) &&
                isDouble &&
                value < 0;

            Color? bgColor;
            if (isNegativeGap || isNegativeGrowth) bgColor = Colors.red[100];

            String displayValue;
            if (isDouble) {
              displayValue = numberFormat.format(value);
            } else {
              displayValue = value.toString();
            }

            return Container(
              alignment:
                  cell.columnName == 'region'
                      ? Alignment.centerLeft
                      : Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              color: bgColor,
              child: Text(
                displayValue,
                style: TextStyle(
                  fontSize: 9.5,
                  color:
                      (isNegativeGap || isNegativeGrowth)
                          ? Colors.red[700]
                          : Colors.grey[800],
                  fontWeight:
                      (isNegativeGap || isNegativeGrowth)
                          ? FontWeight.bold
                          : FontWeight.w400,
                ),
              ),
            );
          }).toList(),
    );
  }
}

// ======================================================
//  Helper untuk Header Cell dan Stacked Header Cell
// ======================================================

Widget _headercasaCell(String text, {Color color = const Color(0xFF6A1B9A)}) {
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

Widget _stackedHeadercasaCell(String text, {Color color = Colors.grey}) {
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
//  FUNGSI BUILD TABLE & DATA DUMMY
// ======================================================

Widget _buildCasaOnlyTable(
  CasaOnlyDataSource source,
  String headerLy,
  String headerLm,
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
        headerRowHeight: 41,
        rowHeight: 35,
        columnWidthMode: ColumnWidthMode.auto,
        columns: [
          GridColumn(
            columnName: 'region',
            width: 115,
            allowSorting: false,
            label: _headercasaCell('REGION'),
          ),
          GridColumn(
            columnName: 'dec24',
            width: 76,
            label: _headercasaCell(
              headerLy.isEmpty ? 'LY' : headerLy,
              color: Colors.deepPurple,
            ),
          ),
          GridColumn(
            columnName: 'sep25',
            width: 76,
            label: _headercasaCell(
              headerLm.isEmpty ? 'LM' : headerLm,
              color: Colors.deepPurple,
            ),
          ),
          GridColumn(
            columnName: 'oct13',
            width: 76,
            label: _headercasaCell(
              headerToday.isEmpty ? 'TODAY' : headerToday,
              color: const Color.fromARGB(255, 32, 135, 34),
            ),
          ),
          GridColumn(
            columnName: 'dtd',
            label: _headercasaCell('DTD', color: Colors.orange),
          ),
          GridColumn(
            columnName: 'mtd',
            label: _headercasaCell('MTD', color: Colors.orange),
          ),
          GridColumn(
            columnName: 'ytd',
            label: _headercasaCell('YTD', color: Colors.orange),
          ),
          GridColumn(
            columnName: 'vol',
            label: _headercasaCell('Vol', color: Colors.green),
          ),
          GridColumn(
            columnName: 'noa',
            label: _headercasaCell('NoA', color: Colors.green),
          ),
        ],
        stackedHeaderRows: [
          StackedHeaderRow(
            cells: [
              StackedHeaderCell(
                columnNames: ['dec24', 'sep25', 'oct13'],
                child: _stackedHeadercasaCell(
                  'ACTUAL (IDR Bio)',
                  color: Colors.deepPurple,
                ),
              ),
              StackedHeaderCell(
                columnNames: ['dtd', 'mtd', 'ytd'],
                child: _stackedHeadercasaCell('GROWTH', color: Colors.orange),
              ),
              StackedHeaderCell(
                columnNames: ['vol', 'noa'],
                child: _stackedHeadercasaCell(
                  'New Rek S09 MTD',
                  color: Colors.green,
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
// CLASS TPB
// ======================================================

class ConsumerOnlyModel {
  final String region;
  final double dec24, sep25, oct13;
  final double dtd, mtd, ytd;
  final double vol, noa;

  ConsumerOnlyModel({
    required this.region,
    required this.dec24,
    required this.sep25,
    required this.oct13,
    required this.dtd,
    required this.mtd,
    required this.ytd,
    required this.vol,
    required this.noa,
  });
}

class ConsumerOnlyDataSource extends DataGridSource {
  List<DataGridRow> _rows = [];

  ConsumerOnlyDataSource(List<ConsumerOnlyModel> data) {
    _rows =
        data
            .map(
              (d) => DataGridRow(
                cells: [
                  DataGridCell(columnName: 'region', value: d.region),
                  DataGridCell(columnName: 'dec24', value: d.dec24),
                  DataGridCell(columnName: 'sep25', value: d.sep25),
                  DataGridCell(columnName: 'oct13', value: d.oct13),
                  DataGridCell(columnName: 'dtd', value: d.dtd),
                  DataGridCell(columnName: 'mtd', value: d.mtd),
                  DataGridCell(columnName: 'ytd', value: d.ytd),
                  DataGridCell(columnName: 'vol', value: d.vol),
                  DataGridCell(columnName: 'noa', value: d.noa),
                ],
              ),
            )
            .toList();
  }

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final NumberFormat numberFormat = NumberFormat("#,##0.00", "id");
    final rowIndex = _rows.indexOf(row);

    return DataGridRowAdapter(
      color: rowIndex.isEven ? Colors.grey[50] : Colors.white,
      cells:
          row.getCells().map((cell) {
            final value = cell.value;
            final isDouble = value is double;

            // Deteksi nilai negatif
            final isNegativeGap =
                cell.columnName == 'noa' && isDouble && value < 0;
            final isNegativeGrowth =
                ['dtd', 'mtd', 'ytd'].contains(cell.columnName) &&
                isDouble &&
                value < 0;

            Color? bgColor;
            if (isNegativeGap || isNegativeGrowth) bgColor = Colors.red[100];

            String displayValue;
            if (isDouble) {
              displayValue = numberFormat.format(value);
            } else {
              displayValue = value.toString();
            }

            return Container(
              alignment:
                  cell.columnName == 'region'
                      ? Alignment.centerLeft
                      : Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              color: bgColor,
              child: Text(
                displayValue,
                style: TextStyle(
                  fontSize: 9.5,
                  color:
                      (isNegativeGap || isNegativeGrowth)
                          ? Colors.red[700]
                          : Colors.grey[800],
                  fontWeight:
                      (isNegativeGap || isNegativeGrowth)
                          ? FontWeight.bold
                          : FontWeight.w400,
                ),
              ),
            );
          }).toList(),
    );
  }
}

// ======================================================
// Helper untuk Header Cell dan Stacked Header Cell
// ======================================================

Widget _headerconCell(
  String text, {
  Color color = const Color.fromARGB(255, 165, 78, 12),
}) {
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

Widget _stackedHeaderconCell(String text, {Color color = Colors.grey}) {
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
// FUNGSI BUILD TABLE
// ======================================================

Widget _buildConsumerOnlyTable(
  ConsumerOnlyDataSource source,
  String headerLy,
  String headerLm,
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
            width: 115,
            allowSorting: false,
            label: _headerconCell('REGION'),
          ),
          GridColumn(
            columnName: 'dec24',
            width: 76,
            label: _headercasaCell(headerLy, color: Colors.deepPurple),
          ),
          GridColumn(
            columnName: 'sep25',
            width: 76,
            label: _headercasaCell(headerLm, color: Colors.deepPurple),
          ),
          GridColumn(
            columnName: 'oct13',
            width: 76,
            label: _headercasaCell(
              headerToday,
              color: const Color.fromARGB(255, 32, 135, 34),
            ),
          ),
          GridColumn(
            columnName: 'dtd',
            label: _headerconCell('DTD', color: Colors.orange),
          ),
          GridColumn(
            columnName: 'mtd',
            label: _headerconCell('MTD', color: Colors.orange),
          ),
          GridColumn(
            columnName: 'ytd',
            label: _headerconCell('YTD', color: Colors.orange),
          ),
          GridColumn(
            columnName: 'vol',
            label: _headerconCell('Vol', color: Colors.green),
          ),
          GridColumn(
            columnName: 'noa',
            label: _headerconCell('NoA', color: Colors.green),
          ),
        ],
        stackedHeaderRows: [
          StackedHeaderRow(
            cells: [
              StackedHeaderCell(
                columnNames: ['dec24', 'sep25', 'oct13'],
                child: _stackedHeaderconCell(
                  'ACTUAL (IDR Bio)',
                  color: Colors.deepPurple,
                ),
              ),
              StackedHeaderCell(
                columnNames: ['dtd', 'mtd', 'ytd'],
                child: _stackedHeaderconCell('GROWTH', color: Colors.orange),
              ),
              StackedHeaderCell(
                columnNames: ['vol', 'noa'],
                child: _stackedHeaderconCell(
                  'New Rek TPB MTD',
                  color: Colors.green,
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
// 🔹 CLASS PAYROLL
// ======================================================

class SmeOnlyModel {
  final String region;
  final double dec24, sep25, oct13;
  final double dtd, mtd, ytd;
  final double vol, noa;

  SmeOnlyModel({
    required this.region,
    required this.dec24,
    required this.sep25,
    required this.oct13,
    required this.dtd,
    required this.mtd,
    required this.ytd,
    required this.vol,
    required this.noa,
  });
}

class SmeOnlyDataSource extends DataGridSource {
  List<DataGridRow> _rows = [];

  SmeOnlyDataSource(List<SmeOnlyModel> data) {
    _rows =
        data
            .map(
              (d) => DataGridRow(
                cells: [
                  DataGridCell(columnName: 'region', value: d.region),
                  DataGridCell(columnName: 'dec24', value: d.dec24),
                  DataGridCell(columnName: 'sep25', value: d.sep25),
                  DataGridCell(columnName: 'oct13', value: d.oct13),
                  DataGridCell(columnName: 'dtd', value: d.dtd),
                  DataGridCell(columnName: 'mtd', value: d.mtd),
                  DataGridCell(columnName: 'ytd', value: d.ytd),
                  DataGridCell(columnName: 'vol', value: d.vol),
                  DataGridCell(columnName: 'noa', value: d.noa),
                ],
              ),
            )
            .toList();
  }

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final NumberFormat numberFormat = NumberFormat("#,##0.00", "id");
    final rowIndex = _rows.indexOf(row);

    return DataGridRowAdapter(
      color: rowIndex.isEven ? Colors.grey[50] : Colors.white,
      cells:
          row.getCells().map((cell) {
            final isRegion = cell.columnName == 'region';
            final isNegativeGap =
                cell.columnName == 'noa' &&
                (cell.value is num && cell.value < 0);
            final isNegativeGrowth =
                ['dtd', 'mtd', 'ytd'].contains(cell.columnName) &&
                (cell.value is num && cell.value < 0);

            Color? bgColor;
            if (isNegativeGrowth) bgColor = Colors.red[100];
            if (isNegativeGap) bgColor = Colors.red[100];

            // 🔹 Tentukan nilai yang akan ditampilkan
            String displayValue;
            if (isRegion) {
              displayValue = cell.value.toString();
            } else if (cell.value is num) {
              displayValue = numberFormat.format(
                cell.value,
              ); // format angka ribuan
            } else {
              displayValue = cell.value.toString();
            }

            return Container(
              alignment: isRegion ? Alignment.centerLeft : Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              color: bgColor,
              child: Text(
                displayValue,
                style: TextStyle(
                  fontSize: 9.5,
                  color:
                      (isNegativeGap || isNegativeGrowth)
                          ? Colors.red[700]
                          : Colors.grey[800],
                  fontWeight:
                      (isNegativeGap || isNegativeGrowth)
                          ? FontWeight.bold
                          : FontWeight.w400,
                ),
              ),
            );
          }).toList(),
    );
  }
}

// ======================================================
// 🔹 Helper untuk Header Cell dan Stacked Header Cell
// ======================================================

Widget _headersmeCell(
  String text, {
  Color color = const Color.fromARGB(255, 165, 78, 12),
}) {
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

Widget _stackedHeadersmeCell(String text, {Color color = Colors.grey}) {
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
// 🔹 FUNGSI BUILD TABLE & DATA DUMMY
// ======================================================

Widget _buildSmeOnlyTable(
  SmeOnlyDataSource source,
  String headerLy,
  String headerLm,
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
            width: 115,
            allowSorting: false,
            label: _headersmeCell('REGION'),
          ),
          GridColumn(
            columnName: 'dec24',
            width: 77,
            label: _headersmeCell(headerLy, color: Colors.deepPurple),
          ),
          GridColumn(
            columnName: 'sep25',
            width: 77,
            label: _headersmeCell(headerLm, color: Colors.deepPurple),
          ),
          GridColumn(
            columnName: 'oct13',
            width: 77,
            label: _headersmeCell(
              headerToday,
              color: const Color.fromARGB(255, 32, 135, 34),
            ),
          ),

          GridColumn(
            columnName: 'dtd',
            label: _headersmeCell('DTD', color: Colors.orange),
          ),
          GridColumn(
            columnName: 'mtd',
            label: _headersmeCell('MTD', color: Colors.orange),
          ),
          GridColumn(
            columnName: 'ytd',
            label: _headersmeCell('YTD', color: Colors.orange),
          ),
          GridColumn(
            columnName: 'vol',
            label: _headersmeCell('Vol', color: Colors.green),
          ),
          GridColumn(
            columnName: 'noa',
            label: _headersmeCell('NoA', color: Colors.green),
          ),
        ],
        stackedHeaderRows: [
          StackedHeaderRow(
            cells: [
              StackedHeaderCell(
                columnNames: ['dec24', 'sep25', 'oct13'],
                child: _stackedHeadersmeCell(
                  'ACTUAL (IDR Bio)',
                  color: Colors.deepPurple,
                ),
              ),
              StackedHeaderCell(
                columnNames: ['dtd', 'mtd', 'ytd'],
                child: _stackedHeadersmeCell('GROWTH', color: Colors.orange),
              ),
              StackedHeaderCell(
                columnNames: ['vol', 'noa'],
                child: _stackedHeadersmeCell(
                  'New Rek PAYROLL MTD',
                  color: Colors.green,
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
// CLASS HIJRAH
// ======================================================
class HijrahModel {
  final String region;
  final double dec24, sep25, oct13;
  final double dtd, mtd, ytd;
  final double vol, noa;

  HijrahModel({
    required this.region,
    required this.dec24,
    required this.sep25,
    required this.oct13,
    required this.dtd,
    required this.mtd,
    required this.ytd,
    required this.vol,
    required this.noa,
  });
}

// ======================================================
// 🔹 DATA SOURCE HIJRAH UNTUK DATAGRID
// ======================================================
class HijrahDataSource extends DataGridSource {
  List<DataGridRow> _rows = [];

  HijrahDataSource(List<HijrahModel> data) {
    _rows =
        data
            .map(
              (d) => DataGridRow(
                cells: [
                  DataGridCell(columnName: 'region', value: d.region),
                  DataGridCell(columnName: 'dec24', value: d.dec24),
                  DataGridCell(columnName: 'sep25', value: d.sep25),
                  DataGridCell(columnName: 'oct13', value: d.oct13),
                  DataGridCell(columnName: 'dtd', value: d.dtd),
                  DataGridCell(columnName: 'mtd', value: d.mtd),
                  DataGridCell(columnName: 'ytd', value: d.ytd),
                  DataGridCell(columnName: 'vol', value: d.vol),
                  DataGridCell(columnName: 'noa', value: d.noa),
                ],
              ),
            )
            .toList();
  }

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final NumberFormat numberFormat = NumberFormat("#,##0.00", "id");
    final rowIndex = _rows.indexOf(row);

    return DataGridRowAdapter(
      color: rowIndex.isEven ? Colors.grey[50] : Colors.white,
      cells:
          row.getCells().map((cell) {
            final isRegion = cell.columnName == 'region';
            final isNegativeGap =
                cell.columnName == 'noa' &&
                (cell.value is num && cell.value < 0);
            final isNegativeGrowth =
                ['dtd', 'mtd', 'ytd'].contains(cell.columnName) &&
                (cell.value is num && cell.value < 0);

            Color? bgColor;
            if (isNegativeGrowth) bgColor = Colors.red[100];
            if (isNegativeGap) bgColor = Colors.red[100];

            String displayValue;
            if (isRegion) {
              displayValue = cell.value.toString();
            } else if (cell.value is num) {
              displayValue = numberFormat.format(cell.value);
            } else {
              displayValue = cell.value.toString();
            }

            return Container(
              alignment: isRegion ? Alignment.centerLeft : Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              color: bgColor,
              child: Text(
                displayValue,
                style: TextStyle(
                  fontSize: 9.5,
                  color:
                      (isNegativeGap || isNegativeGrowth)
                          ? Colors.red[700]
                          : Colors.grey[800],
                  fontWeight:
                      (isNegativeGap || isNegativeGrowth)
                          ? FontWeight.bold
                          : FontWeight.w400,
                ),
              ),
            );
          }).toList(),
    );
  }
}

// ======================================================
// 🔹 WIDGET TABEL HIJRAH
// ======================================================
Widget buildHijrahTable(
  HijrahDataSource source,
  String headerLy,
  String headerLm,
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
            width: 115,
            label: _headerhijrahCell('REGION', color: Colors.teal[900]!),
          ),
          GridColumn(
            columnName: 'dec24',
            width: 77,
            label: _headerhijrahCell(headerLy, color: Colors.teal),
          ),
          GridColumn(
            columnName: 'sep25',
            width: 77,
            label: _headerhijrahCell(headerLm, color: Colors.teal),
          ),
          GridColumn(
            columnName: 'oct13',
            width: 77,
            label: _headerhijrahCell(headerToday, color: Colors.teal),
          ),
          GridColumn(
            columnName: 'dtd',
            label: _headerhijrahCell('DTD', color: Colors.orange),
          ),
          GridColumn(
            columnName: 'mtd',
            label: _headerhijrahCell('MTD', color: Colors.orange),
          ),
          GridColumn(
            columnName: 'ytd',
            label: _headerhijrahCell('YTD', color: Colors.orange),
          ),
          GridColumn(
            columnName: 'vol',
            label: _headerhijrahCell('Vol', color: Colors.green),
          ),
          GridColumn(
            columnName: 'noa',
            label: _headerhijrahCell('NoA', color: Colors.green),
          ),
        ],
        stackedHeaderRows: [
          StackedHeaderRow(
            cells: [
              StackedHeaderCell(
                columnNames: ['dec24', 'sep25', 'oct13'],
                child: _stackedHeaderhijrahCell(
                  'ACTUAL (IDR Bio)',
                  color: Colors.teal,
                ),
              ),
              StackedHeaderCell(
                columnNames: ['dtd', 'mtd', 'ytd'],
                child: _stackedHeaderhijrahCell('GROWTH', color: Colors.orange),
              ),
              StackedHeaderCell(
                columnNames: ['vol', 'noa'],
                child: _stackedHeaderhijrahCell(
                  'New Rek HIJRAH MTD',
                  color: Colors.green,
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
// 🔹 STYLE HEADER
// ======================================================
Widget _headerhijrahCell(String text, {Color? color}) {
  return Container(
    alignment: Alignment.center,
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: color ?? Colors.blueGrey,
      border: Border.all(color: Colors.white, width: 0.5),
    ),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 11,
      ),
    ),
  );
}

Widget _stackedHeaderhijrahCell(String text, {Color? color}) {
  return Container(
    alignment: Alignment.center,
    padding: const EdgeInsets.symmetric(vertical: 6),
    color: color ?? Colors.blueGrey,
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

// ======================================================
// CLASS OTHERS SA
// ======================================================
class OthersSaModel {
  final String region;
  final double dec24, sep25, oct13;
  final double dtd, mtd, ytd;
  final double vol, noa;

  OthersSaModel({
    required this.region,
    required this.dec24,
    required this.sep25,
    required this.oct13,
    required this.dtd,
    required this.mtd,
    required this.ytd,
    required this.vol,
    required this.noa,
  });
}

// ======================================================
// 🔹 DATA SOURCE OTHERS SA UNTUK DATAGRID
// ======================================================
class OthersSaDataSource extends DataGridSource {
  List<DataGridRow> _rows = [];

  OthersSaDataSource(List<OthersSaModel> data) {
    _rows =
        data
            .map(
              (d) => DataGridRow(
                cells: [
                  DataGridCell(columnName: 'region', value: d.region),
                  DataGridCell(columnName: 'dec24', value: d.dec24),
                  DataGridCell(columnName: 'sep25', value: d.sep25),
                  DataGridCell(columnName: 'oct13', value: d.oct13),
                  DataGridCell(columnName: 'dtd', value: d.dtd),
                  DataGridCell(columnName: 'mtd', value: d.mtd),
                  DataGridCell(columnName: 'ytd', value: d.ytd),
                  DataGridCell(columnName: 'vol', value: d.vol),
                  DataGridCell(columnName: 'noa', value: d.noa),
                ],
              ),
            )
            .toList();
  }

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final NumberFormat numberFormat = NumberFormat("#,##0.00", "id");
    final rowIndex = _rows.indexOf(row);

    return DataGridRowAdapter(
      color: rowIndex.isEven ? Colors.grey[50] : Colors.white,
      cells:
          row.getCells().map((cell) {
            final isRegion = cell.columnName == 'region';
            final isNegativeGap =
                cell.columnName == 'noa' &&
                (cell.value is num && cell.value < 0);
            final isNegativeGrowth =
                ['dtd', 'mtd', 'ytd'].contains(cell.columnName) &&
                (cell.value is num && cell.value < 0);

            Color? bgColor;
            if (isNegativeGrowth) bgColor = Colors.red[100];
            if (isNegativeGap) bgColor = Colors.red[100];

            String displayValue;
            if (isRegion) {
              displayValue = cell.value.toString();
            } else if (cell.value is num) {
              displayValue = numberFormat.format(cell.value);
            } else {
              displayValue = cell.value.toString();
            }

            return Container(
              alignment: isRegion ? Alignment.centerLeft : Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              color: bgColor,
              child: Text(
                displayValue,
                style: TextStyle(
                  fontSize: 9.5,
                  color:
                      (isNegativeGap || isNegativeGrowth)
                          ? Colors.red[700]
                          : Colors.grey[800],
                  fontWeight:
                      (isNegativeGap || isNegativeGrowth)
                          ? FontWeight.bold
                          : FontWeight.w400,
                ),
              ),
            );
          }).toList(),
    );
  }
}

// ======================================================
// 🔹 WIDGET TABEL OTHERS SA
// ======================================================
Widget buildOthersSaTable(
  OthersSaDataSource source,
  String headerLy,
  String headerLm,
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
            width: 115,
            label: _headerothersaCell('REGION', color: Colors.teal[900]!),
          ),
          GridColumn(
            columnName: 'dec24',
            width: 77,
            label: _headerothersaCell(headerLy, color: Colors.teal),
          ),
          GridColumn(
            columnName: 'sep25',
            width: 77,
            label: _headerothersaCell(headerLm, color: Colors.teal),
          ),
          GridColumn(
            columnName: 'oct13',
            width: 77,
            label: _headerothersaCell(headerToday, color: Colors.teal),
          ),
          GridColumn(
            columnName: 'dtd',
            label: _headerothersaCell('DTD', color: Colors.orange),
          ),
          GridColumn(
            columnName: 'mtd',
            label: _headerothersaCell('MTD', color: Colors.orange),
          ),
          GridColumn(
            columnName: 'ytd',
            label: _headerothersaCell('YTD', color: Colors.orange),
          ),
          GridColumn(
            columnName: 'vol',
            label: _headerothersaCell('Vol', color: Colors.green),
          ),
          GridColumn(
            columnName: 'noa',
            label: _headerothersaCell('NoA', color: Colors.green),
          ),
        ],
        stackedHeaderRows: [
          StackedHeaderRow(
            cells: [
              StackedHeaderCell(
                columnNames: ['dec24', 'sep25', 'oct13'],
                child: _stackedHeaderothersaCell(
                  'ACTUAL (IDR Bio)',
                  color: Colors.teal,
                ),
              ),
              StackedHeaderCell(
                columnNames: ['dtd', 'mtd', 'ytd'],
                child: _stackedHeaderothersaCell(
                  'GROWTH',
                  color: Colors.orange,
                ),
              ),
              StackedHeaderCell(
                columnNames: ['vol', 'noa'],
                child: _stackedHeaderothersaCell(
                  'New Rek OTHERS SA MTD',
                  color: Colors.green,
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
// 🔹 HEADER & STACKED HEADER CELL OTHERS SA
// ======================================================
Widget _headerothersaCell(String text, {required Color color}) {
  return Container(
    alignment: Alignment.center,
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

Widget _stackedHeaderothersaCell(String text, {required Color color}) {
  return Container(
    alignment: Alignment.center,
    color: color.withOpacity(0.85),
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
