import 'package:googleapis/sheets/v4.dart' as sheets;

abstract class SpreadsheetRepo {
  Future<sheets.Spreadsheet> createSpreadsheet(String title);

  Future<void> addNewSheet({
    required String spreadsheetId,
    required String sheetName,
  });

  Future<void> removeSheet({
    required String spreadsheetId,
    required String sheetName,
  });

  Future<List<List<dynamic>>> getFieldsFromRange({
    required String spreadsheetId,
    required String sheetName,
    required String startRange,
    required String endRange,
  });

  Future<void> updateFieldsInRange({
    required String spreadsheetId,
    required String sheetName,
    required String startRange,
    required String endRange,
    required sheets.ValueRange valueRange,
  });
}
