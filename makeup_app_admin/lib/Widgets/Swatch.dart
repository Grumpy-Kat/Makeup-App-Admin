import 'package:flutter/material.dart';
import '../ColorMath/ColorObjects.dart';
import '../theme.dart' as theme;
import '../presetPalettesIO.dart' as IO;
import '../types.dart';
import 'InfoBox.dart';

class Swatch {
  String paletteId;
  int id;
  RGBColor color;
  String colorName;
  String finish;
  String brand;
  String palette;
  String shade = '';
  double weight = 0.0;
  double price = 0.0;

  Swatch({ @required this.paletteId, @required this.id, @required this.color, @required this.finish,this.colorName = '', this.brand = '', this.palette = '', this.shade = '', this.weight = 0.0, this.price = 0.0 });

  int compareTo(Swatch other, List<double> Function(Swatch) comparator) {
    List<double> thisValues = comparator(this);
    List<double> otherValues = comparator(other);
    for(int i = 0; i < thisValues.length; i++) {
      int comp = thisValues[i].compareTo(otherValues[i]);
      if(comp != 0) {
        return comp;
      }
    }
    return 0;
  }

  bool operator ==(other) {
    if(!(other is Swatch)) {
      return false;
    }
    return this.id == other.id && this.paletteId == other.paletteId;
  }
  
  Map<String, dynamic> getMap() {
    return {
      'color': color,
      'colorName': colorName.trim(),
      'finish': finish,
      'brand': brand.trim(),
      'palette': palette.trim(),
      'shade': shade.trim(),
      'weight': weight,
      'price': price,
    };
  }

  @override
  String toString() {
    return '$color $finish $brand $palette $shade';
  }

  @override
  int get hashCode => super.hashCode;
}

class SwatchIcon extends StatelessWidget {
  final Swatch swatch;
  final String paletteId;
  final int swatchId;

  final GlobalKey infoBoxKey = GlobalKey();
  final GlobalKey childKey = GlobalKey();

  final bool showInfoBox;

  final OnSwatchAction onDelete;

  SwatchIcon.swatch(this.swatch, { this.showInfoBox = true, this.onDelete }) : this.paletteId = swatch.paletteId, this.swatchId = swatch.id;

  SwatchIcon.id(this.swatchId, this.paletteId, { this.showInfoBox = true, this.onDelete }) : this.swatch = IO.getSwatch(paletteId, swatchId), super(key: GlobalKey(debugLabel: '$paletteId.$swatchId'));

  @override
  Widget build(BuildContext context) {
    List<double> color;
    String finish;
    if(swatch == null) {
      color = [0.5, 0.5, 0.5];
      finish = 'finish_matte';
    } else {
      color =  swatch.color.getValues();
      finish = swatch.finish.toLowerCase();
    }
    final Widget swatchImg = Image(
      key: childKey,
      image: AssetImage('imgs/$finish.png'),
      colorBlendMode: BlendMode.modulate,
      color: Color.fromRGBO((color[0] * 255).round(), (color[1] * 255).round(), (color[2] * 255).round(), 1),
    );
    Widget child;
    if(onDelete != null) {
      child = Stack(
        children: <Widget>[
          swatchImg,
          Align(
            alignment: Alignment(1.15, -1.15),
            child: Container(
              width: 23,
              height: 23,
              child: FloatingActionButton(
                heroTag: 'Delete $paletteId $swatchId',
                backgroundColor: theme.errorTextColor,
                child: Icon(
                  Icons.clear,
                  size: 19,
                  color: theme.primaryColor,
                ),
                onPressed: () {
                  onDelete(paletteId, swatchId);
                },
              ),
            ),
          ),
        ],
      );
    } else {
      child = swatchImg;
    }
    if(showInfoBox) {
      return InfoBox(
        key: infoBoxKey,
        swatch: swatch,
        onTap: _onTap,
        child: child,
        childKey: childKey,
      );
    }
    return GestureDetector(
      onTap: _onTap,
      child: child,
    );
  }

  void _onTap() {
    if(showInfoBox) {
      (infoBoxKey?.currentState as InfoBoxState).open();
    }
  }
}