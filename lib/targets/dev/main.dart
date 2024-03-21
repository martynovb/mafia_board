import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mafia_board/presentation/feature/mafia_board_app.dart';
import 'package:mafia_board/presentation/injector.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mafia_board/targets/run_configurations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: HydratedStorage.webStorageDirectory,
  );
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: RunConfigurations.firebaseApiKey,
      appId: RunConfigurations.firebaseAppId,
      messagingSenderId: RunConfigurations.firebaseMessagingSenderId,
      projectId: RunConfigurations.firebaseProjectId,
    ),
  );
  
  await Injector.inject();
  runApp(const MafiaBoardApp());
}
