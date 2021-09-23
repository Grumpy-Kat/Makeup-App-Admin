import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../Widgets/SizedSafeArea.dart';
import '../Widgets/InfoBox.dart';
import '../theme.dart' as theme;

mixin ScreenState {
  Size? screenSize;

  GlobalKey scaffoldKey = GlobalKey();
  GlobalKey menuKey = GlobalKey();
  GlobalKey recommendedSwatchBarKey = GlobalKey();

  bool isDragging = false;

  Widget buildComplete(BuildContext context, String title, int menu, { required Widget body, Widget? leftBar, List<Widget>? rightBar, Widget? floatingActionButton, Widget? endDrawer }) {
    Widget child = SizedSafeArea(
      builder: (context, screenSize) {
        this.screenSize = screenSize.biggest;
        InfoBox.screenSize = this.screenSize;
        return Column(
          children: <Widget>[
            //top bar, including menu button, right bar, left bar, and title, takes up top 10%
            Expanded(
              flex: 1,
              child: Container(
                color: theme.primaryColor,
                child: Row(
                  children: <Widget>[
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 7),
                      child: (leftBar != null) ? leftBar : Container(),
                    ),
                    Expanded(
                      child: Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 2, right: 2, top: 3),
                        child: AutoSizeText(
                          title,
                          style: theme.primaryTextBold,
                          minFontSize: 11,
                          maxFontSize: theme.primaryTextBold.fontSize!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 7),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: rightBar ?? [],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            //body is determined by screen subclassing, takes up middle 80%
            Expanded(
              flex: 9,
              child: body,
            ),
          ],
        );
      },
    );
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: theme.bgColor,
      //floatingActionButton is determined by screen subclassing
      floatingActionButton: floatingActionButton,
      resizeToAvoidBottomInset: false,
      body: child,
    );
  }

  void onExit() async { }
}
