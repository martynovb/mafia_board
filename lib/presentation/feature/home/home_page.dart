import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mafia_board/data/model/game_info_model.dart';
import 'package:mafia_board/presentation/feature/home/board/board_bloc/board_bloc.dart';
import 'package:mafia_board/presentation/feature/home/players_sheet/players_sheet_page.dart';
import 'package:mafia_board/presentation/feature/router.dart';
import 'package:mafia_board/presentation/feature/table/table_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: _appBar(context),
        body: _body(),
      ),
    );
  }

  AppBar _appBar(BuildContext context) => AppBar(
        actions: [
          IconButton(
              onPressed: () =>
                  Navigator.pushNamed(context, AppRouter.settingsPage),
              icon: const Icon(Icons.settings))
        ],
      );

  Widget _body() => StreamBuilder(
      stream: GetIt.instance<BoardBloc>().gameInfoStream,
      builder: (context, AsyncSnapshot<GameInfoModel> snapshot) {
        GameInfoModel? gameInfo;
        if (snapshot.hasData) {
          gameInfo = snapshot.data;
        }
        if(gameInfo?.isGameStarted == true){
          return const TablePage();
        }
        return const PlayersSheetPage();
      });
}
