import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'data/store_repository.dart';
import 'screens/home_screen.dart';
import 'state/store_cubit.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const GemStoreApp());
}

class GemStoreApp extends StatelessWidget {
  final StoreRepository? repository;
  const GemStoreApp({super.key, this.repository});
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => StoreCubit(repository ?? StoreRepository())..load(),
    child: MaterialApp(
      title: 'GemStore',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const HomeScreen(),
    ),
  );
}
