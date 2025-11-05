// 📄 rm_consumer_datasource.dart
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import '../models/rmconsumer_activity.dart';
import 'package:intl/intl.dart';

class RmConsumerDataSource extends DataGridSource {
  final int level;
  late final List<DataGridRow> _rows;

  RmConsumerDataSource(List<RmConsumerActivity> activities, {this.level = 4}) {
    _rows =
        activities.map((data) {
          final cells = <DataGridCell>[
            DataGridCell<String>(columnName: 'NAMA', value: data.nama),
            DataGridCell<String>(
              columnName: 'NAMA_CABANG',
              value: data.namaCabang,
            ),
            DataGridCell<int>(
              columnName: 'TODAY_ACTIVITY',
              value: data.todayActivity,
            ),
            DataGridCell<String>(
              columnName: 'STATUS_ACTIVITY',
              value: data.statusActivity,
            ),
            DataGridCell<int>(columnName: 'TOT_VISIT', value: data.totVisit),
            DataGridCell<double>(
              columnName: 'MTD_AVG_VISIT',
              value: data.mtdAvgVisit,
            ),
            DataGridCell<int>(columnName: 'TOT_CALL', value: data.totCall),
            DataGridCell<double>(
              columnName: 'MTD_AVG_CALL',
              value: data.mtdAvgCall,
            ),
            DataGridCell<double>(
              columnName: 'MTD_SUBMISSION',
              value: data.mtdSubmission,
            ),
            DataGridCell<double>(columnName: 'MTD_NTB', value: data.mtdNtb),
          ];

          return DataGridRow(cells: cells);
        }).toList();
  }

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells:
          row.getCells().map((cell) {
            final isTextColumn = [
              'NAMA',
              'POSISI',
              'NAMA_CABANG',
              'REGION',
              'STATUS_ACTIVITY',
            ].contains(cell.columnName);

            TextStyle style = const TextStyle(fontSize: 11);
            String displayValue = '';

            // 🔹 Format angka 2 desimal dengan format Indonesia (titik ribuan, koma desimal)
            if (cell.value is double || cell.value is int) {
              final numberFormat = NumberFormat.currency(
                locale: 'id_ID',
                symbol: '', 
                decimalDigits: 2,
              );

              final value = (cell.value as num).toDouble();
              displayValue = numberFormat.format(value);
            } else {
              displayValue = cell.value?.toString() ?? '';
            }

            // 🔹 MTD_SUBMISSION merah jika negatif
            if (cell.columnName == 'MTD_SUBMISSION' && cell.value is num) {
              final value = cell.value as num;
              if (value < 0) {
                style = const TextStyle(
                  fontSize: 11,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                );
              }
            }

            // 🔹 Atur alignment kolom
            Alignment alignment;
            if ([
              'TODAY_ACTIVITY',
              'STATUS_ACTIVITY',
              'TOT_VISIT',
              'TOT_CALL',
            ].contains(cell.columnName)) {
              alignment = Alignment.center; // 🔸 Tengah
            } else if (isTextColumn) {
              alignment = Alignment.centerLeft; // 🔸 Kiri
            } else {
              alignment = Alignment.centerRight; // 🔸 Kanan
            }

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              alignment: alignment,
              color: _getCellColor(cell),
              child: Text(
                displayValue,
                style: style,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
    );
  }

  Color? _getCellColor(DataGridCell cell) {
    // Tambahkan warna background ringan untuk nilai MTD_SUBMISSION negatif
    if (cell.columnName == 'MTD_SUBMISSION' && cell.value is num) {
      final val = cell.value as num;
      if (val < 0) return Colors.red[50];
    }
    return null;
  }
}
