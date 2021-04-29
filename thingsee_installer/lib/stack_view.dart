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
import 'package:thingsee_installer/app_localizations.dart';

class StackView extends StatefulWidget {
  StackView({Key key, this.stackIdentifier}) : super(key: key);
  final StackIdentifier stackIdentifier;

  @override
  StackViewState createState() => StackViewState(stackIdentifier);
}

class StackViewState extends State<StackView> {
  var _endScaffoldKey = new GlobalKey<ScaffoldState>();
  StackIdentifier stackIdentifier;

  StackViewState(StackIdentifier stackIdentifier) {
    this.stackIdentifier = stackIdentifier;
  }

  @override
  Widget build(BuildContext context) {
    bool _refreshNeeded = true;

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
              Navigator.pop(context, _refreshNeeded);
            },
          ),
          title: Text(
            stackIdentifier.name,
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
        body: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
          children: <Widget>[
            /*SizedBox(
              height: 60,
              child: Container(
                padding: EdgeInsets.fromLTRB(10, 0, 0, 5),
                alignment: Alignment.bottomLeft,
                color: HexColor("#ececec"),
                child: Text(
                  AppLocalizations.of(context).translate('stack_info_header'),
                  style: TextStyle(
                      fontFamily: 'Haltian Sans',
                      fontSize: 20,
                      color: Colors.black,
                      fontStyle: FontStyle.normal,
                      decoration: TextDecoration.none),
                ),
              ),
            ),*/
            SizedBox(
              height: 50,
              child: Container(
                padding: EdgeInsets.fromLTRB(15, 0, 0, 5),
                alignment: Alignment.bottomLeft,
                child: Text(
                  AppLocalizations.of(context)
                          .translate('stack_info_client_id') +
                      stackIdentifier.clientId,
                  style: TextStyle(
                      fontFamily: 'Haltian Sans',
                      fontSize: 20,
                      color: Colors.black,
                      fontStyle: FontStyle.normal,
                      decoration: TextDecoration.none),
                ),
              ),
            ),
          ],
        ),
        endDrawer: _stacksMenu(),
      ),
    );
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
          width: 140,
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
                      _removeStack();
                    },
                    child: Text(
                      AppLocalizations.of(context)
                          .translate('stacks_menu_item_remove_stack'),
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

  _removeStack() {
    showQueryDialog(
        context,
        AppLocalizations.of(context).translate('stacks_query_remove_title'),
        AppLocalizations.of(context).translate('stacks_query_remove_message'),
        AppLocalizations.of(context).translate('button_remove'),
        AppLocalizations.of(context).translate('button_cancel'),
        _removeStackPermanently,
        _cancelRemoveStack);
  }

  _removeStackPermanently() {
    print("Remove stack");
    ThingseeNetworkAPIs.removeStack(stackIdentifier.id);
    Navigator.pop(context, true);
  }

  _cancelRemoveStack() {
    print("Removal aborted");
  }
}
