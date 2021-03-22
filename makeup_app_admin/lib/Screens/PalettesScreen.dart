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
  Future _addPalettesFuture;
  static List<Palette> _allPalettes = [];
  static List<Palette> _palettes = [];

  bool _isSearching = false;
  String _search = '';

  bool _isComparing = false;
  List<String> _idsSelected = [];

  @override
  void initState() {
    super.initState();
    _addPalettesFuture = _addPalettes();
  }

  Future<List<Palette>> _addPalettes() async {
    if(_allPalettes == null || _allPalettes.length == 0 || _allPalettes[0].status != PalettesScreen.status) {
      Map<String, Palette> map = (await IO.loadStatusFormatted(PalettesScreen.status));
      _allPalettes = map.values.toList() ?? [];
      _palettes = _allPalettes;
    }
    if(_search != '') {
      _palettes = await IO.search(_allPalettes, _search);
    } else {
      _palettes = _allPalettes;
    }
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
          constraints: BoxConstraints.tight(const Size.fromWidth(26)),
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
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
            currentFocus.focusedChild.unfocus();
          }
          setState(() {
            _isSearching = false;
          });
        },
        child: Column(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              alignment: const Alignment(-1.0, 0.0),
              child: Stack(
                overflow: Overflow.visible,
                children: [
                  AnimatedContainer(
                    margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    duration: const Duration(milliseconds: 375),
                    width: _isSearching ? MediaQuery.of(context).size.width - 103 : MediaQuery.of(context).size.width - 30,
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
                    curve: Curves.easeOut,
                    alignment: const Alignment(-1.0, 0.0),
                    child: TextFormField(
                      initialValue: _search,
                      textInputAction: TextInputAction.search,
                      onTap: () {
                        setState(() {
                          _isSearching = true;
                        });
                      },
                      onChanged: (value) {
                        setState(() {
                          _search = value;
                          _addPalettesFuture = _addPalettes();
                        });
                      },
                      style: theme.primaryTextPrimary,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        isCollapsed: true,
                        icon: Icon(
                          Icons.search,
                          color: theme.tertiaryTextColor,
                          size: theme.secondaryIconSize,
                        ),
                        hintText: 'Search...',
                        hintStyle: TextStyle(color: theme.tertiaryTextColor, fontSize: theme.primaryTextSize, fontFamily: theme.fontFamily),
                      ),
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: theme.primaryColorDark,
                    ),
                  ),
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 375),
                    top: 0,
                    left: _isSearching ? MediaQuery.of(context).size.width - 110 : MediaQuery.of(context).size.width - 30,
                    curve: Curves.easeOut,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6.5),
                      width: 100,
                      alignment: const Alignment(1.0, 0.0),
                      child: AnimatedOpacity(
                        opacity: _isSearching ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: TextButton(
                          child: Text(
                            'Cancel',
                            style: TextStyle(color: theme.secondaryTextColor, fontSize: theme.primaryTextSize, fontFamily: theme.fontFamily),
                          ),
                          onPressed: () {
                            FocusScopeNode currentFocus = FocusScope.of(context);
                            if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
                              currentFocus.focusedChild.unfocus();
                            }
                            setState(() {
                              _isSearching = false;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder(
                future: _addPalettesFuture,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  List<Widget> children = [];
                  if(snapshot.connectionState != ConnectionState.active && snapshot.connectionState != ConnectionState.waiting) {
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
                                const Offset(1, 0),
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
                  } else {
                    children.add(
                      Center(
                        child: Container(
                          width: 70,
                          height: 70,
                          margin: const EdgeInsets.all(10),
                          child: const CircularProgressIndicator(),
                        ),
                      ),
                    );
                  }
                  return ListView(
                    children: children,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      //check button to compare
      floatingActionButton: !_isComparing ? null : Container(
        margin: const EdgeInsets.only(right: 15, bottom: 15),
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
                const Offset(1, 0),
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
