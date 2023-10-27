import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:mafia_board/presentation/feature/auth/bloc/auth_bloc.dart';
import 'package:mafia_board/presentation/feature/auth/bloc/auth_event.dart';
import 'package:mafia_board/presentation/feature/auth/bloc/auth_state.dart';
import 'package:mafia_board/presentation/feature/dimensions.dart';
import 'package:mafia_board/presentation/feature/router.dart';
import 'package:mafia_board/presentation/feature/settings/settings_item.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late AuthBloc _authBloc;
  Widget? _currentSettingsContent;
  final double _minWidth = 600;
  final double _maxWidth = 800;

  @override
  void initState() {
    _authBloc = GetIt.I.get();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _currentSettingsContent = _accountSettingsList();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: const Text('Settings'),
              centerTitle: true,
            ),
            body: WillPopScope(onWillPop: () async {
              final currentWidth = MediaQuery.of(context).size.width;
              if (_currentSettingsContent != null && currentWidth < _minWidth) {
                _currentSettingsContent = null;
                setState(() {});
                return false;
              }
              return true;
            }, child: LayoutBuilder(builder: (context, constraints) {
              if (constraints.maxWidth < _minWidth) {
                return _currentSettingsContent != null
                    ? _currentSettingsContent!
                    : _menuList();
              }
              return BlocConsumer(
                  bloc: _authBloc,
                  listener: (context, AuthState state) {
                    if (state is LogoutSuccessAuthState) {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          AppRouter.loginPage, (route) => false);
                    }
                  },
                  builder: (context, AuthState state) {
                    return Center(
                        child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: _maxWidth,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                const Spacer(),
                                Flexible(
                                  flex: 2,
                                  child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: Dimensions.defaultSidePadding,
                                          left: Dimensions.defaultSidePadding),
                                      child: _menuList()),
                                ),
                                Flexible(
                                    flex: 5,
                                    child: _currentSettingsContent != null
                                        ? Padding(
                                            padding: const EdgeInsets.all(
                                                Dimensions.defaultSidePadding),
                                            child: _currentSettingsContent!)
                                        : Container()),
                                const Spacer(),
                              ],
                            )));
                  });
            }))));
  }

  Widget _menuList() => ListView(
        children: [
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Account'),
            titleTextStyle:
                TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            onTap: () {
              _currentSettingsContent = _accountSettingsList();
              setState(() {});
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            iconColor: Colors.redAccent,
            textColor: Colors.redAccent,
            titleTextStyle: TextStyle(fontWeight: FontWeight.bold),
            title: Text('Logout'),
            onTap: () => _authBloc.add(LogoutAuthEvent()),
          ),
        ],
      );

  Widget _accountSettingsList() => ListView(
        children: [
          SettingsItem(
            title: 'Nickname',
            description: 'magic',
            onPressed: () {},
            btnText: 'Change',
          ),
          Divider(),
          SettingsItem(
            title: 'Email',
            description: 'magic@magic.com',
            onPressed: () {},
            btnText: 'Change',
          ),
        ],
      );
}
