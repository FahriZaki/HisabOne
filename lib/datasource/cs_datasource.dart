import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import '../models/cs_activity.dart';

class CsDataSource extends DataGridSource {
  final List<String> visibleColumns;
  List<DataGridRow> _rows = [];

  CsDataSource(List<CsActivity> activities, this.visibleColumns) {
    _rows = activities.map((data) {
      final List<DataGridCell> cells = [];

      if (visibleColumns.contains('NAMA')) {
        cells.add(DataGridCell<String>(columnName: 'NAMA', value: data.nama));
      }
      if (visibleColumns.contains('NAMA_CABANG')) {
        cells.add(DataGridCell<String>(
          columnName: 'NAMA_CABANG',
          value: data.namaCabang,
        ));
      }
      if (visibleColumns.contains('TODAY_ACTIVITY')) {
        cells.add(DataGridCell<int>(
          columnName: 'TODAY_ACTIVITY',
          value: data.todayActivity,
        ));
      }
      if (visibleColumns.contains('STATUS_ACTIVITY')) {
        cells.add(DataGridCell<String>(
          columnName: 'STATUS_ACTIVITY',
          value: data.statusActivity,
        ));
      }
      if (visibleColumns.contains('TOT_VISIT')) {
        cells.add(DataGridCell<int>(
          columnName: 'TOT_VISIT',
          value: data.totVisit,
        ));
      }
      if (visibleColumns.contains('MTD_AVG_VISIT')) {
        cells.add(DataGridCell<double>(
          columnName: 'MTD_AVG_VISIT',
          value: data.mtdAvgVisit,
        ));
      }
      if (visibleColumns.contains('TOT_CALL')) {
        cells.add(DataGridCell<int>(
          columnName: 'TOT_CALL',
          value: data.totCall,
        ));
      }
      if (visibleColumns.contains('MTD_AVG_CALL')) {
        cells.add(DataGridCell<double>(
          columnName: 'MTD_AVG_CALL',
          value: data.mtdAvgCall,
        ));
      }

      return DataGridRow(cells: cells);
    }).toList();
  }

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map((cell) {
        final isTextColumn = [
          'NAMA',
          'NAMA_CABANG',
          'STATUS_ACTIVITY',
        ].contains(cell.columnName);

        TextStyle style = const TextStyle(fontSize: 10);
        String displayValue = '';

        // 🔹 Format angka desimal tanpa pembulatan
        if (cell.value is double) {
          double value = cell.value as double;
          double truncated = (value * 100).truncateToDouble() / 100;
          displayValue = truncated.toStringAsFixed(2);
        } else {
          displayValue = cell.value?.toString() ?? '';
        }

        // 🔹 Atur alignment
        Alignment alignment;
        if (cell.columnName == 'STATUS_ACTIVITY' ||
            cell.columnName == 'TODAY_ACTIVITY' ||
            cell.columnName == 'TOT_VISIT' ||
            cell.columnName == 'TOT_CALL') {
          alignment = Alignment.center;
        } else if (isTextColumn) {
          alignment = Alignment.centerLeft;
        } else {
          alignment = Alignment.centerRight;
        }

        return Container(
          padding: const EdgeInsets.all(8),
          alignment: alignment,
          child: Text(
            displayValue,
            style: style,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        );
      }).toList(),
    );
  }
}
