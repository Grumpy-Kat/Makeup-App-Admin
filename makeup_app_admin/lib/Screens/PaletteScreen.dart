import 'package:flutter/material.dart' hide HSVColor;
import '../Widgets/Palette.dart';
import '../Widgets/Swatch.dart';
import '../Widgets/SwatchList.dart';
import '../globalWidgets.dart' as globalWidgets;
import '../navigation.dart' as navigation;
import '../presetPalettesIO.dart' as IO;
import '../theme.dart' as theme;
import '../localizationIO.dart';
import 'Screen.dart';

class PaletteScreen extends StatefulWidget {
  static String paletteId;
  static String brand;
  static String name;
  static bool isReloading = true;

  PaletteScreen({ String paletteId, String brand = '', String name = '' }) {
    isReloading = true;
    print('isReloading');
    if(paletteId != null && paletteId != '') {
      //sets screen info
      PaletteScreen.paletteId = paletteId;
      PaletteScreen.brand = brand;
      PaletteScreen.name = name;
    }
    //otherwise, most likely returning from screen, such as SwatchScreen
  }

  @override
  PaletteScreenState createState() => PaletteScreenState();
}

class PaletteScreenState extends State<PaletteScreen> with ScreenState, SwatchListState {
  Palette _palette;

  List<Swatch> _swatches = [];
  List<SwatchIcon> _swatchIcons = [];
  Future<List<Swatch>> _swatchesFuture;

  SwatchList _swatchList;

  @override
  void initState() {
    super.initState();
    _swatchesFuture = _addSwatches();
    createSwatchList();
    PaletteScreen.isReloading = false;
  }

  Future<List<Swatch>> _addSwatches() async {
    _palette = IO.getPalette(PaletteScreen.paletteId);
    _swatches = _palette.swatches;
    _addSwatchIcons();
    return _swatches;
  }

  void _addSwatchIcons() {
    _swatchIcons.clear();
    for(int i = 0; i < _swatches.length; i++) {
      _swatchIcons.add(
        SwatchIcon.id(
          _swatches[i].id,
          _swatches[i].paletteId,
          showInfoBox: true,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if(PaletteScreen.isReloading) {
      _swatchesFuture = _addSwatches();
      createSwatchList();
      PaletteScreen.isReloading = false;
    }
    init(_swatchList);
    _addSwatchIcons();
    Widget btn1;
    Widget btn2;
    if(_palette != null) {
      switch(_palette.status) {
        case PaletteStatus.Approved: {
          //if approved, pend or delete
          btn1 = FlatButton(
            height: 40,
            color: theme.accentColor,
            onPressed: () async {
              globalWidgets.openTwoButtonDialog(
                context,
                'Are you sure you want to make this palette pending?',
                () async {
                  await IO.changeStatus(_palette, PaletteStatus.Pending);
                  navigation.pop(context, true);
                },
                () { },
              );
            },
            child: Text(
              'Pend',
              style: theme.accentTextBold,
            ),
          );
          btn2 = FlatButton(
            height: 40,
            color: theme.accentColor,
            onPressed: () async {
              globalWidgets.openTwoButtonDialog(
                context,
                'Are you sure you want to delete this palette?',
                () async {
                  await IO.changeStatus(_palette, PaletteStatus.Deleted);
                  navigation.pop(context, true);
                },
                () { },
              );
            },
            child: Text(
              'Delete',
              style: theme.accentTextBold,
            ),
          );
          break;
        }
        case PaletteStatus.Pending: {
          //if pending, approve or reject
          btn1 = FlatButton(
            height: 40,
            color: theme.accentColor,
            onPressed: () async {
              globalWidgets.openTwoButtonDialog(
                context,
                'Are you sure you want to approve this palette?',
                () async {
                  await IO.changeStatus(_palette, PaletteStatus.Approved);
                  navigation.pop(context, true);
                },
                () { },
              );
            },
            child: Text(
              'Approve',
              style: theme.accentTextBold,
            ),
          );
          btn2 = FlatButton(
            height: 40,
            color: theme.accentColor,
            onPressed: () async {
              globalWidgets.openTwoButtonDialog(
                context,
                'Are you sure you want to reject this palette?',
                () async {
                  await IO.changeStatus(_palette, PaletteStatus.Rejected);
                  navigation.pop(context, true);
                },
                () { },
              );
            },
            child: Text(
              'Reject',
              style: theme.accentTextBold,
            ),
          );
          break;
        }
        case PaletteStatus.Rejected: {
          //if rejected, approve or pend
          btn1 = FlatButton(
            height: 40,
            color: theme.accentColor,
            onPressed: () async {
              globalWidgets.openTwoButtonDialog(
                context,
                'Are you sure you want to approve this palette?',
                () async {
                  await IO.changeStatus(_palette, PaletteStatus.Approved);
                  navigation.pop(context, true);
                },
                () { },
              );
            },
            child: Text(
              'Approve',
              style: theme.accentTextBold,
            ),
          );
          btn2 = FlatButton(
            height: 40,
            color: theme.accentColor,
            onPressed: () async {
              globalWidgets.openTwoButtonDialog(
                context,
                'Are you sure you want to make this palette pending?',
                () async {
                  await IO.changeStatus(_palette, PaletteStatus.Pending);
                  navigation.pop(context, true);
                },
                () { },
              );
            },
            child: Text(
              'Pend',
              style: theme.accentTextBold,
            ),
          );
          break;
        }
        case PaletteStatus.Deleted: {
          //if deleted, approve or pend
          btn1 = FlatButton(
            height: 40,
            color: theme.accentColor,
            onPressed: () async {
              globalWidgets.openTwoButtonDialog(
                context,
                'Are you sure you want to approve this palette?',
                () async {
                  await IO.changeStatus(_palette, PaletteStatus.Approved);
                  navigation.pop(context, true);
                },
                () { },
              );
            },
            child: Text(
              'Approve',
              style: theme.accentTextBold,
            ),
          );
          btn2 = FlatButton(
            height: 40,
            color: theme.accentColor,
            onPressed: () async {
              globalWidgets.openTwoButtonDialog(
                context,
                'Are you sure you want to make this palette pending?',
                () async {
                  await IO.changeStatus(_palette, PaletteStatus.Pending);
                  navigation.pop(context, true);
                },
                () { },
              );
            },
            child: Text(
              'Pend',
              style: theme.accentTextBold,
            ),
          );
          break;
        }
      }
    }
    return buildComplete(
      context,
      (_palette == null) ? '${PaletteScreen.brand} ${PaletteScreen.name}' : '${_palette.brand} ${_palette.name}',
      3,
      leftBar: globalWidgets.getBackButton(() => navigation.pop(context, true)),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 7,
            child: ListView(
              padding: EdgeInsets.all(20),
              children: <Widget>[
                globalWidgets.getTextField(
                  context,
                  getString('addPalette_brand'),
                  (_palette == null) ? '' : _palette.brand,
                  getString('addPalette_brandError'),
                  false,
                  (String val) {
                    _palette.brand = val;
                  },
                  (String val) {
                    _palette.brand = val;
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                globalWidgets.getTextField(
                  context,
                  getString('addPalette_palette'),
                  (_palette == null) ? '' : _palette.name,
                  getString('addPalette_paletteError'),
                  false,
                  (String val) {
                    _palette.name = val;
                  },
                  (String val) {
                    _palette.name = val;
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                globalWidgets.getNumField(
                  context,
                  getString('addPalette_weight'),
                  (_palette == null) ? 0.0 : _palette.weight,
                  '',
                  false,
                  (double val) {
                    _palette.weight = double.parse(val.toStringAsFixed(4));
                  },
                  (double val) {
                    setState(() {
                      _palette.weight = double.parse(val.toStringAsFixed(4));
                    });
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                globalWidgets.getNumField(
                  context,
                  getString('addPalette_price'),
                  (_palette == null) ? 0.0 : _palette.price,
                  '',
                  false,
                  (double val) {
                    _palette.price = double.parse(val.toStringAsFixed(2));
                  },
                  (double val) {
                    setState(() {
                      _palette.price = double.parse(val.toStringAsFixed(2));
                    });
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                FlatButton(
                  height: 40,
                  color: theme.accentColor,
                  onPressed: () async {
                    await IO.save(_palette);
                    await IO.loadAllFormatted();
                    setState(() { });
                  },
                  child: Text(
                    getString('save'),
                    style: theme.accentTextBold,
                  ),
                ),
                if(btn1 != null) SizedBox(
                  height: 7,
                ),
                if(btn1 != null) btn1,
                if(btn1 != null && btn2 != null) SizedBox(
                  height: 7,
                ),
                if(btn2 != null) btn2,
              ],
            ),
          ),
          Expanded(
            flex: 6,
            child: FutureBuilder(
              future: _swatchList.addSwatches,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                return buildSwatchList(
                  context,
                  snapshot,
                  _swatchIcons,
                  axis: Axis.vertical,
                  crossAxisCount: 4,
                  padding: 20,
                  spacing: 30,
                );
              },
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
