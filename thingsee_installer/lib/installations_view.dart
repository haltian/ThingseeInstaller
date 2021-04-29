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
import 'package:thingsee_installer/installations_list_view.dart';
import 'package:thingsee_installer/utilities.dart';
import 'package:thingsee_installer/app_localizations.dart';
import 'package:thingsee_installer/create_or_edit_installation.dart';
import 'package:thingsee_installer/installation_view.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:modal_progress_hud/modal_progress_hud.dart';

class InstallationsView extends StatefulWidget {
  InstallationsView();

  @override
  InstallationsViewState createState() => InstallationsViewState();
}

class InstallationsViewState extends State<InstallationsView> {
  bool _loading = true;
  Installations _installations;

  @override
  Widget build(BuildContext context) {
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
            Navigator.pop(context, -1);
          },
        ),
        title: Text(
          AppLocalizations.of(context).translate('installations_view_title'),
          style: TextStyle(fontFamily: 'Haltian Sans'),
        ),
      ),
      body:
          ModalProgressHUD(child: _loadInstallations(), inAsyncCall: _loading),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {_newInstallation()},
        child:
            Image.asset('assets/ts_add_white.png', width: 35, height: 35),
        backgroundColor: Colors.blue,
      ),
    );
  }

  _newInstallation() async {
    print("New installation");
    final InstallationInfo installationInfo = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CreateOrEditInstallation(installation: null)),
    );
    if (installationInfo.name.isNotEmpty && installationInfo.deploymentGroupId.isNotEmpty) {
      _installations.installations.add(installationInfo);
      _installations.saveInstallations();
      setState(() {
        _loading = true;
      });
      _installationSelected(_installations.installations.length - 1);
    }
  }

  _loadInstallations() {
    if (_loading) {
      _installations = new Installations();
      _installations.loadInstallations().then((value) => _loadedInstallations());
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
      if (_installations.installations.isEmpty) {
        return SingleChildScrollView(
          child: Container(
              padding: EdgeInsets.fromLTRB(40, 40, 40, 20),
              child: Column(children: <Widget>[
                Center(
                  child: Align(
                    heightFactor: 2,
                    child: _noInstallationsInfo(),
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
            child: InstallationsListView(
                _installations.installations, (index) => _installationSelected(index)));
      }
    }
  }
  _loadedInstallations() {
    setState(() {
      _loading = false;
    });
  }

  _installationSelected(int index) async {
    print(index);
    int action = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => InstallationView(installations: _installations, installationIndex : index)),
    );

    if (action == InstallationView.INSTALLATION_DELETED) {
      //Deleted
      setState(() {
        _installations.installations.removeAt(index);
        _installations.saveInstallations();
        _loading = true;
      });
    } else if (action == InstallationView.REFRESH_DEVICE_AMOUNT) {
      setState(() {
        _loading = true;
      });
    }
  }

  _noInstallationsInfo() {
    return Column(
      children: <Widget>[
        Text(
          AppLocalizations.of(context).translate('no_installations_avail'),
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
                      .translate('no_installations_avail_select'),
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
                      .translate('no_installations_avail_to_add'),
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
              .translate('no_installations_avail_to_add_to_phone'),
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
}
