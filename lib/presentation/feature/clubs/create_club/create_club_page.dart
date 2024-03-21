import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:mafia_board/presentation/feature/clubs/create_club/bloc/create_club_bloc.dart';
import 'package:mafia_board/presentation/feature/clubs/create_club/bloc/create_club_event.dart';
import 'package:mafia_board/presentation/feature/clubs/create_club/bloc/create_club_state.dart';
import 'package:mafia_board/presentation/feature/dimensions.dart';
import 'package:mafia_board/presentation/feature/router.dart';
import 'package:mafia_board/presentation/feature/widgets/input_text_field.dart';

class CreateClubPage extends StatefulWidget {
  const CreateClubPage({Key? key}) : super(key: key);

  @override
  State<CreateClubPage> createState() => _CreateClubPageState();
}

class _CreateClubPageState extends State<CreateClubPage> {
  final _clubNameController = TextEditingController();
  final _clubDescriptionController = TextEditingController();

  late CreateClubBloc _createClubBloc;

  @override
  void initState() {
    _createClubBloc = GetIt.I();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: BlocListener(
          bloc: _createClubBloc,
          listener: (context, state) {
            if (state is ClubCreatedState) {
              Navigator.pushReplacementNamed(
                context,
                AppRouter.gameRulesPage,
                arguments: {'clubId': state.club.id},
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.only(
              top: Dimensions.defaultSidePadding,
              left: Dimensions.defaultSidePadding,
              right: Dimensions.defaultSidePadding,
            ),
            child: Column(
              children: [
                // club name input
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        bottom: Dimensions.sidePadding0_5x),
                    child: const Text(
                      'clubName',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ).tr(),
                  ),
                ),
                InputTextField(
                  controller: _clubNameController,
                ),
                const SizedBox(height: Dimensions.defaultSidePadding),

                // club description input
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      bottom: Dimensions.sidePadding0_5x,
                    ),
                    child: const Text(
                      'clubDescription',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ).tr(),
                  ),
                ),
                InputTextField(
                  height: 70,
                  controller: _clubDescriptionController,
                ),
                const SizedBox(height: Dimensions.defaultSidePadding),

                // Sign in button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => _createClubBloc.add(CreateClubEvent(
                      name: _clubNameController.text.trim(),
                      clubDescription: _clubDescriptionController.text.trim(),
                    )),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.red),
                    ),
                    child: const Text(
                      'createClub',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ).tr(),
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
