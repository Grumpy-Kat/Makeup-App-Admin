import 'package:flutter/material.dart' hide HSVColor;
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'theme.dart' as theme;
import 'routes.dart' as routes;
import 'navigation.dart' as navigation;
import 'presetPalettesIO.dart' as presetPalettesIO;
import 'localizationIO.dart' as localizationIO;

void main() => runApp(GlamKitApp());

class GlamKitApp extends StatefulWidget {
  @override
  GlamKitAppState createState() => GlamKitAppState();
}

class GlamKitAppState extends State<GlamKitApp> {
  static bool hasLoaded = false;

  @override
  Widget build(BuildContext context) {
    if(!hasLoaded) {
      load().then((value) => setState(() { }));
    }
    return MaterialApp(
      title: 'GlamKit Admin',
      theme: theme.themeData,
      home: _getHome(),
      routes: routes.routes,
      debugShowCheckedModeBanner: false,
    );
  }

  static Future<void> load() async {
    await Firebase.initializeApp();
    await login();
    await localizationIO.load();
    theme.isDarkTheme = (WidgetsBinding.instance!.window.platformBrightness == Brightness.dark);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    routes.setRoutes();
    presetPalettesIO.init();
    hasLoaded = true;
  }

  static Future<void> login() async {
    String login = await rootBundle.loadString('assets/login.txt');
    login = login.trim().split('\n')[0];
    if(FirebaseAuth.instance.currentUser == null) {
      await FirebaseAuth.instance.signInAnonymously();
    }
    await FirebaseAuth.instance.currentUser!.updateDisplayName(login);
    await FirebaseAuth.instance.currentUser!.getIdToken(true);
    print(FirebaseAuth.instance.currentUser!.displayName);
  }

  Widget _getHome() {
    if(hasLoaded) {
      navigation.init(routes.ScreenRoutes.CategoriesScreen);
      return routes.routes[routes.defaultRoute]!(null);
    }
    return Container();
  }
}