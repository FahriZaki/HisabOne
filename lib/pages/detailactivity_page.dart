import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DetailActivityPage extends StatefulWidget {
  const DetailActivityPage({super.key});

  @override
  State<DetailActivityPage> createState() => _DetailActivityPageState();
}

class _DetailActivityPageState extends State<DetailActivityPage> {
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> allData = []; // data asli dari API
  List<dynamic> filteredData = []; // data setelah dicari
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
    _searchController.addListener(_onSearchChanged);
  }

  /// Fungsi ambil data dari API sesuai kode_cabang user
  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? kodeCabang = prefs.getString('kode_cabang');
    int? level = prefs.getInt('level');

    late Uri url;
    if (level == 4) {
      url = Uri.parse(
        "http://103.59.95.71/api_performance/detailactivity.php?level=$level",
      );
    } else {
      if (kodeCabang == null || kodeCabang.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Kode cabang tidak ditemukan")),
          );
        }
        return;
      }
      url = Uri.parse(
        "http://103.59.95.71/api_performance/detailactivity.php?kode_cabang=$kodeCabang&level=$level",
      );
    }

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse["status"] == "success") {
          setState(() {
            allData = jsonResponse["data"];
            filteredData = allData;
            isLoading = false;
          });
        } else {
          setState(() => isLoading = false);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(jsonResponse["message"] ?? "Gagal ambil data"),
              ),
            );
          }
        }
      } else {
        setState(() => isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Gagal load data dari API")),
          );
        }
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  /// Fungsi pencarian
  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredData =
          allData.where((item) {
            final client = item["CLIENTNAME"].toString().toLowerCase();
            final salesAccount = item["SALESACCOUNT"].toString().toLowerCase();
            final result = item["RESULT"].toString().toLowerCase();
            final marketingName = item["MARKETINGNAME"].toString().toLowerCase();
            final activity = item["ACTIVITY"].toString().toLowerCase();
            final kodeCabang = item["KODE_CABANG"].toString().toLowerCase();

            return client.contains(query) ||
                salesAccount.contains(query) ||
                result.contains(query) ||
                marketingName.contains(query) ||
                activity.contains(query) ||
                kodeCabang.contains(query);
          }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
          child: const Text(
            "Detail Activity",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              letterSpacing: 1.2,
              color: Colors.white,
            ),
          ),
        ),
        // Tambahkan actions untuk tombol refresh
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: "Refresh Data",
            onPressed: () async {
              await fetchData(); // panggil method ambil data
            },
          ),
        ],
      ),

      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText:
                    "Cari Client / Marketing / Activity / Result / Kode Cabang",
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // List Data
          Expanded(
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredData.isEmpty
                    ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.search_off, size: 50, color: Colors.grey),
                        SizedBox(height: 8),
                        Text("Tidak ada data yang cocok"),
                      ],
                    )
                    : ListView.builder(
                      itemCount: filteredData.length,
                      itemBuilder: (context, index) {
                        final item = filteredData[index];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFF05A3F9),
                              child: const Icon(
                                Icons.person,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              item["CLIENTNAME"] ?? "-",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Marketing: ${item["MARKETINGNAME"] ?? "-"}",
                                  ),
                                  Text("Activity: ${item["ACTIVITY"] ?? "-"}"),
                                  Text("Result: ${item["RESULT"] ?? "-"}"),
                                  Text("Date: ${item["RECORDDATE"] ?? "-"}"),
                                ],
                              ),
                            ),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder:
                                    (_) => AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      title: Text(
                                        item["CLIENTNAME"] ?? "-",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      content: SingleChildScrollView(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            _buildDetailRow(
                                              "Sales Account",
                                              item["SALESACCOUNT"],
                                            ),
                                            _buildDetailRow(
                                              "Marketing",
                                              item["MARKETINGNAME"],
                                            ),
                                            _buildDetailRow(
                                              "Activity",
                                              item["ACTIVITY"],
                                            ),
                                            _buildDetailRow(
                                              "Result",
                                              item["RESULT"],
                                            ),
                                            _buildDetailRow(
                                              "Product Type",
                                              item["PRODUCTTIME"],
                                            ),
                                            _buildDetailRow(
                                              "Status FU",
                                              item["STATUS_FU"],
                                            ),
                                            _buildDetailRow(
                                              "Remarks",
                                              item["REMARKS"],
                                            ),
                                            _buildDetailRow(
                                              "Kode Cabang",
                                              item["KODE_CABANG"],
                                            ),
                                          ],
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () => Navigator.pop(context),
                                          child: const Text("Tutup"),
                                        ),
                                      ],
                                    ),
                              );
                            },
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  /// Helper untuk detail row di dialog
  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value?.toString() ?? "-")),
        ],
      ),
    );
  }
}
