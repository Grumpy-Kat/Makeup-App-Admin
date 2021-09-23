import 'Screens/CategoriesScreen.dart';
import 'Screens/PalettesScreen.dart';
import 'Screens/PaletteScreen.dart';
import 'Screens/ComparePalettesScreen.dart';
import 'Screens/SwatchScreen.dart';
import 'types.dart';

Map<String, OnScreenAction> routes = {};
Map<ScreenRoutes, OnScreenAction> enumRoutes = {};

String defaultRoute = '/categoriesScreen';
ScreenRoutes defaultEnumRoute = ScreenRoutes.CategoriesScreen;

enum ScreenRoutes {
  CategoriesScreen,
  PalettesScreen,
  PaletteScreen,
  ComparePalettesScreen,
  SwatchScreen,
}

void setRoutes() {
  routes = {
    '/categoriesScreen': (context) => CategoriesScreen(),
    '/palettesScreen': (context) => PalettesScreen(),
    '/paletteScreen': (context) => PaletteScreen(),
    '/comparePalettesScreen': (context) => ComparePalettesScreen(),
    '/swatchScreen': (context) => SwatchScreen(paletteId: '', swatchId: 0),
  };
  enumRoutes = {
    ScreenRoutes.CategoriesScreen: routes['/categoriesScreen']!,
    ScreenRoutes.PalettesScreen: routes['/palettesScreen']!,
    ScreenRoutes.PaletteScreen: routes['/paletteScreen']!,
    ScreenRoutes.ComparePalettesScreen: routes['/comparePalettesScreen']!,
    ScreenRoutes.SwatchScreen: routes['/swatchScreen']!,
  };
}