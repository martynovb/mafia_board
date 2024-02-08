import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mafia_board/presentation/feature/mafia_board_app.dart';
import 'package:mafia_board/presentation/injector.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: HydratedStorage.webStorageDirectory,
  );
  await Firebase.initializeApp(
      options: const FirebaseOptions(
    apiKey: 'AIzaSyBxLwoighrVb1r31lfZVJKhif0j8EoRo4k',
    appId: '1:594061159084:web:6549c1cd91afb2e9c14d09',
    messagingSenderId: '',
    projectId: 'mafia-board-app',
  ));
  await Injector.inject();
  runApp(const MafiaBoardApp());
}
