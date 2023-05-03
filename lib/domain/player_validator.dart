import 'package:mafia_board/data/model/player_model.dart';
import 'package:mafia_board/data/model/role.dart';
import 'package:mafia_board/domain/exceptions/invalid_player_data_exception.dart';

class PlayerValidator {
  void validate(PlayerModel player) {
    if (player.nickname.isEmpty) {
      throw InvalidPlayerDataException('Some player has empty nickname');
    }

    if (player.role == Role.NONE) {
      throw InvalidPlayerDataException("Some player doesn't have a role");
    }

    if (player.fouls > 0) {
      throw InvalidPlayerDataException("Player with foul can't start the game");
    }
  }
}
