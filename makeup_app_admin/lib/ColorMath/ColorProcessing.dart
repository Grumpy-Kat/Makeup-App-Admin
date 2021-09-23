import 'ColorObjects.dart';
import 'ColorDifferences.dart';
import 'ColorConversions.dart';
import 'ColorSorting.dart';

String getColorName(RGBColor rgb) {
  Map<String, RGBColor> colorWheel = createColorNames();
  double minDist = 1000;
  String minColor = 'unknown';
  LabColor color0 = RGBtoLab(rgb);
  List<String> keys = colorWheel.keys.toList();
  for(int i = 0; i < keys.length; i++) {
    String color = keys[i];
    LabColor color1 = RGBtoLab(colorWheel[color]!);
    double dist = deltaECie2000(color0, color1);
    if(dist < minDist) {
      minDist = dist;
      minColor = color;
    }
  }
  return minColor;
}
