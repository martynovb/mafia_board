import 'package:easy_localization/easy_localization.dart';
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

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late AuthBloc _authBloc;
  late final TextEditingController _emailEditController =
      TextEditingController();
  late final TextEditingController _passwordEditController =
      TextEditingController();

  @override
  void initState() {
    _authBloc = GetIt.instance();
    _emailEditController.text = "palantir.nr@gmail.com";
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

        return SingleChildScrollView(
          child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: width),
              child: BlocConsumer(
                listener: (context, AuthState state) {
                  if (state is SuccessAuthState) {
                    Navigator.pushNamedAndRemoveUntil(
                        context, AppRouter.homePage, (route) => false);
                  }
                },
                bloc: _authBloc,
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
                        'loginTitle',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ).tr(),
                      const SizedBox(height: Dimensions.defaultSidePadding),

                      if (state is ErrorAuthState) ...[
                        InfoField(
                          message: state.errorMessage,
                          infoFieldType: InfoFieldType.error,
                        ),
                        const SizedBox(height: Dimensions.defaultSidePadding),
                      ],
                      if (state is ValidationErrorState) ...[
                        InfoField(
                          message: state.validationError,
                          infoFieldType: InfoFieldType.error,
                        ),
                        const SizedBox(height: Dimensions.defaultSidePadding),
                      ],

                      // Email input
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            bottom: Dimensions.sidePadding0_5x,
                          ),
                          child: const Text(
                            'email',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ).tr(),
                        ),
                      ),
                      InputTextField(
                        controller: _emailEditController,
                      ),
                      const SizedBox(height: Dimensions.defaultSidePadding),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          const Text(
                            'password',
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ).tr(),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(
                                context, AppRouter.resetPasswordPage),
                            child: const Text(
                              'forgotPassword',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.redAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ).tr(),
                          ),
                        ],
                      ),
                      const SizedBox(height: Dimensions.defaultSidePadding),
                      // Password input
                      InputTextField(
                        controller: _passwordEditController,
                      ),
                      const SizedBox(height: Dimensions.defaultSidePadding),

                      // Sign in button
                      SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () => _authBloc.add(LoginAuthEvent(
                              email: _emailEditController.text.trim(),
                              password: _passwordEditController.text.trim(),
                            )),
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.red),
                            ),
                            child: const Text(
                              'login',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ).tr(),
                          )),
                      const SizedBox(height: Dimensions.defaultSidePadding),

                      // Don't have an account? Create an account
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('dontHaveAccount').tr(),
                          TextButton(
                            onPressed: () => Navigator.pushNamed(
                                context, AppRouter.createAccountPage),
                            child: const Text(
                              'createAccount',
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ).tr(),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              )),
        );
      })),
    );
  }

  @override
  void dispose() {
    _authBloc.add(ClearAuthEvent());
    _emailEditController.dispose();
    _passwordEditController.dispose();
    super.dispose();
  }
}
