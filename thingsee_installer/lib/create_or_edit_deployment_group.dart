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

import 'region_selection_view.dart';
import 'thingsee_network_apis.dart';
import 'utilities.dart';
import 'app_localizations.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CreateOrEditDeploymentGroup extends StatefulWidget {
  CreateOrEditDeploymentGroup({Key key, this.group, this.countries}) : super(key: key);
  final DeploymentGroupInfo group;
  final Country countries;

  @override
  _CreateOrEditDeploymentGroupState createState() =>
      _CreateOrEditDeploymentGroupState(this.group, this.countries);
}

class _CreateOrEditDeploymentGroupState
    extends State<CreateOrEditDeploymentGroup> {
  DeploymentGroupInfo _group;
  Country _countries;
  String _groupId;
  String _screenHeader;

  String countryName;
  String countryCode;

  List<String> _environment = []; // Option 2
  String _selectedLocation; // Option 2

  String holder = '';

  bool _loading = false;

  _CreateOrEditDeploymentGroupState(DeploymentGroupInfo group, Country countries) {
    this._group = group;
    this._countries = countries;
  }

  @override
  Widget build(BuildContext context) {
    bool groupDecoded = false;
    if (_group.groupId.isNotEmpty && _groupId == null) {
      _screenHeader =
          AppLocalizations.of(context).translate('deployment_group_edit');
      if (_group.groupId.startsWith("pr") ||
          _group.groupId.startsWith("rd") ||
          _group.groupId.startsWith("dm") ||
          _group.groupId.startsWith("un")) {
        if (_group.groupId.substring(4, 6) == "00") {
          groupDecoded = true;
          controllerForName.text = _group.groupId.substring(6);
          holder = _group.groupId.substring(0, 2);
          countryCode = _group.groupId.substring(2, 4);
          if (_countries != null && _countries.countryCodes.isNotEmpty) {
            countryName = _countries.getCountryName(countryCode);
          }
          _groupId = _group.groupId;
        }
      }
      if (!groupDecoded) {
        controllerForName.text = _group.groupId;
      }
      controllerForDesc.text = _group.desciption;
      _editDescriptionEnabled = false;
    } else {
      _screenHeader =
          AppLocalizations.of(context).translate('deployment_group_create');
    }

    if (_environment.isEmpty) {
      _environment.add(AppLocalizations.of(context)
          .translate('deployment_group_choose_env_pr'));
      _environment.add(AppLocalizations.of(context)
          .translate('deployment_group_choose_env_rd'));
      _environment.add(AppLocalizations.of(context)
          .translate('deployment_group_choose_env_dm'));
      _environment.add(AppLocalizations.of(context)
          .translate('deployment_group_choose_env_un'));
    }

    controllerForName.addListener(() {
      setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCCAndName());

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
            DeploymentGroupInfo deploymentGroupInfo =
                new DeploymentGroupInfo("", "");
            Navigator.pop(context, deploymentGroupInfo);
          },
        ),
        title: Text(
          _screenHeader,
          style: TextStyle(fontFamily: 'Haltian Sans'),
        ),
      ),
      body: ModalProgressHUD(child: _contentWidget(), inAsyncCall: _loading),
    );
  }

  _contentWidget() {
    return SingleChildScrollView(
      child: Container(
          padding: EdgeInsets.fromLTRB(40, 40, 40, 20),
          child: Column(
            children: <Widget>[
              Align(
                alignment: Alignment(-0.60, -0.90),
                child: Text(
                  AppLocalizations.of(context)
                      .translate('deployment_group_create_info'),
                  style: TextStyle(
                    fontFamily: 'Haltian Sans',
                    fontSize: 20,
                    color: HexColor("#000000"),
                    fontStyle: FontStyle.normal,
                  ),
                ),
              ),
              Align(
                child: _selectEnvironmentWidget(),
              ),
              Align(
                child: _selectCountryWidget(context),
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
                child: _saveGroup(),
              ),
            ],
          )),
    );
  }

  _loadCCAndName() async {
    final storage = new FlutterSecureStorage();
    if (countryCode == null)
      countryCode = await storage.read(key: Country.countryCodeKey);
    if (countryName == null)
      countryName = await storage.read(key: Country.countryNameKey);
    setState(() {
      if (countryName == null || countryCode == null) {
        countryName = null;
        countryCode = null;
      }
    });
  }

  // Deployment group name: Display Environment
  _envSelected() {
    if (_selectedLocation == null && holder.isEmpty) {
      return _envDPG();
    } else {
      return _envDisplay();
    }
  }

  _envDisplay() {
    return Row(
      children: <Widget>[
        SizedBox(
          height: 25.0,
        ),
        Text(
          '$holder',
          style: TextStyle(
            fontFamily: 'Haltian Sans',
            fontSize: 20,
            color: HexColor("#000000"),
            fontStyle: FontStyle.normal,
          ),
        ),
      ],
    );
  }

  _envDPG() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        SizedBox(
          width: 5.0,
          height: 25.0,
        ),
        boxPlaceholder,
        SizedBox(
          width: 5.0,
          height: 25.0,
        ),
        boxPlaceholder,
        SizedBox(
          width: 5.0,
          height: 25.0,
        ),
      ],
    );
  }

  _selectEnvironmentWidget() {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 20.0,
        ),
        DropdownButtonHideUnderline(
          child: DropdownButton(
            isExpanded: true,
            hint: Text(AppLocalizations.of(context)
                .translate('deployment_group_choose_env')),
            style: TextStyle(
                fontSize: 18,
                fontFamily: 'Haltian Sans',
                color: HexColor("#000000"),
                fontWeight: FontWeight.bold), // Not necessary for Option 1
            icon: Icon(
              Icons.arrow_drop_down,
              size: 35.0,
              color: Colors.blue,
            ),
            value: _selectedLocation,
            onChanged: (newValue) {
              setState(() {
                _selectedLocation = newValue;
                holder = _selectedLocation.substring(0, 2);
              });
            },
            items: _environment.map((location) {
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
        Divider(
          color: Colors.grey,
          thickness: 1,
        ),
      ],
    );
  }

  var boxPlaceholder = Row(
    children: [
      SizedBox(
        width: 25.0,
        height: 25.0,
        child: const DecoratedBox(
          decoration: const BoxDecoration(color: Colors.blue),
        ),
      ),
    ],
  );

  _selectCountryWidget(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 15.0,
        ),
        Row(
          children: <Widget>[
            SizedBox(
              height: 50.0,
            ),
            Text(
              AppLocalizations.of(context)
                  .translate('deployment_group_select_region'),
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
            _newCountry(context);
          },
          child: Row(
            children: <Widget>[
              _countrySelection(),
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

  _newCountry(context) async {
    final Map<String, String> countryCodes = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegionSelectionView()),
    );
    if (countryCodes != null) {
      setState(() {
        countryCode = countryCodes.values.elementAt(0);
        countryName = countryCodes.keys.elementAt(0);
      });
    }
  }

  _countrySelection() {
    if (countryName == null && countryCode == null) {
      return _countryCodePH();
    } else {
      return _countryChoice();
    }
  }

  _countryCodePH() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        boxPlaceholder,
        SizedBox(
          width: 5.0,
          height: 25.0,
        ),
        boxPlaceholder,
        SizedBox(
          width: 10.0,
          height: 25.0,
        ),
        Text(
          AppLocalizations.of(context)
              .translate('deployment_group_selected_country'),
          style: TextStyle(
            fontFamily: 'Haltian Sans',
            fontSize: 20,
            color: HexColor("#000000"),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  _countryChoice() {
    return Expanded(
      child: Text(
        countryCode.toUpperCase() + " - " + countryName,
        style: TextStyle(
          fontFamily: 'Haltian Sans',
          fontSize: 20,
          color: HexColor("#000000"),
          fontStyle: FontStyle.normal,
        ),
      ),
    );
  }

  //TextField

  final controllerForName = TextEditingController();
  final controllerForDesc = TextEditingController();
  bool _editDescriptionEnabled = true;

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
            inputFormatters: [
              new FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9]")),
            ],
            maxLength: 25,
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
            enabled: _editDescriptionEnabled,
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

  // Deployment group name: Country code

  _countryCodeDisplay() {
    if (countryName == null && countryCode == null) {
      return _countryCodeDPG();
    } else {
      return _countryCodeChoice();
    }
  }

  _countryCodeDPG() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        SizedBox(
          width: 5.0,
          height: 25.0,
        ),
        boxPlaceholder,
        SizedBox(
          width: 5.0,
          height: 25.0,
        ),
        boxPlaceholder,
        SizedBox(
          width: 5.0,
          height: 25.0,
        ),
      ],
    );
  }

  _countryCodeChoice() {
    return Row(
      children: <Widget>[
        Text(
          countryCode.toLowerCase(),
          style: TextStyle(
            fontFamily: 'Haltian Sans',
            fontSize: 20,
            color: HexColor("#000000"),
            fontStyle: FontStyle.normal,
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
        Row(
          children: <Widget>[
            SizedBox(
              height: 80.0,
            ),
            Row(
              children: <Widget>[
                _envSelected(),
              ],
            ),
            SizedBox(
              width: 5.0,
              height: 25.0,
            ),
            Row(
              children: <Widget>[
                _countryCodeDisplay(),
              ],
            ),
            SizedBox(
              width: 5.0,
              height: 25.0,
            ),
            Text(
              '00',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontFamily: 'Haltian Sans',
                fontSize: 20,
                color: HexColor("#000000"),
                fontWeight: FontWeight.normal,
              ),
            ),
            SizedBox(
              width: 5.0,
              height: 25.0,
            ),
            Expanded(
                child: Text(
              controllerForName.text,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              maxLines: 1,
              style: TextStyle(
                fontFamily: 'Haltian Sans',
                fontSize: 20,
                color: HexColor("#000000"),
                fontStyle: FontStyle.normal,
              ),
            )),
          ],
        ),
      ],
    );
  }

  _saveGroup() {
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
            onPressed: () => _addOrSaveGroupAndExit(),
            child: Text(
              AppLocalizations.of(context).translate('button_save'),
              style: TextStyle(fontSize: 20.0),
            ),
          ),
        ),
      ],
    );
  }

  _addOrSaveGroupAndExit() {
    if (countryCode.isEmpty ||
        controllerForName.text.isEmpty ||
        holder.isEmpty) {
      showSimpleQueryDialog(
          context,
          AppLocalizations.of(context).translate('error_title'),
          AppLocalizations.of(context)
              .translate('error_message_group_info_missing'),
          AppLocalizations.of(context).translate('button_ok'),
          _doNothing);
    } else {
      _groupId = holder + countryCode + "00" + controllerForName.text;
      _groupId = _groupId.toLowerCase();
      if (_group.groupId.isNotEmpty && _groupId == _group.groupId) {
        _doNothing();
        Navigator.pop(context, _group);
      } else {
        _loading = true;
        setState(() {});
        ThingseeNetworkAPIs.nwGetDeploymentGroups().then(_getGroupsResponse);
      }
    }
  }

  _getGroupsResponse(List<DeploymentGroupInfo> groups) async {
    List<DeploymentGroupInfo> _groups = groups;
    bool found = false;
    _groups.forEach((group) {
      if (group.groupId == _groupId) {
        found = true;
        showSimpleQueryDialog(
            context,
            AppLocalizations.of(context).translate('error_title'),
            AppLocalizations.of(context)
                .translate('error_message_group_already_exists'),
            AppLocalizations.of(context).translate('button_ok'),
            _doNothing);
      }
    });
    if (!found) {
      if (_group.groupId.isEmpty) {
        DeploymentGroupInfo deploymentGroupInfo =
            new DeploymentGroupInfo(_groupId, controllerForDesc.text);
        Map<String, dynamic> codedResponse =
            await ThingseeNetworkAPIs.nwCreateDeploymentGroup(
                deploymentGroupInfo.groupId, deploymentGroupInfo.desciption);
        if (codedResponse["responseCode"] == 200) {
          //Created, pop back
          _doNothing();
          Navigator.pop(context, deploymentGroupInfo);
        } else {
          showSimpleQueryDialog(
              context,
              AppLocalizations.of(context).translate('error_title'),
              AppLocalizations.of(context)
                  .translate('error_message_something_went_wrong'),
              AppLocalizations.of(context).translate('button_ok'),
              _doNothing);
        }
      } else {
        Map<String, dynamic> codedResponse =
            await ThingseeNetworkAPIs.nwRenameDeploymentGroup(
                _group.groupId, _groupId);
        if (codedResponse["responseCode"] == 200) {
          //Created, pop back
          _doNothing();
          _group.groupId = _groupId;
          _group.desciption = controllerForDesc.text;
          Navigator.pop(context, _group);
        } else {
          showSimpleQueryDialog(
              context,
              AppLocalizations.of(context).translate('error_title'),
              AppLocalizations.of(context)
                  .translate('error_message_something_went_wrong'),
              AppLocalizations.of(context).translate('button_ok'),
              _doNothing);
        }
      }
    } else {
      _doNothing();
    }
  }

  _doNothing() {
    _loading = false;
    setState(() {});
  }
}
