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

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';

import 'package:thingsee_installer/thingsee_network_apis.dart';
import 'package:thingsee_installer/utilities.dart';
import 'package:thingsee_installer/app_localizations.dart';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:encrypt/encrypt.dart' as encryptionLib;

class AddStackWidget extends StatefulWidget {
  @override
  AddStackWidgetState createState() => AddStackWidgetState();
}

class AddStackWidgetState extends State<AddStackWidget> {
  var _endScaffoldKey = new GlobalKey<ScaffoldState>();

  String _stackName = "";
  String _clientId = "";
  String _path = "";
  String _secret = "";

  bool _scanningSecret = false;
  String _qrCode4Secret = "";

  bool _refreshNeeded = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          Navigator.pop(context, _refreshNeeded);
          return Future.value(false); // if true allow back else block it
        },
        child: Scaffold(
          key: _endScaffoldKey,
          appBar: AppBar(
            backgroundColor: HexColor("#1f87d8"),
            leading: IconButton(
              icon: new SvgPicture.asset(
                'assets/ts_arrow.svg',
                color: HexColor("#ffffff"),
              ),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
            title: Text(
              AppLocalizations.of(context).translate('add_stack_header'),
              style: TextStyle(fontFamily: 'Haltian Sans'),
            ),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(40.0),
            physics: NeverScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints.tightFor(
                  height: MediaQuery.of(context).size.height - 160),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)
                          .translate('add_stack_info_title'),
                      style:
                          TextStyle(fontFamily: 'Haltian Sans', fontSize: 26),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: Column(
                      children: <Widget>[
                        Divider(
                          color: Colors.black,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            ButtonTheme(
                              minWidth: 10.0,
                              child: TextButton(
                                style: getFlatButton(Colors.white,
                                    HexColor("#1f87d8"), EdgeInsets.all(8.0)),
                                onPressed: () => {_checkPermission(false)},
                                child: Text(
                                  AppLocalizations.of(context)
                                      .translate('button_qr'),
                                  style: TextStyle(
                                      fontFamily: 'Haltian Sans',
                                      color: Colors.white,
                                      fontSize: 20),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                    child: Text(
                      AppLocalizations.of(context)
                              .translate('stack_client_id_title') +
                          _clientId,
                      style:
                          TextStyle(fontFamily: 'Haltian Sans', fontSize: 20),
                      maxLines: 1,
                      softWrap: false,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                    child: Text(
                      AppLocalizations.of(context)
                              .translate('stack_url_title') +
                          _path,
                      style:
                          TextStyle(fontFamily: 'Haltian Sans', fontSize: 20),
                      maxLines: 1,
                      softWrap: false,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
                    child: Column(
                      children: <Widget>[
                        Divider(
                          color: Colors.black,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            ButtonTheme(
                              minWidth: 10.0,
                              child: TextButton(
                                style: getFlatButton(Colors.white,
                                    HexColor("#1f87d8"), EdgeInsets.all(8.0)),
                                onPressed: () => {_checkPermission(true)},
                                child: Text(
                                  AppLocalizations.of(context)
                                      .translate('button_qr'),
                                  style: TextStyle(
                                      fontFamily: 'Haltian Sans',
                                      color: Colors.white,
                                      fontSize: 20),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 10, 0, 20),
                    child: Text(
                      AppLocalizations.of(context)
                              .translate('stack_secret_title') +
                          _qrCode4Secret,
                      style:
                          TextStyle(fontFamily: 'Haltian Sans', fontSize: 20),
                      maxLines: 1,
                      softWrap: false,
                    ),
                  ),
                  Divider(
                    color: Colors.black,
                  ),
                  Expanded(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 40, 0, 10),
                        child: ButtonTheme(
                          minWidth: 300.0,
                          child: TextButton(
                            style: getFlatButton(Colors.white,
                                HexColor("#1f87d8"), EdgeInsets.all(10.0)),
                            onPressed: () => {_checkAndSaveNewStack()},
                            child: Text(
                              AppLocalizations.of(context)
                                  .translate('button_add'),
                              style: TextStyle(
                                  fontFamily: 'Haltian Sans',
                                  color: Colors.white,
                                  fontSize: 20),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).viewInsets.bottom,
                      ),
                    ],
                  )),
                ],
              ),
            ),
          ),
        ));
  }

  _checkAndSaveNewStack() async {
    if (_secret.length > 0) {
      if (_clientId.length > 0 && _path.length > 0) {
        print("Create new stack:" + _stackName);
        bool validStack =
            await ThingseeNetworkAPIs.testStack(_path, _clientId, _secret);

        if (validStack) {
          await ThingseeNetworkAPIs.addStack(
              _stackName, _path, _clientId, _secret, true);
          Navigator.pop(context, true);
        } else {
          print("Error login in to new stack!");
          showSimpleQueryDialog(
              context,
              AppLocalizations.of(context).translate('error_title'),
              AppLocalizations.of(context)
                  .translate('error_message_could_not_login_to_stack'),
              AppLocalizations.of(context).translate('button_ok'),
              _closeDialog);
        }
      } else {
        print("Error QR code not read!");
        showInfoDialog(
            context,
            AppLocalizations.of(context).translate('error_title'),
            AppLocalizations.of(context)
                .translate('error_message_qr_code_missing'),
            AppLocalizations.of(context).translate('button_close'));
      }
    } else {
      print("Error secret missing!");
      showInfoDialog(
          context,
          AppLocalizations.of(context).translate('error_title'),
          AppLocalizations.of(context)
              .translate('error_message_secret_missing'),
          AppLocalizations.of(context).translate('button_close'));
    }
  }

  _closeDialog() {}

  _checkPermission(bool scanningSecret) async {
    _scanningSecret = scanningSecret;
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
      print('The user did not grant the camera permission!');
    }
  }

  Future _scan() async {
    try {
      ScanResult barcode = await BarcodeScanner.scan();
      String result = "";
      bool qrCodeError = true;
      result = barcode.rawContent;
      print(result);

      //ECB, 256bits
      final key =
          encryptionLib.Key.fromUtf8("efgwgWyw4646ewtewefgwetwee55wetw");
      final iv = encryptionLib.IV.fromLength(16);
      final encrypter = encryptionLib.Encrypter(
          encryptionLib.AES(key, mode: encryptionLib.AESMode.ecb)); //256bit
      final encryptionLib.Encrypted code =
          encryptionLib.Encrypted.fromBase64(result);
      final String decrypted = encrypter.decrypt(code, iv: iv);
      print(decrypted);

      List<String> parts = decrypted.split(",");
      if (parts.length == 2 || parts.length == 4) {
        if (parts[0] == "V1") {
          if (parts.length == 2 && _scanningSecret) {
            _secret = parts[1];
            _qrCode4Secret = barcode.rawContent;
            qrCodeError = false;
          } else if (parts.length == 4 && !_scanningSecret) {
            _stackName = parts[1];
            _path = parts[2];
            _clientId = parts[3];
            qrCodeError = false;
          }
        }
      }

      if (qrCodeError) {
        print("Error, QR code not supported!");
        showInfoDialog(
            context,
            AppLocalizations.of(context).translate('error_title'),
            AppLocalizations.of(context)
                .translate('error_message_invalid_qr_code'),
            AppLocalizations.of(context).translate('button_close'));
      } else {
        setState(() {});
      }
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.cameraAccessDenied) {
        print('The user did not grant the camera permission!');
      } else {
        print('Unknown error: $e');
      }
    } on FormatException {
      print('FormatException');
    } catch (e) {
      print('Unknown error: $e');
    }
  }
}
