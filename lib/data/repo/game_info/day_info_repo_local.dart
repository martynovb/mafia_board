import 'package:collection/collection.dart';
import 'package:mafia_board/domain/model/game_info_model.dart';
import 'package:mafia_board/domain/model/phase_type.dart';
import 'package:mafia_board/domain/model/player_model.dart';
import 'package:mafia_board/data/repo/game_info/day_info_repo.dart';

class DayInfoRepoLocal extends DayInfoRepo {
  final List<DayInfoModel> _list = [];

  @override
  Future<List<DayInfoModel>> getAllDaysInfo() async {
    return _list;
  }

  @override
  Future<int> getCurrentDay() async {
    final int? currentDay = (await getLastValidDayInfoByDay())?.day;
    return currentDay ?? -1;
  }

  @override
  Future<DayInfoModel?> getLastValidDayInfoByDay() async {
    return _list
        .where((dayInfo) => dayInfo.currentPhase != PhaseType.none)
        .sorted(
          (a, b) => a.day.compareTo(b.day),
        )
        .lastOrNull;
  }

  @override
  Future<void> mutePlayer(PlayerModel player) async {
    final lastDayInfo = await getLastValidDayInfoByDay();
    if (lastDayInfo != null) {
      lastDayInfo.addMutedPlayer(player);
      await updateDayInfo(lastDayInfo);
    }
  }

  @override
  Future<void> deleteAll() async {
    _list.clear();
  }

  @override
  Future<bool> updateDayInfo(DayInfoModel dayInfoModel) async {
    final index = _list.indexWhere(
        (existingDayInfo) => existingDayInfo.id == dayInfoModel.id);

    if (index != -1) {
      _list[index] = dayInfoModel;
      return true;
    }
    return false;
  }

  @override
  Future<void> add(DayInfoModel dayInfoModel) async {
    _list.add(dayInfoModel);
  }

  @override
  Future<void> setCurrentPhaseType({required PhaseType phaseType}) async {
    final lastDayInfo = await getLastValidDayInfoByDay();
    if (lastDayInfo != null) {
      lastDayInfo.currentPhase = phaseType;
      await updateDayInfo(lastDayInfo);
    }
  }

  @override
  Future<DayInfoModel?> getLastDayInfoByDay() async {
    return _list
        .sorted(
          (a, b) => a.day.compareTo(b.day),
        )
        .lastOrNull;
  }
}
