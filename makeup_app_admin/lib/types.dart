import 'package:flutter/material.dart';
import 'ColorMath/ColorObjects.dart';
import 'Widgets/Swatch.dart';

typedef OnVoidAction = void Function();
typedef OnBoolAction = void Function(bool);
typedef OnStringAction = void Function(String);
typedef OnStringListAction = void Function(List<String>);
typedef OnRGBColorAction = void Function(RGBColor);
typedef OnIntAction = void Function(int);
typedef OnDoubleAction = void Function(double);
//same thing, but for clarity
typedef OnSwatchAction = void Function(String, int);
typedef OnSwatchListAction = void Function(String, List<Swatch>);
typedef OnScreenAction = StatefulWidget Function(BuildContext);