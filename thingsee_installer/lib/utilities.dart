/* Copyright (c) 2021 Haltian Oy

 Permission is hereby granted, free of charge, to any person obtaining
 a copy of this software and associated documentation files (the
 "Software"), to deal in the Software without restriction, including
 without limitation the rights to use, copy, modify, merge, publish,
 distribute, sublicense, and/or sell copies of the Software, and to
 permit persons to whom the Software is furnished to do so, subject to
 the following conditions:

 The above copyright notice and this permission notice shall be included
 in all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
 CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}

class FlatButtonWithRipple extends StatelessWidget {
  final AssetImage leading;
  final String title;
  final String subtitle;
  final String trailing;
  final AssetImage trailingIcon;
  final VoidCallback onTap;

  FlatButtonWithRipple(
      {this.leading,
      this.title,
      this.subtitle,
      this.trailing,
      this.trailingIcon,
      this.onTap});

  Widget build(BuildContext context) {
    return InkWell(onTap: this.onTap, child: _checkNeedForSubtitle());
  }

  _checkNeedForSubtitle() {
    if (this.subtitle != null && this.subtitle != "") {
      return ListTile(
          leading: _checkLeading(),
          title: Text(
            title,
            style: new TextStyle(
                fontFamily: 'Haltian Sans',
                fontSize: 20,
                color: HexColor("#000000"),
                fontStyle: FontStyle.normal,
                decoration: TextDecoration.none),
            maxLines: 1,
          ),
          subtitle: Text(
            subtitle,
            style: new TextStyle(
                fontFamily: 'Haltian Sans',
                fontSize: 16,
                color: HexColor("#000000"),
                fontStyle: FontStyle.normal,
                decoration: TextDecoration.none),
            maxLines: 1,
          ),
          trailing: _checkTrailing());
    } else {
      return ListTile(
          leading: _checkLeading(),
          title: Text(
            title,
            style: new TextStyle(
                fontFamily: 'Haltian Sans',
                fontSize: 20,
                color: HexColor("#000000"),
                fontStyle: FontStyle.normal,
                decoration: TextDecoration.none),
            maxLines: 1,
          ),
          trailing: _checkTrailing());
    }
  }

  _checkLeading() {
    if (this.leading != null) {
      return Padding(
        padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
        child: Image(image: this.leading),
      );
    }
  }

  _checkTrailing() {
    if (this.trailing != null) {
      return Padding(
          padding: EdgeInsets.fromLTRB(5, 5, 0, 0),
          child: Column(children: <Widget>[
            Text(
              this.trailing,
              style: TextStyle(fontFamily: 'Haltian Sans', fontSize: 14),
            ),
          ]));
    } else if (this.trailingIcon != null) {
      return Padding(
        padding: EdgeInsets.fromLTRB(5, 15, 5, 15),
        child: Image(image: this.trailingIcon),
      );
    }
  }
}

void showInfoDialog(
    BuildContext context, String title, String message, String buttonText) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      // return object of type Dialog
      return AlertDialog(
        backgroundColor: HexColor("#1f87d8"),
        title: new Text(title,
            style: TextStyle(
                fontFamily: 'Haltian Sans', color: Colors.white, fontSize: 20)),
        content: new Text(message,
            style: TextStyle(
                fontFamily: 'Haltian Sans', color: Colors.white, fontSize: 20)),
        actions: <Widget>[
          // usually buttons at the bottom of the dialog
          new TextButton(
            style: getFlatButton(
                Colors.white, HexColor("#1f87d8"), EdgeInsets.all(0.0)),
            child: Text(buttonText,
                style: TextStyle(
                    fontFamily: 'Haltian Sans',
                    color: Colors.white,
                    fontSize: 20)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

void showSimpleQueryDialog(BuildContext context, String title, String message,
    String buttonText, VoidCallback buttonCallback) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return WillPopScope(
            onWillPop: () {
              Navigator.of(context).pop();
              buttonCallback();
              return Future.value(false);
            },
            child: AlertDialog(
              backgroundColor: HexColor("#1f87d8"),
              title: new Text(title,
                  style: TextStyle(
                      fontFamily: 'Haltian Sans',
                      color: Colors.white,
                      fontSize: 20)),
              content: new Text(message,
                  style: TextStyle(
                      fontFamily: 'Haltian Sans',
                      color: Colors.white,
                      fontSize: 20)),
              actions: <Widget>[
                // usually buttons at the bottom of the dialog
                new TextButton(
                  style: getFlatButton(
                      Colors.white, HexColor("#1f87d8"), EdgeInsets.all(10.0)),
                  child: Text(buttonText,
                      style: TextStyle(
                          fontFamily: 'Haltian Sans',
                          color: Colors.white,
                          fontSize: 20)),
                  onPressed: () {
                    Navigator.of(context).pop();
                    buttonCallback();
                  },
                ),
              ],
            ));
      });
}

void showQueryDialog(
    BuildContext context,
    String title,
    String message,
    String buttonText1,
    String buttonText2,
    VoidCallback button1,
    VoidCallback button2) {
  VoidCallback onTapButton1 = button1;
  VoidCallback onTapButton2 = button2;
  showDialog(
    context: context,
    builder: (BuildContext context) {
      // return object of type Dialog
      return AlertDialog(
        backgroundColor: HexColor("#1f87d8"),
        title: new Text(title,
            style: TextStyle(
                fontFamily: 'Haltian Sans', color: Colors.white, fontSize: 20)),
        content: new Text(message,
            style: TextStyle(
                fontFamily: 'Haltian Sans', color: Colors.white, fontSize: 18)),
        actions: <Widget>[
          new TextButton(
            style: getFlatButton(
                Colors.white, HexColor("#1f87d8"), EdgeInsets.all(10.0)),
            child: Text(buttonText1,
                style: TextStyle(
                    fontFamily: 'Haltian Sans',
                    color: Colors.white,
                    fontSize: 20)),
            onPressed: () {
              Navigator.pop(context);
              onTapButton1();
            },
          ),
          new TextButton(
            style: getFlatButton(
                Colors.white, HexColor("#1f87d8"), EdgeInsets.all(10.0)),
            child: Text(buttonText2,
                style: TextStyle(
                    fontFamily: 'Haltian Sans',
                    color: Colors.white,
                    fontSize: 20)),
            onPressed: () {
              Navigator.pop(context);
              onTapButton2();
            },
          ),
        ],
      );
    },
  );
}

class CustomInkWell extends InkWell {
  final Widget child;
  final VoidCallback onTap;
  final VoidCallback onTapLead;

  CustomInkWell({this.child, this.onTap, this.onTapLead});
}

class FlatButtonWithRippleIndicatorAndArrow extends StatelessWidget {
  final bool showLead;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final VoidCallback onTapLead;

  FlatButtonWithRippleIndicatorAndArrow(
      {this.showLead, this.title, this.subtitle, this.onTap, this.onTapLead});

  Widget build(BuildContext context) {
    return CustomInkWell(
      onTap: this.onTap,
      child: _checkNeedForSubtitle(),
      onTapLead: this.onTapLead,
    );
  }

  _checkNeedForSubtitle() {
    if (this.subtitle != "") {
      return ListTile(
          leading: _checkNeedForLead(this.showLead),
          title: Text(title,
              style: new TextStyle(
                  fontFamily: 'Haltian Sans',
                  fontSize: 20,
                  color: HexColor("#000000"),
                  fontStyle: FontStyle.normal,
                  decoration: TextDecoration.none)),
          subtitle: Text(subtitle,
              style: new TextStyle(
                  fontFamily: 'Haltian Sans',
                  fontSize: 16,
                  color: HexColor("#000000"),
                  fontStyle: FontStyle.normal,
                  decoration: TextDecoration.none)),
          trailing: Transform.rotate(
              angle: 3.14159,
              child: SizedBox(
                  width: 40.0,
                  height: 40.0,
                  child: new SvgPicture.asset('assets/ts_arrow.svg',
                      color: Colors.black))));
    } else {
      return ListTile(
        title: Text(title,
            style: new TextStyle(
                fontFamily: 'Haltian Sans',
                fontSize: 20,
                color: HexColor("#000000"),
                fontStyle: FontStyle.normal,
                decoration: TextDecoration.none)),
      );
    }
  }

  _checkNeedForLead(bool showLead) {
    Color indicatorColor = Colors.grey;
    Color indicatorColor2 = Colors.white;
    if (showLead) {
      indicatorColor = HexColor("#1f87d8");
      indicatorColor2 = HexColor("#1f87d8");
    }
    return GestureDetector(
        onTap: () {
          this.onTapLead();
        },
        child: Stack(children: <Widget>[
          new SizedBox(
              width: 40,
              height: 40,
              child: new Container(
                color: Colors.white,
              )),
          new SizedBox(
              width: 40,
              height: 40,
              child: Padding(
                  padding: EdgeInsets.all(10),
                  child: new Container(
                      width: 20,
                      height: 20,
                      decoration: new BoxDecoration(
                        color: indicatorColor,
                        shape: BoxShape.circle,
                      )))),
          new SizedBox(
              width: 40,
              height: 40,
              child: Padding(
                  padding: EdgeInsets.all(11),
                  child: new Container(
                      width: 20,
                      height: 20,
                      decoration: new BoxDecoration(
                        color: indicatorColor2,
                        shape: BoxShape.circle,
                      ))))
        ]));
  }
}

enum SensorConnectionStatus {
  sensorConnectionStatusUnknown,
  sensorConnectionStatusNotConnected,
  sensorConnectionStatusConnected
}

enum SensorType {
  sensorTypeUnknown,
  sensorTypePresence,
  sensorTypeEnvironment,
  sensorTypeAngle,
  sensorTypeGateway,
  sensorTypeDistance,
  sensorTypeDistanceBeam,
  sensorTypeLANGateway,
  sensorTypeAIR,
  sensorTypeLooLight,
  sensorTypeLeakage
}

SensorType getSensorType(String tuid) {
  SensorType type = SensorType.sensorTypeUnknown;

  if (tuid.startsWith("TSGW05") || tuid.startsWith("XXXX16"))
    type = SensorType.sensorTypeLANGateway;
  else if (tuid.startsWith("TSGW") || tuid.startsWith("XXXX00"))
    type = SensorType.sensorTypeGateway;
  else if (tuid.startsWith("TSTF") ||
      tuid.startsWith("XXXX04") ||
      tuid.startsWith("XXXX20")) {
    type = SensorType.sensorTypeDistance;
    if (tuid.startsWith("TSTF04") || tuid.startsWith("XXXX20"))
      type = SensorType.sensorTypeDistanceBeam;
  } else if (tuid.startsWith("TSPD") || tuid.startsWith("XXXX03"))
    type = SensorType.sensorTypeEnvironment;
  else if (tuid.startsWith("TSPR") ||
      tuid.startsWith("XXXX06") ||
      tuid.startsWith("XXXX13"))
    type = SensorType.sensorTypePresence;
  else if (tuid.startsWith("TSAR") ||
      tuid.startsWith("XXAR01") ||
      tuid.startsWith("XXXX14"))
    type = SensorType.sensorTypeAIR;
  else if (tuid.startsWith("TSAN") || tuid.startsWith("XXXX10"))
    type = SensorType.sensorTypeAngle;
  else if (tuid.startsWith("TSLK") || tuid.startsWith("XXLK01"))
    type = SensorType.sensorTypeLeakage;
  else if (tuid.startsWith("WHLL01") ||
      tuid.startsWith("LOLT01") ||
      tuid.startsWith("XXLT01")) type = SensorType.sensorTypeLooLight;

  return type;
}

String getSensorName(SensorType type) {
  Map<SensorType, String> typesToName = {
    SensorType.sensorTypeGateway: "Thingsee GATEWAY",
    SensorType.sensorTypeLANGateway: "Thingsee GATEWAY LAN",
    SensorType.sensorTypeEnvironment: "Thingsee ENVIRONMENT",
    SensorType.sensorTypePresence: "Thingsee PRESENCE",
    SensorType.sensorTypeDistance: "Thingsee DISTANCE",
    SensorType.sensorTypeAngle: "Thingsee ANGLE",
    SensorType.sensorTypeLeakage: "Thingsee LEAKAGE",
    SensorType.sensorTypeDistanceBeam: "Thingsee BEAM",
    SensorType.sensorTypeAIR: "Thingsee AIR",
    SensorType.sensorTypeLooLight: "Whiffaway Loolight"
  };

  String name = "Thingsee UNKNOWN";

  if (typesToName.containsKey(type)) {
    name = typesToName[type];
  }
  return name;
}

getSensorImage(String tuid) {
  SensorType type = getSensorType(tuid);

  switch (type) {
    case SensorType.sensorTypeDistance:
      return AssetImage('assets/ts_asset_distance_darkgrey.png');
    case SensorType.sensorTypeAngle:
      return AssetImage('assets/ts_asset_angle_black.png');
    case SensorType.sensorTypeEnvironment:
      return AssetImage(
          'assets/ts_asset_environment_darkgrey.png');
    case SensorType.sensorTypePresence:
      return AssetImage('assets/ts_asset_presence_darkgrey.png');
    case SensorType.sensorTypeGateway:
      return AssetImage('assets/ts_asset_gateway_darkgrey.png');
    case SensorType.sensorTypeLANGateway:
      return AssetImage('assets/ts_asset_langw_black.png');
    case SensorType.sensorTypeDistanceBeam:
      return AssetImage('assets/ts_asset_langw_black.png');
    case SensorType.sensorTypeAIR:
      return AssetImage('assets/ts_asset_air_black.png');
    case SensorType.sensorTypeLooLight:
      return AssetImage('assets/ts_unknown.png');
    case SensorType.sensorTypeUnknown:
    default:
      return AssetImage('assets/ts_unknown.png');
  }
}

ButtonStyle getFlatButton(
    Color textColor, Color backgroundColor, EdgeInsetsGeometry padding) {
  final ButtonStyle raisedButtonStyle = ElevatedButton.styleFrom(
    onPrimary: textColor,
    primary: backgroundColor,
    minimumSize: Size(10, 10),
    padding: padding,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(0)),
    ),
  );

  return raisedButtonStyle;
}

class Country {
  String _countrySelected = " ";
  Map<String, String> countryCodes = {}; //Name, country code
  SplayTreeMap<String, String> codes = SplayTreeMap<String, String>();
  Country(Map<String, Map<String, String>> data) {
    for (final String iso2 in data.keys) {
      String name = data[iso2]["name"];
      codes[name] = iso2;
    }
    countryCodes.addAll(codes);
  }
  Map<String, String> getCountryCodes() {
    return countryCodes;
  }

  String getCountryName(String code) {
    String _name;
    countryCodes.forEach((countryName, countryCode) {
      if (countryCode.toLowerCase() == code.toLowerCase()) {
        _name = countryName;
        return;
      }
    });
    return _name;
  }

  bool setSelectedCountryCode(String iso2) {
    if (countryCodes.containsValue(iso2)) {
      _countrySelected = iso2;
      return true;
    }
    return false;
  }

  String getSelectedCountryCode() {
    return _countrySelected;
  }

  static String countryCodeKey = "FI";
  static String countryNameKey = "SE";
}
