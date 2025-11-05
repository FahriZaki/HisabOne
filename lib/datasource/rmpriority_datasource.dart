import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import '../models/rmpriority_activity.dart';
import 'package:intl/intl.dart';

class RmPriorityDataSource extends DataGridSource {
  final List<String> visibleColumns;
  List<DataGridRow> _rows = [];

  RmPriorityDataSource(
    List<RmPriorityActivity> activities,
    this.visibleColumns,
  ) {
    _rows =
        activities.map((data) {
          final List<DataGridCell> cells = [];

          if (visibleColumns.contains('NAMA')) {
            cells.add(
              DataGridCell<String>(columnName: 'NAMA', value: data.nama),
            );
          }
          if (visibleColumns.contains('NAMA_CABANG')) {
            cells.add(
              DataGridCell<String>(
                columnName: 'NAMA_CABANG',
                value: data.namaCabang,
              ),
            );
          }
          if (visibleColumns.contains('TODAY_ACTIVITY')) {
            cells.add(
              DataGridCell<int>(
                columnName: 'TODAY_ACTIVITY',
                value: data.todayActivity,
              ),
            );
          }
          if (visibleColumns.contains('STATUS_ACTIVITY')) {
            cells.add(
              DataGridCell<String>(
                columnName: 'STATUS_ACTIVITY',
                value: data.statusActivity,
              ),
            );
          }
          if (visibleColumns.contains('TOT_VISIT')) {
            cells.add(
              DataGridCell<int>(columnName: 'TOT_VISIT', value: data.totVisit),
            );
          }
          if (visibleColumns.contains('MTD_AVG_VISIT')) {
            cells.add(
              DataGridCell<double>(
                columnName: 'MTD_AVG_VISIT',
                value: data.mtdAvgVisit,
              ),
            );
          }
          if (visibleColumns.contains('TOT_CALL')) {
            cells.add(
              DataGridCell<int>(columnName: 'TOT_CALL', value: data.totCall),
            );
          }
          if (visibleColumns.contains('MTD_AVG_CALL')) {
            cells.add(
              DataGridCell<double>(
                columnName: 'MTD_AVG_CALL',
                value: data.mtdAvgCall,
              ),
            );
          }
          if (visibleColumns.contains('MTD_NTB')) {
            cells.add(
              DataGridCell<int>(columnName: 'MTD_NTB', value: data.mtdNtb),
            );
          }
          if (visibleColumns.contains('FUND_GROWTH')) {
            cells.add(
              DataGridCell<double>(
                columnName: 'FUND_GROWTH',
                value: data.fundGrowth,
              ),
            );
          }

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
              'NAMA_CABANG',
              'STATUS_ACTIVITY',
            ].contains(cell.columnName);

            TextStyle style = const TextStyle(fontSize: 10);
            String displayValue = '';

            // 🔹 Format angka 2 desimal dengan format Indonesia
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

            if (cell.columnName == 'FUND_GROWTH' && cell.value is double) {
              final value = cell.value as double;
              final numberFormat = NumberFormat.currency(
                locale: 'id_ID',
                symbol: '',
                decimalDigits: 2,
              );

              displayValue = numberFormat.format(value);

              if (value < 0) {
                style = const TextStyle(
                  fontSize: 10,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                );
              }
            }

            // 🔹 Atur alignment
            Alignment alignment;
            if ([
              'TODAY_ACTIVITY',
              'STATUS_ACTIVITY',
              'TOT_VISIT',
              'TOT_CALL',
            ].contains(cell.columnName)) {
              alignment = Alignment.center; // Tengah
            } else if ([
              'MTD_AVG_VISIT',
              'MTD_AVG_CALL',
              'FUND_GROWTH',
            ].contains(cell.columnName)) {
              alignment = Alignment.centerRight; // Rata kanan
            } else if (isTextColumn) {
              alignment = Alignment.centerLeft; // Kiri
            } else {
              alignment = Alignment.center; // Default tengah
            }

            return Container(
              padding: const EdgeInsets.all(8),
              alignment: alignment,
              child: Text(
                displayValue,
                style: style,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
    );
  }
}
