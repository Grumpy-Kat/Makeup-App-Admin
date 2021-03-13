import 'package:flutter/material.dart' hide HSVColor;
import '../Widgets/Palette.dart';
import '../globalWidgets.dart' as globalWidgets;
import '../theme.dart' as theme;
import '../navigation.dart' as navigation;
import '../routes.dart' as routes;
import '../presetPalettesIO.dart' as IO;
import 'Screen.dart';
import 'PaletteScreen.dart';
import 'ComparePalettesScreen.dart';

class PalettesScreen extends StatefulWidget {
  static PaletteStatus status;

  PalettesScreen({ PaletteStatus status }) {
    if(status != null) {
      //sets screen info
      PalettesScreen.status = status;
    }
    //otherwise, most likely returning from screen, such as ComparePalettesScreen or PaletteScreen
  }

  @override
  PalettesScreenState createState() => PalettesScreenState();
}

class PalettesScreenState extends State<PalettesScreen> with ScreenState {
  List<Palette> _palettes;

  bool _isComparing = false;
  List<String> _idsSelected = [];

  @override
  void initState() {
    super.initState();
  }

  Future<List<Palette>> _addPalettes() async {
    Map<String, Palette> map = (await IO.loadStatusFormatted(PalettesScreen.status));
    _palettes = map.values.toList() ?? [];
    return _palettes;
  }

  @override
  Widget build(BuildContext context) {
    return buildComplete(
      context,
      '${PalettesScreen.status.toString().split('.')[1]} Palettes',
      1,
      leftBar: globalWidgets.getBackButton(() => navigation.pop(context, false)),
      rightBar: [
        IconButton(
          constraints: BoxConstraints.tight(Size.fromWidth(26)),
          icon: Icon(
            Icons.compare,
            size: 19,
            color: theme.iconTextColor,
          ),
          onPressed: () {
            setState(() {
              _isComparing = !_isComparing;
            });
          },
        ),
      ],
      body: FutureBuilder(
        future: _addPalettes(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          List<Widget> children = [];
          if(snapshot.connectionState == ConnectionState.done) {
            _palettes = _palettes ?? [];
            for(int i = 0; i < _palettes.length; i++) {
              children.add(
                globalWidgets.getListItem(
                  '${_palettes[i].brand}',
                  '${_palettes[i].name}',
                  i == _palettes.length - 1,
                  () {
                    if(_isComparing) {
                      if(_idsSelected.contains(_palettes[i].id)) {
                        setState(() {
                          _idsSelected.remove(_palettes[i].id);
                        });
                      } else if(_idsSelected.length < 3) {
                        //can compare up to 3
                        setState(() {
                          _idsSelected.add(_palettes[i].id);
                        });
                      }
                    } else {
                      navigation.push(
                        context,
                        Offset(1, 0),
                        routes.ScreenRoutes.PaletteScreen,
                        PaletteScreen(paletteId: _palettes[i].id, brand: _palettes[i].brand, name: _palettes[i].name),
                      );
                    }
                  },
                  hasCheckBox: _isComparing,
                  isCheckBoxChecked: _idsSelected.contains(_palettes[i].id),
                ),
              );
            }
          }
          return ListView(
            children: children,
          );
        },
      ),
      //check button to compare
      floatingActionButton: !_isComparing ? null : Container(
        margin: EdgeInsets.only(right: 15, bottom: (MediaQuery.of(context).size.height * 0.1) + 15),
        width: 65,
        height: 65,
        child: FloatingActionButton(
          heroTag: 'AddPaletteScreen Check',
          backgroundColor: theme.checkTextColor,
          child: Icon(
            Icons.check,
            size: 40,
            color: theme.accentTextColor,
          ),
          onPressed: () {
            if(_idsSelected.length > 1) {
              navigation.push(
                context,
                Offset(1, 0),
                routes.ScreenRoutes.ComparePalettesScreen,
                ComparePalettesScreen(paletteIds: _idsSelected),
              );
            }
          },
        ),
      ),
    );
  }
}
