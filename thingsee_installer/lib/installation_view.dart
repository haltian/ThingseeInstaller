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

import 'package:flutter/services.dart';
import 'package:thingsee_installer/data_classes.dart';
import 'package:thingsee_installer/thingsee_network_apis.dart';
import 'package:thingsee_installer/utilities.dart';
import 'package:thingsee_installer/app_localizations.dart';
import 'package:thingsee_installer/add_or_edit_device_installation_view.dart';
import 'package:thingsee_installer/installation_devices_list_view.dart';
import 'package:thingsee_installer/create_or_edit_installation.dart';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';

import 'dart:math' as math;
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class InstallationView extends StatefulWidget {
  InstallationView({Key key, this.installations, this.installationIndex})
      : super(key: key);
  final Installations installations;
  final int installationIndex;

  static const int NO_ACTION = 0;
  static const int REFRESH_DEVICE_AMOUNT = 1;
  static const int INSTALLATION_DELETED = 2;

  @override
  InstallationViewState createState() =>
      InstallationViewState(installations, installationIndex);
}

class InstallationViewState extends State<InstallationView> {
  Installations _installations;
  int _installationIndex;

  var _endScaffoldKey = new GlobalKey<ScaffoldState>();
  String _qrCode = "";
  bool _showHUD = false;

  int action = InstallationView.NO_ACTION;

  InstallationViewState(Installations installations, int installationIndex) {
    _installations = installations;
    _installationIndex = installationIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _endScaffoldKey,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: HexColor("#1f87d8"),
          leading: IconButton(
            icon: new SvgPicture.asset(
              'assets/ts_arrow.svg',
              color: HexColor("#ffffff"),
            ),
            onPressed: () {
              Navigator.pop(context, action);
            },
          ),
          title: Text(
            _installations.installations[_installationIndex].name,
            style: TextStyle(fontFamily: 'Haltian Sans'),
          ),
          actions: <Widget>[
            SizedBox(
                width: 60,
                child: Container(
                    child: IconButton(
                  icon: Image(
                    image: AssetImage('assets/ts_edit_menu_black.png'),
                    color: HexColor("#ffffff"),
                  ),
                  onPressed: _menuSelected,
                )))
          ],
        ),
        body: ModalProgressHUD(
            inAsyncCall:
                _showHUD, // here show is bool value, which is used to when to show the progess indicator
            child: _listDevices()),
        endDrawer: _installationViewMenu(),
        floatingActionButton: Row(children: [
          Padding(
            padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
            child: FloatingActionButton(
              onPressed: () => {_checkCameraPermission(true)},
              child: Transform.rotate(
                  angle: math.pi / 2,
                  child: Image.asset(
                      'assets/ts_asset_test_connection_white.png',
                      width: 35,
                      height: 35)),
              backgroundColor: Colors.blue,
              heroTag: 'replaceDevice',
            ),
          ),
          Expanded(
            child: Row(
              children: <Widget>[],
            ),
          ),
          Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: FloatingActionButton(
                onPressed: () => {_checkCameraPermission(false)},
                child: Image.asset('assets/ts_add_white.png',
                    width: 35, height: 35),
                backgroundColor: Colors.blue,
                heroTag: 'addDevice',
              )),
        ]));
  }

  _menuSelected() {
    _endScaffoldKey.currentState.openEndDrawer();
  }

  _installationViewMenu() {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
        child: SizedBox(
          width: 150,
          height: 280,
          child: Container(
            color: HexColor("#1f87d8"),
            child: ListView(
              // Important: Remove any padding from the ListView.
              padding: EdgeInsets.fromLTRB(10, 30, 0, 0),
              children: <Widget>[
                SizedBox(
                  height: 70,
                  width: 100,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _testDevices();
                    },
                    child: Text(
                      AppLocalizations.of(context)
                          .translate('installation_menu_item_test_devices'),
                      style: TextStyle(
                          fontFamily: 'Haltian Sans',
                          fontSize: 16,
                          color: HexColor("#ffffff"),
                          fontStyle: FontStyle.normal,
                          decoration: TextDecoration.none),
                    ),
                  ),
                ),
                SizedBox(
                  height: 70,
                  width: 100,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _editInstallationInfo();
                    },
                    child: Text(
                      AppLocalizations.of(context)
                          .translate('installation_menu_item_edit_info'),
                      style: TextStyle(
                          fontFamily: 'Haltian Sans',
                          fontSize: 16,
                          color: HexColor("#ffffff"),
                          fontStyle: FontStyle.normal,
                          decoration: TextDecoration.none),
                    ),
                  ),
                ),
                SizedBox(
                  height: 70,
                  width: 100,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _exportInstallationAsCSV();
                    },
                    child: Text(
                      AppLocalizations.of(context)
                          .translate('installation_menu_item_export_as_csv'),
                      style: TextStyle(
                          fontFamily: 'Haltian Sans',
                          fontSize: 16,
                          color: HexColor("#ffffff"),
                          fontStyle: FontStyle.normal,
                          decoration: TextDecoration.none),
                    ),
                  ),
                ),
                SizedBox(
                  height: 70,
                  width: 100,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _deleteInstallation();
                    },
                    child: Text(
                      AppLocalizations.of(context).translate(
                          'installation_menu_item_delete_installation'),
                      style: TextStyle(
                          fontFamily: 'Haltian Sans',
                          fontSize: 16,
                          color: HexColor("#ffffff"),
                          fontStyle: FontStyle.normal,
                          decoration: TextDecoration.none),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _listDevices() {
    if (_installations.installations[_installationIndex].devices.isEmpty) {
      return SingleChildScrollView(
        child: Container(
            padding: EdgeInsets.fromLTRB(40, 40, 40, 20),
            child: Column(children: <Widget>[
              Center(
                child: Align(
                  heightFactor: 2,
                  child: _noAddedDeviceInfo(),
                ),
              ),
              Align(
                child: Text(""),
              ),
            ])),
      );
    } else {
      return Material(
          color: HexColor("#ffffff"),
          child: InstallationDevicesListView(
              _installations.installations[_installationIndex].devices,
              (index) => _deviceSelected(index)));
    }
  }

  _editInstallationInfo() async {
    print("Edit installation info");
    final InstallationInfo installationInfo = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CreateOrEditInstallation(
              installation: _installations.installations[_installationIndex])),
    );
    if (installationInfo.name.isNotEmpty &&
        installationInfo.deploymentGroupId.isNotEmpty) {
      _installations.installations[_installationIndex] = installationInfo;
      _installations.saveInstallations();
      setState(() {});
    }
  }

  _testDevices() {
    print("Check devices");
    if (_installations.installations[_installationIndex].devices.isNotEmpty) {
      setState(() {
        _showHUD = true;
      });
      int count = 0;
      _installations.installations[_installationIndex].devices
          .forEach((device) async {
        count++;
        Map<String, dynamic> response =
            await ThingseeNetworkAPIs.nwGetDeviceMessages(device.tuid, 5);
        if (response["responseCode"] == 200) {
          AutogeneratedMessageData messages =
              AutogeneratedMessageData.fromJson(response["responseBody"]);
          if (messages.messages.isNotEmpty) {
            device.hasMessages = true;
            DateTime date = new DateTime.fromMillisecondsSinceEpoch(
                messages.messages.first.tsmTs * 1000);
            if (date != null)
              device.messagesLatestTs = date.toLocal().toIso8601String();
          }
          device.messagesCheckedTs = new DateTime.now().toIso8601String();
        }
        if (count ==
            _installations.installations[_installationIndex].devices.length)
          setState(() {
            _showHUD = false;
          });
      });
    }
  }

  _exportInstallationAsCSV() {
    print("Export installation as CSV");
    _checkFilePermission();
  }

  _deleteInstallation() {
    print("Delete installation");
    showQueryDialog(
        context,
        AppLocalizations.of(context).translate('delete_title'),
        AppLocalizations.of(context)
            .translate('confirmation_query_delete_installation_from_the_phone'),
        AppLocalizations.of(context).translate('button_delete'),
        AppLocalizations.of(context).translate('button_cancel'),
        _removeInstallationFromMemory,
        _doNothing);
  }

  _removeInstallationFromMemory() {
    Navigator.pop(context, InstallationView.INSTALLATION_DELETED);
  }

  _doNothing() {
    setState(() {
      _showHUD = false;
    });
  }

  _deviceSelected(int index) async {
    print(index);
    Device device =
        _installations.installations[_installationIndex].devices[index];
    device = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AddOrEditDeviceInstallationScreen(
                device: device,
                groupId: _installations
                    .installations[_installationIndex].deploymentGroupId,
                edit: true,
              )),
    );
    setState(() {
      if (device == null) {
        setState(() {
          _installations.installations[_installationIndex].devices
              .removeAt(index);
          _installations.saveInstallations();
          action = InstallationView.REFRESH_DEVICE_AMOUNT;
        });
      }
    });
  }

  _noAddedDeviceInfo() {
    return Column(
      children: <Widget>[
        Text(
          AppLocalizations.of(context).translate('no_devices_avail'),
          style: TextStyle(
            fontFamily: 'Haltian Sans',
            fontSize: 22,
            color: HexColor("#000000"),
            fontStyle: FontStyle.normal,
          ),
        ),
        SizedBox(
          height: 25,
          width: 25,
        ),
        Padding(
          padding: EdgeInsets.only(left: 3.0),
          child: Container(
            alignment: FractionalOffset.center,
            child: new Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  AppLocalizations.of(context)
                      .translate('no_devices_avail_select'),
                  style: TextStyle(
                    fontFamily: 'Haltian Sans',
                    fontSize: 22,
                    color: HexColor("#000000"),
                    fontStyle: FontStyle.normal,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(left: 4.0, right: 4.0),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  height: 25.0,
                  width: 25.0,
                  child: new Image.asset('assets/ts_add_white.png',
                      width: 24.0, height: 24.0),
                ),
                Text(
                  AppLocalizations.of(context)
                      .translate('no_devices_avail_to_add'),
                  style: TextStyle(
                    fontFamily: 'Haltian Sans',
                    fontSize: 22,
                    color: HexColor("#000000"),
                    fontStyle: FontStyle.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
        Text(
          AppLocalizations.of(context)
              .translate('no_devices_avail_to_add_to_installation'),
          style: TextStyle(
            fontFamily: 'Haltian Sans',
            fontSize: 22,
            color: HexColor("#000000"),
            fontStyle: FontStyle.normal,
          ),
        ),
      ],
    );
  }

  _checkCameraPermission(bool replacement) async {
    if (await Permission.camera.status != PermissionStatus.granted) {
      _requestCameraPermission(replacement);
    } else {
      _scan(replacement);
    }
  }

  _requestCameraPermission(bool replacement) async {
    if (await Permission.camera.request().isGranted) {
      _scan(replacement);
    } else {
      showInfoDialog(
          context,
          AppLocalizations.of(context).translate('error_title'),
          AppLocalizations.of(context)
              .translate('error_message_camera_permission_not_granted'),
          AppLocalizations.of(context).translate('button_close'));
    }
  }

  Future _scan(bool replacement) async {
    try {
      bool alreadyInInstallation = false;
      var barcode = await BarcodeScanner.scan();
      _qrCode = barcode.rawContent;
      List<String> tuidParts = _qrCode.split(',');
      if (tuidParts.length > 1 &&
          tuidParts[0].length == 11 &&
          tuidParts[1].length == 6) {
        String tuid = tuidParts[1] + tuidParts[0];
        _installations.installations[_installationIndex].devices
            .forEach((device) {
          if (device.tuid == tuid) {
            alreadyInInstallation = true;
          }
        });
        if (alreadyInInstallation) {
          showSimpleQueryDialog(
              context,
              AppLocalizations.of(context).translate('error_title'),
              AppLocalizations.of(context)
                  .translate('error_message_device_already_in_installation'),
              AppLocalizations.of(context).translate('button_close'),
              _doNothing);
        } else {
          setState(() {
            _showHUD = true;
          });
          DeviceInfo deviceInfo =
              await ThingseeNetworkAPIs.nwCheckDeviceInfoAndState(tuid);
          deviceInfo = await ThingseeNetworkAPIs.nwGetDeviceInstallationStatus(
              deviceInfo);
          if (deviceInfo.installationStatus == "installed" ||
              deviceInfo.installationStatus == "quarantine" ||
              deviceInfo.installationStatus == "retired") {
            showQueryDialog(
                context,
                AppLocalizations.of(context).translate('installed_title'),
                AppLocalizations.of(context).translate(
                    'confirmation_query_install_even_already_installed_at_some_point'),
                AppLocalizations.of(context).translate('button_install'),
                AppLocalizations.of(context).translate('button_cancel'),
                () => _proceedWithNewDevice(tuid),
                _doNothing);
          } else {
            _proceedWithNewDevice(tuid);
          }
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

  _proceedWithNewDevice(String tuid) async {
    setState(() {
      _showHUD = false;
    });
    Device device = new Device(tuid, null, "", "");
    device = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AddOrEditDeviceInstallationScreen(
                device: device,
                groupId: _installations
                    .installations[_installationIndex].deploymentGroupId,
                edit: false,
              )),
    );
    if (device != null) {
      setState(() {
        _installations.installations[_installationIndex].devices.add(device);
        _installations.saveInstallations();
      });
      action = InstallationView.REFRESH_DEVICE_AMOUNT;
    }
  }

  _checkFilePermission() async {
    if (await Permission.storage.status != PermissionStatus.granted) {
      _requestFilePermission();
    } else {
      _exportInstallation();
    }
  }

  _requestFilePermission() async {
    if (await Permission.storage.request().isGranted) {
      _exportInstallation();
    } else {
      showInfoDialog(
          context,
          AppLocalizations.of(context).translate('error_title'),
          AppLocalizations.of(context)
              .translate('error_message_storage_permission_not_granted'),
          AppLocalizations.of(context).translate('button_close'));
    }
  }

  _exportInstallation() async {
    StackIdentifier stack = ThingseeNetworkAPIs.getCurrentStack();
    InstallationInfo installation =
        _installations.installations[_installationIndex];
    bool containsDeviceReplacement = false;

    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd hh:mm:ss');
    String formatted = formatter.format(now) + ".csv";
    String stackName = stack.name;
    stackName.replaceAll(" ", "_");
    stackName.replaceAll("/", "_");
    stackName.replaceAll("\\", "_");
    String _logFilename = stackName + formatted;

    final _localPath = await getApplicationDocumentsDirectory();
    final file = _createFile(_localPath, _logFilename);

    installation.devices.forEach((device) {
      if (device.wasReplacedBy != null &&
          device.wasReplacedBy.isNotEmpty &&
          device.wasReplacedBy != ("-")) {
        containsDeviceReplacement = true;
      }
    });

    String title = stackName +
        "\n" +
        installation.description +
        "," +
        installation.deploymentGroupId +
        "," +
        formatter.format(now) +
        "\n";
    writeString(title, file);

    String _sensorsTitle = AppLocalizations.of(context)
            .translate('installation_export_title_dev_type') +
        "," +
        AppLocalizations.of(context)
            .translate('installation_export_title_dev_tuid') +
        "," +
        AppLocalizations.of(context)
            .translate('installation_export_title_dev_latest_event_ts') +
        "," +
        AppLocalizations.of(context)
            .translate('installation_export_title_dev_desc') +
        "\n";
    if (containsDeviceReplacement) {
      _sensorsTitle = AppLocalizations.of(context)
              .translate('installation_export_title_dev_type') +
          "," +
          AppLocalizations.of(context)
              .translate('installation_export_title_dev_tuid') +
          "," +
          AppLocalizations.of(context)
              .translate('installation_export_title_device_replaced') +
          "," +
          AppLocalizations.of(context)
              .translate('installation_export_title_dev_latest_event_ts') +
          "," +
          AppLocalizations.of(context)
              .translate('installation_export_title_dev_desc') +
          "\n";
    }
    writeString(_sensorsTitle, file);

    print("Export:" + title + _sensorsTitle);

    installation.devices.forEach((device) {
      String sensor = "";
      String type = getSensorName(device.deviceType);

      String ts = AppLocalizations.of(context).translate(
          'installation_export_title_dev_latest_event_ts_not_checked');
      if (device.messagesLatestTs.isNotEmpty) {
        ts = device.messagesLatestTs + " (UTC)";
      }

      sensor = type +
          "," +
          device.tuid +
          "," +
          ts +
          "," +
          device.description +
          "," +
          device.installationStatus +
          "\n";
      if (containsDeviceReplacement) {
        String replaceBy = "-";
        if (device.wasReplacedBy.isNotEmpty) replaceBy = device.wasReplacedBy;
        sensor = type +
            "," +
            device.tuid +
            "," +
            replaceBy +
            "," +
            ts +
            "," +
            device.description +
            "," +
            device.installationStatus +
            "\n";
      }
      writeString(sensor, file);
      print("sensor:" + sensor);
    });

    showInfoDialog(
        context,
        AppLocalizations.of(context).translate('export_title'),
        AppLocalizations.of(context).translate('installation_export_done') +
            stackName +
            _logFilename,
        AppLocalizations.of(context).translate('button_ok'));

    List<String> paths = [];
    paths.add(file.path);
    sendEmail(_logFilename, paths);
  }

  File _createFile(Directory path, String filename) {
    File file;
    String fullPathToFile = path.path + "/" + filename;
    try {
      file = File(fullPathToFile);
    } catch (error) {
      print("Oh dear!!!");
    }
    return file;
  }

  Future<void> writeString(String text, File localFile) async {
    try {
      return await localFile.writeAsString('$text', mode: FileMode.append);
    } catch (error) {
      print("Oh dear!!!");
    }
  }

  Future<void> sendEmail(String subject, List<String> attachmentPath) async {
    final Email email = Email(
      subject: subject,
      attachmentPaths: attachmentPath,
      isHTML: false,
    );

    String platformResponse;

    try {
      await FlutterEmailSender.send(email);
      platformResponse = 'success';
    } catch (error) {
      platformResponse = error.toString();
    }

    if (platformResponse != 'success') {
      showInfoDialog(
          context,
          AppLocalizations.of(context).translate('error_title'),
          AppLocalizations.of(context).translate('sending_email_failed') +
              platformResponse,
          AppLocalizations.of(context).translate('button_ok'));
    }
  }
}
