import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:mafia_board/domain/model/club_member_rating_model.dart';
import 'package:mafia_board/domain/model/game_model.dart';
import 'package:mafia_board/presentation/common/base_bloc/base_state.dart';
import 'package:mafia_board/presentation/feature/clubs/rating_table/bloc/rating_table_bloc.dart';
import 'package:mafia_board/presentation/feature/clubs/rating_table/bloc/rating_table_event.dart';
import 'package:mafia_board/presentation/feature/clubs/rating_table/bloc/rating_table_state.dart';
import 'package:mafia_board/presentation/feature/clubs/rating_table/sort_type.dart';
import 'package:mafia_board/presentation/feature/dimensions.dart';
import 'package:mafia_board/presentation/feature/widgets/info_field.dart';

class RatingTableWidget extends StatefulWidget {
  final String clubId;
  final List<GameModel> allGames;

  const RatingTableWidget({
    super.key,
    required this.clubId,
    required this.allGames,
  });

  @override
  State<RatingTableWidget> createState() => _RatingTableWidgetState();
}

class _RatingTableWidgetState extends State<RatingTableWidget> {
  late RatingTableBloc _bloc;

  final int _numberFlex = 1;
  final int _nicknameFlex = 2;
  final int _totalGamesFlex = 1;
  final int _totalWinsFlex = 1;
  final int _winRateFlex = 2;
  final int _totalPointsFlex = 1;
  final int _civilianWinRateFlex = 2;
  final int _mafWinRateFlex = 2;
  final int _sheriffWinRateFlex = 2;
  final int _donWinRateFlex = 2;
  final int _donMafWinRateFlex = 2;
  final int _civilSherWinRateFlex = 2;

  @override
  void initState() {
    _bloc = GetIt.I.get();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _bloc.add(
      GetRatingTableEvent(clubId: widget.clubId, allGames: widget.allGames),
    );
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: _bloc,
      builder: (context, RatingTableState state) {
        if (state.status == StateStatus.data) {
          return Padding(
              padding: const EdgeInsets.only(
                  left: Dimensions.defaultSidePadding,
                  right: Dimensions.defaultSidePadding),
              child: Column(
                children: [
                  _tableHeader(),
                  _membersTable(state.membersRating),
                ],
              ));
        } else if (state.status == StateStatus.error) {
          return Center(
            child: InfoField(
              message: state.errorMessage,
              infoFieldType: InfoFieldType.error,
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _headerItem({
    required int flex,
    required String text,
    SortType sortType = SortType.none,
  }) {
    return Expanded(
        flex: flex,
        child: GestureDetector(
          onTap: () {
            if (sortType == SortType.none) return;
            _bloc.add(ChangeSortTypeEvent(sortType: sortType));
          },
          child: Center(
            child: Text(
              text,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: TextStyle(
                color: _bloc.state.sortType == sortType
                    ? Colors.green
                    : Colors.white,
                backgroundColor: _bloc.state.sortType == sortType
                    ? Colors.white.withOpacity(0.1)
                    : Colors.transparent,
              ),
            ),
          ),
        ));
  }

  Widget _tableHeader() {
    return Container(
        padding: const EdgeInsets.all(Dimensions.sidePadding0_5x),
        child: Row(
          children: [
            Expanded(
              flex: _numberFlex,
              child: const Icon(
                Icons.numbers,
                size: Dimensions.defaultIconSize,
              ),
            ),
            const VerticalDivider(),
            _headerItem(flex: _nicknameFlex, text: 'nickname'),
            const VerticalDivider(),
            _headerItem(
              flex: _totalPointsFlex,
              text: 'total points',
              sortType: SortType.totalPoints,
            ),
            const VerticalDivider(),
            _headerItem(
              flex: _totalWinsFlex,
              text: 'total wins',
              sortType: SortType.totalWins,
            ),
            const VerticalDivider(),
            _headerItem(
              flex: _winRateFlex,
              text: 'total win rate',
              sortType: SortType.winRate,
            ),
            const VerticalDivider(),
            _headerItem(
              flex: _civilianWinRateFlex,
              text: 'civilian win rate',
              sortType: SortType.civilianWinRate,
            ),
            const VerticalDivider(),
            _headerItem(
              flex: _sheriffWinRateFlex,
              text: 'sheriff win rate',
              sortType: SortType.sheriffWinRate,
            ),
            const VerticalDivider(),
            _headerItem(
              flex: _civilSherWinRateFlex,
              text: 'civil + sheriff win rate',
              sortType: SortType.civilSherWinRate,
            ),
            const VerticalDivider(),
            _headerItem(
              flex: _mafWinRateFlex,
              text: 'mafia win rate',
              sortType: SortType.mafWinRate,
            ),
            const VerticalDivider(),
            _headerItem(
              flex: _donWinRateFlex,
              text: 'don win rate',
              sortType: SortType.donWinRate,
            ),
            const VerticalDivider(),
            _headerItem(
              flex: _donMafWinRateFlex,
              text: 'don + mafia win rate',
              sortType: SortType.donMafWinRate,
            ),
            const VerticalDivider(),
            _headerItem(
              flex: _totalGamesFlex,
              text: 'total games',
              sortType: SortType.totalGames,
            ),
          ],
        ));
  }

  Widget _membersTable(List<ClubMemberRatingModel> rating) => Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
            border: Border.all(width: 1, color: Colors.white30),
            borderRadius: const BorderRadius.all(Radius.circular(0))),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: rating.length,
          separatorBuilder: (context, index) => const Divider(
            height: Dimensions.sidePadding0_5x,
          ),
          itemBuilder: (__, index) => _memberItem(
            index,
            rating[index],
          ),
        ),
      );

  Widget _tableCell(int flex, String value) {
    return Expanded(
      flex: flex,
      child: Center(
        child: Text(value.toString()),
      ),
    );
  }

  Widget _memberItem(int index, ClubMemberRatingModel memberRating) {
    return SizedBox(
      height: Dimensions.playerItemHeight,
      child: Row(
        children: [
          _tableCell(
            _numberFlex,
            (index + 1).toString(),
          ),
          const VerticalDivider(color: Colors.transparent),
          _tableCell(
            _nicknameFlex,
            memberRating.member.user.nickname,
          ),
          const VerticalDivider(color: Colors.transparent),
          _tableCell(
            _totalPointsFlex,
            memberRating.totalPoints.toString(),
          ),
          const VerticalDivider(color: Colors.transparent),
          _tableCell(
            _totalWinsFlex,
            memberRating.totalWins.toString(),
          ),
          const VerticalDivider(color: Colors.transparent),
          _tableCell(
            _winRateFlex,
            memberRating.winRate.toStringAsFixed(2),
          ),
          const VerticalDivider(color: Colors.transparent),
          _tableCell(
            _civilianWinRateFlex,
            memberRating.civilianWinRate.toStringAsFixed(2),
          ),
          const VerticalDivider(color: Colors.transparent),
          _tableCell(
            _sheriffWinRateFlex,
            memberRating.sheriffWinRate.toStringAsFixed(2),
          ),
          const VerticalDivider(color: Colors.transparent),
          _tableCell(
            _civilSherWinRateFlex,
            memberRating.civilSherWinRate.toStringAsFixed(2),
          ),
          const VerticalDivider(color: Colors.transparent),
          _tableCell(
            _mafWinRateFlex,
            memberRating.mafWinRate.toStringAsFixed(2),
          ),
          const VerticalDivider(color: Colors.transparent),
          _tableCell(
            _donWinRateFlex,
            memberRating.donWinRate.toStringAsFixed(2),
          ),
          const VerticalDivider(color: Colors.transparent),
          _tableCell(
            _donMafWinRateFlex,
            memberRating.donMafWinRate.toStringAsFixed(2),
          ),
          const VerticalDivider(color: Colors.transparent),
          _tableCell(
            _totalGamesFlex,
            memberRating.totalGames.toString(),
          ),
        ],
      ),
    );
  }
}
