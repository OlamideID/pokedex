import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:poke/routes/routes.dart';
import 'package:poke/services/favorite.dart';
import 'package:poke/services/http_service.dart';
import 'package:url_strategy/url_strategy.dart';

void main() async {
  await _setup();
  setPathUrlStrategy();

  runApp(const ProviderScope(child: MyApp()));
}

Future<void> _setup() async {
  GetIt.instance.registerSingleton<HttpService>(HttpService());
  GetIt.instance.registerSingleton<FavoriteList>(FavoriteList());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
        textTheme: GoogleFonts.latoTextTheme(),
      ),
      routerConfig: router,
      title: 'Pokédexishh',
    );
  }
}
