import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class SnapshotcabangPage extends StatefulWidget {
  const SnapshotcabangPage({super.key});

  @override
  State<SnapshotcabangPage> createState() => _SnapshotcabangPageState();
}

class _SnapshotcabangPageState extends State<SnapshotcabangPage> {
  String username = "";
  String headerLy = '';
  String headerLm = '';
  String headerYesterday = '';
  String headerToday = '';

  //snapshot all
  SnapshotDataSource? _fundingDataSource;
  bool _isLoading = true;

  //casa only
  CasaOnlyDataSource? _casaOnlyDataSource;
  bool _isCasaLoading = true;

  //tabungan only
  TabunganDataSource? _TabunganDataSource;
  bool _isTabunganLoading = true;

  //consumer only
  ConsumerOnlyDataSource? _consumerOnlyDataSource;
  bool _isConsumerOnlyLoading = true;

  //booking consumer
  BookingConsumerDataSource? _bookingConsumerDataSource;
  bool _isBookingConsumerLoading = true;

  //banca sunlife
  SunlifeOnlyDataSource? _sunlifeOnlyDataSource;
  bool _isSunlifeOnlyLoading = true;

  //SME ONLY
  SmeOnlyDataSource? _smeOnlyDataSource;
  bool _isSmeOnlyLoading = true;

  //BOOKING SME
  BookingSmeOnlyDataSource? _bookingsmeOnlyDataSource;
  bool _isBookingsmeOnlyLoading = true;

  //QUALITY CONSUMER
  QualityConsumerDataSource? _qualityConsumerDataSource;
  bool _isQualityConsumerLoading = true;

  //QUALITY SME
  QualitySmeDataSource? _qualitySmeDataSource;
  bool _isQualitySmeLoading = true;

  //PORSI HAJI
  PorsiHajiDataSource? _porsiHajiDataSource;
  bool _isPorsiHajiLoading = true;

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
      await fetchTabunganData();
      await fetchConsumerOnlyData();
      await fetchBookingConsumerData();
      await fetchSunlifeOnlyData();
      await fetchSmeOnlyData();
      await fetchBookingsmeOnlyData();
      await fetchQualityConsumerData();
      await fetchQualitySmeData();
      await fetchPorsiHajiData();
    });
  }

  Future<void> fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    username = prefs.getString("username") ?? "";

    await fetchDummyData();
  }

  Future<void> fetchDummyData() async {
  try {
    // 🔹 Ambil region & level dari SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final region = prefs.getString('region') ?? '';
    final level = prefs.getInt('level') ?? 4;

    // 🔹 Buat URL dengan parameter level & region
    final url = Uri.parse(
      "http://103.59.95.71/api_performance/snapshot_fundingall.php?level=$level&region=$region",
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      if (jsonData["status"] == "success") {
        final List<dynamic> data = jsonData["data"];
        final header = jsonData["header"];

          setState(() {
            headerLy = header["ly"] ?? '';
            headerLm = header["lm"] ?? '';
            headerToday = header["today"] ?? '';
          });

        // 🔹 Mapping JSON ke model
        final fundingAll = data.map((item) {
          return SnapshotModel(
            region: item["region"],
            dec24: double.tryParse(item["dec24"].toString()) ?? 0,
            sep25: double.tryParse(item["sep25"].toString()) ?? 0,
            oct13: double.tryParse(item["oct13"].toString()) ?? 0,
            dtd: double.tryParse(item["dtd"].toString()) ?? 0,
            mtd: double.tryParse(item["mtd"].toString()) ?? 0,
            ytd: double.tryParse(item["ytd"].toString()) ?? 0,
            target: double.tryParse(item["target"].toString()) ?? 0,
            gap: double.tryParse(item["gap"].toString()) ?? 0,
          );
        }).toList();

        setState(() {
          _fundingDataSource = SnapshotDataSource(fundingAll);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        debugPrint("Data kosong atau status != success");
      }
    } else {
      setState(() => _isLoading = false);
      debugPrint("Request gagal: ${response.statusCode}");
    }
  } catch (e) {
    setState(() => _isLoading = false);
    debugPrint("Error mengambil data: $e");
  }
}


  //casa only
  Future<void> fetchCasaOnlyData() async {
    try {
      final url = Uri.parse(
        "http://103.59.95.71/api_performance/snapshot_casaonly.php",
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
                  target: double.tryParse(item["target"].toString()) ?? 0,
                  gap: double.tryParse(item["gap"].toString()) ?? 0,
                );
              }).toList();

          setState(() {
            _casaOnlyDataSource = CasaOnlyDataSource(casaList);
            _isCasaLoading = false;
          });
        } else {
          setState(() => _isCasaLoading = false);
          debugPrint("CASA data kosong");
        }
      } else {
        setState(() => _isCasaLoading = false);
        debugPrint("Gagal request CASA: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => _isCasaLoading = false);
      debugPrint("Error CASA: $e");
    }
  }

  // tabungan
  Future<void> fetchTabunganData() async {
    try {
      final url = Uri.parse(
        "http://103.59.95.71/api_performance/snapshot_tabungan.php",
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData["status"] == "success") {
          final List<dynamic> data = jsonData["data"];

          final tabunganList =
              data.map((item) {
                return TabunganModel(
                  region: item["region"],
                  saS09: double.tryParse(item["saS09"].toString()) ?? 0,
                  saTpb: double.tryParse(item["saTpb"].toString()) ?? 0,
                  saWadiah: double.tryParse(item["saWadiah"].toString()) ?? 0,
                  allSa: double.tryParse(item["allSa"].toString()) ?? 0,
                  ytdSaS09: double.tryParse(item["ytdSaS09"].toString()) ?? 0,
                  ytdSaTpb: double.tryParse(item["ytdSaTpb"].toString()) ?? 0,
                  ytdSaWadiah:
                      double.tryParse(item["ytdSaWadiah"].toString()) ?? 0,
                  ytdAllSa: double.tryParse(item["ytdAllSa"].toString()) ?? 0,
                  newVol: double.tryParse(item["newVol"].toString()) ?? 0,
                  newNoa: double.tryParse(item["newNoa"].toString()) ?? 0,
                );
              }).toList();

          setState(() {
            _TabunganDataSource = TabunganDataSource(tabunganList);
            _isTabunganLoading = false;
          });
        } else {
          setState(() => _isTabunganLoading = false);
          debugPrint("Tabungan data kosong");
        }
      } else {
        setState(() => _isTabunganLoading = false);
        debugPrint("Gagal request Tabungan: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => _isTabunganLoading = false);
      debugPrint("Error Tabungan: $e");
    }
  }

  //consumer only
  Future<void> fetchConsumerOnlyData() async {
    try {
      final url = Uri.parse(
        "http://103.59.95.71/api_performance/snapshot_consumeronly.php",
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
                  target: double.tryParse(item["target"].toString()) ?? 0,
                  gap: double.tryParse(item["gap"].toString()) ?? 0,
                );
              }).toList();

          setState(() {
            _consumerOnlyDataSource = ConsumerOnlyDataSource(consumerList);
            _isConsumerOnlyLoading = false;
          });
        } else {
          setState(() => _isConsumerOnlyLoading = false);
          debugPrint("CONSUMER data kosong");
        }
      } else {
        setState(() => _isConsumerOnlyLoading = false);
        debugPrint("Gagal request CONSUMER: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => _isConsumerOnlyLoading = false);
      debugPrint("Error CONSUMER: $e");
    }
  }

  // booking consumer
  Future<void> fetchBookingConsumerData() async {
    try {
      final url = Uri.parse(
        "http://103.59.95.71/api_performance/snapshot_bookingcon.php",
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData["status"] == "success") {
          final List<dynamic> data = jsonData["data"];
          final header = jsonData["header"]; // 🔹 Ambil header dari API

          // 🔹 Update header grid
          setState(() {
            headerYesterday = header["yesterday"] ?? "Yesterday";
            headerToday = header["today"] ?? "Today";
          });

          // 🔹 Mapping data ke model
          final bookingconsumerList =
              data.map((item) {
                return BookingConsumerModel(
                  region: item["region"],
                  oct10: double.tryParse(item["oct10"].toString()) ?? 0,
                  oct13: double.tryParse(item["oct13"].toString()) ?? 0,
                  mtd: double.tryParse(item["mtd"].toString()) ?? 0,
                  ytd: double.tryParse(item["ytd"].toString()) ?? 0,
                  kpr: double.tryParse(item["kpr"].toString()) ?? 0,
                  mg: double.tryParse(item["mg"].toString()) ?? 0,
                  soleh: double.tryParse(item["soleh"].toString()) ?? 0,
                  prohajj: double.tryParse(item["prohajj"].toString()) ?? 0,
                );
              }).toList();

          setState(() {
            _bookingConsumerDataSource = BookingConsumerDataSource(
              bookingconsumerList,
            );
            _isBookingConsumerLoading = false;
          });
        } else {
          setState(() => _isBookingConsumerLoading = false);
          debugPrint("Booking Consumer data kosong");
        }
      } else {
        setState(() => _isBookingConsumerLoading = false);
        debugPrint("Gagal request Booking Consumer: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => _isBookingConsumerLoading = false);
      debugPrint("Error Booking Consumer: $e");
    }
  }

  //sunlife only
  Future<void> fetchSunlifeOnlyData() async {
    setState(() {
      _isSunlifeOnlyLoading = true;
    });

    try {
      final url = Uri.parse(
        "http://103.59.95.71/api_performance/snapshot_banca.php",
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData["status"] == "success" && jsonData["data"] != null) {
          final List<dynamic> data = jsonData["data"];

          // 🔹 Ambil header tanggal dari API
          final header = jsonData["header"];
          final yesterday = header?["yesterday"] ?? "Yesterday";
          final today = header?["today"] ?? "Today";

          // 🔹 Mapping data ke model
          final sunlifeonlyList =
              data.map((item) => SunlifeOnlyModel.fromJson(item)).toList();

          setState(() {
            _sunlifeOnlyDataSource = SunlifeOnlyDataSource(sunlifeonlyList);
            headerYesterday = yesterday;
            headerToday = today;
            _isSunlifeOnlyLoading = false;
          });

          debugPrint("Sunlife Only Loaded: ${sunlifeonlyList.length} data");
          debugPrint("Header: Yesterday=$yesterday, Today=$today");
        } else {
          setState(() => _isSunlifeOnlyLoading = false);
          debugPrint("Sunlife Only data kosong atau status bukan success");
        }
      } else {
        setState(() => _isSunlifeOnlyLoading = false);
        debugPrint("❌ Gagal request Sunlife Only: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => _isSunlifeOnlyLoading = false);
      debugPrint("❌ Error Sunlife Only: $e");
    }
  }

  //sme only
  Future<void> fetchSmeOnlyData() async {
    try {
      final url = Uri.parse(
        "http://103.59.95.71/api_performance/snapshot_smeonly.php",
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
                  target: double.tryParse(item["target"].toString()) ?? 0,
                  gap: double.tryParse(item["gap"].toString()) ?? 0,
                );
              }).toList();

          setState(() {
            _smeOnlyDataSource = SmeOnlyDataSource(smeList);
            _isSmeOnlyLoading = false;
          });
        } else {
          setState(() => _isSmeOnlyLoading = false);
          debugPrint("SME data kosong");
        }
      } else {
        setState(() => _isSmeOnlyLoading = false);
        debugPrint("❌ Gagal request SME: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => _isSmeOnlyLoading = false);
      debugPrint("❌ Error SME: $e");
    }
  }

  // 🔹 Booking SME Only
  Future<void> fetchBookingsmeOnlyData() async {
    setState(() {
      _isBookingsmeOnlyLoading = true;
    });

    try {
      final url = Uri.parse(
        "http://103.59.95.71/api_performance/snapshot_bookingsme.php",
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData["status"] == "success" && jsonData["data"] != null) {
          final List<dynamic> data = jsonData["data"];

          // 🔹 Ambil header tanggal dari API
          final header = jsonData["header"];
          final yesterday = header?["yesterday"] ?? "Yesterday";
          final today = header?["today"] ?? "Today";

          // 🔹 Mapping data ke model
          final bookingsmeList =
              data.map((item) {
                return BookingSmeOnlyModel(
                  region: item["region"],
                  oct10: double.tryParse(item["oct10"].toString()) ?? 0,
                  oct13: double.tryParse(item["oct13"].toString()) ?? 0,
                  mtd: double.tryParse(item["mtd"].toString()) ?? 0,
                  ytd: double.tryParse(item["ytd"].toString()) ?? 0,
                  target: double.tryParse(item["target"].toString()) ?? 0,
                  gap: double.tryParse(item["gap"].toString()) ?? 0,
                );
              }).toList();

          // 🔹 Update state
          setState(() {
            _bookingsmeOnlyDataSource = BookingSmeOnlyDataSource(
              bookingsmeList,
            );
            headerYesterday = yesterday;
            headerToday = today;
            _isBookingsmeOnlyLoading = false;
          });

          debugPrint("Booking SME Loaded: ${bookingsmeList.length} data");
          debugPrint("Header: Yesterday=$yesterday, Today=$today");
        } else {
          setState(() => _isBookingsmeOnlyLoading = false);
          debugPrint("BOOKING SME data kosong atau status bukan success");
        }
      } else {
        setState(() => _isBookingsmeOnlyLoading = false);
        debugPrint("❌ Gagal request Booking SME: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => _isBookingsmeOnlyLoading = false);
      debugPrint("Error Booking SME: $e");
    }
  }

  // QUALITY CONSUMER
Future<void> fetchQualityConsumerData() async {
  try {
    final url = Uri.parse(
      "http://103.59.95.71/api_performance/snapshot_qualitycon.php",
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      if (jsonData["status"] == "success") {
        final List<dynamic> data = jsonData["data"];

        double parseDouble(dynamic value) {
          if (value == null || value.toString().trim().isEmpty) return 0;
          return double.tryParse(value.toString()) ?? 0;
        }

        final qualityConsumerList = data.map((item) {
          return QualityConsumerModel(
            region: item["region"] ?? "-",
            kol2LmVol: parseDouble(item["kol2LmVol"]),
            kol2TodayVol: parseDouble(item["kol2TodayVol"]),
            kol2LmPct: parseDouble(item["kol2LmPct"]),
            kol2TodayPct: parseDouble(item["kol2TodayPct"]),
            kol2MtdVarVol: parseDouble(item["kol2MtdVarVol"]),
            kol2YtdVarVol: parseDouble(item["kol2YtdVarVol"]),
            npfLmVol: parseDouble(item["npfLmVol"]),
            npfTodayVol: parseDouble(item["npfTodayVol"]),
            npfLmPct: parseDouble(item["npfLmPct"]),
            npfTodayPct: parseDouble(item["npfTodayPct"]),
            npfMtdVarVol: parseDouble(item["npfMtdVarVol"]),
            npfYtdVarVol: parseDouble(item["npfYtdVarVol"]),
          );
        }).toList();

        setState(() {
          _qualityConsumerDataSource = QualityConsumerDataSource(qualityConsumerList);
          _isQualityConsumerLoading = false;
        });
      } else {
        setState(() => _isQualityConsumerLoading = false);
        debugPrint("QUALITY CONSUMER data kosong");
      }
    } else {
      setState(() => _isQualityConsumerLoading = false);
      debugPrint("❌ Gagal request Quality Consumer: ${response.statusCode}");
    }
  } catch (e) {
    setState(() => _isQualityConsumerLoading = false);
    debugPrint("Error QUALITY CONSUMER: $e");
  }
}


  // QUALITY SME
Future<void> fetchQualitySmeData() async {
  try {
    final url = Uri.parse(
      "http://103.59.95.71/api_performance/snapshot_qualitysme.php",
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      if (jsonData["status"] == "success" && jsonData["data"] != null) {
        final List<dynamic> data = jsonData["data"];

        // 🔹 Ambil header tanggal dari API
        final header = jsonData["header"];
        final headerLm = header?["lm"] ?? "Last Month";
        final headerToday = header?["today"] ?? "Today";

        // 🔹 Mapping data ke model
        final qualitySmeList = data.map((item) {
          return QualitySmeModel(
            region: item["region"],

            // KOL2
            kol2LmVol: double.tryParse(item["kol2LmVol"].toString()) ?? 0,
            kol2TodayVol: double.tryParse(item["kol2TodayVol"].toString()) ?? 0,
            kol2LmPct: double.tryParse(item["kol2LmPct"].toString()) ?? 0,
            kol2TodayPct: double.tryParse(item["kol2TodayPct"].toString()) ?? 0,
            kol2MtdVarVol:
                double.tryParse(item["kol2MtdVarVol"].toString()) ?? 0,
            kol2YtdVarVol:
                double.tryParse(item["kol2YtdVarVol"].toString()) ?? 0,

            // NPF
            npfLmVol: double.tryParse(item["npfLmVol"].toString()) ?? 0,
            npfTodayVol: double.tryParse(item["npfTodayVol"].toString()) ?? 0,
            npfLmPct: double.tryParse(item["npfLmPct"].toString()) ?? 0,
            npfTodayPct: double.tryParse(item["npfTodayPct"].toString()) ?? 0,
            npfMtdVarVol:
                double.tryParse(item["npfMtdVarVol"].toString()) ?? 0,
            npfYtdVarVol:
                double.tryParse(item["npfYtdVarVol"].toString()) ?? 0,
          );
        }).toList();

        // 🔹 Update state
        setState(() {
          _qualitySmeDataSource = QualitySmeDataSource(qualitySmeList);
          this.headerLm = headerLm;
          this.headerToday = headerToday;
          _isQualitySmeLoading = false;
        });

        debugPrint("QUALITY SME Loaded: ${qualitySmeList.length} data");
        debugPrint("Header: LM=$headerLm, Today=$headerToday");
      } else {
        setState(() => _isQualitySmeLoading = false);
        debugPrint("QUALITY SME data kosong atau status bukan success");
      }
    } else {
      setState(() => _isQualitySmeLoading = false);
      debugPrint("❌ Gagal request QUALITY SME: ${response.statusCode}");
    }
  } catch (e) {
    setState(() => _isQualitySmeLoading = false);
    debugPrint("💥 Error QUALITY SME: $e");
  }
}

  // PORSI HAJI
  Future<void> fetchPorsiHajiData() async {
    try {
      final url = Uri.parse(
        "http://103.59.95.71/api_performance/snapshot_porsihaji.php",
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData["status"] == "success") {
          final List<dynamic> data = jsonData["data"];
          final header = jsonData["header"]; // 🔹 Ambil header tanggal dari API

          // 🔹 Ambil nilai header tanggal
          final yesterday = header?["yesterday"] ?? "Yesterday";
          final today = header?["today"] ?? "Today";

          // 🔹 Mapping data ke model
          final porsiHajiList =
              data.map((item) {
                return PorsiHajiModel(
                  region: item["region"] ?? "-",
                  oct10: double.tryParse(item["oct10"].toString()) ?? 0,
                  oct13: double.tryParse(item["oct13"].toString()) ?? 0,
                  reguler: double.tryParse(item["reguler"].toString()) ?? 0,
                  khusus: double.tryParse(item["khusus"].toString()) ?? 0,
                  total: double.tryParse(item["total"].toString()) ?? 0,
                  act: double.tryParse(item["act"].toString()) ?? 0,
                  targetOkt: double.tryParse(item["targetOkt"].toString()) ?? 0,
                  acv: double.tryParse(item["acv"].toString()) ?? 0,
                );
              }).toList();

          // 🔹 Update state
          setState(() {
            _porsiHajiDataSource = PorsiHajiDataSource(porsiHajiList);
            headerYesterday = yesterday;
            headerToday = today;
            _isPorsiHajiLoading = false;
          });

          debugPrint("Porsi Haji Loaded: ${porsiHajiList.length} data");
          debugPrint("Header: Yesterday=$yesterday, Today=$today");
        } else {
          setState(() => _isPorsiHajiLoading = false);
          debugPrint("Porsi Haji data kosong atau status bukan success");
        }
      } else {
        setState(() => _isPorsiHajiLoading = false);
        debugPrint("❌ Gagal request Porsi Haji: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => _isPorsiHajiLoading = false);
      debugPrint("❌ Error Porsi Haji: $e");
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

        debugPrint("Header berhasil diupdate: $headerToday | $headerYesterday | $headerLm | $headerLy");
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
      _isTabunganLoading = true;
      _isConsumerOnlyLoading = true;
      _isBookingConsumerLoading = true;
      _isSunlifeOnlyLoading = true;
      _isSmeOnlyLoading = true;
      _isBookingsmeOnlyLoading = true;
      _isQualityConsumerLoading = true;
      _isQualitySmeLoading = true;
      _isPorsiHajiLoading = true;
    });

    await fetchHeaderDate();
    await Future.wait([
      fetchUserData(),
      fetchCasaOnlyData(),
      fetchTabunganData(),
      fetchConsumerOnlyData(),
      fetchBookingConsumerData(),
      fetchSunlifeOnlyData(),
      fetchSmeOnlyData(),
      fetchBookingsmeOnlyData(),
      fetchQualityConsumerData(),
      fetchQualitySmeData(),
      fetchPorsiHajiData(),
      
    ]);

    setState(() {
      _isLoading = false;
      _isCasaLoading = false;
      _isTabunganLoading = false;
      _isConsumerOnlyLoading = false;
      _isBookingConsumerLoading = false;
      _isSunlifeOnlyLoading = false;
      _isSmeOnlyLoading = false;
      _isBookingsmeOnlyLoading = false;
      _isQualityConsumerLoading = false;
      _isQualitySmeLoading = false;
      _isPorsiHajiLoading = false;
    });
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
              columnName: 'target',
              label: _headerCell('YTD Growth', color: Colors.purple[700]!),
            ),
            GridColumn(
              columnName: 'gap',
              label: _headerCell('Gap', color: Colors.purple[700]!),
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
                  columnNames: ['target', 'gap'],
                  child: _stackedHeaderCell(
                    'TARGET',
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
          "Snapshot Region",
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
                    // SECTION 1 - FUNDING
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.blue[900],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Text(
                        "FUNDING",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // FUNDING ALL
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
                        "FUNDING ALL",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
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

                    const SizedBox(height: 28),

                    // CASA ONLY
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
                        "CASA ONLY",
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
                        ? const Text("Data CASA belum tersedia")
                        : _buildCasaOnlyTable(
                          _casaOnlyDataSource!,
                          headerLy,
                          headerLm,
                          headerToday,
                        ),

                    const SizedBox(height: 28),

                    // TABUNGAN
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
                        "TABUNGAN",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),
                    _isTabunganLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _TabunganDataSource == null
                        ? const Text("Data CASA belum tersedia")
                        : _buildTabunganTable(_TabunganDataSource!),
                    const SizedBox(height: 20),

                    // SECTION 2: CONSUMER
                    const SizedBox(height: 10),
                    const Divider(thickness: 2),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.blue[900],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Text(
                        "CONSUMER",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Consumer
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
                        "CONSUMER",
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
                        ? const Text("Data CONSUMER belum tersedia")
                        : _buildConsumerOnlyTable(
                          _consumerOnlyDataSource!,
                          headerLy,
                          headerLm,
                          headerToday,
                        ),
                    const SizedBox(height: 28),

                    // Booking Consumer
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
                        "BOOKING CONSUMER",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 251, 189, 32),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _isBookingConsumerLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _bookingConsumerDataSource == null
                        ? const Text("Data CONSUMER belum tersedia")
                        : _buildBookingConsumerTable(
                          _bookingConsumerDataSource!,
                          headerYesterday,
                          headerToday,
                        ),

                    // SECTION 3: BANCASSURANCE
                    const SizedBox(height: 32),
                    const Divider(thickness: 2),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.blue[900],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Text(
                        "BANCASSURANCE (SUNLIFE)",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // SUNLIFE ONLY
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(
                          255,
                          227,
                          253,
                          227,
                        ), // background lembut
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color.fromARGB(255, 144, 249, 151),
                          width: 1,
                        ),
                      ),
                      child: const Text(
                        "SUNLIFE ONLY",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 27, 125, 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _isSunlifeOnlyLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _sunlifeOnlyDataSource == null
                        ? const Text("Data Sunlife belum tersedia")
                        : _buildSunlifeOnlyTable(
                          _sunlifeOnlyDataSource!,
                          headerYesterday,
                          headerToday,
                        ),

                    // SECTION 4: SME
                    const SizedBox(height: 32),
                    const Divider(thickness: 2),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.blue[900],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Text(
                        "SME",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // SME
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
                        "SME",
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
                    const SizedBox(height: 28),

                    // Booking SME
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
                        "BOOKING SME",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 251, 90, 32),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _isBookingsmeOnlyLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _bookingsmeOnlyDataSource == null
                        ? const Text("Data Sunlife belum tersedia")
                        : _buildBookingSmeOnlyTable(
                          _bookingsmeOnlyDataSource!,
                          headerYesterday,
                          headerToday,
                        ),

                    // SECTION 5: FINANCING QUALITY
                    const SizedBox(height: 32),
                    const Divider(thickness: 2),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.blue[900],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Text(
                        "FINANCING QUALITY",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // QUALITY CONSUMER
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(
                          255,
                          232,
                          227,
                          253,
                        ), // background lembut
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color.fromARGB(255, 184, 144, 249),
                          width: 1,
                        ),
                      ),
                      child: const Text(
                        "QUALITY CONSUMER",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 123, 32, 251),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _isQualityConsumerLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _qualityConsumerDataSource == null
                        ? const Text("Data Sunlife belum tersedia")
                        : buildQualityConsumerTable(
                          _qualityConsumerDataSource!,
                          headerLm,
                          headerToday,
                        ),
                    const SizedBox(height: 28),

                    // QUALITY SME
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(
                          255,
                          232,
                          227,
                          253,
                        ), // background lembut
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color.fromARGB(255, 184, 144, 249),
                          width: 1,
                        ),
                      ),
                      child: const Text(
                        "QUALITY SME",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 123, 32, 251),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _isQualitySmeLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _qualitySmeDataSource == null
                        ? const Text("Data Sunlife belum tersedia")
                        : buildQualitySmeTable(
                          _qualitySmeDataSource!,
                          headerLm,
                          headerToday,
                        ),

                    // SECTION 6: PORSI HAJI
                    const SizedBox(height: 32),
                    const Divider(thickness: 2),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.blue[900],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Text(
                        "PORSI HAJI",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // SPORSI HAJI
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(
                          255,
                          253,
                          227,
                          245,
                        ), // background lembut
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color.fromARGB(255, 249, 144, 226),
                          width: 1,
                        ),
                      ),
                      child: const Text(
                        "PORSI HAJI",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 251, 32, 185),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _isPorsiHajiLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _porsiHajiDataSource == null
                        ? const Text("Data Sunlife belum tersedia")
                        : buildPorsiHajiTable(
                          _porsiHajiDataSource!,
                          headerYesterday,
                          headerToday,
                        ),
                  ],
                ),
              ),
    );
  }
}

// =======================================================
// Model
// =======================================================
class SnapshotModel {
  final String region;
  final double dec24, sep25, oct13, dtd, mtd, ytd, target, gap;

  SnapshotModel({
    required this.region,
    required this.dec24,
    required this.sep25,
    required this.oct13,
    required this.dtd,
    required this.mtd,
    required this.ytd,
    required this.target,
    required this.gap,
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
                  DataGridCell(columnName: 'target', value: d.target),
                  DataGridCell(columnName: 'gap', value: d.gap),
                ],
              ),
            )
            .toList();
  }

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final NumberFormat numberFormat = NumberFormat.decimalPattern(
      'id',
    ); // Format Indonesia

    final rowIndex = _rows.indexOf(row);

    return DataGridRowAdapter(
      color: rowIndex.isEven ? Colors.grey[50] : Colors.white,
      cells:
          row.getCells().map((cell) {
            final value = cell.value;
            final isNumeric = value is num;
            final isNegative = isNumeric && value < 0;

            // Tentukan tampilan nilai
            String displayValue;
            if (isNumeric) {
              displayValue = numberFormat.format(
                value,
              ); // Format angka 1.000.000
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
                          : Colors.grey[800], // Warna merah jika negatif
                  fontWeight: FontWeight.w400,
                ),
              ),
            );
          }).toList(),
    );
  }
}

// ======================================================
//  CLASS CASA ONLY SECTION 1
// ======================================================
class CasaOnlyModel {
  final String region;
  final double dec24, sep25, oct13;
  final double dtd, mtd, ytd;
  final double target, gap;

  CasaOnlyModel({
    required this.region,
    required this.dec24,
    required this.sep25,
    required this.oct13,
    required this.dtd,
    required this.mtd,
    required this.ytd,
    required this.target,
    required this.gap,
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
                  DataGridCell(columnName: 'target', value: d.target),
                  DataGridCell(columnName: 'gap', value: d.gap),
                ],
              ),
            )
            .toList();
  }

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final NumberFormat numberFormat = NumberFormat.decimalPattern(
      'id',
    ); // Format Indonesia
    final rowIndex = _rows.indexOf(row);

    return DataGridRowAdapter(
      color: rowIndex.isEven ? Colors.grey[50] : Colors.white,
      cells:
          row.getCells().map((cell) {
            final value = cell.value;
            final isDouble = value is double;
            final isNegativeGap =
                cell.columnName == 'gap' && isDouble && value < 0;
            final isNegativeGrowth =
                ['dtd', 'mtd', 'ytd'].contains(cell.columnName) &&
                isDouble &&
                value < 0;

            // Tentukan warna background
            Color? bgColor;
            if (isNegativeGap || isNegativeGrowth) bgColor = Colors.red[100];

            // Format tampilan angka
            String displayValue;
            if (isDouble) {
              // contoh: 1.000.000,0 → dibulatkan 1 angka di belakang koma
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
            columnName: 'target',
            label: _headercasaCell('Target', color: Colors.green),
          ),
          GridColumn(
            columnName: 'gap',
            label: _headercasaCell('GAP', color: Colors.green),
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
                columnNames: ['target', 'gap'],
                child: _stackedHeadercasaCell('TARGET', color: Colors.green),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

// ======================================================
// CLASS TABUNGAN SECTION 1
// ======================================================
class TabunganModel {
  final String region;
  final double saS09, saTpb, saWadiah, allSa;
  final double ytdSaS09, ytdSaTpb, ytdSaWadiah, ytdAllSa;
  final double newVol, newNoa;

  TabunganModel({
    required this.region,
    required this.saS09,
    required this.saTpb,
    required this.saWadiah,
    required this.allSa,
    required this.ytdSaS09,
    required this.ytdSaTpb,
    required this.ytdSaWadiah,
    required this.ytdAllSa,
    required this.newVol,
    required this.newNoa,
  });
}

class TabunganDataSource extends DataGridSource {
  List<DataGridRow> _rows = [];

  TabunganDataSource(List<TabunganModel> data) {
    _rows =
        data
            .map(
              (d) => DataGridRow(
                cells: [
                  DataGridCell(columnName: 'region', value: d.region),
                  DataGridCell(columnName: 'saS09', value: d.saS09),
                  DataGridCell(columnName: 'saTpb', value: d.saTpb),
                  DataGridCell(columnName: 'saWadiah', value: d.saWadiah),
                  DataGridCell(columnName: 'allSa', value: d.allSa),
                  DataGridCell(columnName: 'ytdSaS09', value: d.ytdSaS09),
                  DataGridCell(columnName: 'ytdSaTpb', value: d.ytdSaTpb),
                  DataGridCell(columnName: 'ytdSaWadiah', value: d.ytdSaWadiah),
                  DataGridCell(columnName: 'ytdAllSa', value: d.ytdAllSa),
                  DataGridCell(columnName: 'newVol', value: d.newVol),
                  DataGridCell(columnName: 'newNoa', value: d.newNoa),
                ],
              ),
            )
            .toList();
  }

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final NumberFormat numberFormat = NumberFormat.decimalPattern(
      'id',
    ); // 🇮🇩 format Indonesia
    final rowIndex = _rows.indexOf(row);

    return DataGridRowAdapter(
      color: rowIndex.isEven ? Colors.grey[50] : Colors.white,
      cells:
          row.getCells().map((cell) {
            final value = cell.value;

            // Cek apakah nilai angka
            final bool isNumeric = value is num;
            final bool isNegative = isNumeric && value < 0;

            // Format angka sesuai Indonesia
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
              padding: const EdgeInsets.all(6),
              child: Text(
                displayValue,
                style: TextStyle(
                  fontSize: 9.5,
                  color: isNegative ? Colors.red[700] : Colors.grey[800],
                  fontWeight: FontWeight.w400,
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

// Header normal (bisa ganti warna background)
Widget _headerCell(String text, {Color? color}) {
  return Container(
    alignment: Alignment.center,
    padding: const EdgeInsets.all(8),
    color: color ?? Colors.blue[900], // pakai warna bawaan kalau nggak diisi
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

// Header gabungan (untuk stacked header)
Widget _stackedHeaderCell(String text, {Color color = Colors.grey}) {
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
// FUNGSI BUILD TABLE & DATA DUMMY
// ======================================================

Widget _buildTabunganTable(TabunganDataSource source) {
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
        rowHeight: 37,
        columnWidthMode: ColumnWidthMode.auto,
        columns: [
          GridColumn(
            columnName: 'region',
            width: 120,
            allowSorting: false,
            label: _headerCell('REGION'),
          ),
          GridColumn(
            columnName: 'saS09',
            width: 69,
            label: _headerCell('SA S09'),
          ),
          GridColumn(
            columnName: 'saTpb',
            width: 69,
            label: _headerCell('SA TPB'),
          ),
          GridColumn(
            columnName: 'saWadiah',
            width: 83,
            label: _headerCell('SA\nWadi’ah'),
          ),
          GridColumn(columnName: 'allSa', label: _headerCell('All SA')),
          GridColumn(columnName: 'ytdSaS09', label: _headerCell('SA S09')),
          GridColumn(columnName: 'ytdSaTpb', label: _headerCell('SA TPB')),
          GridColumn(
            columnName: 'ytdSaWadiah',
            label: _headerCell('SA Wadi’ah'),
          ),
          GridColumn(columnName: 'ytdAllSa', label: _headerCell('All SA')),
          GridColumn(
            columnName: 'newVol',
            width: 100,
            label: _headerCell('Vol'),
          ),
          GridColumn(
            columnName: 'newNoa',
            width: 100,
            label: _headerCell('NoA'),
          ),
        ],
        stackedHeaderRows: [
          StackedHeaderRow(
            cells: [
              StackedHeaderCell(
                columnNames: ['saS09', 'saTpb', 'saWadiah', 'allSa'],
                child: _stackedHeaderCell(
                  'MTD Growth',
                  color: Colors.lightBlue,
                ),
              ),
              StackedHeaderCell(
                columnNames: [
                  'ytdSaS09',
                  'ytdSaTpb',
                  'ytdSaWadiah',
                  'ytdAllSa',
                ],
                child: _stackedHeaderCell('YTD Growth', color: Colors.green),
              ),
              StackedHeaderCell(
                columnNames: ['newVol', 'newNoa'],
                child: _stackedHeaderCell(
                  'New Rek S09 MTD',
                  color: Colors.amber,
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
// CLASS CONSUMER SECTION 2 (FINAL, DARI SERVER)
// ======================================================

class ConsumerOnlyModel {
  final String region;
  final double dec24, sep25, oct13;
  final double dtd, mtd, ytd;
  final double target, gap;

  ConsumerOnlyModel({
    required this.region,
    required this.dec24,
    required this.sep25,
    required this.oct13,
    required this.dtd,
    required this.mtd,
    required this.ytd,
    required this.target,
    required this.gap,
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
                  DataGridCell(columnName: 'target', value: d.target),
                  DataGridCell(columnName: 'gap', value: d.gap),
                ],
              ),
            )
            .toList();
  }

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final NumberFormat numberFormat = NumberFormat.decimalPattern(
      'id',
    ); // Format angka Indonesia
    final rowIndex = _rows.indexOf(row);

    return DataGridRowAdapter(
      color: rowIndex.isEven ? Colors.grey[50] : Colors.white,
      cells:
          row.getCells().map((cell) {
            final value = cell.value;
            final isDouble = value is double;

            // Deteksi nilai negatif
            final isNegativeGap =
                cell.columnName == 'gap' && isDouble && value < 0;
            final isNegativeGrowth =
                ['dtd', 'mtd', 'ytd'].contains(cell.columnName) &&
                isDouble &&
                value < 0;

            // Warna background merah muda jika negatif
            Color? bgColor;
            if (isNegativeGap || isNegativeGrowth) bgColor = Colors.red[100];

            // Format tampilan angka
            String displayValue;
            if (isDouble) {
              // Gunakan format ribuan Indonesia
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
            columnName: 'target',
            label: _headerconCell('Target', color: Colors.green),
          ),
          GridColumn(
            columnName: 'gap',
            label: _headerconCell('GAP', color: Colors.green),
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
                columnNames: ['target', 'gap'],
                child: _stackedHeaderconCell('TARGET', color: Colors.green),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

// ======================================================
// CLASS BOOKING CONSUMER SECTION 2
// ======================================================

class BookingConsumerModel {
  final String region;
  final double oct10, oct13;
  final double mtd, ytd;
  final double kpr, mg, soleh, prohajj;

  BookingConsumerModel({
    required this.region,
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

class BookingConsumerDataSource extends DataGridSource {
  List<DataGridRow> _rows = [];

  BookingConsumerDataSource(List<BookingConsumerModel> data) {
    _rows =
        data
            .map(
              (d) => DataGridRow(
                cells: [
                  DataGridCell(columnName: 'region', value: d.region),
                  DataGridCell(columnName: 'oct10', value: d.oct10),
                  DataGridCell(columnName: 'oct13', value: d.oct13),
                  DataGridCell(columnName: 'mtd', value: d.mtd),
                  DataGridCell(columnName: 'ytd', value: d.ytd),
                  DataGridCell(columnName: 'kpr', value: d.kpr),
                  DataGridCell(columnName: 'mg', value: d.mg),
                  DataGridCell(columnName: 'soleh', value: d.soleh),
                  DataGridCell(columnName: 'prohajj', value: d.prohajj),
                ],
              ),
            )
            .toList();
  }

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final NumberFormat currencyFormat = NumberFormat.decimalPattern(
      'id',
    ); // format ribuan Indonesia
    final rowIndex = _rows.indexOf(row);

    return DataGridRowAdapter(
      color: rowIndex.isEven ? Colors.grey[50] : Colors.white,
      cells:
          row.getCells().map((cell) {
            final value = cell.value;
            String displayValue;

            if (value is double) {
              // Format angka desimal + pemisah ribuan
              // Contoh: 1234567.4 → 1.234.567,4
              displayValue = currencyFormat.format(value);
            } else {
              displayValue = value.toString();
            }

            return Container(
              alignment:
                  cell.columnName == 'region'
                      ? Alignment.centerLeft
                      : Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Text(displayValue, style: const TextStyle(fontSize: 9.5)),
            );
          }).toList(),
    );
  }
}

// ======================================================
// HEADER CELL HELPERS
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
// BUILD TABLE BOOKING CONSUMER
// ======================================================

Widget _buildBookingConsumerTable(
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
            width: 137,
            allowSorting: false,
            label: _headerBookingCell('REGION'),
          ),
          GridColumn(
            columnName: 'oct10',
            width: 102,
            label: _headerBookingCell(
              headerYesterday.isNotEmpty ? headerYesterday : 'Yesterday',
              color: Colors.orange,
            ),
          ),
          GridColumn(
            columnName: 'oct13',
            width: 102,
            label: _headerBookingCell(
              headerToday.isNotEmpty ? headerToday : 'Today',
              color: const Color.fromARGB(255, 32, 135, 34),
            ),
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
            columnName: 'kpr',
            label: _headerBookingCell('KPR', color: Colors.brown),
          ),
          GridColumn(
            columnName: 'mg',
            label: _headerBookingCell('MG', color: Colors.brown),
          ),
          GridColumn(
            columnName: 'soleh',
            label: _headerBookingCell('Soleh', color: Colors.brown),
          ),
          GridColumn(
            columnName: 'prohajj',
            label: _headerBookingCell('Prohajj', color: Colors.brown),
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
                columnNames: ['mtd', 'ytd'],
                child: _stackedHeaderBookingCell(
                  'Total Booking',
                  color: Colors.blue[900]!,
                ),
              ),
              StackedHeaderCell(
                columnNames: ['kpr', 'mg', 'soleh', 'prohajj'],
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
// CLASS SUNLIFE ONLY SECTION 3
// ======================================================

class SunlifeOnlyModel {
  final String region;
  final double oct10;
  final double oct13;
  final double booked;
  final double fbi;
  final double issuedH1;
  final double issued;
  final double targetYtdOkt;
  final double percentIssuedTarget;

  SunlifeOnlyModel({
    required this.region,
    required this.oct10,
    required this.oct13,
    required this.booked,
    required this.fbi,
    required this.issuedH1,
    required this.issued,
    required this.targetYtdOkt,
    required this.percentIssuedTarget,
  });

  factory SunlifeOnlyModel.fromJson(Map<String, dynamic> json) {
    double parseNum(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v.replaceAll(',', '')) ?? 0;
      return 0;
    }

    return SunlifeOnlyModel(
      region: json['region'] ?? '-',
      oct10: parseNum(json['oct10']),
      oct13: parseNum(json['oct13']),
      booked: parseNum(json['booked']),
      fbi: parseNum(json['fbi']),
      issuedH1: parseNum(json['issuedH1']),
      issued: parseNum(json['issued']),
      targetYtdOkt: parseNum(json['targetYtdOkt']),
      percentIssuedTarget: parseNum(json['percentIssuedTarget']),
    );
  }
}

class SunlifeOnlyDataSource extends DataGridSource {
  List<DataGridRow> _rows = [];

  SunlifeOnlyDataSource(List<SunlifeOnlyModel> data) {
    _rows =
        data
            .map(
              (d) => DataGridRow(
                cells: [
                  DataGridCell<String>(columnName: 'region', value: d.region),
                  DataGridCell<double>(columnName: 'oct10', value: d.oct10),
                  DataGridCell<double>(columnName: 'oct13', value: d.oct13),
                  DataGridCell<double>(columnName: 'booked', value: d.booked),
                  DataGridCell<double>(columnName: 'fbi', value: d.fbi),
                  DataGridCell<double>(
                    columnName: 'issuedH1',
                    value: d.issuedH1,
                  ),
                  DataGridCell<double>(columnName: 'issued', value: d.issued),
                  DataGridCell<double>(
                    columnName: 'targetYtdOkt',
                    value: d.targetYtdOkt,
                  ),
                  DataGridCell<double>(
                    columnName: 'percentIssuedTarget',
                    value: d.percentIssuedTarget,
                  ),
                ],
              ),
            )
            .toList();
  }

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final NumberFormat currencyFormat = NumberFormat(
      "#,##0.0",
      "id",
    ); // format Indonesia (1.000,0)
    final NumberFormat percentFormat = NumberFormat(
      "#,##0.000",
      "id",
    ); // untuk kolom persen
    final rowIndex = _rows.indexOf(row);

    return DataGridRowAdapter(
      color: rowIndex.isEven ? Colors.grey[50] : Colors.white,
      cells:
          row.getCells().map<Widget>((cell) {
            final isRegion = cell.columnName == 'region';
            final isPercent =
                cell.columnName == 'acv' ||
                cell.columnName == 'percentIssuedTarget';

            String displayValue;
            if (isRegion) {
              displayValue = cell.value.toString();
            } else if (cell.value is num) {
              if (isPercent) {
                // Kolom persen (3 desimal)
                displayValue = percentFormat.format(cell.value);
              } else {
                // 🔹 Kolom angka biasa (pakai format ribuan)
                displayValue = currencyFormat.format(cell.value);
              }
            } else {
              displayValue = cell.value.toString();
            }

            return Container(
              alignment: isRegion ? Alignment.centerLeft : Alignment.center,
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 6,
              ), // tambah vertical biar lega
              child: Text(
                displayValue,
                style: TextStyle(
                  fontSize: 9.5, // sedikit lebih besar biar nyaman dibaca
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w400, // font lembut
                ),
              ),
            );
          }).toList(),
    );
  }
}

// ======================================================
// 🔹 Header helper widgets
Widget _headerSunlifeCell(String text, {Color color = Colors.green}) {
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

Widget _stackedHeaderSunlifeCell(String text, {Color color = Colors.grey}) {
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
// 🔹 Build table (Booked sudah pindah ke MTD)
Widget _buildSunlifeOnlyTable(
  SunlifeOnlyDataSource source,
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
            width: 135,
            allowSorting: false,
            label: _headerSunlifeCell('Region', color: Colors.deepPurple),
          ),
          GridColumn(
            columnName: 'oct10',
            width: 103,
            label: _headerSunlifeCell(
              headerYesterday.isNotEmpty ? headerYesterday : 'Yesterday',
              color: Colors.orange[700]!,
            ),
          ),
          GridColumn(
            columnName: 'oct13',
            width: 103,
            label: _headerSunlifeCell(
              headerToday.isNotEmpty ? headerToday : 'Today',
              color: Colors.orange[700]!,
            ),
          ),
          GridColumn(
            columnName: 'booked',
            width: 80,
            label: _headerSunlifeCell('Booked', color: Colors.green[600]!),
          ),
          GridColumn(
            columnName: 'fbi',
            width: 65,
            label: _headerSunlifeCell('FBI', color: Colors.green[600]!),
          ),
          GridColumn(
            columnName: 'issuedH1',
            width: 75,
            label: _headerSunlifeCell(
              'Issued (H-1)',
              color: Colors.green[600]!,
            ),
          ),
          GridColumn(
            columnName: 'issued',
            width: 77,
            label: _headerSunlifeCell('Issued', color: Colors.green[800]!),
          ),
          GridColumn(
            columnName: 'targetYtdOkt',
            width: 103,
            label: _headerSunlifeCell(
              'Target YTD Okt',
              color: Colors.yellow[800]!,
            ),
          ),
          GridColumn(
            columnName: 'percentIssuedTarget',
            width: 103,
            label: _headerSunlifeCell(
              '% Issued vs Target (YTD)',
              color: Colors.yellow[800]!,
            ),
          ),
        ],
        // 2 stacked header rows
        stackedHeaderRows: [
          // Baris 1 — AFYP (IDR Mio) full sampai kanan
          StackedHeaderRow(
            cells: [
              StackedHeaderCell(
                columnNames: [
                  'oct10',
                  'oct13',
                  'booked',
                  'fbi',
                  'issuedH1',
                  'issued',
                  'targetYtdOkt',
                  'percentIssuedTarget',
                ],
                child: _stackedHeaderSunlifeCell(
                  'AFYP (IDR Mio)',
                  color: Colors.green,
                ),
              ),
            ],
          ),

          // Baris 2 — Subheader di bawah AFYP
          StackedHeaderRow(
            cells: [
              StackedHeaderCell(
                columnNames: ['oct10', 'oct13'],
                child: _stackedHeaderSunlifeCell(
                  'Last Day Booked',
                  color: Colors.orange[700]!,
                ),
              ),
              StackedHeaderCell(
                columnNames: ['booked', 'fbi', 'issuedH1'],
                child: _stackedHeaderSunlifeCell(
                  'MTD',
                  color: Colors.green[600]!,
                ),
              ),
              StackedHeaderCell(
                columnNames: ['issued'],
                child: _stackedHeaderSunlifeCell(
                  'YTD',
                  color: Colors.green[800]!,
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
// 🔹 CLASS SME SECTION 4
// ======================================================

class SmeOnlyModel {
  final String region;
  final double dec24, sep25, oct13;
  final double dtd, mtd, ytd;
  final double target, gap;

  SmeOnlyModel({
    required this.region,
    required this.dec24,
    required this.sep25,
    required this.oct13,
    required this.dtd,
    required this.mtd,
    required this.ytd,
    required this.target,
    required this.gap,
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
                  DataGridCell(columnName: 'target', value: d.target),
                  DataGridCell(columnName: 'gap', value: d.gap),
                ],
              ),
            )
            .toList();
  }

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final NumberFormat numberFormat = NumberFormat(
      "#,##0.0",
      "id",
    ); // format 1.000,0
    final rowIndex = _rows.indexOf(row);

    return DataGridRowAdapter(
      color: rowIndex.isEven ? Colors.grey[50] : Colors.white,
      cells:
          row.getCells().map((cell) {
            final isRegion = cell.columnName == 'region';
            final isNegativeGap =
                cell.columnName == 'gap' &&
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
            columnName: 'growth',
            label: _headersmeCell('Growth', color: Colors.green),
          ),
          GridColumn(
            columnName: 'gap',
            label: _headersmeCell('GAP', color: Colors.green),
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
                columnNames: ['growth', 'gap'],
                child: _stackedHeadersmeCell(
                  'Target Full Year',
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
// 🔹 CLASS BOOKING SME SECTION 4
// ======================================================

class BookingSmeOnlyModel {
  final String region;
  final double oct10, oct13;
  final double mtd, ytd;
  final double target, gap;

  BookingSmeOnlyModel({
    required this.region,
    required this.oct10,
    required this.oct13,
    required this.mtd,
    required this.ytd,
    required this.target,
    required this.gap,
  });
}

class BookingSmeOnlyDataSource extends DataGridSource {
  List<DataGridRow> _rows = [];

  BookingSmeOnlyDataSource(List<BookingSmeOnlyModel> data) {
    _rows =
        data
            .map(
              (d) => DataGridRow(
                cells: [
                  DataGridCell(columnName: 'region', value: d.region),
                  DataGridCell(columnName: 'sep25', value: d.oct10),
                  DataGridCell(columnName: 'oct13', value: d.oct13),
                  DataGridCell(columnName: 'mtd', value: d.mtd),
                  DataGridCell(columnName: 'ytd', value: d.ytd),
                  DataGridCell(columnName: 'target', value: d.target),
                  DataGridCell(columnName: 'gap', value: d.gap),
                ],
              ),
            )
            .toList();
  }

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final NumberFormat numberFormat = NumberFormat(
      "#,##0.0",
      "id",
    ); // format angka Indonesia
    final rowIndex = _rows.indexOf(row);

    return DataGridRowAdapter(
      color: rowIndex.isEven ? Colors.grey[50] : Colors.white,
      cells:
          row.getCells().map((cell) {
            final isRegion = cell.columnName == 'region';
            final isNegativeGap =
                cell.columnName == 'gap' &&
                (cell.value is num && cell.value < 0);
            final isNegativeGrowth =
                ['mtd', 'ytd'].contains(cell.columnName) &&
                (cell.value is num && cell.value < 0);

            Color? bgColor;
            if (isNegativeGrowth) bgColor = Colors.red[100];
            if (isNegativeGap) bgColor = Colors.red[100];

            // 🔹 Format tampilan nilai
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
// 🔹 Helper untuk Header Cell dan Stacked Header Cell
// ======================================================

Widget _headerbookingsmeCell(
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

Widget _stackedHeaderbookingsmeCell(String text, {Color color = Colors.grey}) {
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

Widget _buildBookingSmeOnlyTable(
  BookingSmeOnlyDataSource source,
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
        headerRowHeight: 43,
        rowHeight: 35,
        columnWidthMode: ColumnWidthMode.auto,
        columns: [
          GridColumn(
            columnName: 'region',
            width: 150,
            allowSorting: false,
            label: _headerbookingsmeCell('REGION'),
          ),
          GridColumn(
            columnName: 'oct10',
            width: 90,
            label: _headerbookingsmeCell(
              headerYesterday, // 🔹 otomatis ambil dari API
              color: Colors.deepPurple,
            ),
          ),
          GridColumn(
            columnName: 'oct13',
            width: 90,
            label: _headerbookingsmeCell(
              headerToday, // 🔹 otomatis ambil dari API
              color: const Color.fromARGB(255, 32, 135, 34),
            ),
          ),

          GridColumn(
            columnName: 'mtd',
            width: 100,
            label: _headerbookingsmeCell('MTD', color: Colors.orange),
          ),
          GridColumn(
            columnName: 'ytd',
            width: 130,
            label: _headerbookingsmeCell('YTD (IDR Mio)', color: Colors.orange),
          ),
          GridColumn(
            columnName: 'target',
            width: 113,
            label: _headerbookingsmeCell(
              'Target Referral MTD',
              color: Colors.green,
            ),
          ),
          GridColumn(
            columnName: 'gap',
            width: 110,
            label: _headerbookingsmeCell(
              'GAP Target VS Act',
              color: Colors.green,
            ),
          ),
        ],
        stackedHeaderRows: [
          StackedHeaderRow(
            cells: [
              StackedHeaderCell(
                columnNames: ['oct10', 'oct13'],
                child: _stackedHeaderbookingsmeCell(
                  'Last Day',
                  color: Colors.deepPurple,
                ),
              ),
              StackedHeaderCell(
                columnNames: ['mtd', 'ytd'],
                child: _stackedHeaderbookingsmeCell(
                  'Total Booking',
                  color: Colors.orange,
                ),
              ),
              StackedHeaderCell(
                columnNames: ['target', 'gap'],
                child: _stackedHeaderbookingsmeCell(
                  'Target Full Year',
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
// 🔹 CLASS QUALITY CONSUMER SECTION 5 (versi dinamis)
// ======================================================

class QualityConsumerModel {
  final String region;

  // 🔹 KOL2
  final double kol2LmVol, kol2TodayVol;
  final double kol2LmPct, kol2TodayPct;
  final double kol2MtdVarVol, kol2YtdVarVol;

  // 🔹 NPF
  final double npfLmVol, npfTodayVol;
  final double npfLmPct, npfTodayPct;
  final double npfMtdVarVol, npfYtdVarVol;

  QualityConsumerModel({
    required this.region,
    required this.kol2LmVol,
    required this.kol2TodayVol,
    required this.kol2LmPct,
    required this.kol2TodayPct,
    required this.kol2MtdVarVol,
    required this.kol2YtdVarVol,
    required this.npfLmVol,
    required this.npfTodayVol,
    required this.npfLmPct,
    required this.npfTodayPct,
    required this.npfMtdVarVol,
    required this.npfYtdVarVol,
  });
}

// ======================================================
// 🔹 DATASOURCE UNTUK DATA GRID
// ======================================================

class QualityConsumerDataSource extends DataGridSource {
  List<DataGridRow> _rows = [];

  QualityConsumerDataSource(List<QualityConsumerModel> data) {
    _rows = data
        .map(
          (d) => DataGridRow(
            cells: [
              DataGridCell(columnName: 'region', value: d.region),

              // 🔸 KOL2
              DataGridCell(columnName: 'kol2LmVol', value: d.kol2LmVol),
              DataGridCell(columnName: 'kol2TodayVol', value: d.kol2TodayVol),
              DataGridCell(columnName: 'kol2LmPct', value: d.kol2LmPct),
              DataGridCell(columnName: 'kol2TodayPct', value: d.kol2TodayPct),
              DataGridCell(columnName: 'kol2MtdVarVol', value: d.kol2MtdVarVol),
              DataGridCell(columnName: 'kol2YtdVarVol', value: d.kol2YtdVarVol),

              // 🔸 NPF
              DataGridCell(columnName: 'npfLmVol', value: d.npfLmVol),
              DataGridCell(columnName: 'npfTodayVol', value: d.npfTodayVol),
              DataGridCell(columnName: 'npfLmPct', value: d.npfLmPct),
              DataGridCell(columnName: 'npfTodayPct', value: d.npfTodayPct),
              DataGridCell(columnName: 'npfMtdVarVol', value: d.npfMtdVarVol),
              DataGridCell(columnName: 'npfYtdVarVol', value: d.npfYtdVarVol),
            ],
          ),
        )
        .toList();
  }

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final NumberFormat numberFormat = NumberFormat("#,##0.0", "id");
    final rowIndex = _rows.indexOf(row);

    return DataGridRowAdapter(
      color: rowIndex.isEven ? Colors.grey[50] : Colors.white,
      cells: row.getCells().map((cell) {
        final isRegion = cell.columnName == 'region';
        final isNumeric = cell.value is num;
        final isNegative = isNumeric && (cell.value < 0);

        String displayValue;
        if (isRegion) {
          displayValue = cell.value.toString();
        } else if (isNumeric) {
          displayValue = numberFormat.format(cell.value);
        } else {
          displayValue = cell.value.toString();
        }

        return Container(
          alignment: isRegion ? Alignment.centerLeft : Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Text(
            displayValue,
            style: TextStyle(
              fontSize: 9.5,
              color: isNegative ? Colors.red[700] : Colors.grey[800],
              fontWeight: FontWeight.w400,
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ======================================================
// 🔹 BUILD TABLE QUALITY CONSUMER (header dinamis)
// ======================================================

Widget buildQualityConsumerTable(
  QualityConsumerDataSource source,
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
            width: 150,
            allowSorting: false,
            label: _headerqualityconCell('REGION', color: Colors.brown[700]!),
          ),

          // 🔸 KOL2 VOL
          GridColumn(
            columnName: 'kol2LmVol',
            width: 95,
            label: _headerqualityconCell(headerLm),
          ),
          GridColumn(
            columnName: 'kol2TodayVol',
            width: 95,
            label: _headerqualityconCell(headerToday),
          ),

          // 🔸 KOL2 %
          GridColumn(
            columnName: 'kol2LmPct',
            width: 95,
            label: _headerqualityconCell(headerLm),
          ),
          GridColumn(
            columnName: 'kol2TodayPct',
            width: 95,
            label: _headerqualityconCell(headerToday),
          ),

          // 🔸 KOL2 VAR VOL
          GridColumn(
            columnName: 'kol2MtdVarVol',
            width: 95,
            label: _headerqualityconCell('MTD'),
          ),
          GridColumn(
            columnName: 'kol2YtdVarVol',
            width: 95,
            label: _headerqualityconCell('YTD'),
          ),

          // 🔸 NPF VOL
          GridColumn(
            columnName: 'npfLmVol',
            width: 95,
            label: _headerqualityconCell(headerLm),
          ),
          GridColumn(
            columnName: 'npfTodayVol',
            width: 95,
            label: _headerqualityconCell(headerToday),
          ),

          // 🔸 NPF %
          GridColumn(
            columnName: 'npfLmPct',
            width: 95,
            label: _headerqualityconCell(headerLm),
          ),
          GridColumn(
            columnName: 'npfTodayPct',
            width: 95,
            label: _headerqualityconCell(headerToday),
          ),

          // 🔸 NPF VAR VOL
          GridColumn(
            columnName: 'npfMtdVarVol',
            width: 95,
            label: _headerqualityconCell('MTD'),
          ),
          GridColumn(
            columnName: 'npfYtdVarVol',
            width: 95,
            label: _headerqualityconCell('YTD'),
          ),
        ],

        // ======================================================
        // 🔹 STACKED HEADER
        // ======================================================
        stackedHeaderRows: [
          // Baris 1 — Header besar: KOL2 dan NPF
          StackedHeaderRow(
            cells: [
              StackedHeaderCell(
                columnNames: [
                  'kol2LmVol',
                  'kol2TodayVol',
                  'kol2LmPct',
                  'kol2TodayPct',
                  'kol2MtdVarVol',
                  'kol2YtdVarVol',
                ],
                child: _stackedHeaderqualityconCell(
                  'KOL2',
                  color: Colors.amber[700]!,
                ),
              ),
              StackedHeaderCell(
                columnNames: [
                  'npfLmVol',
                  'npfTodayVol',
                  'npfLmPct',
                  'npfTodayPct',
                  'npfMtdVarVol',
                  'npfYtdVarVol',
                ],
                child: _stackedHeaderqualityconCell(
                  'NPF',
                  color: Colors.brown[700]!,
                ),
              ),
            ],
          ),

          // Baris 2 — Subheader: VOL, %, VAR VOL
          StackedHeaderRow(
            cells: [
              // 🔸 KOL2
              StackedHeaderCell(
                columnNames: ['kol2LmVol', 'kol2TodayVol'],
                child: _stackedHeaderqualityconCell(
                  'VOL',
                  color: Colors.brown[400]!,
                ),
              ),
              StackedHeaderCell(
                columnNames: ['kol2LmPct', 'kol2TodayPct'],
                child: _stackedHeaderqualityconCell(
                  '%',
                  color: Colors.brown[500]!,
                ),
              ),
              StackedHeaderCell(
                columnNames: ['kol2MtdVarVol', 'kol2YtdVarVol'],
                child: _stackedHeaderqualityconCell(
                  'VAR VOL',
                  color: Colors.brown[600]!,
                ),
              ),

              // 🔸 NPF
              StackedHeaderCell(
                columnNames: ['npfLmVol', 'npfTodayVol'],
                child: _stackedHeaderqualityconCell(
                  'VOL',
                  color: Colors.brown[400]!,
                ),
              ),
              StackedHeaderCell(
                columnNames: ['npfLmPct', 'npfTodayPct'],
                child: _stackedHeaderqualityconCell(
                  '%',
                  color: Colors.brown[500]!,
                ),
              ),
              StackedHeaderCell(
                columnNames: ['npfMtdVarVol', 'npfYtdVarVol'],
                child: _stackedHeaderqualityconCell(
                  'VAR VOL',
                  color: Colors.brown[600]!,
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
// 🔹 Helper UI
// ======================================================

Widget _headerqualityconCell(String text, {Color color = Colors.brown}) =>
    Container(
      alignment: Alignment.center,
      color: color,
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );

Widget _stackedHeaderqualityconCell(
  String text, {
  Color color = Colors.brown,
}) =>
    Container(
      alignment: Alignment.center,
      color: color,
      padding: const EdgeInsets.all(6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );


  // ======================================================
  // 🔹 CLASS QUALITY SME SECTION 5 (Updated Selaras Consumer)
  // ======================================================

  class QualitySmeModel {
    final String region;

    // KOL2
    final double kol2LmVol, kol2TodayVol;
    final double kol2LmPct, kol2TodayPct;
    final double kol2MtdVarVol, kol2YtdVarVol;

    // NPF
    final double npfLmVol, npfTodayVol;
    final double npfLmPct, npfTodayPct;
    final double npfMtdVarVol, npfYtdVarVol;

    QualitySmeModel({
      required this.region,
      required this.kol2LmVol,
      required this.kol2TodayVol,
      required this.kol2LmPct,
      required this.kol2TodayPct,
      required this.kol2MtdVarVol,
      required this.kol2YtdVarVol,
      required this.npfLmVol,
      required this.npfTodayVol,
      required this.npfLmPct,
      required this.npfTodayPct,
      required this.npfMtdVarVol,
      required this.npfYtdVarVol,
    });
  }

  // ======================================================
  // 🔹 DATASOURCE UNTUK DATA GRID
  // ======================================================

  class QualitySmeDataSource extends DataGridSource {
    List<DataGridRow> _rows = [];

    QualitySmeDataSource(List<QualitySmeModel> data) {
      _rows = data.map(
        (d) => DataGridRow(
          cells: [
            DataGridCell(columnName: 'region', value: d.region),

            // 🔸 KOL2
            DataGridCell(columnName: 'kol2LmVol', value: d.kol2LmVol),
            DataGridCell(columnName: 'kol2TodayVol', value: d.kol2TodayVol),
            DataGridCell(columnName: 'kol2LmPct', value: d.kol2LmPct),
            DataGridCell(columnName: 'kol2TodayPct', value: d.kol2TodayPct),
            DataGridCell(columnName: 'kol2MtdVarVol', value: d.kol2MtdVarVol),
            DataGridCell(columnName: 'kol2YtdVarVol', value: d.kol2YtdVarVol),

            // 🔸 NPF
            DataGridCell(columnName: 'npfLmVol', value: d.npfLmVol),
            DataGridCell(columnName: 'npfTodayVol', value: d.npfTodayVol),
            DataGridCell(columnName: 'npfLmPct', value: d.npfLmPct),
            DataGridCell(columnName: 'npfTodayPct', value: d.npfTodayPct),
            DataGridCell(columnName: 'npfMtdVarVol', value: d.npfMtdVarVol),
            DataGridCell(columnName: 'npfYtdVarVol', value: d.npfYtdVarVol),
          ],
        ),
      ).toList();
    }

    @override
    List<DataGridRow> get rows => _rows;

    @override
    DataGridRowAdapter buildRow(DataGridRow row) {
      final NumberFormat numberFormat = NumberFormat("#,##0.0", "id");
      final rowIndex = _rows.indexOf(row);

      return DataGridRowAdapter(
        color: rowIndex.isEven ? Colors.grey[50] : Colors.white,
        cells: row.getCells().map((cell) {
          final isRegion = cell.columnName == 'region';
          final isNumeric = cell.value is num;
          final isNegative = isNumeric && (cell.value < 0);

          String displayValue;
          if (isRegion) {
            displayValue = cell.value.toString();
          } else if (isNumeric) {
            displayValue = numberFormat.format(cell.value);
          } else {
            displayValue = cell.value.toString();
          }

          return Container(
            alignment: isRegion ? Alignment.centerLeft : Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            child: Text(
              displayValue,
              style: TextStyle(
                fontSize: 9.5,
                color: isNegative ? Colors.red[700] : Colors.grey[800],
                fontWeight: FontWeight.w400,
              ),
            ),
          );
        }).toList(),
      );
    }
  }

  // ======================================================
  // 🔹 BUILD TABLE QUALITY SME (Header Dinamis)
  // ======================================================

  Widget buildQualitySmeTable(
    QualitySmeDataSource source,
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
              width: 150,
              allowSorting: false,
              label: _headerqualitysmeCell('REGION', color: Colors.orange[700]!),
            ),

            // 🔸 KOL2 VOL
            GridColumn(
              columnName: 'kol2LmVol',
              width: 95,
              label: _headerqualitysmeCell(headerLm),
            ),
            GridColumn(
              columnName: 'kol2TodayVol',
              width: 95,
              label: _headerqualitysmeCell(headerToday),
            ),

            // 🔸 KOL2 %
            GridColumn(
              columnName: 'kol2LmPct',
              width: 95,
              label: _headerqualitysmeCell(headerLm),
            ),
            GridColumn(
              columnName: 'kol2TodayPct',
              width: 95,
              label: _headerqualitysmeCell(headerToday),
            ),

            // 🔸 KOL2 VAR VOL
            GridColumn(
              columnName: 'kol2MtdVarVol',
              width: 95,
              label: _headerqualitysmeCell('MTD'),
            ),
            GridColumn(
              columnName: 'kol2YtdVarVol',
              width: 95,
              label: _headerqualitysmeCell('YTD'),
            ),

            // 🔸 NPF VOL
            GridColumn(
              columnName: 'npfLmVol',
              width: 95,
              label: _headerqualitysmeCell(headerLm),
            ),
            GridColumn(
              columnName: 'npfTodayVol',
              width: 95,
              label: _headerqualitysmeCell(headerToday),
            ),

            // 🔸 NPF %
            GridColumn(
              columnName: 'npfLmPct',
              width: 95,
              label: _headerqualitysmeCell(headerLm),
            ),
            GridColumn(
              columnName: 'npfTodayPct',
              width: 95,
              label: _headerqualitysmeCell(headerToday),
            ),

            // 🔸 NPF VAR VOL
            GridColumn(
              columnName: 'npfMtdVarVol',
              width: 95,
              label: _headerqualitysmeCell('MTD'),
            ),
            GridColumn(
              columnName: 'npfYtdVarVol',
              width: 95,
              label: _headerqualitysmeCell('YTD'),
            ),
          ],

          // ======================================================
          // 🔹 STACKED HEADER
          // ======================================================
          stackedHeaderRows: [
            StackedHeaderRow(
              cells: [
                StackedHeaderCell(
                  columnNames: [
                    'kol2LmVol',
                    'kol2TodayVol',
                    'kol2LmPct',
                    'kol2TodayPct',
                    'kol2MtdVarVol',
                    'kol2YtdVarVol',
                  ],
                  child: _stackedHeaderqualitysmeCell(
                    'KOL2_SME',
                    color: Colors.amber[700]!,
                  ),
                ),
                StackedHeaderCell(
                  columnNames: [
                    'npfLmVol',
                    'npfTodayVol',
                    'npfLmPct',
                    'npfTodayPct',
                    'npfMtdVarVol',
                    'npfYtdVarVol',
                  ],
                  child: _stackedHeaderqualitysmeCell(
                    'NPF_SME',
                    color: Colors.brown[700]!,
                  ),
                ),
              ],
            ),
            StackedHeaderRow(
              cells: [
                StackedHeaderCell(
                  columnNames: ['kol2LmVol', 'kol2TodayVol'],
                  child: _stackedHeaderqualitysmeCell('VOL', color: Colors.brown[400]!),
                ),
                StackedHeaderCell(
                  columnNames: ['kol2LmPct', 'kol2TodayPct'],
                  child: _stackedHeaderqualitysmeCell('%', color: Colors.brown[500]!),
                ),
                StackedHeaderCell(
                  columnNames: ['kol2MtdVarVol', 'kol2YtdVarVol'],
                  child: _stackedHeaderqualitysmeCell('VAR VOL', color: Colors.brown[600]!),
                ),
                StackedHeaderCell(
                  columnNames: ['npfLmVol', 'npfTodayVol'],
                  child: _stackedHeaderqualitysmeCell('VOL', color: Colors.brown[400]!),
                ),
                StackedHeaderCell(
                  columnNames: ['npfLmPct', 'npfTodayPct'],
                  child: _stackedHeaderqualitysmeCell('%', color: Colors.brown[500]!),
                ),
                StackedHeaderCell(
                  columnNames: ['npfMtdVarVol', 'npfYtdVarVol'],
                  child: _stackedHeaderqualitysmeCell('VAR VOL', color: Colors.brown[600]!),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ======================================================
  // 🔹 Helper UI
  // ======================================================

  Widget _headerqualitysmeCell(String text, {Color color = Colors.brown}) => 
      Container(
        alignment: Alignment.center,
        color: color,
        padding: const EdgeInsets.all(8),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );

  Widget _stackedHeaderqualitysmeCell(String text, {Color color = Colors.brown}) => 
      Container(
        alignment: Alignment.center,
        color: color,
        padding: const EdgeInsets.all(6),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );


// ======================================================
// 🔹 CLASS PORSI HAJI SECTION 6
// ======================================================

class PorsiHajiModel {
  final String region;
  final double oct10;
  final double oct13;
  final double reguler;
  final double khusus;
  final double total;
  final double act;
  final double targetOkt;
  final double acv;

  PorsiHajiModel({
    required this.region,
    required this.oct10,
    required this.oct13,
    required this.reguler,
    required this.khusus,
    required this.total,
    required this.act,
    required this.targetOkt,
    required this.acv,
  });
}

// ======================================================
// 🔸 DATASOURCE
// ======================================================
class PorsiHajiDataSource extends DataGridSource {
  List<DataGridRow> _rows = [];

  PorsiHajiDataSource(List<PorsiHajiModel> data) {
    _rows =
        data
            .map(
              (d) => DataGridRow(
                cells: [
                  DataGridCell(columnName: 'region', value: d.region),
                  DataGridCell(columnName: 'oct10', value: d.oct10),
                  DataGridCell(columnName: 'oct13', value: d.oct13),
                  DataGridCell(columnName: 'reguler', value: d.reguler),
                  DataGridCell(columnName: 'khusus', value: d.khusus),
                  DataGridCell(columnName: 'total', value: d.total),
                  DataGridCell(columnName: 'act', value: d.act),
                  DataGridCell(columnName: 'targetOkt', value: d.targetOkt),
                  DataGridCell(columnName: 'acv', value: d.acv),
                ],
              ),
            )
            .toList();
  }

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final NumberFormat numberFormat = NumberFormat(
      "#,##0",
      "id",
    ); // format uang Indonesia

    final rowIndex = _rows.indexOf(row);

    return DataGridRowAdapter(
      color: rowIndex.isEven ? Colors.grey[50] : Colors.white,
      cells:
          row.getCells().map((cell) {
            String displayValue;

            if (cell.value is num) {
              if (cell.columnName == 'acv') {
                // 🔹 Kolom 'acv' → 3 desimal
                displayValue = NumberFormat(
                  "#,##0.000",
                  "id",
                ).format(cell.value);
              } else {
                // 🔹 Kolom lain → format uang Indonesia tanpa desimal
                displayValue = numberFormat.format(cell.value);
              }
            } else {
              displayValue = cell.value.toString();
            }

            return Container(
              alignment:
                  cell.columnName == 'region'
                      ? Alignment.centerLeft
                      : Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Text(displayValue, style: const TextStyle(fontSize: 9.5)),
            );
          }).toList(),
    );
  }
}

// ======================================================
// HEADER CELL HELPERS
// ======================================================
Widget _headerHajiCell(String text, {Color color = Colors.brown}) {
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

Widget _stackedHeaderHajiCell(String text, {Color color = Colors.brown}) {
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
// BUILD TABLE
// ======================================================
Widget buildPorsiHajiTable(
  PorsiHajiDataSource source,
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
            width: 135,
            allowSorting: false,
            label: _headerHajiCell('REGION'),
          ),
          GridColumn(
            columnName: 'oct10',
            width: 102,
            label: _headerHajiCell(
              headerYesterday, // 🔹 ambil dari variabel yang di-set di setState
              color: Colors.orange,
            ),
          ),
          GridColumn(
            columnName: 'oct13',
            width: 102,
            label: _headerHajiCell(
              headerToday, // 🔹 ambil dari variabel yang di-set di setState
              color: const Color.fromARGB(255, 32, 135, 34),
            ),
          ),

          GridColumn(
            columnName: 'reguler',
            width: 79,
            label: _headerHajiCell('Reguler', color: Colors.blue[900]!),
          ),
          GridColumn(
            columnName: 'khusus',
            width: 79,
            label: _headerHajiCell('Khusus', color: Colors.blue[900]!),
          ),
          GridColumn(
            columnName: 'total',
            width: 68,
            label: _headerHajiCell('Total', color: Colors.blue[900]!),
          ),
          GridColumn(
            columnName: 'act',
            width: 65,
            label: _headerHajiCell('Act', color: Colors.green[700]!),
          ),
          GridColumn(
            columnName: 'targetOkt',
            width: 80,
            label: _headerHajiCell('Target Okt', color: Colors.green[700]!),
          ),
          GridColumn(
            columnName: 'acv',
            width: 60,
            label: _headerHajiCell('% Acv', color: Colors.green[700]!),
          ),
        ],
        stackedHeaderRows: [
          // Baris 1
          StackedHeaderRow(
            cells: [
              StackedHeaderCell(
                columnNames: ['oct10', 'oct13'],
                child: _stackedHeaderHajiCell(
                  'Last Day',
                  color: Colors.orange[700]!,
                ),
              ),
              StackedHeaderCell(
                columnNames: ['reguler', 'khusus', 'total'],
                child: _stackedHeaderHajiCell('MTD', color: Colors.blue[900]!),
              ),
              StackedHeaderCell(
                columnNames: ['act', 'targetOkt', 'acv'],
                child: _stackedHeaderHajiCell('YTD', color: Colors.green[700]!),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

