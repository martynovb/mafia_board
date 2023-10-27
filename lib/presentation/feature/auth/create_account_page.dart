import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:mafia_board/presentation/feature/auth/bloc/auth_bloc.dart';
import 'package:mafia_board/presentation/feature/auth/bloc/auth_event.dart';
import 'package:mafia_board/presentation/feature/auth/bloc/auth_state.dart';
import 'package:mafia_board/presentation/feature/dimensions.dart';
import 'package:mafia_board/presentation/feature/router.dart';
import 'package:mafia_board/presentation/feature/widgets/info_field.dart';
import 'package:mafia_board/presentation/feature/widgets/input_text_field.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({Key? key}) : super(key: key);

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  late AuthBloc _authBloc;
  final TextEditingController _nickEditController = TextEditingController();
  final TextEditingController _emailEditController = TextEditingController();
  final TextEditingController _passwordEditController = TextEditingController();
  final TextEditingController _repeatPasswordEditController =
      TextEditingController();

  @override
  void initState() {
    _authBloc = GetIt.instance();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        double width;
        if (constraints.maxWidth > 400) {
          width = 400;
        } else {
          width = constraints.maxWidth;
        }

        return ConstrainedBox(
            constraints: BoxConstraints(maxWidth: width),
            child: BlocConsumer(
              bloc: _authBloc,
              listener: (context, AuthState state) {
                if (state is SuccessAuthState) {
                  Navigator.pushNamedAndRemoveUntil(
                      context, AppRouter.homePage, (route) => false);
                }
              },
              builder: (context, AuthState state) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Logo (replace with your asset image)
                    const SizedBox(
                      height: Dimensions.defaultSidePadding,
                    ),
                    const Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.thumb_up, size: 70, color: Colors.red),
                        Icon(Icons.thumb_down, size: 70, color: Colors.black)
                      ],
                    ),
                    const SizedBox(height: Dimensions.sidePadding2x),

                    // Sign in to your account
                    const Text(
                      'Create an account',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: Dimensions.defaultSidePadding),

                    if (state is ErrorAuthState) ...[
                      InfoField(
                          message: state.errorMessage,
                          infoFieldType: InfoFieldType.error),
                      const SizedBox(height: Dimensions.defaultSidePadding),
                    ],

                    // Nickname input
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding:
                            EdgeInsets.only(bottom: Dimensions.sidePadding0_5x),
                        child: Text(
                          'Nickname',
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    InputTextField(
                      controller: _nickEditController,
                    ),
                    const SizedBox(height: Dimensions.defaultSidePadding),
                    // Email input
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding:
                            EdgeInsets.only(bottom: Dimensions.sidePadding0_5x),
                        child: Text(
                          'Email',
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    InputTextField(
                      controller: _emailEditController,
                    ),
                    const SizedBox(height: Dimensions.defaultSidePadding),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding:
                            EdgeInsets.only(bottom: Dimensions.sidePadding0_5x),
                        child: Text(
                          'Password',
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),

                    // Password input
                    InputTextField(
                      obscureText: true,
                      controller: _passwordEditController,
                    ),
                    const SizedBox(height: Dimensions.defaultSidePadding),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding:
                            EdgeInsets.only(bottom: Dimensions.sidePadding0_5x),
                        child: Text(
                          'Repeat password',
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),

                    // Password input
                    InputTextField(
                      controller: _repeatPasswordEditController,
                      obscureText: true,
                    ),
                    const SizedBox(height: Dimensions.defaultSidePadding),
                    // Sign in button
                    SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () => _authBloc.add(RegistrationAuthEvent(
                            nickname: _nickEditController.text.trim(),
                            email: _emailEditController.text.trim(),
                            password: _passwordEditController.text.trim(),
                            repeatPassword:
                                _repeatPasswordEditController.text.trim(),
                          )),
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.red),
                          ),
                          child: const Text('Sign up',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold)),
                        )),
                    const SizedBox(height: Dimensions.defaultSidePadding),

                    // Don't have an account? Create an account
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Already have an account?'),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Sign in',
                            style: TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ));
      })),
    );
  }

  @override
  void dispose() {
    _authBloc.add(ClearAuthEvent());
    super.dispose();
  }
}
