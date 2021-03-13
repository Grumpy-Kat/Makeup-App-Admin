import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'Widgets/Swatch.dart';
import 'Widgets/Palette.dart';
import 'globalIO.dart';
import 'globalWidgets.dart' as globalWidgets;
import 'types.dart';

List<DocumentSnapshot> docs;
Map<String, Palette> palettes;
//palettes will include everything, while these are for easier access and may be more common to access
Map<String, Palette> approvedPalettes;
Map<String, Palette> pendingPalettes;
Map<String, Palette> rejectedPalettes;
Map<String, Palette> deletedPalettes;

List<OnVoidAction> onSaveChanged = [];
bool hasSaveChanged = true;
bool isLoading = true;

CollectionReference _databaseCompleted;
CollectionReference _databasePending;

void init() {
  _databaseCompleted = FirebaseFirestore.instance.collection('presetPalettes');
  _databasePending = FirebaseFirestore.instance.collection('pendingPresetPalettes');
}

void listenOnSaveChanged(OnVoidAction listener) {
  onSaveChanged.add(listener);
}

Map<String, Palette> getStatusList(PaletteStatus status) {
  switch(status) {
    case PaletteStatus.Approved: {
      return approvedPalettes;
    }
    case PaletteStatus.Pending: {
      return pendingPalettes;
    }
    case PaletteStatus.Rejected: {
      return rejectedPalettes;
    }
    case PaletteStatus.Deleted: {
      return deletedPalettes;
    }
  }
  return {};
}

Future<void> editSwatch(String paletteId, Swatch swatch) async {
  if(palettes == null || hasSaveChanged) {
    await loadAllFormatted();
  }
  if(paletteId != '' && swatch.id >= 0) {
    Palette palette = palettes[paletteId];
    palette.swatches[swatch.id] = swatch;
    await save(palette);
  }
}

Future<void> removeSwatch(String paletteId, int swatchId) async {
  if(palettes == null || hasSaveChanged) {
    await loadAllFormatted();
  }
  if(paletteId != '' && swatchId >= 0) {
    Palette palette = palettes[paletteId];
    palette.swatches.remove(swatchId);
    await save(palette);
  }
}

Future<void> removePalette(String paletteId) async {
  hasSaveChanged = true;
  print('Removing palette $paletteId');
  DocumentSnapshot doc;
  if(palettes[paletteId].status == PaletteStatus.Approved) {
    doc = await _databaseCompleted.doc(paletteId).get();
  } else {
    doc = await _databasePending.doc(paletteId).get();
  }
  await doc.reference.delete();
}

Swatch getSwatch(String paletteId, int swatchId) {
  Palette palette = getPalette(paletteId);
  if(palette != null && palette.swatches.length > swatchId) {
    return palette.swatches[swatchId];
  }
  return null;
}

Palette getPalette(String paletteId) {
  if(palettes == null || hasSaveChanged) {
    loadAllFormatted();
  }
  if(palettes.containsKey(paletteId)) {
    return palettes[paletteId];
  }
  return null;
}

Future<void> changeStatus(Palette palette, PaletteStatus status) async {
  if(palette.status == status) {
    //nothing to do, save just in case
    await save(palette);
    return;
  }
  if(palette.status == PaletteStatus.Approved && status != PaletteStatus.Approved) {
    //approving from other status, need to change database
    DocumentSnapshot doc = await _databaseCompleted.doc(palette.id).get();
    await doc.reference.delete();
    palette.status = status;
    await save(palette);
    return;
  }
  if(palette.status != PaletteStatus.Approved && status == PaletteStatus.Approved) {
    //deleting, rejected, or making pending from approved, need to change database
    DocumentSnapshot doc = await _databasePending.doc(palette.id).get();
    await doc.reference.delete();
    palette.status = status;
    await save(palette);
    return;
  }
  //nothing special to be done, just value change
  palette.status = status;
  await save(palette);
}

Future<void> save(Palette palette) async {
  //assumes just changing palette data, not status, use different method for that
  hasSaveChanged = true;
  //clean name input
  String brand = globalWidgets.toTitleCase(removeAllChars(palette.brand, [r';', r'\\']));
  String name = globalWidgets.toTitleCase(removeAllChars(palette.name, [r';', r'\\']));
  double weight = double.parse(palette.weight.toStringAsFixed(4));
  double price = double.parse(palette.price.toStringAsFixed(2));
  String swatchData = '';
  for(int i = 0; i < palette.swatches.length; i++) {
    palette.swatches[i].brand = brand;
    palette.swatches[i].palette = name;
    palette.swatches[i].weight = double.parse((weight / palette.swatches.length).toStringAsFixed(4));
    palette.swatches[i].price = double.parse((price / palette.swatches.length).toStringAsFixed(4));
    String save = await saveSwatch(palette.swatches[i]);
    swatchData += '$save';
  }
  swatchData = compress(swatchData);
  if(palette.status == PaletteStatus.Approved) {
    await _databaseCompleted.doc(palette.id).set(
        {
          'brand': brand,
          'name': name,
          'weight': weight,
          'price': price,
          'data': swatchData,
        }
    );
  } else {
    await _databasePending.doc(palette.id).set(
        {
          'brand': brand,
          'name': name,
          'weight': weight,
          'price': price,
          'data': swatchData,
          'status': PaletteStatus.values.indexOf(palette.status),
        }
    );
  }
}

Future<List<DocumentSnapshot>> load({ bool override = false }) async {
  if(docs == null || hasSaveChanged || override) {
    docs = (await _databaseCompleted.get()).docs;
    docs.addAll((await _databasePending.get()).docs);
  }
  return docs;
}

Future<Map<String, Palette>> loadAllFormatted({ bool override = false, overrideInner = false }) async {
  if(palettes == null || hasSaveChanged || override || overrideInner) {
    isLoading = true;
    palettes = {};
    approvedPalettes = {};
    pendingPalettes = {};
    rejectedPalettes = {};
    deletedPalettes = {};
    List<DocumentSnapshot> info = await load(override: overrideInner);
    for(int i = 0; i < info.length; i++) {
      Map<String, dynamic> data = info[i].data();
      List<Swatch> swatches = [];
      List<String> swatchLines = decompress(data['data']).split('\n');
      for(int j = 0; j < swatchLines.length; j++) {
        String line = swatchLines[j];
        if(line != '') {
          swatches.add(await loadSwatch(info[i].id, swatches.length, line));
        }
      }
      if(swatches.length == 0) {
        continue;
      }
      Palette palette = Palette(
        id: info[i].id,
        brand: globalWidgets.toTitleCase(data['brand'] ?? ''),
        name: globalWidgets.toTitleCase(data['name'] ?? ''),
        weight: double.parse((data['weight'] ?? 0).toString()),
        price: double.parse((data['price'] ?? 0).toString()),
        swatches: swatches,
        status: data.containsKey('status') ? PaletteStatus.values[data['status']] : PaletteStatus.Approved,
      );
      palettes[palette.id] = palette;
      getStatusList(palette.status)[palette.id] = palette;
    }
    print('${palettes.length} palettes');
    hasSaveChanged = false;
    isLoading = false;
  }
  return palettes;
}

Future<Map<String, Palette>> loadApprovedFormatted({ bool override = false, overrideInner = false }) async {
  if(palettes == null || hasSaveChanged || override || overrideInner) {
    await loadAllFormatted(override: override, overrideInner: overrideInner);
  }
  return approvedPalettes;
}

Future<Map<String, Palette>> loadPendingFormatted({ bool override = false, overrideInner = false }) async {
  if(palettes == null || hasSaveChanged || override || overrideInner) {
    await loadAllFormatted(override: override, overrideInner: overrideInner);
  }
  return pendingPalettes;
}

Future<Map<String, Palette>> loadRejectedFormatted({ bool override = false, overrideInner = false }) async {
  if(palettes == null || hasSaveChanged || override || overrideInner) {
    await loadAllFormatted(override: override, overrideInner: overrideInner);
  }
  return rejectedPalettes;
}

Future<Map<String, Palette>> loadDeletedFormatted({ bool override = false, overrideInner = false }) async {
  if(palettes == null || hasSaveChanged || override || overrideInner) {
    await loadAllFormatted(override: override, overrideInner: overrideInner);
  }
  return deletedPalettes;
}

Future<Map<String, Palette>> loadStatusFormatted(PaletteStatus status, { bool override = false, overrideInner = false }) async {
  if(palettes == null || hasSaveChanged || override || overrideInner) {
    await loadAllFormatted(override: override, overrideInner: overrideInner);
  }
  return getStatusList(status);
}