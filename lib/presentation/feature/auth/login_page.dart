import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mafia_board/presentation/feature/auth/bloc/auth_bloc.dart';
import 'package:mafia_board/presentation/feature/auth/bloc/auth_event.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late AuthBloc _authBloc;
  late TextEditingController _emailEditController = TextEditingController();
  late TextEditingController _passwordEditController = TextEditingController();

  @override
  void initState() {
    _authBloc = GetIt.instance();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(),
            body: Column(
              children: [
                const Icon(Icons.login),
                const Text('Sign in to your account'),
                TextField(
                  maxLines: 1,
                  controller: _emailEditController,
                  decoration: const InputDecoration(
                    hintText: 'email',
                    border: InputBorder.none,
                  ),
                ),
                TextField(
                  maxLines: 1,
                  controller: _passwordEditController,
                  decoration: const InputDecoration(
                    hintText: 'password',
                    border: InputBorder.none,
                  ),
                ),
                ElevatedButton(
                    onPressed: () {
                      _authBloc.add(LoginAuthEvent(
                        email: _emailEditController.text,
                        password: _passwordEditController.text,
                      ));
                    },
                    child: Text('Sign in')),
              ],
            )));
  }
}
