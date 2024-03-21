import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:mafia_board/domain/model/club_model.dart';
import 'package:mafia_board/domain/model/finish_game_type.dart';
import 'package:mafia_board/domain/model/game_status.dart';
import 'package:mafia_board/domain/model/player_model.dart';
import 'package:mafia_board/domain/model/role.dart';
import 'package:mafia_board/presentation/feature/game/game_bloc/game_bloc.dart';
import 'package:mafia_board/presentation/feature/game/game_bloc/game_event.dart';
import 'package:mafia_board/presentation/feature/game/game_bloc/game_state.dart';
import 'package:mafia_board/presentation/feature/game/players_sheet/players_sheet_page.dart';
import 'package:mafia_board/presentation/feature/game/table/table_page.dart';
import 'package:mafia_board/presentation/feature/router.dart';
import 'package:mafia_board/presentation/feature/widgets/dialogs.dart';

class GamePage extends StatefulWidget {
  const GamePage({Key? key}) : super(key: key);

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage>
    with SingleTickerProviderStateMixin {
  late GameBloc gameBloc;
  bool _isGameStarted = false;

  @override
  void initState() {
    gameBloc = GetIt.I();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    final Map<String, dynamic>? args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    gameBloc.add(PrepareGameEvent(club: args?['club'] ?? gameBloc.state.club));

    gameBloc.gameStream.listen((gameModel) {
      if (gameModel?.gameStatus == GameStatus.finished &&
          gameModel?.finishGameType == FinishGameType.normalFinish) {
       // _showFinishSuccessDialog();
      }
    });

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isGameStarted,
      onPopInvoked: (bool didPop) => _showFinishConfirmationDialog(context),
      child: BlocListener(
        bloc: gameBloc,
        listener: (context, GameState state) {
          if (state is GoToGameResults) {
           _showFinishSuccessDialog();
          } else if (state is GamePhaseState) {
            _isGameStarted =
                state.currentGame?.gameStatus == GameStatus.inProgress;
          } else if (state is CloseGameState) {
            Navigator.pop(context);
          }
        },
        child: SafeArea(
          child: Scaffold(
            appBar: _appBar(context),
            body: Row(
              children: [
                Expanded(
                  child: PlayersSheetPage(
                    club: gameBloc.state.club ?? ClubModel.empty(),
                    onPPKGameFinished: _showFinishConfirmationPPKDialog,
                  ),
                ),
                const VerticalDivider(),
                Expanded(
                  child: TablePage(
                    onGameFinished: () =>
                        _showFinishConfirmationDialog(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  AppBar _appBar(BuildContext context) => AppBar(
        title: Text(gameBloc.state.club?.title ?? ''),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(
              context,
              AppRouter.gameRulesPage,
              arguments: {
                'clubId': gameBloc.state.club?.id,
              },
            ),
            icon: const Icon(Icons.settings),
          )
        ],
      );

  Future<bool> _showFinishConfirmationDialog(BuildContext context) async {
    if (!_isGameStarted) {
      return true;
    }
    return await showDefaultDialog(
      context: context,
      title: 'finishGameDialogTitle'.tr(),
      actions: <Widget>[
        TextButton(
          child: const Text('finishWithoutSaving').tr(),
          onPressed: () {
            if (gameBloc.state.club != null) {
              gameBloc.add(
                FinishGameEvent(
                  FinishGameType.reset,
                  gameBloc.state.club!,
                ),
              );
            }
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('cancel').tr(),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  Future<bool> _showFinishSuccessDialog() async {
    return await showDefaultDialog(
      context: context,
      title: 'gameFinished'.tr(),
      actions: <Widget>[
        TextButton(
          child: const Text('goToResults').tr(),
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).pushNamed(
              AppRouter.gameResultsPage,
              arguments: {
                'club': gameBloc.state.club,
              },
            );
          },
        ),
        TextButton(
          child: const Text('finishWithoutSaving').tr(),
          onPressed: () {
            gameBloc.add(RemoveGameDataEvent());
            Navigator.of(context).popUntil(
                (route) => route.settings.name == AppRouter.clubDetailsPage);
          },
        ),
      ],
    );
  }

  Future<void> _showFinishConfirmationPPKDialog(PlayerModel player) async {
    await showDefaultDialog(
      context: context,
      title: 'ppkForUser'.tr(args: [
        (mafiaRoles().contains(player.role) ? 'mafia' : 'civilian').tr(),
        player.seatNumber.toString(),
        player.nickname,
      ]),
      actions: <Widget>[
        TextButton(
          child: const Text("finishGame").tr(),
          onPressed: () {
            if (gameBloc.state.club != null) {
              gameBloc.add(
                FinishGameEvent(
                  FinishGameType.ppk,
                  gameBloc.state.club!,
                  player.tempId,
                ),
              );
            }
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('cancel').tr(),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
