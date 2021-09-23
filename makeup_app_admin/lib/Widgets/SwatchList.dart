import 'package:flutter/material.dart' hide HSVColor;
import 'package:flutter/rendering.dart';
import '../Widgets/Swatch.dart';
import '../theme.dart' as theme;
import '../types.dart';

class SwatchList {
  Future? addSwatches;
  //keep original for when changed with sorting or filtering
  Future? orgAddSwatches;

  final bool showInfoBox;

  final bool showPlus;
  final OnVoidAction? onPlusPressed;

  final bool showDelete;

  SwatchList({ required this.addSwatches, this.orgAddSwatches, this.showInfoBox = true, this.showPlus = false, this.onPlusPressed, this.showDelete = false });
}

mixin SwatchListState {
  late SwatchList swatchList;

  void init(SwatchList swatchList) {
    this.swatchList = swatchList;
  }

  Widget buildSwatchList(BuildContext context, AsyncSnapshot snapshot, List<SwatchIcon?> swatchIcons, { Axis axis = Axis.vertical, int crossAxisCount = 3, double padding = 20, double spacing = 35 }) {
    int itemCount = 0;
    if(snapshot.connectionState != ConnectionState.active && snapshot.connectionState != ConnectionState.waiting) {
      //check if any swatches are null
      for(int i = swatchIcons.length - 1; i >= 0; i--) {
        if(swatchIcons[i] == null) {
          swatchIcons.remove(i);
        }
      }
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
    return GridView.builder(
      scrollDirection: axis,
      primary: true,
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
        if(swatchList.showPlus && swatchIcons.length == i) {
          return Ink(
            decoration: ShapeDecoration(
              color: theme.accentColor,
              shape: const CircleBorder(),
            ),
            child: IconButton(
              color: theme.accentTextColor,
              icon: Icon(
                Icons.add,
                size: 50.0,
              ),
              onPressed: swatchList.onPlusPressed,
            ),
          );
        }
        return swatchIcons[i]!;
      }
    );
  }

  void setState(OnVoidAction func);
}
