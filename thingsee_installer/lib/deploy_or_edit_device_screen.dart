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

import 'package:thingsee_installer/app_localizations.dart';
import 'package:thingsee_installer/utilities.dart';
import 'package:thingsee_installer/thingsee_network_apis.dart';

import 'package:modal_progress_hud/modal_progress_hud.dart';

class DeployOrEditDeviceScreen extends StatefulWidget {
  DeployOrEditDeviceScreen({Key key, this.tuid, this.groupid}) : super(key: key);
  final String tuid;
  final String groupid;

  @override
  _DeployOrEditDeviceScreenState createState() =>
      _DeployOrEditDeviceScreenState(tuid, groupid);
}

class _DeployOrEditDeviceScreenState extends State<DeployOrEditDeviceScreen> {
  var _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool _loading = true;
  bool _loaded = false;
  // Sensor information
  String tuid = "-";
  String timestamp = "-";
  String battLevel = "-";
  String deviceType = "-";
  SensorType sensorType = SensorType.sensorTypeUnknown;

  String groupid;

  List<String> _status = [];
  String installationStatus;

  _DeployOrEditDeviceScreenState(String tuid, String groupid) {
    this.tuid = tuid;
    this.groupid = groupid;
  }

  @override
  Widget build(BuildContext context) {
    if (_status.isEmpty) {
      _status.add(AppLocalizations.of(context)
          .translate('activator_installation_status_installed'));
      _status.add(AppLocalizations.of(context)
          .translate('activator_installation_status_new'));
      _status.add(AppLocalizations.of(context)
          .translate('activator_installation_status_quarantine'));
      _status.add(AppLocalizations.of(context)
          .translate('activator_installation_status_retired'));
      _status.add(AppLocalizations.of(context)
          .translate('activator_installation_status_uninstalled'));
    }

    return WillPopScope(
        onWillPop: () {
          Navigator.pop(context, false);
          return Future.value(false); // if true allow back else block it
        },
        child: Scaffold(
          key: _scaffoldKey,
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
              AppLocalizations.of(context)
                  .translate('activator_sensor_view_title'),
              style: TextStyle(fontFamily: 'Haltian Sans'),
            ),
          ),
          body:
              ModalProgressHUD(child: _contentWidget(), inAsyncCall: _loading),
        ));
  }

  _contentWidget() {
    if (_loaded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
              padding: EdgeInsets.fromLTRB(4, 25, 0, 0),
              child: Row(
                children: <Widget>[
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          child: SizedBox(
                            width: 110,
                            height: 110,
                            child: Image(image: getSensorImage(tuid)),
                          ),
                        ),
                      ]),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        AppLocalizations.of(context)
                            .translate('activator_sensor_tuid'),
                        style: TextStyle(
                            fontFamily: 'Haltian Sans',
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        tuid,
                        style:
                            TextStyle(fontFamily: 'Haltian Sans', fontSize: 24),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                      ),
                      Text(
                        AppLocalizations.of(context)
                            .translate('activator_sensor_type'),
                        style: TextStyle(
                            fontFamily: 'Haltian Sans',
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        getSensorName(sensorType),
                        style:
                            TextStyle(fontFamily: 'Haltian Sans', fontSize: 24),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                      ),
                    ],
                  )
                ],
              )),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 5, 0, 0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    AppLocalizations.of(context).translate(
                        'activator_sensor_installation_status_edit_title'),
                    style: TextStyle(
                        fontFamily: 'Haltian Sans',
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  DropdownButtonHideUnderline(
                    child: DropdownButton(
                      isExpanded: true,
                      hint: Text(AppLocalizations.of(context).translate(
                          'activator_sensor_choose_installation_status')),
                      style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Haltian Sans',
                          color: HexColor("#000000"),
                          fontStyle:
                              FontStyle.normal), // Not necessary for Option 1
                      icon: Icon(
                        Icons.arrow_drop_down,
                        size: 35.0,
                        color: Colors.blue,
                      ),
                      value: installationStatus,
                      onChanged: (newValue) {
                        setState(() {
                          installationStatus = newValue;
                        });
                      },
                      items: _status.map((location) {
                        return DropdownMenuItem(
                          child: new Text(
                            location,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontFamily: 'Haltian Sans',
                                fontSize: 20,
                                color: HexColor("#000000"),
                                fontStyle: FontStyle.normal),
                          ),
                          value: location,
                        );
                      }).toList(),
                    ),
                  ),
                ]),
          ),
          Expanded(
            child: Column(
              children: <Widget>[],
            ),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 40),
              child: ButtonTheme(
                minWidth: 300.0,
                child: TextButton(
                  style: getFlatButton(
                      Colors.white, HexColor("#1f87d8"), EdgeInsets.all(10.0)),
                  onPressed: () => {_saveDeviceStatus()},
                  child: Text(
                    AppLocalizations.of(context).translate('button_save'),
                    style: TextStyle(
                        fontFamily: 'Haltian Sans',
                        color: Colors.white,
                        fontSize: 20),
                  ),
                ),
              ),
            ),
          ]),
        ],
      );
    } else {
      return Container(
        color: HexColor("#ffffff"),
        constraints: BoxConstraints.expand(),
        child: Align(alignment: Alignment.center, child: _loadThingInfo()),
      );
    }
  }

  _loadThingInfo() {
    ThingseeNetworkAPIs.nwCheckDeviceInfoAndState(tuid).then(_thingInfoLoaded);
  }

  _thingInfoLoaded(DeviceInfo deviceInfo) {
    print(deviceInfo);
    if (deviceInfo.error.isEmpty) {
      battLevel = deviceInfo.battLvl;
      timestamp = deviceInfo.timestamp;
      sensorType = getSensorType(deviceInfo.tuid);
      _loadThingInstallationInfo(deviceInfo);
    } else if (deviceInfo.error.contains("404")) {
      //Sensor not found from this stack
      Navigator.pop(context, true);
    } else {
      showSimpleQueryDialog(
          context,
          AppLocalizations.of(context).translate('error_title'),
          AppLocalizations.of(context)
              .translate('error_message_something_went_wrong'),
          AppLocalizations.of(context).translate('button_close'),
          _popOutFromWidget);
    }
  }

  _popOutFromWidget() {
    Navigator.pop(context, false);
  }

  _loadThingInstallationInfo(DeviceInfo deviceInfo) {
    ThingseeNetworkAPIs.nwGetDeviceInstallationStatus(deviceInfo)
        .then(_thingInstallationInfoLoaded);
  }

  _thingInstallationInfoLoaded(DeviceInfo deviceInfo) {
    print(deviceInfo.toString());
    if (deviceInfo.error.isEmpty) {
      setState(() {
        if (deviceInfo.installationStatus == "installed") {
          installationStatus = AppLocalizations.of(context)
              .translate('activator_installation_status_installed');
        } else if (deviceInfo.installationStatus == "new") {
          installationStatus = AppLocalizations.of(context)
              .translate('activator_installation_status_new');
        } else if (deviceInfo.installationStatus == "quarantine") {
          installationStatus = AppLocalizations.of(context)
              .translate('activator_installation_status_quarantine');
        } else if (deviceInfo.installationStatus == "retired") {
          installationStatus = AppLocalizations.of(context)
              .translate('activator_installation_status_retired');
        } else {
          installationStatus = AppLocalizations.of(context)
              .translate('activator_installation_status_uninstalled');
        }
        _loaded = true;
        _loading = false;
      });
    } else if (deviceInfo.error.contains("404")) {
      //Sensor not found from this stack
      Navigator.pop(context, true);
    } else {
      showSimpleQueryDialog(
          context,
          AppLocalizations.of(context).translate('error_title'),
          AppLocalizations.of(context)
              .translate('error_message_something_went_wrong'),
          AppLocalizations.of(context).translate('button_close'),
          _popOutFromWidget);
    }
  }

  _saveDeviceStatus() async {
    String status = "installed";
    setState(() {
      if (installationStatus == AppLocalizations.of(context)
          .translate('activator_installation_status_installed'))
        status = "installed";
      else if (installationStatus == AppLocalizations.of(context)
          .translate('activator_installation_status_new'))
        status = "new";
      else if (installationStatus == AppLocalizations.of(context)
          .translate('activator_installation_status_quarantine'))
        status = "quarantine";
      else if (installationStatus == AppLocalizations.of(context)
          .translate('activator_installation_status_retired'))
        status = "retired";
      else if (installationStatus == AppLocalizations.of(context)
          .translate('activator_installation_status_uninstalled'))
        status = "uninstalled";
      _loaded = true;
      _loading = true;
    });

    var result = await ThingseeNetworkAPIs.nwSetDeviceInstallationStatus(
        tuid, status);
    print("Response code: " + result["responseCode"].toString());
    print(result);

    if (groupid != null) {
      result = await ThingseeNetworkAPIs.nwSetDeviceDeploymentGroup(
          tuid, groupid);
      print("Response code: " + result["responseCode"].toString());
      print(result);
    }

    Navigator.pop(context, true);
  }
}
