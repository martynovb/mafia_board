import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mafia_board/presentation/feature/dimensions.dart';
import 'package:mafia_board/presentation/feature/widgets/input_text_field.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({Key? key}) : super(key: key);

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  late final TextEditingController _emailEditController =
      TextEditingController();

  @override
  void initState() {
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
          child: Column(
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
                  Icon(Icons.thumb_up, size: 100, color: Colors.red),
                  Icon(Icons.thumb_down, size: 100, color: Colors.black)
                ],
              ),
              const SizedBox(height: Dimensions.sidePadding2x),

              // Sign in to your account
              const Text(
                'resetPasswordTitle',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: Dimensions.defaultSidePadding),

              // Email input
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding:
                      const EdgeInsets.only(bottom: Dimensions.sidePadding0_5x),
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
              SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.red),
                    ),
                    child: const Text(
                      'resetPassword',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ).tr(),
                  )),
              const SizedBox(height: Dimensions.defaultSidePadding),

              // Don't have an account? Create an account
              Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'backToSignIn',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ).tr(),
                ),
              )
            ],
          ),
        );
      })),
    );
  }
}
