import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme.dart' as theme;
import 'types.dart';

Future<void> openDialog(BuildContext context, Widget Function(BuildContext) builder) {
  return showDialog(
    context: context,
    builder: builder,
  );
}

Widget getAlertDialog(BuildContext context, { Widget? title, Widget? content, List<Widget>? actions }) {
  return AlertDialog(
    shape: const RoundedRectangleBorder(
      borderRadius: const BorderRadius.all(const Radius.circular(10.0)),
    ),
    title: title,
    content: content,
    actions: actions,
  );
}

Future<void> openLoadingDialog(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: theme.bgColor.withAlpha(35),
        elevation: 0,
        insetPadding: EdgeInsets.zero,
        
        child: Center(
          child: Container(
            width: 100,
            height: 100,
            child: const CircularProgressIndicator(),
          ),
        ),
      );
    },
  );
}

Future<void> openTextDialog(BuildContext context, String title, String error, String buttonLabel, OnStringAction onPressed, { String orgValue = '', bool required = true }) {
  String value = orgValue;
  bool showErrorText = false;
  return openDialog(
    context,
    (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return getAlertDialog(
            context,
            title: Text(title, style: theme.primaryTextBold),
            content: getTextField(
              context,
              null,
              value,
              error,
              showErrorText,
              (String val) {
                value = val;
                if(required) {
                  if(showErrorText && val != '') {
                    setState(() { showErrorText = false; });
                  }
                }
              },
              (String val) {
                value = val;
                if(required) {
                  if(showErrorText && value != '') {
                    setState(() { showErrorText = false; });
                  }
                  if(value == '') {
                    setState(() { showErrorText = true; });
                  }
                }
              }
            ),
            actions: <Widget>[
              getFlatButton(
                bgColor: theme.accentColor,
                onPressed: () {
                  if(required && value == '') {
                    setState(() { showErrorText = true; });
                  } else {
                    //doesn't use navigation because is popping a Dialog
                    Navigator.pop(context);
                    onPressed(value);
                  }
                },
                child: Text(
                  buttonLabel,
                  style: theme.accentTextBold,
                ),
              )
            ],
          );
        },
      );
    },
  );
}

Future<void> openTwoButtonDialog(BuildContext context, String title, OnVoidAction onPressedYes, OnVoidAction onPressedNo) {
  return openDialog(
    context,
    (BuildContext context) {
      return getAlertDialog(
        context,
        title: Text(title, style: theme.primaryTextPrimary),
        actions: <Widget>[
          getFlatButton(
            bgColor: theme.accentColor,
            onPressed: () {
              //doesn't use navigation because is popping an Dialog
              Navigator.pop(context);
              onPressedYes();
            },
            child: Text(
              'Yes',
              style: theme.accentTextBold,
            ),
          ),
          getFlatButton(
            bgColor: theme.accentColor,
            onPressed: () {
              Navigator.pop(context);
              onPressedNo();
            },
            child: Text(
              'No',
              style: theme.accentTextBold,
            ),
          ),
        ],
      );
    },
  );
}

PageRouteBuilder slideTransition(BuildContext context, Widget nextScreen, int duration, Offset begin, Offset end) {
  return PageRouteBuilder(
    transitionDuration: Duration(milliseconds: duration),
    pageBuilder: (context, animation, secondaryAnimation) { return nextScreen; },
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween(
          begin: begin,
          end: end,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutCirc,
          ),
        ),
        child: child,
      );
    },
  );
}

Widget getTextField(BuildContext context, String? label, String value, String error, bool showErrorText, OnStringAction onChanged, OnStringAction onSubmitted, { Key? key }) {
  return TextFormField(
    key: key,
    textAlign: TextAlign.left,
    style: theme.primaryTextSecondary,
    textCapitalization: TextCapitalization.words,
    cursorColor: theme.accentColor,
    initialValue: value,
    decoration: InputDecoration(
      fillColor: theme.primaryColor,
      labelText: label,
      labelStyle: theme.primaryTextSecondary,
      errorText: showErrorText ? error : null,
      errorStyle: theme.errorTextSecondary,
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: theme.errorTextColor,
          width: 1.0,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: theme.errorTextColor,
          width: 2.5,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: theme.primaryColorDark,
          width: 1.0,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: theme.accentColor,
          width: 2.5,
        ),
      ),
    ),
    onChanged: onChanged,
    onFieldSubmitted: onSubmitted,
  );
}

Widget getNumField(BuildContext context, String label, double value, String error, bool showErrorText, OnDoubleAction onChanged, OnDoubleAction onSubmitted, { Key? key }) {
  return TextFormField(
    key: key,
    textAlign: TextAlign.left,
    style: theme.primaryTextSecondary,
    textInputAction: TextInputAction.done,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    cursorColor: theme.accentColor,
    initialValue: value.toString(),
    inputFormatters: <TextInputFormatter>[
      FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
    ],
    decoration: InputDecoration(
      fillColor: theme.primaryColor,
      labelText: label,
      labelStyle: theme.primaryTextSecondary,
      errorText: showErrorText ? error : null,
      errorStyle: theme.errorTextSecondary,
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: theme.errorTextColor,
          width: 1.0,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: theme.errorTextColor,
          width: 2.5,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: theme.primaryColorDark,
          width: 1.0,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: theme.accentColor,
          width: 2.5,
        ),
      ),
    ),
    onChanged: (String val) {
      onChanged(double.parse(val));
    },
    onFieldSubmitted: (String val) {
      onSubmitted(double.parse(val));
    },
  );
}

Widget getBackButton(OnVoidAction onPressed) {
  return IconButton(
    constraints: BoxConstraints.tight(const Size.fromWidth(26)),
    icon: Icon(
      Icons.arrow_back_ios,
      size: 19,
      color: theme.iconTextColor,
    ),
    onPressed: onPressed,
  );
}

Widget getListItem(String text1, String? text2, bool isLast, OnVoidAction onTap, { bool hasCheckBox = false, bool isCheckBoxChecked = false }) {
  Decoration decorationLast = BoxDecoration(
    color: theme.primaryColor,
    border: Border(
      top: BorderSide(
        color: theme.primaryColorDark,
      ),
      bottom: BorderSide(
        color: theme.primaryColorDark,
      ),
    ),
  );
  Decoration decorationNotLast = BoxDecoration(
    color: theme.primaryColor,
    border: Border(
      top: BorderSide(
        color: theme.primaryColorDark,
      ),
    ),
  );
  Widget text;
  if(text2 == null || text2 == '') {
    text = Container(
      alignment: Alignment.centerLeft,
      child: Text('$text1', style: theme.primaryTextPrimary),
    );
  } else {
    text = Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          alignment: Alignment.centerLeft,
          child: Text('$text1', style: theme.primaryTextSecondary),
        ),
        Container(
          alignment: Alignment.centerLeft,
          child: Text('$text2', style: theme.primaryTextPrimary),
        ),
      ],
    );
  }
  Widget child;
  if(hasCheckBox) {
    child = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          child: text,
        ),
        Container(
          alignment: Alignment.centerLeft,
          child: Checkbox(
            value: isCheckBoxChecked,
            onChanged: (bool? val) {
              onTap();
            },
            checkColor: theme.accentColor,
          ),
        ),
      ],
    );
  } else {
    child = text;
  }
  return GestureDetector(
    onTap: onTap,
    child: Container(
      height: (text2 != null && text2 != '') ? 64 : 62,
      decoration: isLast ? decorationLast : decorationNotLast,
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 10),
      child: child,
    ),
  );
}

Widget getFlatButton({ OnVoidAction? onPressed, required Widget child, EdgeInsets? padding, Color? bgColor, Color? splashColor }) {
  return TextButton(
    onPressed: onPressed,
    style: TextButton.styleFrom(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
      backgroundColor: bgColor ?? Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(const Radius.circular(2)),
      ),
    ).copyWith(
      overlayColor: MaterialStateProperty.resolveWith<Color?>(
        (Set<MaterialState> states) {
          if(states.contains(MaterialState.pressed)) {
            return splashColor ?? theme.accentColor.withAlpha(130);
          }
          return null;
        },
      ),
    ),
    child: child,
  );
}

Widget getOutlineButton({ OnVoidAction? onPressed, required Widget child, EdgeInsets? padding, Color? bgColor, Color? outlineColor, double? outlineWidth, Color? splashColor }) {
  return OutlinedButton(
    onPressed: onPressed,
    style: OutlinedButton.styleFrom(
      padding: padding ?? EdgeInsets.symmetric(horizontal: 16),
      backgroundColor: bgColor ?? Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(const Radius.circular(2)),
      ),
    ).copyWith(
      side: MaterialStateProperty.resolveWith<BorderSide?>(
        (Set<MaterialState> states) {
          if(states.contains(MaterialState.pressed)) {
            return BorderSide(
              color: outlineColor ?? theme.primaryColorDark,
              width: outlineWidth ?? 1,
            );
          }
          return null;
        },
      ),
      overlayColor: MaterialStateProperty.resolveWith<Color?>(
        (Set<MaterialState> states) {
          if(states.contains(MaterialState.pressed)) {
            return splashColor ?? theme.accentColor.withAlpha(130);
          }
          return null;
        },
      ),
    ),
    child: child,
  );
}

String toTitleCase(String text) {
  List<String> words = text.split(' ');
  String result = '';
  for(int i = 0; i < words.length; i++) {
    if(words[i].length <= 1) {
      result += words[i].toUpperCase() + ' ';
      continue;
    }
    result += words[i].substring(0, 1).toUpperCase() + words[i].substring(1) + ' ';
  }
  return result;
}

String toCamelCase(String text) {
  List<String> words = text.split(' ');
  String result = words[0].toLowerCase();
  for(int i = 1; i < words.length; i++) {
    if(words[i].length <= 1) {
      result += words[i].toUpperCase();
      continue;
    }
    result += words[i].substring(0, 1).toUpperCase() + words[i].substring(1);
  }
  return result;
}