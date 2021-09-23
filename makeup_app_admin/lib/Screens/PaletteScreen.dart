import 'package:flutter/material.dart' hide HSVColor;
import '../ColorMath/ColorObjects.dart';
import '../Widgets/Palette.dart';
import '../Widgets/Swatch.dart';
import '../Widgets/SwatchList.dart';
import '../Widgets/ReorderableSwatchList.dart';
import '../globalWidgets.dart' as globalWidgets;
import '../navigation.dart' as navigation;
import '../presetPalettesIO.dart' as IO;
import '../theme.dart' as theme;
import '../localizationIO.dart';
import 'Screen.dart';

class PaletteScreen extends StatefulWidget {
  static String? paletteId;
  static String? brand;
  static String? name;
  static bool isReloading = true;
  static bool hasDeletedSwatch = false;

  PaletteScreen({ String? paletteId, String brand = '', String name = '' }) {
    isReloading = true;
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

class PaletteScreenState extends State<PaletteScreen> with ScreenState, SwatchListState, ReorderableSwatchListState {
  Palette? _palette;

  List<Swatch> _swatches = [];
  List<SwatchIcon> _swatchIcons = [];
  Future<List<Swatch>>? _swatchesFuture;

  late SwatchList _swatchList;

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _swatchesFuture = _addSwatches();
    createSwatchList();
    PaletteScreen.isReloading = false;
  }

  Future<List<Swatch>> _addSwatches() async {
    if(PaletteScreen.hasDeletedSwatch) {
      await IO.loadAllFormatted();
      PaletteScreen.hasDeletedSwatch = false;
      setState(() {});
    }
    _palette = IO.getPalette(PaletteScreen.paletteId!);
    _swatches = _palette!.swatches;
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
    initReorderable(
      _swatchList,
      (String paletteId, List<Swatch> swatches) {
        _swatches = swatches;
      }
    );
    _addSwatchIcons();
    List<Widget> statusBtns = getStatusBtns();
    return buildComplete(
      context,
      (_palette == null) ? '${PaletteScreen.brand} ${PaletteScreen.name}' : '${_palette!.brand} ${_palette!.name}',
      3,
      leftBar: globalWidgets.getBackButton(() => navigation.pop(context, true)),
      rightBar: [
        IconButton(
          constraints: BoxConstraints.tight(const Size.fromWidth(theme.primaryIconSize + 15)),
          icon: Icon(
            (_isEditing ? Icons.done : Icons.mode_edit),
            size: theme.primaryIconSize,
            color: theme.iconTextColor,
          ),
          onPressed: () {
            setState(
              () {
                _isEditing = !_isEditing;
              }
            );
          },
        ),
      ],
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 7,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: <Widget>[
                globalWidgets.getTextField(
                  context,
                  getString('addPalette_brand'),
                  (_palette == null) ? '' : _palette!.brand,
                  getString('addPalette_brandError'),
                  false,
                  (String val) {
                    _palette!.brand = val;
                  },
                  (String val) {
                    _palette!.brand = val;
                  },
                  key: Key((_palette == null) ? '' : _palette!.brand),
                ),
                const SizedBox(
                  height: 20,
                ),
                globalWidgets.getTextField(
                  context,
                  getString('addPalette_palette'),
                  (_palette == null) ? '' : _palette!.name,
                  getString('addPalette_paletteError'),
                  false,
                  (String val) {
                    _palette!.name = val;
                  },
                  (String val) {
                    _palette!.name = val;
                  },
                  key: Key((_palette == null) ? '' : _palette!.name),
                ),
                const SizedBox(
                  height: 20,
                ),
                globalWidgets.getNumField(
                  context,
                  getString('addPalette_weight'),
                  (_palette == null) ? 0.0 : _palette!.weight,
                  '',
                  false,
                  (double val) {
                    _palette!.weight = double.parse(val.toStringAsFixed(4));
                  },
                  (double val) {
                    setState(() {
                      _palette!.weight = double.parse(val.toStringAsFixed(4));
                    });
                  },
                  key: Key((_palette == null) ? '' : _palette!.weight.toString()),
                ),
                const SizedBox(
                  height: 20,
                ),
                globalWidgets.getNumField(
                  context,
                  getString('addPalette_price'),
                  (_palette == null) ? 0.0 : _palette!.price,
                  '',
                  false,
                  (double val) {
                    _palette!.price = double.parse(val.toStringAsFixed(2));
                  },
                  (double val) {
                    setState(() {
                      _palette!.price = double.parse(val.toStringAsFixed(2));
                    });
                  },
                  key: Key((_palette == null) ? '' : _palette!.price.toString()),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  height: 40,
                  child: globalWidgets.getFlatButton(
                    bgColor: theme.accentColor,
                    onPressed: () async {
                      _palette!.swatches = _swatches;
                      await IO.save(_palette!);
                      await IO.loadAllFormatted();
                      await _addSwatches();
                      setState(() { });
                    },
                    child: Text(
                      getString('save'),
                      style: theme.accentTextBold,
                    ),
                  ),
                ),
                if(statusBtns.length >= 1) const SizedBox(
                  height: 7,
                ),
                if(statusBtns.length >= 1) statusBtns[0],
                if(statusBtns.length >= 2) const SizedBox(
                  height: 7,
                ),
                if(statusBtns.length >= 2) statusBtns[1],
              ],
            ),
          ),
          Expanded(
            flex: 6,
            child: FutureBuilder(
              future: _swatchList.addSwatches,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if(!_isEditing) {
                  return buildSwatchList(
                    context,
                    snapshot,
                    _swatchIcons,
                    axis: Axis.vertical,
                    crossAxisCount: 4,
                    padding: 20,
                    spacing: 30,
                  );
                } else {
                  return buildReorderableSwatchList(
                    context,
                    snapshot,
                    _swatchIcons,
                    crossAxisCount: 4,
                    padding: 20,
                    spacing: 30,
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: !_isEditing ? null : Container(
        margin: EdgeInsets.only(right: 15, bottom: 15),
        width: 65,
        height: 65,
        child: FloatingActionButton(
          heroTag: 'AddPaletteScreen Plus',
          child: Icon(
            Icons.add,
            color: theme.accentTextColor,
            size: 40.0,
          ),
          onPressed: () {
            globalWidgets.openLoadingDialog(context);
            _swatches.add(
              Swatch(
                id: _swatches.length,
                paletteId: _palette!.id,
                color: RGBColor(0.5, 0.5, 0.5),
                finish: 'finish_matte',
                brand: _palette!.brand,
                palette: _palette!.name,
                weight: 0,
                price: 0,
                shade: '',
              ),
            );
            _palette!.swatches = _swatches;
            IO.save(_palette!).then(
              (value) {
                IO.loadAllFormatted().then(
                  (value) {
                    setState(() {
                      _addSwatchIcons();
                      Navigator.pop(context);
                    });
                  }
                );
              }
            );
          },
        ),
      ),
    );
  }

  List<Widget> getStatusBtns() {
    Widget? btn1;
    Widget? btn2;

    if(_palette != null) {
      switch(_palette!.status) {
        case PaletteStatus.Approved: {
          //if approved, pend or delete
          btn1 = Container(
            height: 40,
            child: globalWidgets.getFlatButton(
              bgColor: theme.accentColor,
              onPressed: () async {
                globalWidgets.openTwoButtonDialog(
                  context,
                  'Are you sure you want to make this palette pending?',
                      () async {
                    await IO.changeStatus(_palette!, PaletteStatus.Pending);
                    navigation.pop(context, true);
                  },
                      () { },
                );
              },
              child: Text(
                'Pend',
                style: theme.accentTextBold,
              ),
            ),
          );
          btn2 = Container(
            height: 40,
            child: globalWidgets.getFlatButton(
              bgColor: theme.accentColor,
              onPressed: () async {
                globalWidgets.openTwoButtonDialog(
                  context,
                  'Are you sure you want to delete this palette?',
                      () async {
                    await IO.changeStatus(_palette!, PaletteStatus.Deleted);
                    navigation.pop(context, true);
                  },
                      () { },
                );
              },
              child: Text(
                'Delete',
                style: theme.accentTextBold,
              ),
            ),
          );
          break;
        }
        case PaletteStatus.Pending: {
          //if pending, approve or reject
          btn1 = Container(
            height: 40,
            child: globalWidgets.getFlatButton(
              bgColor: theme.accentColor,
              onPressed: () async {
                globalWidgets.openTwoButtonDialog(
                  context,
                  'Are you sure you want to approve this palette?',
                      () async {
                    await IO.changeStatus(_palette!, PaletteStatus.Approved);
                    navigation.pop(context, true);
                  },
                      () { },
                );
              },
              child: Text(
                'Approve',
                style: theme.accentTextBold,
              ),
            ),
          );
          btn2 = Container(
            height: 40,
            child: globalWidgets.getFlatButton(
              bgColor: theme.accentColor,
              onPressed: () async {
                globalWidgets.openTwoButtonDialog(
                  context,
                  'Are you sure you want to reject this palette?',
                      () async {
                    await IO.changeStatus(_palette!, PaletteStatus.Rejected);
                    navigation.pop(context, true);
                  },
                      () { },
                );
              },
              child: Text(
                'Reject',
                style: theme.accentTextBold,
              ),
            ),
          );
          break;
        }
        case PaletteStatus.Rejected: {
          //if rejected, approve or pend
          btn1 = Container(
            height: 40,
            child: globalWidgets.getFlatButton(
              bgColor: theme.accentColor,
              onPressed: () async {
                globalWidgets.openTwoButtonDialog(
                  context,
                  'Are you sure you want to approve this palette?',
                      () async {
                    await IO.changeStatus(_palette!, PaletteStatus.Approved);
                    navigation.pop(context, true);
                  },
                      () { },
                );
              },
              child: Text(
                'Approve',
                style: theme.accentTextBold,
              ),
            ),
          );
          btn2 = Container(
            height: 40,
            child: globalWidgets.getFlatButton(
              bgColor: theme.accentColor,
              onPressed: () async {
                globalWidgets.openTwoButtonDialog(
                  context,
                  'Are you sure you want to make this palette pending?',
                      () async {
                    await IO.changeStatus(_palette!, PaletteStatus.Pending);
                    navigation.pop(context, true);
                  },
                      () { },
                );
              },
              child: Text(
                'Pend',
                style: theme.accentTextBold,
              ),
            ),
          );
          break;
        }
        case PaletteStatus.Deleted: {
          //if deleted, approve or pend
          btn1 = Container(
            height: 40,
            child: globalWidgets.getFlatButton(
              bgColor: theme.accentColor,
              onPressed: () async {
                globalWidgets.openTwoButtonDialog(
                  context,
                  'Are you sure you want to approve this palette?',
                      () async {
                    await IO.changeStatus(_palette!, PaletteStatus.Approved);
                    navigation.pop(context, true);
                  },
                      () { },
                );
              },
              child: Text(
                'Approve',
                style: theme.accentTextBold,
              ),
            ),
          );
          btn2 = Container(
            height: 40,
            child: globalWidgets.getFlatButton(
              bgColor: theme.accentColor,
              onPressed: () async {
                globalWidgets.openTwoButtonDialog(
                  context,
                  'Are you sure you want to make this palette pending?',
                      () async {
                    await IO.changeStatus(_palette!, PaletteStatus.Pending);
                    navigation.pop(context, true);
                  },
                      () { },
                );
              },
              child: Text(
                'Pend',
                style: theme.accentTextBold,
              ),
            ),
          );
          break;
        }
      }
    }

    List<Widget> ret = [];
    if(btn1 != null) {
      ret.add(btn1);
    }
    if(btn2 != null) {
      ret.add(btn2);
    }

    return ret;
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
