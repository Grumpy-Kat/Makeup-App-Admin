import 'package:flutter/material.dart' hide HSVColor;
import 'package:flutter/rendering.dart';
import 'package:drag_and_drop_gridview/devdrag.dart';
import '../Widgets/Swatch.dart';
import '../Widgets/SwatchList.dart';
import '../types.dart';

mixin ReorderableSwatchListState {
  late SwatchList swatchList;
  OnSwatchListAction? updateSwatches;

  List<SwatchIcon?>? reordering;
  int? draggingIndex;

  void initReorderable(SwatchList swatchList, OnSwatchListAction updateSwatches) {
    this.swatchList = swatchList;
    this.updateSwatches = updateSwatches;
  }


  Widget buildReorderableSwatchList(BuildContext context, AsyncSnapshot snapshot, List<SwatchIcon?> swatchIcons, { int crossAxisCount = 3, double padding = 20, double spacing = 35 }) {
    int itemCount = 0;
    if(snapshot.connectionState != ConnectionState.active && snapshot.connectionState != ConnectionState.waiting) {
      //check if any swatches are null
      for(int i = swatchIcons.length - 1; i >= 0; i--) {
        if(swatchIcons[i] == null) {
          swatchIcons.remove(i);
        }
      }
      reordering = [...swatchIcons];
      //swatches
      itemCount = swatchIcons.length;
    } else {
      //loading indicator
      itemCount += 1;
    }
    if(swatchList.showPlus) {
      //plus button
      itemCount++;
    }
    return DragAndDropGridView(
      //primary: true,
      padding: EdgeInsets.all(padding),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
        crossAxisCount: crossAxisCount,
      ),
      itemCount: itemCount,
      itemBuilder: (BuildContext context, int i) {
        if(swatchIcons.length == 0) {
          if(snapshot.connectionState == ConnectionState.active || snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
        }
        return Opacity(
          opacity: draggingIndex != null ? (draggingIndex == i ? 0.6 : 1) : 1,
          child: swatchIcons[i],
        );
      },
      onWillAccept: (int oldIndex, int newIndex) {
        swatchIcons = _reorder(swatchIcons, oldIndex, newIndex);
        setState(
          () {
            draggingIndex = newIndex;
          },
        );
        return true;
      },
      onReorder: (oldIndex, newIndex) {
        swatchIcons = _reorder(swatchIcons, oldIndex, newIndex);
        reordering = [...swatchIcons];
        updateSwatchList(swatchIcons);
        setState(
          () {
            draggingIndex = null;
          },
        );
      },
    );
  }

  List<SwatchIcon?> _reorder(List<SwatchIcon?> swatchIcons, int oldIndex, int newIndex) {
    swatchIcons = [...reordering!];
    // Can't simplify into loop by reversing oldIndex and newIndex because order matters and loops would not be equivalent
    if(oldIndex > newIndex) {
      for(int i = oldIndex; i > newIndex; i--) {
        SwatchIcon? temp = swatchIcons[i - 1];
        swatchIcons[i - 1] = swatchIcons[i];
        swatchIcons[i] = temp;
      }
    } else {
      for(int i = oldIndex; i < newIndex; i++) {
        SwatchIcon? temp = swatchIcons[i + 1];
        swatchIcons[i + 1] = swatchIcons[i];
        swatchIcons[i] = temp;
      }
    }
    return swatchIcons;
  }

  void updateSwatchList(List<SwatchIcon?> swatchIcons) {
    if(swatchIcons.length == 0) {
      //can't do anything
      return;
    }
    String paletteId = swatchIcons[0]!.paletteId;
    List<Swatch> swatches = [];
    for(int i = 0; i < swatchIcons.length; i++) {
      swatches.add(swatchIcons[i]!.swatch!);
    }
    updateSwatches!(paletteId, swatches);
  }

  void setState(OnVoidAction func);
}
