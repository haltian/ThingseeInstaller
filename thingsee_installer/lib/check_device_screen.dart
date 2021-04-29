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

import 'package:thingsee_installer/check_device_sensor_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:thingsee_installer/app_localizations.dart';
import 'package:thingsee_installer/utilities.dart';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:permission_handler/permission_handler.dart';

class CheckDeviceScreen extends StatefulWidget {
  @override
  _CheckDeviceScreenState createState() => _CheckDeviceScreenState();
}

class _CheckDeviceScreenState extends State<CheckDeviceScreen> {
  var _endScaffoldKey = new GlobalKey<ScaffoldState>();

  String _qrCode = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _endScaffoldKey,
      appBar: AppBar(
        backgroundColor: HexColor("#1f87d8"),
        leading: IconButton(
          icon: new SvgPicture.asset(
            'assets/ts_arrow.svg',
            color: HexColor("#ffffff"),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          AppLocalizations.of(context).translate('check_device_info_title'),
          style: TextStyle(fontFamily: 'Haltian Sans'),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(40, 40, 40, 10),
            child: Text(
              AppLocalizations.of(context).translate('check_device_info_1'),
              style: TextStyle(fontFamily: 'Haltian Sans', fontSize: 24),
            ),
          ),
          new Expanded(
              child: new Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(40, 0, 40, 30),
                    child: ButtonTheme(
                      minWidth: 300.0,
                      child: TextButton (
                        style: getFlatButton(Colors.white, HexColor("#1f87d8"), EdgeInsets.all(10.0)),
                        onPressed: () => {_checkPermission()},
                        child: Text(
                          AppLocalizations.of(context)
                              .translate('button_read_qr_code'),
                          style: TextStyle(
                              fontFamily: 'Haltian Sans',
                              color: Colors.white,
                              fontSize: 20),
                        ),
                      ),
                    ),
                  ))),
        ],
      ),
    );
  }

  _checkPermission() async {
    if (await Permission.camera.status != PermissionStatus.granted) {
      _requestPermission();
    } else {
      _scan();
    }
  }

  _requestPermission() async {
    if (await Permission.camera.request().isGranted) {
      _scan();
    } else {
      showInfoDialog(
          context,
          AppLocalizations.of(context).translate('error_title'),
          AppLocalizations.of(context)
              .translate('error_message_camera_permission_not_granted'),
          AppLocalizations.of(context).translate('button_close'));
    }
  }

  Future _scan() async {
    try {
      var barcode = await BarcodeScanner.scan();
      _qrCode = barcode.rawContent;
      List<String> tuidParts = _qrCode.split(',');
      if (tuidParts.length > 1 &&
          tuidParts[0].length == 11 &&
          tuidParts[1].length == 6) {
        String tuid = tuidParts[1] + tuidParts[0];
        final bool notFound = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => CheckDeviceSensorScreen(tuid: tuid)),
        );
        if (notFound) {
          showInfoDialog(
              context,
              AppLocalizations.of(context).translate('note_title'),
              AppLocalizations.of(context)
                      .translate('note_message_sensor_not_in_stack') +
                  tuid,
              AppLocalizations.of(context).translate('button_ok'));
        }
      } else {
        showInfoDialog(
            context,
            AppLocalizations.of(context).translate('error_title'),
            AppLocalizations.of(context)
                .translate('error_message_invalid_qr_code'),
            AppLocalizations.of(context).translate('button_close'));
      }
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.cameraAccessDenied) {
        setState(() {
          showInfoDialog(
              context,
              AppLocalizations.of(context).translate('error_title'),
              AppLocalizations.of(context)
                  .translate('error_message_camera_permission_not_granted'),
              AppLocalizations.of(context).translate('button_close'));
        });
      } else {
        showInfoDialog(
            context,
            AppLocalizations.of(context).translate('error_title'),
            AppLocalizations.of(context)
                .translate('error_message_something_went_wrong'),
            AppLocalizations.of(context).translate('button_close'));
      }
    } on FormatException {
      print("User returned using the 'back'-button before scanning anything.");
    } catch (e) {
      showInfoDialog(
          context,
          AppLocalizations.of(context).translate('error_title'),
          AppLocalizations.of(context)
              .translate('error_message_something_went_wrong'),
          AppLocalizations.of(context).translate('button_close'));
    }
  }
}
