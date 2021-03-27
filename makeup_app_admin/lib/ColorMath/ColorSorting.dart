import 'ColorObjects.dart';

Map<String, RGBColor> colorNames;

Map<String, RGBColor> createColorNames() {
  if(colorNames == null) {
    colorNames = Map<String, RGBColor>();
    colorNames['color_pastelRed'] = RGBColor(1, 0.95, 0.95);
    colorNames['color_nude'] = RGBColor(0.920, 0.804, 0.745);
    colorNames['color_lightRed'] = RGBColor(1, 0.8, 0.8);
    colorNames['color_red'] = RGBColor(0.9, 0.3, 0.3);
    colorNames['color_darkRed'] = RGBColor(0.2, 0, 0);
    colorNames['color_burgundy'] = RGBColor(0.322, 0, 0.078);
    colorNames['color_pastelOrange'] = RGBColor(1, 0.95, 0.85);
    colorNames['color_peach'] = RGBColor(1, 0.882, 0.741);
    colorNames['color_lightOrange'] = RGBColor(1, 0.8, 0.6);
    colorNames['color_orange'] = RGBColor(1, 0.5, 0.1);
    colorNames['color_darkOrange'] = RGBColor(0.2, 0.1, 0);
    colorNames['color_lightBrown'] = RGBColor(0.851, 0.654, 0.494);
    colorNames['color_beige'] = RGBColor(0.761, 0.551, 0.471);
    colorNames['color_taupe'] = RGBColor(0.529, 0.475, 0.427);
    colorNames['color_tan'] = RGBColor(0.859, 0.600, 0.318);
    colorNames['color_brown'] = RGBColor(0.565, 0.350, 0.212);
    colorNames['color_rust'] = RGBColor(0.600, 0.220, 0.114);
    colorNames['color_darkBeige'] = RGBColor(0.388, 0.322, 0.240);
    colorNames['color_darkBrown'] = RGBColor(0.169, 0.114, 0.063);
    colorNames['color_chocolate'] = RGBColor(0.251, 0.102, 0.039);
    colorNames['color_pastelYellow'] = RGBColor(1, 1, 0.9);
    colorNames['color_cream'] = RGBColor(1, 0.959, 0.851);
    colorNames['color_lightYellow'] = RGBColor(1, 1, 0.6);
    colorNames['color_yellow'] = RGBColor(0.9, 0.9, 0.1);
    colorNames['color_lightChartreuse'] = RGBColor(0.9, 1, 0.8);
    colorNames['color_chartreuse'] = RGBColor(0.5, 0.9, 0.1);
    colorNames['color_darkChartreuse'] = RGBColor(0.1, 0.2, 0);
    colorNames['color_pastelGreen'] = RGBColor(0.95, 1, 0.95);
    colorNames['color_lightGreen'] = RGBColor(0.8, 1, 0.8);
    colorNames['color_green'] = RGBColor(0.1, 0.9, 0.1);
    colorNames['color_darkGreen'] = RGBColor(0, 0.2, 0);
    colorNames['color_pastelMint'] = RGBColor(0.9, 1, 0.95);
    colorNames['color_mint'] = RGBColor(0.8, 1, 0.9);
    colorNames['color_aquamarine'] = RGBColor(0.2, 0.9, 0.5);
    colorNames['color_darkAquamarine'] = RGBColor(0, 0.2, 0.1);
    colorNames['color_pastelTurquoise'] = RGBColor(0.9, 1, 1);
    colorNames['color_lightTurquoise'] = RGBColor(0.8, 1, 1);
    colorNames['color_turquoise'] = RGBColor(0.4, 0.9, 0.9);
    colorNames['color_darkTurquoise'] = RGBColor(0, 0.2, 0.2);
    colorNames['color_lightSkyBlue'] = RGBColor(0.8, 0.9, 1);
    colorNames['color_skyBlue'] = RGBColor(0.2, 0.5, 0.9);
    colorNames['color_darkSkyBlue'] = RGBColor(0, 0.1, 0.2);
    colorNames['color_pastelBlue'] = RGBColor(0.9, 0.95, 1);
    colorNames['color_lightBlue'] = RGBColor(0.8, 0.8, 1);
    colorNames['color_blue'] = RGBColor(0.1, 0.1, 0.9);
    colorNames['color_darkBlue'] = RGBColor(0, 0, 0.2);
    colorNames['color_pastelLavender'] = RGBColor(0.95, 0.9, 1);
    colorNames['color_lavender'] = RGBColor(0.9, 0.8, 1);
    colorNames['color_indigo'] = RGBColor(0.5, 0, 1);
    colorNames['color_darkIndigo'] = RGBColor(0.1, 0, 0.2);
    colorNames['color_lightPurple'] = RGBColor(1, 0.8, 1);
    colorNames['color_purple'] = RGBColor(0.9, 0.1, 0.9);
    colorNames['color_darkPurple'] = RGBColor(0.2, 0, 0.2);
    colorNames['color_mauve'] = RGBColor(0.8, 0.6, 0.7);
    colorNames['color_violet'] = RGBColor(0.9, 0.3, 0.9);
    colorNames['color_darkViolet'] = RGBColor(0.15, 0, 0.15);
    colorNames['color_pastelPink'] = RGBColor(1, 0.9, 0.95);
    colorNames['color_lightPink'] = RGBColor(1, 0.8, 0.9);
    colorNames['color_pink'] = RGBColor(0.9, 0.1, 0.5);
    colorNames['color_darkPink'] = RGBColor(0.2, 0, 0.1);
    colorNames['color_white'] = RGBColor(1, 1, 1);
    colorNames['color_lightGray'] = RGBColor(0.75, 0.75, 0.75);
    colorNames['color_gray'] = RGBColor(0.5, 0.5, 0.5);
    colorNames['color_darkGray'] = RGBColor(0.25, 0.25, 0.25);
    colorNames['color_darkTaupe'] = RGBColor(0.271, 0.247, 0.227);
    colorNames['color_black'] = RGBColor(0, 0, 0);
  }
  return colorNames;
}