import 'package:easy_localization/easy_localization.dart';
import 'package:mafia_board/domain/exceptions/error_type.dart';
import 'package:mafia_board/domain/model/player_model.dart';
import 'package:mafia_board/domain/model/role.dart';
import 'package:mafia_board/domain/exceptions/exception.dart';

class PlayerValidator {
  void validate(PlayerModel player) {
    if (player.nickname.isEmpty) {
      throw InvalidPlayerDataException(
        errorType: ErrorType.invalidPlayerDataNicknames,
        errorMessage: 'validationErrorInvalidPlayersNicknames'.tr(),
      );
    }

    if (player.role == Role.none) {
      throw InvalidPlayerDataException(
        errorType: ErrorType.invalidPlayerDataRoles,
        errorMessage: 'validationErrorInvalidPlayersRoles'.tr(),
      );
    }

    if (player.fouls > 0) {
      throw InvalidPlayerDataException(
        errorType: ErrorType.invalidPlayerData,
        errorMessage: 'validationErrorInvalidPlayersFouls'.tr(),
      );
    }
  }
}
