// ignore_for_file: library_private_types_in_public_api

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';

class NewPDFTest extends StatefulWidget {
  const NewPDFTest({Key? key}) : super(key: key);

  @override
  _NewPDFTestState createState() => _NewPDFTestState();
}

class _NewPDFTestState extends State<NewPDFTest> {
  final key = GlobalKey();

  List<Employee> employees = <Employee>[];
  late EmployeeDataSource employeeDataSource;

  @override
  void initState() {
    super.initState();
    employees = getEmployeeData();
    employeeDataSource = EmployeeDataSource(employeeData: employees);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(
            height: 40,
          ),
          RepaintBoundary(
            key: key,
            child: Container(
              color: Colors.white,
              child: SfDataGrid(
                gridLinesVisibility: GridLinesVisibility.both,
                headerGridLinesVisibility: GridLinesVisibility.both,
                source: employeeDataSource,
                columns: <GridColumn>[
                  GridColumn(
                    columnName: 'id',
                    label: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      alignment: Alignment.centerRight,
                      child: const Text(
                        'ID',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  GridColumn(
                    columnName: 'name',
                    label: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        'Name',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  GridColumn(
                    columnName: 'designation',
                    label: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      alignment: Alignment.centerRight,
                      child: const Text(
                        'Designation',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  GridColumn(
                    columnName: 'salary',
                    label: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        'Salary',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
                stackedHeaderRows: <StackedHeaderRow>[
                  StackedHeaderRow(cells: [
                    StackedHeaderCell(
                      columnNames: ['id', 'name', 'designation', 'salary'],
                      child: Container(
                        color: const Color(0xFFF1F1F1),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Icon(Icons.group),
                            Center(
                              child: Text(
                                'Order Shipment Details',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              generateAndOpenPDF();
            },
            child: const Text('Generate and Open PDF'),
          ),
        ],
      ),
    );
  }

  List<Employee> getEmployeeData() {
    return [
      Employee(10001, 'James', 'Project Lead', 20000),
      Employee(10002, 'Kathryn', 'Manager', 30000),
      Employee(10003, 'Lara', 'Developer', 15000),
    ];
  }

  Uint8List? pdfBytes;
  Directory? tempDir;
  String? tempFilePath;
  Future<void> generateAndOpenPDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          children: [
            pw.Header(text: 'Order Shipment Details', level: 1),
            pw.Table.fromTextArray(
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellAlignment: pw.Alignment.center,
              headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
              headers: ['ID', 'Name', 'Designation', 'Salary'],
              data: getEmployeeData()
                  .map((e) => [e.id, e.name, e.designation, e.salary])
                  .toList(),
            ),
          ],
        ),
      ),
    );

    pdfBytes = await pdf.save();
    tempDir = await getTemporaryDirectory();
    tempFilePath =
        '${tempDir!.path}/document_${DateTime.now().millisecondsSinceEpoch}.pdf';
    File(tempFilePath!).writeAsBytesSync(pdfBytes!);

    OpenFile.open(tempFilePath);
  }
}

class Employee {
  final int id;
  final String name;
  final String designation;
  final int salary;

  Employee(this.id, this.name, this.designation, this.salary);
}

class EmployeeDataSource extends DataGridSource {
  List<DataGridRow> _employeeData = [];

  EmployeeDataSource({required List<Employee> employeeData}) {
    _employeeData = employeeData
        .map<DataGridRow>((e) => DataGridRow(cells: [
              DataGridCell<int>(columnName: 'id', value: e.id),
              DataGridCell<String>(columnName: 'name', value: e.name),
              DataGridCell<String>(
                  columnName: 'designation', value: e.designation),
              DataGridCell<int>(columnName: 'salary', value: e.salary),
            ]))
        .toList();
  }

  @override
  List<DataGridRow> get rows => _employeeData;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((e) {
        return Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(8.0),
          child: Text(e.value.toString()),
        );
      }).toList(),
    );
  }
}
