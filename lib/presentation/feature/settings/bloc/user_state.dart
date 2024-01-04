import 'package:mafia_board/domain/model/user_model.dart';

abstract class UserState {}

class UserDataState extends UserState {
  final UserModel userModel;
  final String? errorMessage;

  UserDataState({
    required this.userModel,
    this.errorMessage,
  });
}

class InitialState extends UserState {}
