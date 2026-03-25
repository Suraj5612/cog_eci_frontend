import 'package:cog_eci_frontend/features/auth/bloc/auth_event.dart';
import 'package:cog_eci_frontend/features/auth/repository/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/router/app_router.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/ocr/bloc/ocr_bloc.dart';
import 'features/voter/bloc/voter_bloc.dart';
import 'features/voter/bloc/voter_repository.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(AuthRepository())..add(CheckAuthStatus()),
        ),
        BlocProvider<OCRBloc>(create: (_) => OCRBloc()),
        BlocProvider<VoterBloc>(create: (_) => VoterBloc(VoterRepository())),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: appRouter,
      ),
    );
  }
}
