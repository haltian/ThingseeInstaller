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

import 'package:thingsee_installer/thingsee_network_apis.dart';
import 'package:thingsee_installer/utilities.dart';
import 'package:thingsee_installer/stack_view.dart';
import 'package:thingsee_installer/stacks_list_view.dart';
import 'package:thingsee_installer/stack_add_widget.dart';
import 'package:thingsee_installer/app_localizations.dart';

import 'package:modal_progress_hud/modal_progress_hud.dart';

class StacksScreen extends StatefulWidget {
  StacksScreen({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _StacksScreenState createState() => _StacksScreenState();
}

class _StacksScreenState extends State<StacksScreen> {
  var _endScaffoldKey = new GlobalKey<ScaffoldState>();

  bool _refreshNeeded = false;

  bool _didLoad = false;
  bool _loading = true;

  List<StackIdentifier> _currentStacks;

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
            elevation: 0.0,
            leading: IconButton(
              icon: new SvgPicture.asset(
                'assets/ts_arrow.svg',
                color: HexColor("#ffffff"),
              ),
              onPressed: () {
                Navigator.pop(context, _refreshNeeded);
              },
            ),
            title: Text(
              AppLocalizations.of(context)
                  .translate('stack_manager_header_title'),
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
          body:
              ModalProgressHUD(child: _contentWidget(), inAsyncCall: _loading),
          endDrawer: _stacksMenu(),
        ));
  }

  _contentWidget() {
    if (_didLoad && _currentStacks.length > 0) {
      return _listStacks();
    } else {
      if (!_didLoad) {
        return Container(
          color: HexColor("#ffffff"),
          constraints: BoxConstraints.expand(),
          child: Align(alignment: Alignment.center, child: _checkForStacks()),
        );
      } else {
        return Container(
          padding: EdgeInsets.fromLTRB(40, 80, 40, 0),
            color: HexColor("#ffffff"),
            constraints: BoxConstraints.expand(),
            child: Align(
                alignment: Alignment.topCenter,
                child: Text(
                  AppLocalizations.of(context).translate('no_stacks'),
                  style: TextStyle(fontFamily: 'Haltian Sans', fontSize: 28),
                )));
      }
    }
  }

  _checkForStacks() {
    _loading = true;
    ThingseeNetworkAPIs.getStacks().then(_continueWithUI);
    return Text(AppLocalizations.of(context).translate('loading_stacks'),
        style: TextStyle(fontFamily: 'Haltian Sans', fontSize: 28));
  }

  _listStacks() {
    return Material(
        color: HexColor("#ffffff"),
        child: StacksListView(
            _currentStacks,
            (index) => _stackSelected(index),
            (index) => _stackSelectedAsActive(index)));
  }

  _stackSelected(int index) async {
    print("_stackSelected: " + index.toString());
    final bool refresh = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              StackView(stackIdentifier: _currentStacks[index])),
    );

    if (refresh) {
      //Refresh stack list
      setState(() {
        _refreshNeeded = true;
        _loading = false;
        _didLoad = false;
        _currentStacks.clear();
      });
    }
  }

  _stackSelectedAsActive(int index) {
    print("_stackSelectedAsActive: " + index.toString());
    setState(() {
      _refreshNeeded = true;
      for (StackIdentifier identy in _currentStacks) {
        identy.isActive = false;
      }
      StackIdentifier prof = _currentStacks[index];
      prof.isActive = true;
      ThingseeNetworkAPIs.setActiveStack(prof.id);
    });
  }

  _menuSelected() {
    _endScaffoldKey.currentState.openEndDrawer();
  }

  _stacksMenu() {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: EdgeInsets.fromLTRB(0, 60, 0, 0),
        child: SizedBox(
          width: 110,
          height: 70,
          child: Container(
            color: HexColor("#1f87d8"),
            child: ListView(
              // Important: Remove any padding from the ListView.
              padding: EdgeInsets.fromLTRB(20, 25, 0, 0),
              children: <Widget>[
                SizedBox(
                  height: 70,
                  width: 100,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _newStack();
                    },
                    child: Text(
                      AppLocalizations.of(context)
                          .translate('stacks_menu_item_new_stack'),
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

  _newStack() async {
    final bool refresh = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddStackWidget()),
    );

    if (refresh) {
      //Refresh stack list
      setState(() {
        _refreshNeeded = true;
        _loading = false;
        _didLoad = false;
        _currentStacks.clear();
      });
    }
  }

  _continueWithUI(List<StackIdentifier> response) {
    _currentStacks = response;
    setState(() {
      _loading = false;
      _didLoad = true;
    });
  }
}
