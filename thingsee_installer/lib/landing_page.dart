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

import 'package:thingsee_installer/groups_list_view.dart';
import 'package:thingsee_installer/thingsee_network_apis.dart';
import 'package:thingsee_installer/check_device_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'create_or_edit_deployment_group.dart';

import 'dart:async';

import 'package:package_info/package_info.dart';

import 'package:thingsee_installer/app_localizations.dart';
import 'package:thingsee_installer/utilities.dart';

import 'package:thingsee_installer/stacks_screen.dart';
import 'package:thingsee_installer/deployment_group_view.dart';
import 'package:thingsee_installer/installations_view.dart';

class LandingPage extends StatefulWidget {
  LandingPageState createState() => LandingPageState();
}

class LandingPageState extends State<LandingPage> {
  var _endScaffoldKey = new GlobalKey<ScaffoldState>();
  var _didLogin = false;

  bool _loading = false;
  bool _didLoadData = false;

  String _version = "";
  String _buildNumber = "";

  bool _noStacks = true;
  String _stackName = "";

  List<DeploymentGroupInfo> _groups = [];

  _getGroupsResponse(List<DeploymentGroupInfo> groups) async {
    _groups = groups;
    setState(() {
      _loading = false;
      _didLoadData = true;
      _didLogin = true;
    });
  }

  _doWeHaveStacks(bool doWeHaveStacks) {
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      _version = packageInfo.version;
      _buildNumber = packageInfo.buildNumber;
    });
    if (doWeHaveStacks) {
      _noStacks = false;
      StackIdentifier stack = ThingseeNetworkAPIs.getCurrentStack();
      _stackName = stack.name;
      if (!_loading) {
        setState(() {
          _loading = true;
          ThingseeNetworkAPIs.nwGetDeploymentGroups().then(_getGroupsResponse);
        });
      }
    } else {
      setState(() {
        _loading = false;
        _didLoadData = false;
        _didLogin = true;
      });
    }
  }

  _checkForStacks() {
    ThingseeNetworkAPIs.doWeHaveStacksDefined().then(_doWeHaveStacks);
    return Text(AppLocalizations.of(context).translate('info_loading_data'),
        style: TextStyle(fontFamily: 'Haltian Sans', fontSize: 28));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          if (_endScaffoldKey.currentState.isDrawerOpen ||
              _endScaffoldKey.currentState.isEndDrawerOpen) {
            Navigator.pop(context);
            return Future.value(false);
          } else {
            showQueryDialog(
                context,
                AppLocalizations.of(context).translate('query_exit_app_title'),
                AppLocalizations.of(context)
                    .translate('query_exit_app_message'),
                AppLocalizations.of(context).translate('button_ok'),
                AppLocalizations.of(context).translate('button_cancel'),
                _exitApp,
                _doNothing);
            return Future.value(false); // if true allow back else block it
          }
        },
        child: DefaultTabController(
          length: 2,
          child: Scaffold(
            key: _endScaffoldKey,
            appBar: AppBar(
              backgroundColor: HexColor("#1f87d8"),
              elevation: 0.0,
              leading: Builder(
                  builder: (context) => Container(
                        child: IconButton(
                          icon: new SvgPicture.asset(
                            'assets/ts_menu.svg',
                            color: HexColor("#ffffff"),
                          ),
                          onPressed: () => Scaffold.of(context).openDrawer(),
                        ),
                      )),
              title: Text(_stackName, style: TextStyle(color: HexColor("#ffffff"), fontFamily: 'Haltian Sans', fontSize: 24)),
              actions: <Widget>[
                Container(
                    child: IconButton(
                      icon: new SvgPicture.asset(
                        'assets/ts_tools.svg',
                        color: HexColor("#ffffff"),
                      ),
                      onPressed: _toolsSelected,
                    ))
              ],
            ),
            body: ModalProgressHUD(
                child: _contentWidget(), inAsyncCall: _loading),
            drawer: _accountMenu(),
            endDrawer: _toolMenu(),
          ),
        ));
  }

  _contentWidget() {
    return _didLogin
        ? _wasDataLoaded()
        : Container(
            color: HexColor("#ffffff"),
            constraints: BoxConstraints.expand(),
            child: Align(alignment: Alignment.center, child: _checkForStacks()),
          );
  }

  _wasDataLoaded() {
    if (_didLoadData) {
      return _mainWidget();
    } else {
      if (_noStacks == false) {
        return Container(
            color: HexColor("#ffffff"),
            constraints: BoxConstraints.expand(),
            child: Align(
                alignment: Alignment.center,
                child: Text(
                  AppLocalizations.of(context).translate('info_no_data'),
                  style: TextStyle(fontFamily: 'Haltian Sans', fontSize: 28),
                )));
      } else {
        return _noStacksWidget();
      }
    }
  }

  _mainWidget() {
    return Container(
        color: HexColor("#ffffff"),
        constraints: BoxConstraints.expand(),
        child:
            Align(alignment: Alignment.center, child: _addDeploymentGroup()));
  }

  _addDeploymentGroup() {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed:  () => _deploymentGroupCreate(),
        child:
            Image.asset('assets/ts_add_white.png', width: 35, height: 35),
        backgroundColor: Colors.blue,
      ),
      body: _listGroups(),
    );
  }

  _deploymentGroupCreate() async {
    DeploymentGroupInfo newGroup = new DeploymentGroupInfo("", "");
    newGroup = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateOrEditDeploymentGroup(group: newGroup, countries: null,)),
    );
    if (newGroup.groupId.isNotEmpty) {
      setState(() {
        _groups.add(newGroup);
      });
      _groupSelected(_groups.indexOf(newGroup));
    }
  }

  _listGroups() {
    return Material(
        color: HexColor("#ffffff"),
        child: GroupsListView(_groups, (index) => _groupSelected(index)));
  }

  _groupSelected(int index) async {
    final int action = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DeploymentGroupView(deploymentGroupInfo : _groups[index])),
    );
    if (action == DeploymentGroupView.DEPLOYMENT_GROUP_DELETED) {
      setState(() {
        _groups.removeAt(index);
      });
    } else if (action == DeploymentGroupView.DEPLOYMENT_GROUP_EDITED) {
      setState(() {
        _didLogin = false;
        _loading = false;
        _didLoadData = false;
      });
    }
  }

  _exitApp() {
    SystemNavigator.pop();
  }

  _doNothing() {}

  _toolsSelected() {
    if (_noStacks == false) {
      _endScaffoldKey.currentState.openEndDrawer();
    } else {
      showInfoDialog(
          context,
          AppLocalizations.of(context).translate('info_title'),
          AppLocalizations.of(context).translate('info_no_stack_defined'),
          AppLocalizations.of(context).translate('button_ok'));
    }
  }

  _accountMenu() {
    return Drawer(
      child: Container(
        color: HexColor("#1f87d8"),
        child: Column(children: <Widget>[
          Expanded(
              child: ListView(padding: EdgeInsets.zero, children: <Widget>[
            Padding(
                padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: ListTile(
                    title: Text(
                        AppLocalizations.of(context)
                            .translate('account_menu_header'),
                        style: TextStyle(
                            fontFamily: 'Haltian Sans',
                            fontSize: 28,
                            color: HexColor("#ffffff"),
                            fontStyle: FontStyle.normal,
                            decoration: TextDecoration.none)),
                    onTap: () {
                      //Do nothing.
                    })),
            ListTile(
              title: Text(
                AppLocalizations.of(context)
                    .translate('account_menu_item_stacks'),
                style: TextStyle(
                    fontFamily: 'Haltian Sans',
                    fontSize: 18,
                    color: HexColor("#ffffff"),
                    fontStyle: FontStyle.normal,
                    decoration: TextDecoration.none),
              ),
              onTap: () {
                Navigator.pop(context);
                _navigateToStackManagement(context);
              },
            ),
            ListTile(
              title: Text(
                AppLocalizations.of(context)
                    .translate('account_menu_item_help'),
                style: TextStyle(
                    fontFamily: 'Haltian Sans',
                    fontSize: 18,
                    color: HexColor("#ffffff"),
                    fontStyle: FontStyle.normal,
                    decoration: TextDecoration.none),
              ),
              onTap: () {
                Navigator.pop(context);
                launch('https://support.haltian.com');
              },
            ),
            Divider(
                height: 3.0,
                color: HexColor("#ffffff"),
                indent: 15,
                endIndent: 15),
            ListTile(
              title: Text(
                AppLocalizations.of(context)
                    .translate('account_menu_item_about'),
                style: TextStyle(
                    fontFamily: 'Haltian Sans',
                    fontSize: 18,
                    color: HexColor("#ffffff"),
                    fontStyle: FontStyle.normal,
                    decoration: TextDecoration.none),
              ),
              onTap: () {
                Navigator.pop(context);
                showInfoDialog(
                    context,
                    AppLocalizations.of(context).translate('about_title'),
                    AppLocalizations.of(context)
                            .translate('about_app_message') +
                        _version +
                        '.' +
                        _buildNumber,
                    AppLocalizations.of(context).translate('button_close'));
              },
            )
          ])),
          Expanded(
              child: Stack(children: <Widget>[
            Align(
              alignment: FractionalOffset.bottomLeft,
              child: Padding(
                padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                child: SizedBox(
                  width: 100,
                  height: 60,
                  child: GestureDetector(
                    onTap: () {
                      _launchURL();
                    },
                    child: new SvgPicture.asset(
                      'assets/haltian_logo.svg',
                      color: HexColor("#ffffff"),
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: FractionalOffset.bottomRight,
              child: SizedBox(
                  width: 130,
                  height: 220,
                  child: Image(
                      image: AssetImage(
                          'assets/ts_splash_screen_pattern.png'))),
            ),
          ]))
        ]),
      ),
    );
  }

  _navigateToStackManagement(BuildContext context) async {
    final bool refresh = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StacksScreen()),
    );

    if (await ThingseeNetworkAPIs.doWeHaveStacksDefined()) {
      _noStacks = false;
    } else {
      _noStacks = true;
    }

    if (refresh) {
      setState(() {
        _didLogin = false;
        _loading = false;
      });
    }
  }

  _toolMenu() {
    return SizedBox(
      width: 100,
      child: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: Container(
          color: HexColor("#1f87d8"),
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: <Widget>[
              SizedBox(
                height: 60,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                  child: Container(
                    child: Text(
                      AppLocalizations.of(context)
                          .translate('tools_menu_header'),
                      style: TextStyle(
                          fontFamily: 'Haltian Sans',
                          fontSize: 28,
                          color: HexColor("#ffffff"),
                          fontStyle: FontStyle.normal,
                          decoration: TextDecoration.none),
                    ),
                    alignment: Alignment.center,
                  ),
                ),
              ),
              SizedBox(
                height: 110,
                width: 100,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CheckDeviceScreen()),
                    );
                  },
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                            alignment: Alignment.center,
                            child: SizedBox(
                              width: 50,
                              height: 50,
                              child: Container(
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.all(1),
                                  child: SizedBox(
                                    width: 30,
                                    height: 30,
                                    child: Image(
                                      image: AssetImage(
                                          'assets/ts_check_device_black.png'),
                                      color: HexColor("#ffffff"),
                                    ),
                                  ),
                                  decoration: new BoxDecoration(
                                    color: HexColor("#1f87d8"),
                                    shape: BoxShape.circle,
                                  )),
                            ),
                            decoration: new BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            )),
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
                        ),
                        Text(
                          AppLocalizations.of(context)
                              .translate('tools_menu_item_check_device'),
                          style: TextStyle(
                              fontFamily: 'Haltian Sans',
                              fontSize: 18,
                              color: HexColor("#ffffff"),
                              fontStyle: FontStyle.normal,
                              decoration: TextDecoration.none),
                        ),
                      ]),
                ),
              ),
              SizedBox(
                height: 110,
                width: 100,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => InstallationsView()),
                    );
                  },
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                            alignment: Alignment.center,
                            child: SizedBox(
                              width: 50,
                              height: 50,
                              child: Container(
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.all(1),
                                  child: SizedBox(
                                    width: 30,
                                    height: 30,
                                    child: Image(
                                      image: AssetImage(
                                          'assets/ts_report_black.png'),
                                      color: HexColor("#ffffff"),
                                    ),
                                  ),
                                  decoration: new BoxDecoration(
                                    color: HexColor("#1f87d8"),
                                    shape: BoxShape.circle,
                                  )),
                            ),
                            decoration: new BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            )),
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
                        ),
                        Text(
                          AppLocalizations.of(context)
                              .translate('tools_menu_item_installations'),
                          style: TextStyle(
                              fontFamily: 'Haltian Sans',
                              fontSize: 18,
                              color: HexColor("#ffffff"),
                              fontStyle: FontStyle.normal,
                              decoration: TextDecoration.none),
                        ),
                      ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _noStacksWidget() {
    TextStyle textStyle1 = TextStyle(
        fontFamily: 'Haltian Sans', fontSize: 26, color: Colors.black);
    TextStyle textStyle2 = TextStyle(
        fontFamily: 'Haltian Sans', fontSize: 18, color: Colors.black);

    return Container(
        color: Colors.white,
        constraints: BoxConstraints.expand(),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(40.0),
          physics: NeverScrollableScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(0, 80, 0, 10),
                child: Text(
                  AppLocalizations.of(context).translate('first_use_info_1'),
                  style: textStyle1,
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 20, 0, 10),
                child: Text(
                  AppLocalizations.of(context).translate('first_use_info_2'),
                  style: textStyle1,
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 30, 0, 10),
                child: Row(children: <Widget>[
                  Container(
                      color: HexColor("#1f87d8"),
                      child: SizedBox(
                          width: 50,
                          height: 50,
                          child: Align(
                              alignment: FractionalOffset.center,
                              child: Text(
                                '1',
                                style: TextStyle(
                                    fontFamily: 'Haltian Sans',
                                    fontSize: 30,
                                    color: HexColor("#ffffff"),
                                    fontStyle: FontStyle.normal,
                                    decoration: TextDecoration.none),
                              )))),
                  Padding(
                    padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                    child: Text(
                      AppLocalizations.of(context)
                          .translate('first_use_info_2_1'),
                      style: textStyle2,
                    ),
                  )
                ]),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: Row(children: <Widget>[
                  Container(
                      color: HexColor("#1f87d8"),
                      child: SizedBox(
                          width: 50,
                          height: 50,
                          child: Align(
                              alignment: FractionalOffset.center,
                              child: Text(
                                '2',
                                style: TextStyle(
                                    fontFamily: 'Haltian Sans',
                                    fontSize: 30,
                                    color: HexColor("#ffffff"),
                                    fontStyle: FontStyle.normal,
                                    decoration: TextDecoration.none),
                              )))),
                  Padding(
                    padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                    child: Text(
                      AppLocalizations.of(context)
                          .translate('first_use_info_2_2'),
                      style: textStyle2,
                    ),
                  ),
                  Icon(
                    Icons.menu,
                    color: Colors.black,
                    size: 30.0,
                  )
                ]),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: Row(children: <Widget>[
                  Container(
                      color: HexColor("#1f87d8"),
                      child: SizedBox(
                          width: 50,
                          height: 50,
                          child: Align(
                              alignment: FractionalOffset.center,
                              child: Text(
                                '3',
                                style: TextStyle(
                                    fontFamily: 'Haltian Sans',
                                    fontSize: 30,
                                    color: HexColor("#ffffff"),
                                    fontStyle: FontStyle.normal,
                                    decoration: TextDecoration.none),
                              )))),
                  Padding(
                    padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                    child: Text(
                      AppLocalizations.of(context)
                          .translate('first_use_info_2_3'),
                      style: textStyle2,
                    ),
                  )
                ]),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: Row(children: <Widget>[
                  Container(
                      color: HexColor("#1f87d8"),
                      child: SizedBox(
                          width: 50,
                          height: 50,
                          child: Align(
                              alignment: FractionalOffset.center,
                              child: Text(
                                '4',
                                style: TextStyle(
                                    fontFamily: 'Haltian Sans',
                                    fontSize: 30,
                                    color: HexColor("#ffffff"),
                                    fontStyle: FontStyle.normal,
                                    decoration: TextDecoration.none),
                              )))),
                  Padding(
                    padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                    child: Text(
                      AppLocalizations.of(context)
                          .translate('first_use_info_2_4'),
                      style: textStyle2,
                    ),
                  )
                ]),
              ),
            ],
          ),
        ));
  }

  _launchURL() async {
    const url = 'https://haltian.com';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
