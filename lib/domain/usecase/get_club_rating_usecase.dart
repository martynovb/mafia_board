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
      var totalCivilGames = 0.0;
      var totalMafWins = 0.0;
      var totalMafGames = 0.0;
      var totalDonWins = 0.0;
      var totalDonGames = 0.0;
      var totalSheriffWins = 0.0;
      var totalSheriffGames = 0.0;
      var totalPoints = 0.0;

      for (final player in allPlayersByMember) {
        final gameByPlayer = allGames.firstWhereOrNull(
          (game) => game.id == player.gameId,
        );
        if (gameByPlayer == null) {
          continue;
        }

        totalPoints += player.total();

        if (player.role == Role.civilian) {
          totalCivilGames++;
        } else if (player.role == Role.mafia) {
          totalMafGames++;
        } else if (player.role == Role.don) {
          totalDonGames++;
        } else if (player.role == Role.sheriff) {
          totalSheriffGames++;
        }

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

      final winRate = _divideSafely(
            totalWins,
            totalGames,
          ) *
          100;
      final civilianWinRate = _divideSafely(
            totalCivilianWins,
            totalCivilGames,
          ) *
          100;
      final mafWinRate = _divideSafely(
            totalMafWins,
            totalMafGames,
          ) *
          100;
      final sheriffWinRate = _divideSafely(
            totalSheriffWins,
            totalSheriffGames,
          ) *
          100;
      final donWinRate = _divideSafely(
            totalDonWins,
            totalDonGames,
          ) *
          100;
      final donMafWinRate = _divideSafely(
            totalMafWins + totalDonWins,
            totalMafGames + totalDonGames,
          ) *
          100;
      final civilSherWinRate = _divideSafely(
            totalCivilianWins + totalSheriffWins,
            totalCivilGames + totalSheriffGames,
          ) *
          100;

      membersRating.add(
        ClubMemberRatingModel(
          member: member,
          totalGames: totalGames,
          totalWins: totalWins,
          totalLosses: totalLosses,
          winRate: winRate,
          civilianWinRate: civilianWinRate,
          mafWinRate: mafWinRate,
          sheriffWinRate: sheriffWinRate,
          donWinRate: donWinRate,
          donMafWinRate: donMafWinRate,
          civilSherWinRate: civilSherWinRate,
          totalPoints: totalPoints,
        ),
      );
    }

    return membersRating;
  }

  double _divideSafely(num dividend, num divisor) {
    if (divisor == 0.0) {
      return 0.0;
    } else {
      return dividend / divisor;
    }
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
