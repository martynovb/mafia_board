import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:mafia_board/domain/model/club_model.dart';
import 'package:mafia_board/domain/model/finish_game_type.dart';
import 'package:mafia_board/domain/model/game_status.dart';
import 'package:mafia_board/domain/model/player_model.dart';
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
  late List<Widget> _pages;
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
        _showFinishSuccessDialog();
      }
    });

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _showFinishConfirmationDialog(),
      child: BlocListener(
        bloc: gameBloc,
        listener: (context, GameState state) {
          if (state is GoToGameResults) {
            Navigator.pushNamed(
              context,
              AppRouter.gameResultsPage,
              arguments: {'club': state.club},
            );
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
            body: Row(children: [
              Expanded(
                child: PlayersSheetPage(
                  club: gameBloc.state.club ?? ClubModel.empty(),
                  onPPKGameFinished: _showFinishConfirmationPPKDialog,
                ),
              ),
              const VerticalDivider(),
              Expanded(
                child: TablePage(
                  onGameFinished: _showFinishConfirmationDialog,
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  AppBar _appBar(BuildContext context) => AppBar(
        title: const Text('Game'),
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
              icon: const Icon(Icons.settings))
        ],
      );

  Future<bool> _showFinishConfirmationDialog() async {
    if (!_isGameStarted) {
      return true;
    }
    return await showDefaultDialog(
      context: context,
      title: 'Do you want to finish the game?',
      actions: <Widget>[
        TextButton(
          child: const Text("Stop the game and close"),
          onPressed: () {
            if (gameBloc.state.club != null) {
              gameBloc.add(FinishGameEvent(
                FinishGameType.reset,
                gameBloc.state.club!,
              ));
            }
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Cancel'),
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
      title: 'Game has been finished',
      actions: <Widget>[
        TextButton(
          child: const Text('Go to results'),
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).pushNamed(
              AppRouter.gameResultsPage,
              arguments: {'club': gameBloc.state.club},
            );
          },
        ),
        TextButton(
          child: const Text('Remove game and exit'),
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
      title:
          'Do you want to finish the game with PPK for (#${player.seatNumber}: ${player.nickname})?',
      actions: <Widget>[
        TextButton(
          child: const Text("Finish game"),
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
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
