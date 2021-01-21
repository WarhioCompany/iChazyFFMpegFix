import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ichazy/domain/model/region.dart';
import 'package:ichazy/internal/application.dart';
import 'package:ichazy/presentation/colors/theme.dart';
import 'package:ichazy/presentation/feed_screen.dart';
import 'package:route_observer_mixin/route_observer_mixin.dart';

import 'data/api/shared_preferences/shared.dart';

void main() async {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarIconBrightness: Brightness.dark, // status bar color
  ));
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await Future.wait([Preferences().init(), RegionSingleton().init()]);
  runApp(RouteObserverProvider(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('ru'),
      ],
      routes: {
        '/feed': (context) => FeedScreen(),
      },
      debugShowCheckedModeBanner: false,
      title: 'iChazy',
      theme: AppTheme.appTheme,
      navigatorObservers: [RouteObserverProvider.of(context)],
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Application();
  }
}
