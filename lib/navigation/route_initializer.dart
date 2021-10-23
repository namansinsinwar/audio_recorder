import 'package:audio_recorder/presentation/home.dart';
import 'package:flutter/material.dart';

Map<String, Widget Function(BuildContext context)> routes() =>
  {
    Routes.homePage: (context) => MyHomePage()
  };

class Routes {
  Routes._();

  static const String homePage = '/homePage';
}