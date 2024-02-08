import 'package:collection/collection.dart';
import 'package:mafia_board/domain/model/game_phase/game_phase_model.dart';
import 'package:mafia_board/domain/model/game_phase/night_phase_model.dart';
import 'package:mafia_board/domain/model/game_phase/speak_phase_model.dart';
import 'package:mafia_board/domain/model/game_phase/vote_phase_model.dart';
import 'package:mafia_board/domain/model/player_model.dart';
import 'package:mafia_board/presentation/common/helper/player_action_wrapper.dart';

class GameDetailsViewHelper {
  static List<PlayerActionViewWrapper> filterOnlyPlayerActions(
    PlayerModel player,
    List<GamePhaseModel> gamePhases,
  ) {
    final List<PlayerActionViewWrapper> playerActions = [];
    for (var item in gamePhases) {
      if (item is SpeakPhaseModel) {
        if (_isPlayerSpoke(player, item)) {
          playerActions.add(
            PlayerActionViewWrapper(
              playerAction: PlayerAction.playerSpoke,
              updatedAt: item.updatedAt,
              gamePhaseModel: item,
            ),
          );
        }
      } else if (item is VotePhaseModel) {
        if (_isPlayerVoted(player, item)) {
          playerActions.add(
            PlayerActionViewWrapper(
              playerAction: PlayerAction.playerVoted,
              updatedAt: item.updatedAt,
              gamePhaseModel: item,
            ),
          );
        } else if (_isPlayerPutOnVote(player, item)) {
          playerActions.add(
            PlayerActionViewWrapper(
              playerAction: PlayerAction.playerPutOnVote,
              updatedAt: item.updatedAt,
              gamePhaseModel: item,
            ),
          );
        }
      } else if (item is NightPhaseModel) {
        if (_isPlayerWokeUp(player, item)) {
          playerActions.add(
            PlayerActionViewWrapper(
              playerAction: PlayerAction.playerWokeUpInNight,
              updatedAt: item.updatedAt,
              gamePhaseModel: item,
            ),
          );
        } else if (_wasPlayerChecked(player, item)) {
          playerActions.add(
            PlayerActionViewWrapper(
              playerAction: PlayerAction.playerWasChecked,
              updatedAt: item.updatedAt,
              gamePhaseModel: item,
            ),
          );
        } else if (_wasPlayerKilled(player, item)) {
          playerActions.add(
            PlayerActionViewWrapper(
              playerAction: PlayerAction.playerWasKilled,
              updatedAt: item.updatedAt,
              gamePhaseModel: item,
            ),
          );
        }
      }
    }

    return playerActions.sorted(
      (a, b) => a.updatedAt.millisecondsSinceEpoch
          .compareTo(b.updatedAt.millisecondsSinceEpoch),
    );
  }

  static bool _isPlayerVoted(PlayerModel player, VotePhaseModel votePhase) {
    return votePhase.votedPlayers
        .any((votedPlayer) => votedPlayer.tempId == player.tempId);
  }

  static bool _isPlayerPutOnVote(PlayerModel player, VotePhaseModel votePhase) {
    return votePhase.whoPutOnVote?.tempId == player.tempId;
  }

  static bool _isPlayerSpoke(PlayerModel player, SpeakPhaseModel speakPhase) {
    return speakPhase.playerTempId == player.tempId;
  }

  static bool _isPlayerWokeUp(PlayerModel player, NightPhaseModel nightPhase) {
    return nightPhase.playersForWakeUp
        .any((nightPlayer) => nightPlayer.tempId == player.tempId);
  }

  static bool _wasPlayerChecked(
      PlayerModel player, NightPhaseModel nightPhase) {
    return nightPhase.checkedPlayer?.tempId == player.tempId;
  }

  static bool _wasPlayerKilled(PlayerModel player, NightPhaseModel nightPhase) {
    return nightPhase.killedPlayer?.tempId == player.tempId;
  }
}
