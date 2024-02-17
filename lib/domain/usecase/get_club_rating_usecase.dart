import 'package:collection/collection.dart';
import 'package:mafia_board/data/repo/clubs/clubs_repo.dart';
import 'package:mafia_board/data/repo/players/players_repo.dart';
import 'package:mafia_board/domain/model/club_member_model.dart';
import 'package:mafia_board/domain/model/club_member_rating_model.dart';
import 'package:mafia_board/domain/model/game_model.dart';
import 'package:mafia_board/domain/model/player_model.dart';
import 'package:mafia_board/domain/model/role.dart';
import 'package:mafia_board/domain/model/winner_type.dart';
import 'package:mafia_board/domain/usecase/base_usecase.dart';

class GetClubRatingUseCase
    extends BaseUseCase<List<ClubMemberRatingModel>, GetClubRatingParams> {
  final ClubsRepo clubsRepo;
  final PlayersRepo playersRepo;

  GetClubRatingUseCase({
    required this.playersRepo,
    required this.clubsRepo,
  });

  @override
  Future<List<ClubMemberRatingModel>> execute({
    GetClubRatingParams? params,
  }) async {
    if (params == null || params.games.isEmpty) return [];

    final allGames = params.games;
    final allMembers =
        (await clubsRepo.getExistedClubMembers(clubId: params.clubId))
            .map((entity) => ClubMemberModel.fromEntity(entity))
            .toList();

    final membersRating = <ClubMemberRatingModel>[];

    for (final member in allMembers) {
      final allPlayersByMember =
          (await playersRepo.fetchAllPlayersByMemberId(memberId: member.id!))
              .map((entity) => PlayerModel.fromEntity(entity))
              .toList();

      final totalGames = allPlayersByMember.length;
      var totalWins = 0;
      var totalLosses = 0;
      var totalCivilianWins = 0.0;
      var totalMafWins = 0.0;
      var totalDonWins = 0.0;
      var totalSheriffWins = 0.0;
      var totalPoints = 0.0;

      for (final player in allPlayersByMember) {
        final gameByPlayer = allGames.firstWhereOrNull(
          (game) => game.id == player.gameId,
        );
        if (gameByPlayer == null) {
          continue;
        }

        totalPoints += player.total();

        if ((gameByPlayer.winnerType == WinnerType.civilian &&
                (player.role == Role.civilian ||
                    player.role == Role.sheriff)) ||
            (gameByPlayer.winnerType == WinnerType.mafia &&
                (player.role == Role.mafia || player.role == Role.don))) {
          totalWins++;
        }

        if ((gameByPlayer.winnerType == WinnerType.mafia &&
                (player.role == Role.civilian ||
                    player.role == Role.sheriff)) ||
            (gameByPlayer.winnerType == WinnerType.civilian &&
                (player.role == Role.mafia || player.role == Role.don))) {
          totalLosses++;
        }

        if ((gameByPlayer.winnerType == WinnerType.civilian &&
            (player.role == Role.civilian))) {
          totalCivilianWins++;
        }

        if ((gameByPlayer.winnerType == WinnerType.civilian &&
            (player.role == Role.sheriff))) {
          totalSheriffWins++;
        }

        if ((gameByPlayer.winnerType == WinnerType.mafia &&
            (player.role == Role.mafia))) {
          totalMafWins++;
        }

        if ((gameByPlayer.winnerType == WinnerType.mafia &&
            (player.role == Role.don))) {
          totalDonWins++;
        }
      }

      membersRating.add(
        ClubMemberRatingModel(
          member: member,
          totalGames: totalGames,
          totalWins: totalWins,
          totalLosses: totalLosses,
          winRate: ((totalWins / totalGames) * 100) ?? 0.0,
          civilianWinRate: ((totalWins / totalCivilianWins) * 100) ?? 0.0,
          mafWinRate: ((totalWins / totalMafWins) * 100) ?? 0.0,
          sheriffWinRate: ((totalWins / totalSheriffWins) * 100) ?? 0.0,
          donWinRate: ((totalWins / totalDonWins) * 100) ?? 0.0,
          donMafWinRate: ((totalWins / (totalMafWins + totalDonWins)) * 100) ?? 0.0,
          civilSherWinRate:
          ((totalWins / (totalCivilianWins + totalSheriffWins)) * 100) ?? 0.0,
          totalPoints: totalPoints,
        ),
      );
    }

    return membersRating;
  }
}

class GetClubRatingParams {
  final String clubId;
  final List<GameModel> games;

  GetClubRatingParams({
    required this.clubId,
    required this.games,
  });
}
