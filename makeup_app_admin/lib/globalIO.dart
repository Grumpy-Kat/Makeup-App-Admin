import 'package:path_provider/path_provider.dart';
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:string_validator/string_validator.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'Widgets/Swatch.dart';
import 'ColorMath/ColorObjects.dart';
import 'ColorMath/ColorSorting.dart';
import 'localizationIO.dart';

Map<String, String> _finishes = { '0': 'finish_matte', '1': 'finish_satin', '2': 'finish_shimmer', '3': 'finish_metallic', '4': 'finish_glitter' };

Future<String> getLocalPath() async {
  final Directory directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

String compress(String string) {
  if(string == '') {
    return '';
  }
  try {
    List<int> bytes = utf8.encode(string);
    String compressed = base64.encode(ZLibCodec().encode(bytes));
    compressed = base64.normalize(compressed);
    assert(isBase64(compressed));
    return compressed;
  } catch(e) {
    print('globalIO compress $e');
    print('globalIO compress $string');
    return string;
  }
}

String decompress(String compressed) {
  if(compressed == '') {
    return '';
  }
  //try {
    List<int> bytes = base64.decode(compressed);
    String string  = utf8.decode(ZLibDecoder().decodeBytes(bytes));
    return string;
  /*} catch(e) {
    print('globalIO decompress $e');
    print('globalIO decompress $compressed');
    return compressed;
  }*/
}

Future<String> saveSwatch(Swatch swatch) async {
  //color
  List<double> colorValues = swatch.color.getValues();
  String color = colorValues[0].toString() + ',' + colorValues[1].toString() + ',' + colorValues[2].toString();
  //finish
  String finish = _finishes.keys.firstWhere((key) => _finishes[key] == swatch.finish, orElse: () => '0');
  //brand
  String brand = removeAllChars(swatch.brand, [r';', r'\\']);
  //palette
  String palette = removeAllChars(swatch.palette, [r';', r'\\']);
  //shade
  String shade = removeAllChars(swatch.shade, [r';', r'\\']);
  //weight
  String weight = swatch.weight.toStringAsFixed(4);
  //price
  String price = swatch.price.toStringAsFixed(2);
  //color name
  String colorName = removeAllChars(swatch.colorName.trim(), [r';', r'\\']);
  if(colorName != '' && !colorName.contains('color_')) {
    //translate color name
    List<String> possibleColorNames = createColorNames().keys.toList();
    for(int i = 0; i < possibleColorNames.length; i++) {
      if(getString(possibleColorNames[i]).toLowerCase() == colorName.toLowerCase()) {
        colorName = possibleColorNames[i];
        break;
      }
    }
  }
  //combined
  return '$color;$finish;$brand;$palette;$shade;$weight;$price;$colorName\n';
}

String removeAllChars(String orgString, List<String> patterns) {
  String newString = orgString;
  for(int i = 0; i < patterns.length; i++) {
    newString = newString.replaceAll(RegExp(patterns[i]), '');
  }
  return newString;
}

Future<Swatch?> loadSwatch(String paletteId, int id, String line) async {
  if(line == '') {
    return null;
  }
  List<String> lineSplit = line.split(';');
  //color
  List<String> colorValues = lineSplit[0].split(',');
  RGBColor color = RGBColor(double.parse(colorValues[0]), double.parse(colorValues[1]), double.parse(colorValues[2]));
  //finish
  String finish = _finishes[lineSplit[1]]!;
  //brand
  String brand = lineSplit[2];
  //palette
  String palette = lineSplit[3];
  //shade
  String shade = lineSplit[4];
  //weight
  double weight = double.parse(lineSplit[5]);
  //price
  double price = double.parse(lineSplit[6]);
  //if exists, color name
  String colorName = lineSplit[7];
  //combined
  return Swatch(paletteId: paletteId, id: id, color: color, finish: finish, brand: brand, palette: palette, shade: shade, weight: weight, price: price, colorName: colorName);
}