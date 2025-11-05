import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import '../models/bm_activity.dart';

class BmDataSource extends DataGridSource {
  List<DataGridRow> _rows = [];

  BmDataSource(List<BmActivity> activities) {
    _rows =
        activities.map((data) {
          // Ubah RM_LOGIN_DTD jadi double supaya sorting benar
          final double rmLogin =
              double.tryParse(data.rmLoginDtd.toString()) ?? 0.0;

          return DataGridRow(
            cells: [
              DataGridCell<String>(columnName: 'NAMA', value: data.nama),
              DataGridCell<String>(
                columnName: 'NAMA_CABANG',
                value: data.namaCabang,
              ),
              DataGridCell<String>(
                columnName: 'BM_LOGIN_DTD',
                value: data.bmLoginDtd,
              ), // tetap String
              DataGridCell<double>(
                columnName: 'RM_LOGIN_DTD',
                value: rmLogin,
              ), //  double
              DataGridCell<String>(
                columnName: 'AVG_VISIT',
                value: data.avgVisit,
              ),
              DataGridCell<int>(columnName: 'MTD_VISIT', value: data.mtdVisit),
              DataGridCell<String>(columnName: 'AVG_CALL', value: data.avgCall),
              DataGridCell<int>(columnName: 'MTD_CALL', value: data.mtdCall),
            ],
          );
        }).toList();
  }

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells:
          row.getCells().map((cell) {
            final isLeftAligned =
                cell.columnName == 'NAMA' || cell.columnName == 'NAMA_CABANG';

            String displayValue;

            if (cell.columnName == 'RM_LOGIN_DTD' && cell.value is double) {
              // Format angka & tambahkan %
              displayValue = "${(cell.value as double).toStringAsFixed(1)}%";
            } else {
              displayValue = cell.value.toString();
            }

            return Container(
              padding: const EdgeInsets.all(8),
              alignment:
                  isLeftAligned ? Alignment.centerLeft : Alignment.center,
              child: Text(displayValue, style: const TextStyle(fontSize: 10)),
            );
          }).toList(),
    );
  }
}
