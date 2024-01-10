import 'package:mafia_board/data/entity/rules_entity.dart';
import 'package:mafia_board/data/repo/rules/rules_repo.dart';
import 'package:mafia_board/data/repo/spreadsheet/spreadsheet_app_consts.dart';
import 'package:mafia_board/data/repo/spreadsheet/spreadsheet_repo.dart';
import 'package:mafia_board/domain/model/club_model.dart';
import 'package:googleapis/sheets/v4.dart' as sheets;

class RulesRepoGoogleTable extends RulesRepo {
  final SpreadsheetRepo spreadsheetRepo;

  RulesRepoGoogleTable({
    required this.spreadsheetRepo,
  });

  @override
  Future<void> createClubRules({
    required ClubModel clubModel,
    required double civilWin,
    required double mafWin,
    required double civilLoss,
    required double mafLoss,
    required double kickLoss,
    required double defaultBonus,
    required double ppkLoss,
    required double gameLoss,
    required double twoBestMove,
    required double threeBestMove,
  }) async {
    await spreadsheetRepo.addNewSheet(
      spreadsheetId: clubModel.googleSheetId,
      sheetName: SpreadsheetAppConsts.rulesSheetName,
    );

    // Prepare keys and values
    var keys = [
      'civilWin',
      'mafWin',
      'civilLoss',
      'mafLoss',
      'kickLoss',
      'defaultBonus',
      'ppkLoss',
      'gameLoss',
      'twoBestMove',
      'threeBestMove'
    ];
    var values = [
      civilWin,
      mafWin,
      civilLoss,
      mafLoss,
      kickLoss,
      defaultBonus,
      ppkLoss,
      gameLoss,
      twoBestMove,
      threeBestMove
    ];

    // Create data in the required format
    List<List<Object>> data = [];
    for (int i = 0; i < keys.length; i++) {
      data.add([keys[i], values[i]]);
    }

    var valueRange = sheets.ValueRange.fromJson({'values': data});
    await spreadsheetRepo.updateFieldsInRange(
      spreadsheetId: clubModel.googleSheetId,
      sheetName: SpreadsheetAppConsts.rulesSheetName,
      startRange: SpreadsheetAppConsts.rulesStartRange,
      endRange: SpreadsheetAppConsts.rulesEndRange,
      valueRange: valueRange,
    );
  }

  @override
  Future<RulesEntity?> getClubRules(ClubModel club) async =>
      RulesEntity.fromSheetValues(
        await spreadsheetRepo.getFieldsFromRange(
          spreadsheetId: club.googleSheetId,
          sheetName: SpreadsheetAppConsts.rulesSheetName,
          startRange: SpreadsheetAppConsts.rulesStartRange,
          endRange: SpreadsheetAppConsts.rulesEndRange,
        ),
      );

  @override
  Future<void> updateClubRules({
    required ClubModel clubModel,
    required double civilWin,
    required double mafWin,
    required double civilLoss,
    required double mafLoss,
    required double kickLoss,
    required double defaultBonus,
    required double ppkLoss,
    required double gameLoss,
    required double twoBestMove,
    required double threeBestMove,
  }) async {
    // Prepare keys and values
    var keys = [
      'civilWin',
      'mafWin',
      'civilLoss',
      'mafLoss',
      'kickLoss',
      'defaultBonus',
      'ppkLoss',
      'gameLoss',
      'twoBestMove',
      'threeBestMove'
    ];
    var values = [
      civilWin,
      mafWin,
      civilLoss,
      mafLoss,
      kickLoss,
      defaultBonus,
      ppkLoss,
      gameLoss,
      twoBestMove,
      threeBestMove
    ];

    // Create data in the required format
    List<List<Object>> data = [];
    for (int i = 0; i < keys.length; i++) {
      data.add([keys[i], values[i]]);
    }

    var valueRange = sheets.ValueRange.fromJson({'values': data});
    await spreadsheetRepo.updateFieldsInRange(
      spreadsheetId: clubModel.googleSheetId,
      sheetName: SpreadsheetAppConsts.rulesSheetName,
      startRange: SpreadsheetAppConsts.rulesStartRange,
      endRange: SpreadsheetAppConsts.rulesEndRange,
      valueRange: valueRange,
    );
  }
}
