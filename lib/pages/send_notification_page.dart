import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';

class SendNotificationPage extends StatefulWidget {
  final int level;
  final ValueChanged<int>? onUnreadChanged;
  const SendNotificationPage({
    super.key,
    required this.level,
    this.onUnreadChanged,
  });

  @override
  State<SendNotificationPage> createState() => _SendNotificationPageState();
}

class _SendNotificationPageState extends State<SendNotificationPage> {
  final _judulController = TextEditingController();
  final _pesanController = TextEditingController();
  bool _isSending = false;

  int? selectedIndex;
  late Future<List<dynamic>> _notifikasiFuture;

  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _notifikasiFuture = _fetchNotifikasi();
  }

  Future<void> _refreshData() async {
    setState(() {
      _notifikasiFuture = _fetchNotifikasi();
    });
  }

  Future<void> _hapusNotifikasi(String id) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final response = await http.post(
      Uri.parse("http://103.59.95.71/api_performance/hapus_notifikasi.php"),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'id': id},
    );

    Navigator.of(context, rootNavigator: true).pop();
    
    final data = jsonDecode(response.body);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(data['message'] ?? 'Error')));

    if (data['status'] == 'success') {
      _refreshData();
    }
  }

  void _showEditDialog(Map<String, dynamic> notif) {
    final editJudul = TextEditingController(text: notif['judul']);
    final editPesan = TextEditingController(text: notif['pesan']);

    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Edit Notifikasi'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: editJudul,
                  decoration: const InputDecoration(labelText: 'Judul'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: editPesan,
                  decoration: const InputDecoration(labelText: 'Pesan'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(dialogContext); // tutup dialog edit
                  final rootContext = context;

                  showDialog(
                    context: rootContext,
                    barrierDismissible: false,
                    builder:
                        (_) => const Center(child: CircularProgressIndicator()),
                  );

                  try {
                    final response = await http.post(
                      Uri.parse(
                        "http://103.59.95.71/api_performance/update_notifikasi.php",
                      ),
                      headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                      },
                      body: {
                        'id': notif['id'],
                        'judul': editJudul.text,
                        'pesan': editPesan.text,
                      },
                    );

                    Navigator.pop(rootContext); // tutup loading
                    final data = jsonDecode(response.body);
                    ScaffoldMessenger.of(rootContext).showSnackBar(
                      SnackBar(content: Text(data['message'] ?? 'Error')),
                    );

                    if (data['status'] == 'success') {
                      _refreshData();
                    }
                  } catch (e) {
                    Navigator.pop(rootContext);
                    ScaffoldMessenger.of(
                      rootContext,
                    ).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                },
                child: const Text('Simpan'),
              ),
            ],
          ),
    );
  }

  Future<void> _kirimNotifikasi() async {
    final judul = _judulController.text.trim();
    final pesan = _pesanController.text.trim();

    if (judul.isEmpty || pesan.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul dan pesan wajib diisi')),
      );
      return;
    }

    setState(() => _isSending = true);

    try {
      final response = await http.post(
        Uri.parse("http://103.59.95.71/api_performance/kirim_notifikasi.php"),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'judul': judul, 'pesan': pesan},
      );

      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        _judulController.clear();
        _pesanController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Notifikasi berhasil dikirim')),
        );
        _refreshData();
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('❌ Gagal: ${data['message']}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }

    setState(() => _isSending = false);
  }

  Future<List<dynamic>> _fetchNotifikasi() async {
    final response = await http.get(
      Uri.parse("http://103.59.95.71/api_performance/get_notifikasi.php"),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        final list = data['data'];

        // ✅ hitung jumlah notifikasi
        setState(() {
          _unreadCount = list.length;
        });

        if (widget.onUnreadChanged != null) {
          widget.onUnreadChanged!(_unreadCount);
        }

        return list;
      }
    }
    return [];
  }

  // 🔹 Fungsi untuk tentukan section berdasarkan tanggal
  String _getSection(String? tanggalStr) {
    if (tanggalStr == null || tanggalStr.isEmpty) return "Others";
    try {
      final tanggal = DateTime.parse(tanggalStr);
      final now = DateTime.now();

      if (DateFormat('yyyy-MM-dd').format(tanggal) ==
          DateFormat('yyyy-MM-dd').format(now)) {
        // Hari ini
        if (tanggal.hour == now.hour) {
          return "Now";
        }
        return "Today";
      } else if (now.difference(tanggal).inDays <= 7) {
        return "Last Week";
      }
    } catch (e) {
      return "Others";
    }
    return "Others";
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
        title: const Text(
          "Notification",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 1.2,
            color: Colors.white,
          ),
        ),
        actions: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications, color: Colors.white),
                onPressed: () {
                  // contoh: kalau ditekan, reset badge
                  setState(() {
                    _unreadCount = 0;
                  });
                },
              ),
              if (_unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      '$_unreadCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),

      body: Column(
        children: [
          if (widget.level == 4)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _judulController,
                        decoration: const InputDecoration(
                          labelText: 'Judul',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _pesanController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Pesan',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        icon:
                            _isSending
                                ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                : const Icon(Icons.send),
                        label: Text(
                          _isSending ? 'Mengirim...' : 'Kirim Notifikasi',
                        ),
                        onPressed: _isSending ? null : _kirimNotifikasi,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _notifikasiFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Belum ada notifikasi'));
                }

                final notifikasiList = snapshot.data!;
                return RefreshIndicator(
                  onRefresh: _refreshData,
                  child: GroupedListView<dynamic, String>(
                    elements: notifikasiList,
                    groupBy: (notif) => _getSection(notif['tanggal']),
                    groupSeparatorBuilder:
                        (String group) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            group,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                    itemBuilder: (context, notif) {
                      return Card(
                        color: const Color.fromARGB(255, 237, 68, 240),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 12,
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            // ✅ Tampilkan dialog detail notifikasi
                            showDialog(
                              context: context,
                              builder:
                                  (dialogContext) => AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    title: Text(
                                      notif['judul'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    content: SingleChildScrollView(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            notif['pesan'],
                                            style: const TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          if (notif['tanggal'] != null)
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.access_time,
                                                  size: 16,
                                                  color: Colors.black,
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  notif['tanggal'],
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ),
                                    actions: [
                                      if (widget.level == 4)
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            TextButton.icon(
                                              onPressed: () {
                                                Navigator.pop(
                                                  dialogContext,
                                                ); // ✅ cuma nutup dialog
                                                _showEditDialog(notif);
                                              },
                                              icon: const Icon(
                                                Icons.edit,
                                                color: Colors.blue,
                                              ),
                                              label: const Text("Edit"),
                                            ),
                                            TextButton.icon(
                                              onPressed: () {
                                                Navigator.pop(
                                                  dialogContext,
                                                ); // ✅ cuma nutup dialog
                                                _hapusNotifikasi(notif['id']);
                                              },
                                              icon: const Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                              ),
                                              label: const Text("Hapus"),
                                            ),
                                          ],
                                        ),
                                      TextButton(
                                        onPressed:
                                            () => Navigator.pop(
                                              dialogContext,
                                            ), // ✅ cuma nutup dialog
                                        child: const Text("Tutup"),
                                      ),
                                    ],
                                  ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.notifications,
                                  color: Colors.yellow,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        notif['judul'],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        notif['pesan'],
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                                if (widget.level != 4)
                                  Text(
                                    notif['tanggal'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    useStickyGroupSeparators: true,
                    order: GroupedListOrder.ASC,

                    // Biar urutannya Now → Today → Last Week
                    groupComparator: (a, b) {
                      const order = ["Now", "Today", "Last Week", "Others"];
                      return order.indexOf(a).compareTo(order.indexOf(b));
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
}
