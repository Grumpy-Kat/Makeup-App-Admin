import 'package:flutter/material.dart' hide HSVColor;
import 'package:flutter/services.dart';
import '../Widgets/Swatch.dart';
import '../Widgets/ColorPicker.dart';
import '../ColorMath/ColorProcessing.dart';
import '../ColorMath/ColorObjects.dart';
import '../ColorMath/ColorConversions.dart';
import '../globalWidgets.dart' as globalWidgets;
import '../navigation.dart' as navigation;
import '../theme.dart' as theme;
import '../presetPalettesIO.dart' as IO;
import '../types.dart';
import '../localizationIO.dart';
import 'Screen.dart';
import 'PaletteScreen.dart';

class SwatchScreen extends StatefulWidget {
  final String? paletteId;
  final int? swatchId;

  SwatchScreen({ this.paletteId, this.swatchId });

  @override
  SwatchScreenState createState() => SwatchScreenState();
}

class SwatchScreenState extends State<SwatchScreen> with ScreenState {
  static late Swatch _swatch;

  bool _isEditing = false;
  bool _hasChanged = false;
  bool _hasSaved = false;
  bool _hasDeleted = false;

  @override
  void initState() {
    super.initState();
    //get swatch from id
    _swatch = IO.getSwatch(widget.paletteId!, widget.swatchId!)!;
  }

  @override
  Widget build(BuildContext context) {
    //divider to mark new section
    Widget divider = Divider(
      color: theme.primaryColorDark,
      height: 17,
      thickness: 1,
      indent: 37,
      endIndent: 37,
    );
    //all swatch data
    SwatchIcon swatchIcon = SwatchIcon.swatch(_swatch, showInfoBox: false);
    RGBColor color = _swatch.color;
    String colorName = _swatch.colorName.trim();
    String finish = _swatch.finish;
    String brand = globalWidgets.toTitleCase(_swatch.brand).trimRight();
    String palette = globalWidgets.toTitleCase(_swatch.palette).trimRight();
    String shade = globalWidgets.toTitleCase(_swatch.shade).trimRight();
    double weight = _swatch.weight;
    double price = _swatch.price;
    //various options
    List<String> finishes = ['finish_matte', 'finish_satin', 'finish_shimmer', 'finish_metallic', 'finish_glitter'];
    return buildComplete(
      context,
      getString('screen_swatch'),
      4,
      //back button
      leftBar: globalWidgets.getBackButton (() => exit()),
      //edit button
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
                if(!_isEditing) {
                  IO.editSwatch(_swatch.paletteId, _swatch);
                }
              }
            );
          },
        ),
      ],
      body: Column(
        children: <Widget>[
          //swatch preview
          Container(
            height: 150,
            margin: const EdgeInsets.only(top: 20, bottom: 50),
            child: swatchIcon,
          ),
          //all fields
          Expanded(
            child: ListView(
              children: <Widget>[
                //color
                getColorField('${getString('swatch_color')}', color, colorName, (RGBColor value) { _swatch.color = value; onChange(true); }, (String value) { _swatch.colorName = value.trim(); onChange(true); }),
                //finish
                getDropdownField('${getString('swatch_finish')}', finishes, finish, (String value) { _swatch.finish = value; onChange(true); }),
                //brand name
                getTextField('${getString('swatch_brand')}', brand, (String value) { _swatch.brand = value; onChange(false); }),
                //palette name
                getTextField('${getString('swatch_palette')}', palette, (String value) { _swatch.palette = value; onChange(false); }),
                //shade name
                getTextField('${getString('swatch_shade')}', shade, (String value) { _swatch.shade = value; onChange(false); }),
                //weight
                getNumField('${getString('swatch_weight')}', weight, (double value) { _swatch.weight = value; onChange(false); }),
                //price
                getNumField('${getString('swatch_price')}', price, (double value) { _swatch.price = value; onChange(false); }),
                divider,
                //delete button
                Container(
                  height: 70,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  child: globalWidgets.getOutlineButton(
                    bgColor: theme.bgColor,
                    outlineColor: theme.primaryColorDark,
                    onPressed: () async {
                      await globalWidgets.openTwoButtonDialog(
                        context,
                        getString('swatch_deleteWarning'),
                        () async {
                          await IO.removeSwatch(_swatch.paletteId, _swatch.id);
                          PaletteScreen.hasDeletedSwatch = true;
                          _hasSaved = true;
                          _hasChanged = true;
                          _hasDeleted = true;
                          exit();
                        },
                        () { },
                      );
                    },
                    child: Text(
                      '${getString('swatch_delete')}',
                      style: theme.errorText,
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

  //generic field with just a label and input on opposite horizontal sides
  //utilized by other varieties of fields
  //everything displays as plain text when not editing, but is more unique during editing
  Widget getField(double height, String label, Widget child) {
    return Container(
      height: height,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 30, right: 30, bottom: 10),
      child: Row(
        children: <Widget>[
          Text(
            '$label: ',
            style: theme.primaryTextPrimary,
            textAlign: TextAlign.left,
          ),
          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }

  //text field, ex for brand or palette name
  Widget getTextField(String label, String value, OnStringAction onChange) {
    return getField(
      55,
      label,
      TextField(
        scrollPadding: EdgeInsets.zero,
        style: theme.primaryTextPrimary,
        controller: TextEditingController()..text = value,
        textAlign: TextAlign.left,
        onChanged: onChange,
        enabled: _isEditing,
        decoration: InputDecoration(
          fillColor: _isEditing ? theme.primaryColorLight : theme.bgColor,
          filled: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(3.0),
            borderSide: BorderSide(
              color: theme.bgColor,
              width: 1.0,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(3.0),
            borderSide: BorderSide(
              color: theme.primaryColorDark,
              width: 1.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(3.0),
            borderSide: BorderSide(
              color: theme.accentColor,
              width: 2.5,
            ),
          ),
        ),
      ),
    );
  }

  //double field, ex for weight or price numbers
  Widget getNumField(String label, double value, OnDoubleAction onChange) {
    return getField(
      55,
      label,
      TextField(
        scrollPadding: EdgeInsets.zero,
        style: theme.primaryTextPrimary,
        controller: TextEditingController()..text = value.toString(),
        textAlign: TextAlign.left,
        onChanged: (String val) { onChange(double.parse(val)); },
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textInputAction: TextInputAction.done,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
        ],
        enabled: _isEditing,
        decoration: InputDecoration(
          fillColor: _isEditing ? theme.primaryColorLight : theme.bgColor,
          filled: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(3.0),
            borderSide: BorderSide(
              color: theme.bgColor,
              width: 1.0,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(3.0),
            borderSide: BorderSide(
              color: theme.primaryColorDark,
              width: 1.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(3.0),
            borderSide: BorderSide(
              color: theme.accentColor,
              width: 2.5,
            ),
          ),
        ),
      ),
    );
  }

  //color field that displays color name and opens popup to color picker
  Widget getColorField(String label, RGBColor color, String colorNameOrg, OnRGBColorAction onChange, OnStringAction onNameChange) {
    String localizedColorName = (colorNameOrg.contains('color_') ? getString(colorNameOrg) : globalWidgets.toTitleCase(colorNameOrg));
    String colorName = colorNameOrg == '' ? getString(getColorName(_swatch.color)) : localizedColorName;
    Widget child = Row(
      children: <Widget>[
        Text(
          colorName,
          style: theme.primaryTextPrimary,
          textAlign: TextAlign.left,
        ),
        if(_isEditing) IconButton(
          padding: const EdgeInsets.only(left: 12, bottom: 70),
          constraints: BoxConstraints.tight(const Size.fromWidth(theme.primaryIconSize + 15)),
          alignment: Alignment.topLeft,
          icon: Icon(
            Icons.colorize,
            size: theme.secondaryIconSize,
          ),
          onPressed: () {
            globalWidgets.openDialog(
              context,
              (BuildContext context) {
                return Padding(
                  padding: EdgeInsets.only(bottom: (MediaQuery.of(context).size.height * 0.4) - 15),
                  //need custom dialog due to size constraints to work with positioning of color picker cursor
                  child: Dialog(
                    insetPadding: const EdgeInsets.symmetric(horizontal: 0),
                    shape: const RoundedRectangleBorder(
                      borderRadius: const BorderRadius.all(const Radius.circular(10.0)),
                    ),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: (MediaQuery.of(context).size.height * 0.4) + 30,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget> [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.only(bottom: 30),
                              alignment: Alignment.topLeft,
                              child: ColorPicker(
                                btnText: '${getString('save')}',
                                initialColor: RGBtoHSV(_swatch.color),
                                onEnter: (double hue, double saturation, double value) {
                                  onChange(HSVtoRGB(HSVColor(hue, saturation, value)));
                                  //doesn't use navigation because is popping an Dialog
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
        if(_isEditing) IconButton(
          padding: const EdgeInsets.only(bottom: 70),
          constraints: BoxConstraints.tight(const Size.fromWidth(theme.primaryIconSize + 15)),
          alignment: Alignment.topLeft,
          icon: Icon(
            Icons.mode_edit,
            size: theme.secondaryIconSize,
          ),
          onPressed: () {
            globalWidgets.openTextDialog(
              context,
              getString('swatch_color_popupInstructions'),
              '',
              getString('save'),
              (String value) {
                onNameChange(value);
              },
              orgValue: localizedColorName,
              required: false,
            );
          },
        ),
      ],
    );
    return getField(
      55,
      label,
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: _isEditing ? theme.primaryColorLight : theme.bgColor,
          borderRadius: BorderRadius.circular(3.0),
          border: Border.fromBorderSide(
            BorderSide(
              color: _isEditing ? theme.primaryColorDark : theme.bgColor,
              width: 1.0,
            ),
          ),
        ),
        child: child,
      ),
    );
  }

  //dropdown field, ex for finish
  Widget getDropdownField(String label, List<String> options, String value, OnStringAction onChange) {
    String valueText = value;
    if(valueText.contains('_')) {
      valueText = getString(valueText);
    }
    return getField(
      55,
      label,
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: _isEditing ? theme.primaryColorLight : theme.bgColor,
          borderRadius: BorderRadius.circular(3.0),
          border: Border.fromBorderSide(
            BorderSide(
              color: _isEditing ? theme.primaryColorDark : theme.bgColor,
              width: 1.0,
            ),
          ),
        ),
        child: DropdownButton<String>(
          disabledHint: Text('$valueText', style: theme.primaryTextPrimary),
          isDense: true,
          isExpanded: true,
          style: theme.primaryTextPrimary,
          value: value,
          onChanged: !_isEditing ? null : (String? value) {
            if(_isEditing) {
              onChange(value ?? '');
            }
          },
          icon: null,
          iconSize: 0,
          underline: Container(),
          items: options.map(
            (String val) {
              String text = val;
              if(text.contains('_')) {
                text = getString(text);
              }
              return DropdownMenuItem(
                value: val,
                child: Text('$text', style: theme.primaryTextPrimary),
              );
            }
          ).toList(),
        ),
      ),
    );
  }

  void onChange(bool shouldSetState) {
    _hasSaved = false;
    _hasChanged = true;
    //update screen and swatch icon if needed, such as with finish or color changes
    //only needed if swatch icon requires visual changes, so is false for something like brand or rating
    if(shouldSetState) {
      setState(() {});
    }
  }

  void exit() async {
    //save data
    await onExit();
    //actually return to previous screen and reload if any changes were made
    navigation.pop(context, true);
  }

  @override
  Future<void> onExit() async {
    super.onExit();
    //save changes to swatch
    if(_hasChanged && !_hasSaved) {
      await IO.editSwatch(_swatch.paletteId, _swatch);
      if(!_hasDeleted) {
        await IO.loadAllFormatted();
      }
    }
  }
}
