import 'package:googleapis/sheets/v4.dart';
import 'package:mafia_board/data/api/error_handler.dart';
import 'package:mafia_board/data/api/google_api_error.dart';
import 'package:mafia_board/data/api/google_client_manager.dart';
import 'package:mafia_board/data/repo/spreadsheet/spreadsheet_repo.dart';
import 'package:googleapis/sheets/v4.dart' as sheets;

class SpreadsheetRepoImpl extends SpreadsheetRepo {
  final GoogleClientManager googleClientManager;

  SpreadsheetRepoImpl({required this.googleClientManager});

  @override
  Future<sheets.Spreadsheet> createSpreadsheet(String title) =>
      _makeSheetsApiRequest((sheetsApi) async {
        var newSheet = sheets.Spreadsheet(
          properties: sheets.SpreadsheetProperties(title: title),
        );
        return await sheetsApi.spreadsheets.create(newSheet);
      });

  @override
  Future<List<List<dynamic>>> getFieldsFromRange({
    required String spreadsheetId,
    required String sheetName,
    required String startRange,
    required String endRange,
  }) =>
      _makeSheetsApiRequest<List<List<dynamic>>>(
        (sheetsApi) async {
          String range = '$sheetName!$startRange:$endRange';
          var response =
              await sheetsApi.spreadsheets.values.get(spreadsheetId, range);
          return response.values ?? [];
        },
      );

  @override
  Future<void> updateFieldsInRange({
    required String spreadsheetId,
    required String sheetName,
    required String startRange,
    required String endRange,
    required sheets.ValueRange valueRange,
  }) =>
      _makeSheetsApiRequest(
        (sheetsApi) async {
          String range = '$sheetName!$startRange:$endRange';
          await sheetsApi.spreadsheets.values.update(
            valueRange,
            spreadsheetId,
            range,
            valueInputOption: 'RAW',
          );
        },
      );

  @override
  Future<void> addNewSheet({
    required String spreadsheetId,
    required String sheetName,
  }) =>
      _makeSheetsApiRequest((sheetsApi) async {
        var newSheet = sheets.Request(
          addSheet: sheets.AddSheetRequest(
            properties: sheets.SheetProperties(title: sheetName),
          ),
        );
        // Batch update to add the new sheet
        await sheetsApi.spreadsheets.batchUpdate(
          sheets.BatchUpdateSpreadsheetRequest(
            requests: [newSheet],
          ),
          spreadsheetId,
        );
      });

  @override
  Future<void> removeSheet({
    required String spreadsheetId,
    required String sheetName,
  }) =>
      _makeSheetsApiRequest(
        (sheets.SheetsApi sheetsApi) async {
          var spreadSheet = await sheetsApi.spreadsheets.get(spreadsheetId);
          var sheetId = spreadSheet.sheets
              ?.firstWhere(
                (s) => s.properties?.title == sheetName,
                orElse: () => throw Exception('Sheet not found'),
              )
              .properties
              ?.sheetId;

          if (sheetId == null) {
            throw Exception('Sheet not found');
          }

          var deleteSheetRequest = sheets.Request(
            deleteSheet: sheets.DeleteSheetRequest(
              sheetId: sheetId,
            ),
          );

          // Batch update to delete the sheet
          await sheetsApi.spreadsheets.batchUpdate(
            sheets.BatchUpdateSpreadsheetRequest(
              requests: [deleteSheetRequest],
            ),
            spreadsheetId,
          );
        },
      );

  Future<T> _makeSheetsApiRequest<T>(
    Future<T> Function(sheets.SheetsApi sheetsApi) request,
  ) async {
    var googleHttpClient = await googleClientManager.fetchGoogleHttpClient();

    if (googleHttpClient == null) {
      await googleClientManager.refreshAccessToken();
      googleHttpClient = await googleClientManager.fetchGoogleHttpClient();
      if (googleHttpClient == null) {
        throw InvalidCredentialsException("Can't sign in with google");
      }
    }

    try {
      return await request(sheets.SheetsApi(googleHttpClient));
    } on sheets.DetailedApiRequestError catch (e) {
      if (e.jsonResponse != null && e.jsonResponse!.isNotEmpty) {
        final error = GoogleApiError.fromJson(e.jsonResponse!);
        if (error.status == 'UNAUTHENTICATED') {
          await googleClientManager.refreshAccessToken();
          final googleHttpClient =
              await googleClientManager.fetchGoogleHttpClient();
          if (googleHttpClient == null) {
            throw InvalidCredentialsException("Can't sign in with google");
          }
          return await request(sheets.SheetsApi(googleHttpClient));
        } else {
          rethrow;
        }
      } else {
        rethrow;
      }
    }
  }
}
