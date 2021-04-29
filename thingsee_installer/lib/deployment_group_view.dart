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
import 'package:thingsee_installer/thingsee_network_apis.dart';
import 'package:thingsee_installer/utilities.dart';
import 'package:thingsee_installer/app_localizations.dart';
import 'package:thingsee_installer/deploy_or_edit_device_screen.dart';
import 'package:thingsee_installer/devices_list_view.dart';
import 'package:thingsee_installer/check_device_sensor_screen.dart';
import 'package:thingsee_installer/create_or_edit_deployment_group.dart';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:country_io/country_io.dart';

class DeploymentGroupView extends StatefulWidget {
  DeploymentGroupView({Key key, this.deploymentGroupInfo}) : super(key: key);
  final DeploymentGroupInfo deploymentGroupInfo;

  static const int DEPLOYMENT_GROUP_NO_CHANGE = 0;
  static const int DEPLOYMENT_GROUP_EDITED = 1;
  static const int DEPLOYMENT_GROUP_DELETED = 2;

  @override
  DeploymentGroupViewState createState() =>
      DeploymentGroupViewState(deploymentGroupInfo);
}

class DeploymentGroupViewState extends State<DeploymentGroupView> {
  DeploymentGroupInfo _deploymentGroupInfo;

  var _endScaffoldKey = new GlobalKey<ScaffoldState>();
  bool _loading = true;
  List<String> _devices = [];
  String _qrCode = "";
  Country _countries;
  int _operation = DeploymentGroupView.DEPLOYMENT_GROUP_NO_CHANGE;

  DeploymentGroupViewState(DeploymentGroupInfo deploymentGroupInfo) {
    _deploymentGroupInfo = deploymentGroupInfo;
  }

  @override
  Widget build(BuildContext context) {
    bool _searching = false;
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
            Navigator.pop(context, _operation);
          },
        ),
        title: Center(
            child: SearchBar(
          isSearching: _searching,
          deploymentGroupInfo: _deploymentGroupInfo,
        )),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              setState(() {
                _searching = !_searching;
              });
            },
            tooltip: AppLocalizations.of(context).translate('tool_tip_search'),
          ),
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
      body: ModalProgressHUD(child: _checkDevices(), inAsyncCall: _loading),
      endDrawer: _deploymentGroupViewMenu(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {_checkPermission()},
        child:
            Image.asset('assets/ts_add_white.png', width: 35, height: 35),
        backgroundColor: Colors.blue,
      ),
    );
  }

  _menuSelected() {
    _endScaffoldKey.currentState.openEndDrawer();
  }

  _deploymentGroupViewMenu() {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
        child: SizedBox(
          width: 130,
          height: 140,
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
                      _editDeploymentGroup();
                    },
                    child: Text(
                      AppLocalizations.of(context)
                          .translate('groups_menu_item_edit_group'),
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
                      _removeDeploymentGroup();
                    },
                    child: Text(
                      AppLocalizations.of(context)
                          .translate('groups_menu_item_remove_group'),
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

  _editDeploymentGroup() async {
    print("_editDeploymentGroup");
    final DeploymentGroupInfo newGroup = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              CreateOrEditDeploymentGroup(group: _deploymentGroupInfo, countries: _countries)),
    );

    if (newGroup.groupId.isNotEmpty) {
      _deploymentGroupInfo = newGroup;
      _operation = DeploymentGroupView.DEPLOYMENT_GROUP_EDITED;
      setState(() {});
    }
  }

  _removeDeploymentGroup() {
    print("_removeDeploymentGroup");
    showQueryDialog(
        context,
        AppLocalizations.of(context).translate('remove_title'),
        AppLocalizations.of(context)
            .translate('confirmation_query_remove_deployment_group'),
        AppLocalizations.of(context).translate('button_remove'),
        AppLocalizations.of(context).translate('button_cancel'),
        _removeGroup,
        _doNothing);
  }

  _removeGroup() async {
    setState(() {
      _loading = true;
    });
    bool deleted = await ThingseeNetworkAPIs.nwDeleteDeploymentGroup(
        _deploymentGroupInfo.groupId);
    if (deleted) {
      _operation = DeploymentGroupView.DEPLOYMENT_GROUP_DELETED;
      Navigator.pop(context, _operation);
    } else {
      showSimpleQueryDialog(
          context,
          AppLocalizations.of(context).translate('error_title'),
          AppLocalizations.of(context)
              .translate('error_message_something_went_wrong'),
          AppLocalizations.of(context).translate('button_close'),
          _doNothing);
    }
  }

  _doNothing() {}

  _checkDevices() {
    if (_loading) {
      ThingseeNetworkAPIs.nwGetDevicesInDeploymentGroup(
              _deploymentGroupInfo.groupId)
          .then(_doWeHaveDevices);
      return Container(
        color: HexColor("#ffffff"),
        constraints: BoxConstraints.expand(),
        child: Align(
            alignment: Alignment.center,
            child: Text(
                AppLocalizations.of(context).translate('info_loading_data'),
                style: TextStyle(fontFamily: 'Haltian Sans', fontSize: 28))),
      );
    } else {
      if (_devices == null || _devices.isEmpty) {
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
            child:
                DevicesListView(_devices, (index) => _deviceSelected(index)));
      }
    }
  }

  _deviceSelected(int index) async {
    print(index);
    String tuid = _devices[index];
    final bool removed = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CheckDeviceSensorScreen(tuid: tuid)),
    );
    if (removed) {
      setState(() {
        _devices.removeAt(index);
      });
    }
  }

  _doWeHaveDevices(List<String> devices) {
    if (devices != null)
      _devices = devices;
    else
      _devices = [];
    Generator().generate().then((Map<String, Map<String, String>> result) {
      _countries = new Country(result);
    });
    //Refresh UI
    setState(() {
      _loading = false;
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
              .translate('no_devices_avail_to_add_to_dg'),
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
        final bool refresh = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => DeployOrEditDeviceScreen(tuid: tuid, groupid: _deploymentGroupInfo.groupId)),
        );
        if (refresh) {
          setState(() {
            _loading = true;
          });
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

///Searchbar Animation:

class SearchBar extends StatelessWidget {
  final bool isSearching;
  final DeploymentGroupInfo deploymentGroupInfo;
  SearchBar({@required this.isSearching, this.deploymentGroupInfo});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimateExpansion(
          animate: !isSearching,
          axisAlignment: 1.0,
          child: Text(deploymentGroupInfo.groupId),
        ),
        AnimateExpansion(
          animate: isSearching,
          axisAlignment: -1.0,
          child: Search(),
        ),
      ],
    );
  }
}

class Search extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TextField(
      autofocus: false,
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: AppLocalizations.of(context).translate('hint_text_search'),
        hintStyle: TextStyle(
          fontSize: 20,
          color: Colors.white.withOpacity(.4),
        ),
      ),
    );
  }
}

class AnimateExpansion extends StatefulWidget {
  final Widget child;
  final bool animate;
  final double axisAlignment;
  AnimateExpansion({
    this.animate = false,
    this.axisAlignment,
    this.child,
  });

  @override
  _AnimateExpansionState createState() => _AnimateExpansionState();
}

class _AnimateExpansionState extends State<AnimateExpansion>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> _animation;

  void prepareAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 350),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInCubic,
      reverseCurve: Curves.easeOutCubic,
    );
  }

  void _toggle() {
    if (widget.animate) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  void initState() {
    super.initState();
    prepareAnimations();
    _toggle();
  }

  @override
  void didUpdateWidget(AnimateExpansion oldWidget) {
    super.didUpdateWidget(oldWidget);
    _toggle();
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
        axis: Axis.horizontal,
        axisAlignment: -1.0,
        sizeFactor: _animation,
        child: widget.child);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

///
