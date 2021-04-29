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

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'create_or_edit_deployment_group.dart';

import 'package:thingsee_installer/app_localizations.dart';
import 'package:thingsee_installer/utilities.dart';

class SelectGroupView extends StatefulWidget {
  SelectGroupViewState createState() => SelectGroupViewState();
}

class SelectGroupViewState extends State<SelectGroupView> {
  bool _loading = true;
  bool _didLoadData = false;

  List<DeploymentGroupInfo> _groups = [];

  _getGroupsResponse(List<DeploymentGroupInfo> groups) async {
    _groups = groups;
    setState(() {
      _loading = false;
      _didLoadData = true;
    });
  }

  _loadGroups() {
    ThingseeNetworkAPIs.nwGetDeploymentGroups().then(_getGroupsResponse);
    return Text(AppLocalizations.of(context).translate('info_loading_data'),
        style: TextStyle(fontFamily: 'Haltian Sans', fontSize: 28));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: HexColor("#1f87d8"),
        elevation: 0.0,
        leading: IconButton(
          icon: new SvgPicture.asset(
            'assets/ts_arrow.svg',
            color: HexColor("#ffffff"),
          ),
          onPressed: () {
            Navigator.pop(context, null);
          },
        ),
        title: Text(
          AppLocalizations.of(context).translate('select_group_view_title'),
          style: TextStyle(fontFamily: 'Haltian Sans'),
        ),
      ),
      body: ModalProgressHUD(child: _contentWidget(), inAsyncCall: _loading),
    );
  }

  _contentWidget() {
    if (_didLoadData == false)
      return _loadGroups();
    else
      return _mainWidget();
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
        onPressed: () => _deploymentGroupCreate(),
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
      MaterialPageRoute(
          builder: (context) => CreateOrEditDeploymentGroup(group: newGroup, countries: null,)),
    );
    if (newGroup.groupId.isNotEmpty) {
      _groups.add(newGroup);
      _groupSelected(_groups.indexOf(newGroup));
    }
  }

  _listGroups() {
    return Material(
        color: HexColor("#ffffff"),
        child: GroupsListView(_groups, (index) => _groupSelected(index)));
  }

  _groupSelected(int index) async {
    Navigator.pop(context, _groups[index].groupId);
  }
}
