import 'package:flutter/material.dart' hide HSVColor;
import '../Widgets/Palette.dart';
import '../Widgets/Swatch.dart';
import '../Widgets/SwatchList.dart';
import '../globalWidgets.dart' as globalWidgets;
import '../navigation.dart' as navigation;
import '../routes.dart' as routes;
import '../presetPalettesIO.dart' as IO;
import '../theme.dart' as theme;
import 'Screen.dart';
import 'PaletteScreen.dart';

class ComparePalettesScreen extends StatefulWidget {
  static List<String>? paletteIds;

  ComparePalettesScreen({ List<String>? paletteIds }) {
    if(paletteIds != null && paletteIds.length > 0) {
      //sets screen info
      ComparePalettesScreen.paletteIds = paletteIds;
    }
    //otherwise, most likely returning from screen, such as ComparePalettesScreen or PaletteScreen
  }

  @override
  ComparePalettesScreenState createState() => ComparePalettesScreenState();
}

class ComparePalettesScreenState extends State<ComparePalettesScreen> with ScreenState, SwatchListState {
  List<Palette> _palettes = [];
  List<List<Swatch>> _swatches = [];
  List<List<SwatchIcon>> _swatchIcons = [];
  Future<List<List<Swatch>>>? _swatchesFuture;

  late SwatchList _swatchList;

  @override
  void initState() {
    super.initState();
    _swatchesFuture = _addSwatches();
    createSwatchList();
  }

  Future<List<List<Swatch>>> _addSwatches() async {
    _palettes = [];
    _swatches = [];
    _swatchIcons = [];
    for(int i = 0; i < ComparePalettesScreen.paletteIds!.length; i++) {
      _swatches.add([]);
      _swatchIcons.add([]);
      Palette palette = IO.getPalette(ComparePalettesScreen.paletteIds![i])!;
      _palettes.add(palette);
      _swatches[i] = palette.swatches;
      for(int j = 0; j < _swatches[i].length; j++) {
        _swatchIcons[i].add(
          SwatchIcon.id(
            _swatches[i][j].id,
            _swatches[i][j].paletteId,
            showInfoBox: true,
          ),
        );
      }
    }
    return _swatches;
  }

  @override
  Widget build(BuildContext context) {
    init(_swatchList);
    String name = '';
    for(int i = 0; i < _palettes.length; i++) {
      name += '${_palettes[i].brand} ${_palettes[i].name}';
      if(i != _swatches.length - 1) {
        name += ' vs ';
      }
    }
    return buildComplete(
      context,
      name,
      2,
      leftBar: globalWidgets.getBackButton(() => navigation.pop(context, true)),
      body: Column(
        children: <Widget>[
          for(int i = 0; i < _swatches.length; i++) Expanded(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: FutureBuilder(
                    future: _swatchList.addSwatches,
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      return buildSwatchList(
                        context,
                        snapshot,
                        _swatchIcons[i],
                        axis: Axis.vertical,
                        crossAxisCount: 4,
                        padding: 20,
                        spacing: 30,
                      );
                    },
                  ),
                ),
                Container(
                  height: 40,
                  child: globalWidgets.getFlatButton(
                    bgColor: theme.accentColor,
                    onPressed: () async {
                      navigation.push(
                        context,
                        const Offset(1, 0),
                        routes.ScreenRoutes.PaletteScreen,
                        PaletteScreen(paletteId: _palettes[i].id, brand: _palettes[i].brand, name: _palettes[i].name),
                      );
                    },
                    child: Text(
                      'Choose',
                      style: theme.accentTextBold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void createSwatchList() {
    _swatchList = SwatchList(
      addSwatches: _swatchesFuture,
      orgAddSwatches: _swatchesFuture,
      showInfoBox: true,
      showPlus: false,
      showDelete: false,
    );
  }
}
