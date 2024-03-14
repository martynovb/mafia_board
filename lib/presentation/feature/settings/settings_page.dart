import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:mafia_board/domain/model/user_model.dart';
import 'package:mafia_board/presentation/feature/auth/bloc/auth_bloc.dart';
import 'package:mafia_board/presentation/feature/auth/bloc/auth_event.dart';
import 'package:mafia_board/presentation/feature/auth/bloc/auth_state.dart';
import 'package:mafia_board/presentation/feature/dimensions.dart';
import 'package:mafia_board/presentation/feature/router.dart';
import 'package:mafia_board/presentation/feature/settings/bloc/user_bloc.dart';
import 'package:mafia_board/presentation/feature/settings/bloc/user_event.dart';
import 'package:mafia_board/presentation/feature/settings/bloc/user_state.dart';
import 'package:mafia_board/presentation/feature/settings/settings_item.dart';
import 'package:mafia_board/presentation/feature/widgets/info_field.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _nicknameController = TextEditingController();
  late AuthBloc _authBloc;
  late UserBloc _userBloc;
  final double _maxWidth = 800;

  @override
  void initState() {
    _authBloc = GetIt.I.get();
    _userBloc = GetIt.I.get();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _userBloc.add(GetUserDataEvent());
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      bloc: _authBloc,
      listener: (context, AuthState state) {
        if (state is LogoutSuccessAuthState) {
          Navigator.of(context)
              .pushNamedAndRemoveUntil(AppRouter.loginPage, (route) => false);
        }
      },
      child: BlocBuilder(
        bloc: _userBloc,
        builder: (context, UserState state) {
          if (state is UserDataState) {
            return LayoutBuilder(
              builder: (context, constraints) {
                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: _maxWidth,
                    ),
                    child: Column(
                      children: [
                        if (state.errorMessage != null) ...[
                          InfoField(
                              message: state.errorMessage!,
                              infoFieldType: InfoFieldType.error),
                          const SizedBox(
                            height: Dimensions.defaultSidePadding,
                          ),
                        ] else
                          const SizedBox(
                            height: Dimensions.defaultSidePadding +
                                Dimensions.infoFieldHeight,
                          ),
                        Expanded(
                            child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            const Spacer(),
                            Flexible(
                              flex: 5,
                              child: _accountSettingsList(state.userModel),
                            ),
                            const Spacer(),
                          ],
                        ))
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _accountSettingsList(UserModel user) => ListView(
        children: [
          SettingsItem(
            title: 'nickname'.tr(),
            description: user.nickname,
            onPressed: () {
              changeNickNameDialog();
            },
            btnText: 'change'.tr(),
          ),
          const Divider(),
          SettingsItem(
            title: 'email'.tr(),
            description: user.email,
          ),
          const Divider(),
          SettingsItem(
            title: 'language'.tr(),
            descriptionWidget: _changeLanguageDropdown(),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            iconColor: Colors.redAccent,
            textColor: Colors.redAccent,
            titleTextStyle: const TextStyle(fontWeight: FontWeight.bold),
            title: const Text('logout').tr(),
            onTap: () => _logoutConfirmationDialog(),
          ),
        ],
      );

  Widget _changeLanguageDropdown() {
    return DropdownButton<String>(
      value: context.locale.languageCode,
      underline: const SizedBox(),
      icon: const Icon(Icons.language),
      iconSize: 24,
      elevation: 16,
      onChanged: (String? newValue) {
        context.setLocale(Locale(newValue!));
      },
      items: <String>['en', 'uk', 'ru'].map<DropdownMenuItem<String>>(
        (String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Padding(
              padding: const EdgeInsets.only(
                right: Dimensions.sidePadding0_5x,
              ),
              child: Text(value.tr()),
            ),
          );
        },
      ).toList(),
    );
  }

  void changeNickNameDialog() {
    showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('changeNickname').tr(),
            content: TextField(
              controller: _nicknameController,
              decoration: InputDecoration(hintText: 'enterNewNickname'.tr()),
            ),
            actions: <Widget>[
              SizedBox(
                  width: 120,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Colors.white30),
                    ),
                    child: const Text(
                      'cancel',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ).tr(),
                  )),
              SizedBox(
                  width: 120,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      final nickname = _nicknameController.text.trim();
                      if (nickname.isNotEmpty) {
                        _userBloc.add(
                          ChangeNicknameEvent(nickname),
                        );
                        Navigator.of(context).pop();
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Colors.white30),
                    ),
                    child: const Text(
                      'save',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ).tr(),
                  )),
            ],
          );
        });
  }

  void _logoutConfirmationDialog() {
    showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('askLogout').tr(),
            actions: <Widget>[
              SizedBox(
                  width: 120,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Colors.white30),
                    ),
                    child: const Text(
                      'cancel',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ).tr(),
                  )),
              SizedBox(
                  width: 120,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      _authBloc.add(LogoutAuthEvent());
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Colors.white30),
                    ),
                    child: const Text(
                      'confirm',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ).tr(),
                  )),
            ],
          );
        });
  }
}
