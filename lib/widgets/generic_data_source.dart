import 'package:flutter/material.dart';

/// Generic [DataTableSource] that turns any list into rows for a
/// [PaginatedDataTable], using a per-row cell builder.
class GenericDataSource<T> extends DataTableSource {
  GenericDataSource(this.rows, this.cellsBuilder);

  final List<T> rows;
  final List<DataCell> Function(T item) cellsBuilder;

  @override
  DataRow? getRow(int index) {
    if (index >= rows.length) return null;
    return DataRow(cells: cellsBuilder(rows[index]));
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => rows.length;

  @override
  int get selectedRowCount => 0;
}
