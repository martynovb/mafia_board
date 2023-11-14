import 'package:mafia_board/domain/model/game_info_model.dart';
import 'package:mafia_board/domain/model/phase_type.dart';
import 'package:mafia_board/domain/model/player_model.dart';

abstract class DayInfoRepo {
  Future<int> getCurrentDay();

  Future<List<DayInfoModel>> getAllDaysInfo();

  Future<DayInfoModel?> getLastValidDayInfoByDay();

  Future<DayInfoModel?> getLastDayInfoByDay();

  Future<void> mutePlayer(PlayerModel player);

  Future<void> updateDayInfo(DayInfoModel dayInfoModel);

  Future<void> deleteAll();

  Future<void> add(DayInfoModel dayInfoModel);

  Future<void> setCurrentPhaseType({required PhaseType phaseType});
}
