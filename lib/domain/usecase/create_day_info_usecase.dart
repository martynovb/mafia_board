import 'package:mafia_board/data/repo/game_info/game_repo.dart';
import 'package:mafia_board/domain/model/game_info_model.dart';
import 'package:mafia_board/domain/model/phase_type.dart';
import 'package:mafia_board/domain/model/player_model.dart';
import 'package:mafia_board/domain/usecase/base_usecase.dart';

class CreateDayInfoUseCase
    extends BaseUseCase<DayInfoModel, CreateDayInfoParams> {
  final GameRepo gameRepo;

  CreateDayInfoUseCase(this.gameRepo);

  @override
  Future<DayInfoModel> execute({CreateDayInfoParams? params}) async {
    return DayInfoModel.fromEntity(
      await gameRepo.createDayInfo(
        day: params?.day,
        currentPhase: params?.initialGamePhase,
        mutedPlayers: params?.mutedPlayers
            ?.map((playerModel) => playerModel.toEntity())
            .toList(),
      ),
    );
  }
}

class CreateDayInfoParams {
  final int day;
  final PhaseType? initialGamePhase;
  final List<PlayerModel>? mutedPlayers;

  CreateDayInfoParams({
    required this.day,
    this.initialGamePhase = PhaseType.none,
    this.mutedPlayers = const [],
  });
}
