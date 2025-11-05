import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

// Formatter untuk angka dengan pemisah ribuan
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  final NumberFormat numberFormat = NumberFormat.decimalPattern('id');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Hilangkan titik dulu
    String numericString = newValue.text.replaceAll('.', '');

    // Kalau bukan angka valid, return lama
    if (int.tryParse(numericString) == null) {
      return oldValue;
    }

    int value = int.parse(numericString);
    String newText = numberFormat.format(value);

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

class PipelineTodayPage extends StatefulWidget {
  const PipelineTodayPage({super.key});

  @override
  State<PipelineTodayPage> createState() => _PipelineTodayPageState();
}

class _PipelineTodayPageState extends State<PipelineTodayPage> {
  int userLevel = 0;
  String? userCode;

  // Controllers
  final fundingInController = TextEditingController();
  final fundingOutController = TextEditingController();
  // Controller untuk subkategori Booking
  final bookKprNocController = TextEditingController();
  final bookKprOsController = TextEditingController();
  final bookMgNocController = TextEditingController();
  final bookMgOsController = TextEditingController();
  final bookSolehNocController = TextEditingController();
  final bookSolehOsController = TextEditingController();
  final bookProhajNocController = TextEditingController();
  final bookProhajOsController = TextEditingController();

  final financingBookingNocController = TextEditingController();
  final financingBookingOsController = TextEditingController();
  final financingSubmissionNocController = TextEditingController();
  final financingSubmissionOsController = TextEditingController();
  final financingBookingSliOsController = TextEditingController();
  final ntbIndividuNocController = TextEditingController();
  final ntbIndividuOsController = TextEditingController();
  final ntbNonIndividuNocController = TextEditingController();
  final ntbNonIndividuOsController = TextEditingController();
  final ntbPriorityNocController = TextEditingController();
  final ntbPriorityOsController = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();

    // Listener untuk auto-sum Booking
    for (var c in [
      bookKprNocController,
      bookKprOsController,
      bookMgNocController,
      bookMgOsController,
      bookSolehNocController,
      bookSolehOsController,
      bookProhajNocController,
      bookProhajOsController,
    ]) {
      c.addListener(_updateTotalBooking);
    }
  }

  Future<void> _loadPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userLevel = prefs.getInt('level') ?? 0;
      userCode = prefs.getString('kode_cabang') ?? "";
    });

    if (userCode != null && userCode!.isNotEmpty) {
      await _fetchPipelineData();
    }
  }

  Future<void> _fetchPipelineData() async {
    setState(() => isLoading = true);
    try {
      final url = Uri.parse(
        "http://103.59.95.71/api_performance/get_pipeline_today.php?code=$userCode",
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          final row = data['data'];
          fundingInController.text = NumberFormat.decimalPattern(
            'id',
          ).format(int.tryParse(row['funding_in'].toString()) ?? 0);
          fundingOutController.text = NumberFormat.decimalPattern(
            'id',
          ).format(int.tryParse(row['funding_out'].toString()) ?? 0);
          financingBookingNocController.text = NumberFormat.decimalPattern(
            'id',
          ).format(int.tryParse(row['book_noc'].toString()) ?? 0);
          financingBookingOsController.text = NumberFormat.decimalPattern(
            'id',
          ).format(int.tryParse(row['book_os'].toString()) ?? 0);
          financingSubmissionNocController.text = NumberFormat.decimalPattern(
            'id',
          ).format(int.tryParse(row['submission_noc'].toString()) ?? 0);
          financingSubmissionOsController.text = NumberFormat.decimalPattern(
            'id',
          ).format(int.tryParse(row['submission_os'].toString()) ?? 0);
          ntbIndividuNocController.text = NumberFormat.decimalPattern(
            'id',
          ).format(int.tryParse(row['ind_noc'].toString()) ?? 0);
          ntbIndividuOsController.text = NumberFormat.decimalPattern(
            'id',
          ).format(int.tryParse(row['ind_os'].toString()) ?? 0);
          ntbNonIndividuNocController.text = NumberFormat.decimalPattern(
            'id',
          ).format(int.tryParse(row['nonind_noc'].toString()) ?? 0);
          ntbNonIndividuOsController.text = NumberFormat.decimalPattern(
            'id',
          ).format(int.tryParse(row['nonind_os'].toString()) ?? 0);
          ntbPriorityNocController.text = NumberFormat.decimalPattern(
            'id',
          ).format(int.tryParse(row['prio_noc'].toString()) ?? 0);
          ntbPriorityOsController.text = NumberFormat.decimalPattern(
            'id',
          ).format(int.tryParse(row['prio_os'].toString()) ?? 0);
          financingBookingSliOsController.text = NumberFormat.decimalPattern(
            'id',
          ).format(int.tryParse(row['bookingsli_os'].toString()) ?? 0);
        }
      }
    } catch (e) {
      debugPrint("Error fetch: $e");
    }
    setState(() => isLoading = false);
  }

  Future<void> _submitPipeline() async {
    if (userCode == null || userCode!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Kode cabang tidak ditemukan")),
      );
      return;
    }

    final body = {
      "code": userCode,
      "funding_in": fundingInController.text.replaceAll('.', ''),
      "funding_out": fundingOutController.text.replaceAll('.', ''),

      // 🟢 Tambahkan subkategori book
      "book_kpr_noc": bookKprNocController.text.replaceAll('.', ''),
      "book_kpr_os": bookKprOsController.text.replaceAll('.', ''),
      "book_mg_noc": bookMgNocController.text.replaceAll('.', ''),
      "book_mg_os": bookMgOsController.text.replaceAll('.', ''),
      "book_soleh_noc": bookSolehNocController.text.replaceAll('.', ''),
      "book_soleh_os": bookSolehOsController.text.replaceAll('.', ''),
      "book_prohaj_noc": bookProhajNocController.text.replaceAll('.', ''),
      "book_prohaj_os": bookProhajOsController.text.replaceAll('.', ''),

      // 🟢 Total booking
      "book_noc": financingBookingNocController.text.replaceAll('.', ''),
      "book_os": financingBookingOsController.text.replaceAll('.', ''),

      "submission_noc": financingSubmissionNocController.text.replaceAll(
        '.',
        '',
      ),
      "submission_os": financingSubmissionOsController.text.replaceAll('.', ''),
      "ind_noc": ntbIndividuNocController.text.replaceAll('.', ''),
      "ind_os": ntbIndividuOsController.text.replaceAll('.', ''),
      "nonind_noc": ntbNonIndividuNocController.text.replaceAll('.', ''),
      "nonind_os": ntbNonIndividuOsController.text.replaceAll('.', ''),
      "prio_noc": ntbPriorityNocController.text.replaceAll('.', ''),
      "prio_os": ntbPriorityOsController.text.replaceAll('.', ''),
      "bookingsli_os": financingBookingSliOsController.text.replaceAll('.', ''),
    };

    setState(() => isLoading = true);

    try {
      final url = Uri.parse(
        "http://103.59.95.71/api_performance/pipelinetoday.php",
      );
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Data berhasil disimpan")),
        );

        _clearAllFields();
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("❌ ${data['message']}")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }

    setState(() => isLoading = false);
  }

  // Fungsi untuk reset semua field
  void _clearAllFields() {
    fundingInController.clear();
    fundingOutController.clear();

    //subkategori book
    bookKprNocController.clear();
    bookKprOsController.clear();
    bookMgNocController.clear();
    bookMgOsController.clear();
    bookSolehNocController.clear();
    bookSolehOsController.clear();
    bookProhajNocController.clear();
    bookProhajOsController.clear();

    financingBookingNocController.clear();
    financingBookingOsController.clear();
    financingSubmissionNocController.clear();
    financingSubmissionOsController.clear();
    ntbIndividuNocController.clear();
    ntbIndividuOsController.clear();
    ntbNonIndividuNocController.clear();
    ntbNonIndividuOsController.clear();
    ntbPriorityNocController.clear();
    ntbPriorityOsController.clear();
    financingBookingSliOsController.clear();
  }

  Widget buildNumberField(TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [ThousandsSeparatorInputFormatter()],
      textAlign: TextAlign.center,
      decoration: const InputDecoration(border: OutlineInputBorder()),
    );
  }

  @override
  void dispose() {
    fundingInController.dispose();
    fundingOutController.dispose();

    //subkategori book
    bookKprNocController.dispose();
    bookKprOsController.dispose();
    bookMgNocController.dispose();
    bookMgOsController.dispose();
    bookSolehNocController.dispose();
    bookSolehOsController.dispose();
    bookProhajNocController.dispose();
    bookProhajOsController.dispose();

    financingBookingNocController.dispose();
    financingBookingOsController.dispose();
    financingSubmissionNocController.dispose();
    financingSubmissionOsController.dispose();
    ntbIndividuNocController.dispose();
    ntbIndividuOsController.dispose();
    ntbNonIndividuNocController.dispose();
    ntbNonIndividuOsController.dispose();
    ntbPriorityNocController.dispose();
    ntbPriorityOsController.dispose();
    financingBookingSliOsController.dispose();
    super.dispose();
  }

  //agar auto input
  void _updateTotalBooking() {
    int parse(String text) => int.tryParse(text.replaceAll('.', '')) ?? 0;

    final totalNoc =
        parse(bookKprNocController.text) +
        parse(bookMgNocController.text) +
        parse(bookSolehNocController.text) +
        parse(bookProhajNocController.text);

    final totalOs =
        parse(bookKprOsController.text) +
        parse(bookMgOsController.text) +
        parse(bookSolehOsController.text) +
        parse(bookProhajOsController.text);

    financingBookingNocController.text = NumberFormat.decimalPattern(
      'id',
    ).format(totalNoc);
    financingBookingOsController.text = NumberFormat.decimalPattern(
      'id',
    ).format(totalOs);
  }

  @override
  Widget build(BuildContext context) {
    if (userLevel != 1 && userLevel != 2) {
      return const Scaffold(
        body: Center(
          child: Text(
            "⛔ Akses Pipeline hanya untuk Level 1 & 2",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                "Plan",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  letterSpacing: 1.2,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 2),
              Text(
                "(Diinput Dengan Angka Penuh)",
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),

      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // === CARD 1: FUNDING + NTB ===
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.only(bottom: 20),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Funding",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: fundingInController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                ThousandsSeparatorInputFormatter(),
                              ],
                              decoration: const InputDecoration(
                                labelText: "In",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: fundingOutController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                ThousandsSeparatorInputFormatter(),
                              ],
                              decoration: const InputDecoration(
                                labelText: "Out",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // NTB
                            const Text(
                              "NTB",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: const [
                                Expanded(flex: 2, child: SizedBox()),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    "CIF",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    "VOL",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Expanded(flex: 2, child: Text("CA")),
                                Expanded(
                                  flex: 1,
                                  child: buildNumberField(
                                    ntbNonIndividuNocController,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 4,
                                  child: buildNumberField(
                                    ntbNonIndividuOsController,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Expanded(
                                  flex: 2,
                                  child: Text("Priority"),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: buildNumberField(
                                    ntbPriorityNocController,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 4,
                                  child: buildNumberField(
                                    ntbPriorityOsController,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // === CARD 2: FINANCING CONSUMER ===
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.only(bottom: 20),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Financing Consumer",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Booking",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: const [
                                Expanded(flex: 2, child: SizedBox()),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    "NOA",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    "VOL",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // --- SUBKATEGORI KPR ---
                            Row(
                              children: [
                                const Expanded(
                                  flex: 2,
                                  child: Text("Booking KPR"),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: buildNumberField(bookKprNocController),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 4,
                                  child: buildNumberField(bookKprOsController),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // --- SUBKATEGORI MG ---
                            Row(
                              children: [
                                const Expanded(
                                  flex: 2,
                                  child: Text("Booking MG"),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: buildNumberField(bookMgNocController),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 4,
                                  child: buildNumberField(bookMgOsController),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // --- SUBKATEGORI SOLEH ---
                            Row(
                              children: [
                                const Expanded(
                                  flex: 2,
                                  child: Text("Booking Soleh"),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: buildNumberField(
                                    bookSolehNocController,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 4,
                                  child: buildNumberField(
                                    bookSolehOsController,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // --- SUBKATEGORI PROHAJJ ---
                            Row(
                              children: [
                                const Expanded(
                                  flex: 2,
                                  child: Text("Booking Prohajj"),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: buildNumberField(
                                    bookProhajNocController,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 4,
                                  child: buildNumberField(
                                    bookProhajOsController,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 20, thickness: 2),

                            // --- TOTAL BOOKING AUTO ---
                            Row(
                              children: [
                                const Expanded(
                                  flex: 2,
                                  child: Text(
                                    "Total Booking",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: buildNumberField(
                                    financingBookingNocController,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 4,
                                  child: buildNumberField(
                                    financingBookingOsController,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // --- SUBMISSION ---
                            Row(
                              children: [
                                const Expanded(
                                  flex: 2,
                                  child: Text("Submission"),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: buildNumberField(
                                    financingSubmissionNocController,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 4,
                                  child: buildNumberField(
                                    financingSubmissionOsController,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // === CARD 3: BOOKING SLI ===
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.only(bottom: 30),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Booking SLI",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: const [
                                Expanded(flex: 2, child: SizedBox()),
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    "VOL",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Expanded(
                                  flex: 2,
                                  child: Text("Banca Sunlife"),
                                ),
                                Expanded(
                                  flex: 4,
                                  child: buildNumberField(
                                    financingBookingSliOsController,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // === BUTTON SUBMIT ===
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: _submitPipeline,
                        child: const Text("Submit"),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
