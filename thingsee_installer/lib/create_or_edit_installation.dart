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

import 'package:thingsee_installer/data_classes.dart';
import 'package:thingsee_installer/select_group_view.dart';

import 'utilities.dart';
import 'app_localizations.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CreateOrEditInstallation extends StatefulWidget {
  CreateOrEditInstallation({Key key, this.installation}) : super(key: key);
  final InstallationInfo installation;

  @override
  _CreateOrEditInstallationState createState() =>
      _CreateOrEditInstallationState(this.installation);
}

class _CreateOrEditInstallationState extends State<CreateOrEditInstallation> {
  InstallationInfo _installation = new InstallationInfo("", "", "");
  String _groupId = "";
  String _screenHeader;
  bool _editing = false;

  _CreateOrEditInstallationState(InstallationInfo installation) {
    if (installation != null) this._installation = installation;
  }

  @override
  Widget build(BuildContext context) {
    if (_installation.name.isNotEmpty) {
      _screenHeader = _installation.name;
      controllerForName.text = _installation.name;
      controllerForDesc.text = _installation.description;
      _groupId = _installation.deploymentGroupId;
      _editing = true;
    } else {
      _screenHeader =
          AppLocalizations.of(context).translate('new_installation');
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: HexColor("#1f87d8"),
        leading: IconButton(
          icon: new SvgPicture.asset(
            'assets/ts_arrow.svg',
            color: HexColor("#ffffff"),
          ),
          onPressed: () {
            Navigator.pop(context, new InstallationInfo("", "", ""));
          },
        ),
        title: Text(
          _screenHeader,
          style: TextStyle(fontFamily: 'Haltian Sans'),
        ),
      ),
      body: _contentWidget(),
    );
  }

  _contentWidget() {
    return SingleChildScrollView(
        child: Container(
            padding: EdgeInsets.fromLTRB(40, 40, 40, 40),
            child: Column(
              children: <Widget>[
                Align(
                  alignment: Alignment(-0.60, -0.90),
                  child: Text(
                    AppLocalizations.of(context)
                        .translate('create_new_installation_info'),
                    style: TextStyle(
                      fontFamily: 'Haltian Sans',
                      fontSize: 20,
                      color: HexColor("#000000"),
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                ),
                Align(
                  child: _defineNameWidget(),
                ),
                Align(
                  child: _deploymentGroupName(),
                ),
                Align(
                  child: _defineDescriptionWidget(),
                ),
                Align(
                  child: _saveChanges(),
                ),
              ],
            )));
  }

  final controllerForName = TextEditingController();
  final controllerForDesc = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    controllerForName.dispose();
    controllerForDesc.dispose();
    super.dispose();
  }

  _defineNameWidget() {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 25.0,
        ),
        Row(
          children: <Widget>[
            SizedBox(
              height: 10.0,
            ),
            Text(
              AppLocalizations.of(context)
                  .translate('deployment_group_new_name'),
              textAlign: TextAlign.left,
              style: TextStyle(
                fontFamily: 'Haltian Sans',
                fontSize: 20,
                color: HexColor("#000000"),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Container(
          width: double.infinity,
          child: TextFormField(
            maxLength: 50,
            decoration: InputDecoration(counterText: ''),
            controller: controllerForName,
            style: TextStyle(
              fontFamily: 'Haltian Sans',
              fontSize: 20,
              color: HexColor("#000000"),
              fontStyle: FontStyle.normal,
            ),
          ),
        ),
      ],
    );
  }

  _defineDescriptionWidget() {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 25.0,
        ),
        Row(
          children: <Widget>[
            SizedBox(
              height: 10.0,
            ),
            Text(
              AppLocalizations.of(context)
                  .translate('deployment_group_new_description'),
              textAlign: TextAlign.left,
              style: TextStyle(
                fontFamily: 'Haltian Sans',
                fontSize: 20,
                color: HexColor("#000000"),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Container(
          width: double.infinity,
          child: TextFormField(
            maxLength: 50,
            decoration: InputDecoration(counterText: ''),
            controller: controllerForDesc,
            style: TextStyle(
              fontFamily: 'Haltian Sans',
              fontSize: 20,
              color: HexColor("#000000"),
              fontStyle: FontStyle.normal,
            ),
          ),
        ),
      ],
    );
  }

  _deploymentGroupName() {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 45.0,
        ),
        Row(
          children: <Widget>[
            SizedBox(
              height: 10.0,
            ),
            Text(
              AppLocalizations.of(context).translate('deployment_group_name'),
              textAlign: TextAlign.left,
              style: TextStyle(
                fontFamily: 'Haltian Sans',
                fontSize: 20,
                color: HexColor("#000000"),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            if (!_editing) _selectDeploymentGroup();
          },
          child: Row(
            children: <Widget>[
              _groupSelection(),
            ],
          ),
        ),
        Divider(
          color: Colors.grey,
          thickness: 1,
        ),
      ],
    );
  }

  _selectDeploymentGroup() async {
    String groupId = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SelectGroupView()),
    );
    if (groupId.isNotEmpty) {
      setState(() {
        _groupId = groupId;
      });
    }
  }

  _groupSelection() {
    if (_groupId == null || _groupId.isEmpty) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Text(
            AppLocalizations.of(context).translate('select_group'),
            style: TextStyle(
              fontFamily: 'Haltian Sans',
              fontSize: 20,
              color: HexColor("#000000"),
              fontStyle: FontStyle.normal,
            ),
          ),
        ],
      );
    } else {
      return Expanded(
        child: Text(
          _groupId,
          style: TextStyle(
            fontFamily: 'Haltian Sans',
            fontSize: 20,
            color: HexColor("#000000"),
            fontStyle: FontStyle.normal,
          ),
        ),
      );
    }
  }

  _saveChanges() {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 15.0,
        ),
        SizedBox(
          width: 200.0, // match_parent
          child: TextButton(
            style: getFlatButton(
                Colors.white, HexColor("#1f87d8"), EdgeInsets.all(8.0)),
            onPressed: () => _createOrUpdateInstallationInfoAndExit(),
            child: _getButtonText(),
          ),
        ),
      ],
    );
  }

  _getButtonText() {
    if (_installation.name.isNotEmpty)
      return Text(
        AppLocalizations.of(context).translate('button_save'),
        style: TextStyle(fontSize: 20.0),
      );
    else
      return Text(
        AppLocalizations.of(context).translate('button_create'),
        style: TextStyle(fontSize: 20.0),
      );
  }

  _createOrUpdateInstallationInfoAndExit() {
    if (_groupId.isEmpty || controllerForName.text.isEmpty) {
      showSimpleQueryDialog(
          context,
          AppLocalizations.of(context).translate('error_title'),
          AppLocalizations.of(context)
              .translate('error_message_installation_info_missing'),
          AppLocalizations.of(context).translate('button_ok'),
          _doNothing);
    } else {
      _installation.name = controllerForName.text;
      _installation.deploymentGroupId = _groupId;
      _installation.description = controllerForDesc.text;
      Navigator.pop(context, _installation);
    }
  }

  _doNothing() {}
}
