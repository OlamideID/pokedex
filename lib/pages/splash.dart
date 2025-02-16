import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:poke/pages/home.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Center(
        child:
            Lottie.asset('assets/lottiefiles/Animation - 1739746455594.json'),
      ),
      nextScreen: HomePage(),
      duration: 3500,
      splashIconSize: 200,
    );
  }
}
