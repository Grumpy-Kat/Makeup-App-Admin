import 'package:flutter/material.dart' hide HSVColor;
import '../Widgets/Palette.dart';
import '../globalWidgets.dart' as globalWidgets;
import '../navigation.dart' as navigation;
import '../routes.dart' as routes;
import '../localizationIO.dart';
import 'Screen.dart';
import 'PalettesScreen.dart';

class CategoriesScreen extends StatefulWidget {
  @override
  CategoriesScreenState createState() => CategoriesScreenState();
}

class CategoriesScreenState extends State<CategoriesScreen> with ScreenState {
  @override
  void initState() {
    super.initState();
    addHasLocalizationLoadedListener(() { setState(() {}); });
  }

  @override
  Widget build(BuildContext context) {
    return buildComplete(
      context,
      'Palettes',
      0,
      body: ListView(
        children: [
          globalWidgets.getListItem(
            'Pending',
            '',
            false,
            () {
              navigation.push(
                context,
                const Offset(1, 0),
                routes.ScreenRoutes.PalettesScreen,
                PalettesScreen(status: PaletteStatus.Pending),
              );
            },
          ),
          globalWidgets.getListItem(
            'Approved',
            '',
            false,
            () {
              navigation.push(
                context,
                const Offset(1, 0),
                routes.ScreenRoutes.PalettesScreen,
                PalettesScreen(status: PaletteStatus.Approved),
              );
            },
          ),
          globalWidgets.getListItem(
            'Rejected',
            '',
            false,
            () {
              navigation.push(
                context,
                const Offset(1, 0),
                routes.ScreenRoutes.PalettesScreen,
                PalettesScreen(status: PaletteStatus.Rejected),
              );
            },
          ),
          globalWidgets.getListItem(
            'Deleted',
            '',
            true,
            () {
              navigation.push(
                context,
                const Offset(1, 0),
                routes.ScreenRoutes.PalettesScreen,
                PalettesScreen(status: PaletteStatus.Deleted),
              );
            },
          ),
        ],
      ),
    );
  }
}
