import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class TopBottomBranchPage extends StatefulWidget {
  const TopBottomBranchPage({super.key});

  @override
  State<TopBottomBranchPage> createState() => _TopBottomBranchPageState();
}

class _TopBottomBranchPageState extends State<TopBottomBranchPage> {
  bool isLoading = false;
  final ScrollController _scrollController = ScrollController();

  final Map<String, Map<String, List<dynamic>>> productData = {
    'FUNDING': {'top': [], 'bottom': []},
    'CASA': {'top': [], 'bottom': []},
    'BOOKING': {'top': [], 'bottom': []},
    'KOL2': {'top': [], 'bottom': []}, 
    'NPF': {'top': [], 'bottom': []}, 
  };

  Future<void> fetchAllProducts() async {
    setState(() => isLoading = true);

    try {
      for (var product in productData.keys) {
        final url = Uri.parse(
          "http://103.59.95.71/api_performance/get_topbottom_branch.php?product=$product",
        );

        final response = await http.get(url);
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data["status"] == "success") {
            productData[product]!['top'] = data["top"];
            productData[product]!['bottom'] = data["bottom"];
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal memuat data: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAllProducts();
  }

  Widget buildBranchList(
  String productName,
  List<dynamic> branches,
  Color color,
  bool isTop,
) {
  final formatter = NumberFormat("#,##0.0", "id_ID");

  final isReverse = productName == 'KOL2' || productName == 'NPF';
  final list = isReverse ? branches.reversed.toList() : branches;

  return Column(
    children: List.generate(list.length, (i) {
      final b = list[i];
      final volume = double.tryParse(b['VOLUME'].toString()) ?? 0.0;
      final formattedVolume = formatter.format(volume);

      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                Text(
                  '${i + 1}. ',
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${b['NAMA_CABANG']} (${b['REGION']})',
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        'BM: ${b['NAMA_BM']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  formattedVolume,
                  style: TextStyle(
                    fontSize: 13,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (i != list.length - 1)
            Divider(height: 6, color: Colors.grey.shade300, thickness: 0.6),
        ],
      );
    }),
  );
}

Widget buildProductSection(String productName, Map<String, List<dynamic>> data) {
  final hasBottom = data['bottom'] != null && data['bottom']!.isNotEmpty;

  String topTitle;
  Color topColor;
  if (productName == 'KOL2') {
    topTitle = 'Top 20 Kenaikan Kol2 Terbesar';
    topColor = Colors.red;
  } else if (productName == 'NPF') {
    topTitle = 'Top 20 Kenaikan NPF Terbesar';
    topColor = Colors.red;
  } else {
    topTitle = '🏆 Top 20 Branches';
    topColor = Colors.green;
  }

  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    elevation: 3,
    margin: const EdgeInsets.symmetric(vertical: 12),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              productName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // TOP SECTION
          Text(
            topTitle,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: topColor,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          buildBranchList(productName, data['top'] ?? [], topColor, true),

          if (hasBottom) ...[
            const SizedBox(height: 16),
            const Text(
              '⬇️ Bottom 20 Branches',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            buildBranchList(productName, data['bottom'] ?? [], Colors.red, false),
          ],
        ],
      ),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Top & Bottom Branches',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: fetchAllProducts,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: productData.entries
                    .map((entry) => buildProductSection(entry.key, entry.value))
                    .toList(),
              ),
            ),
    );
  }
}
