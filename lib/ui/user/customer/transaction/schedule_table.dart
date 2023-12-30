import 'package:flutter/material.dart';

class ScheduleTable extends StatelessWidget {
  const ScheduleTable({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.all(),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        _buildTableRow(['Day', 'Opening Hours', 'Closing Hours'], header: true),
        _buildTableRow(['Monday', '9:00 AM', '9:30 PM']),
        _buildTableRow(['Tuesday', '9:00 AM', '9:30 PM']),
        _buildTableRow(['Wednesday', '9:00 AM', '9:30 PM']),
        _buildTableRow(['Thursday', '9:00 AM', '9:30 PM']),
        _buildTableRow(['Friday', '9:00 AM', '9:30 PM']),
        _buildTableRow(['Saturday', '10:00 AM', '5:00 PM']),
        _buildTableRow(['Sunday', '10:00 AM', '5:00 PM']),
      ],
    );
  }

  TableRow _buildTableRow(List<String> data, {bool header = false}) {
    final List<Widget> children = data
        .map((item) => TableCell(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
                child: Center(
                  child: Text(
                    item,
                    style: TextStyle(
                      fontWeight: header ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ))
        .toList();

    return TableRow(children: children);
  }
}
