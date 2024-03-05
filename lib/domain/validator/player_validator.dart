import 'package:mafia_board/domain/exceptions/error_type.dart';
import 'package:mafia_board/domain/model/player_model.dart';
import 'package:mafia_board/domain/model/role.dart';
import 'package:mafia_board/domain/exceptions/exception.dart';

class PlayerValidator {
  void validate(PlayerModel player) {
    if (player.nickname.isEmpty) {
      throw InvalidPlayerDataException(
        errorType: ErrorType.invalidPlayerDataNicknames,
        errorMessage: '',
      );
    }

    if (player.role == Role.none) {
      throw InvalidPlayerDataException(
        errorType: ErrorType.invalidPlayerDataRoles,
        errorMessage: '',
      );
    }

    if (player.fouls > 0) {
      throw InvalidPlayerDataException(
        errorType: ErrorType.invalidPlayerData,
        errorMessage: '',
      );
    }
  }
}
