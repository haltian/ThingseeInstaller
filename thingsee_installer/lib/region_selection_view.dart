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

import 'package:thingsee_installer/utilities.dart';
import 'package:country_io/country_io.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:thingsee_installer/region_selection_list.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class RegionSelectionView extends StatefulWidget {
  RegionSelectionView();
  @override
  _RegionSelectionView createState() =>
      _RegionSelectionView();
}
class _RegionSelectionView extends State<RegionSelectionView> {
  Country _countries;
  bool _loading = true;
  bool _loaded = false;
  String selectedCC;

  @override
  Widget build(BuildContext context) {

    _loadingCC();


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
            Navigator.pop(context, null);
          },
        ),
        title: Text(
          "Select Region",
          style: TextStyle(fontFamily: 'Haltian Sans'),
        ),
        bottom: CustomSearchBar(),
      ),
      body: ModalProgressHUD(child: _contentWidget(), inAsyncCall: _loading),
    );
  }

  _loadingCC() async {
    final storage = new FlutterSecureStorage();
    selectedCC = await storage.read(key: Country.countryCodeKey);
  }


  _contentWidget() {
    if (_loaded) {
      return Material(
        child: RegionListView(_countries, (countryName, countryCode) => _countryCodeSelected(countryName, countryCode)),

              );
    } else {
      return Container(
        color: HexColor("#ffffff"),
        constraints: BoxConstraints.expand(),
        child: Align(alignment: Alignment.center, child: _loadCountryInfo()),
      );
    }
  }

  _countryCodeSelected(String countryName, String countryCode) {
    Map<String, String> countryCodes = {};
    countryCodes[countryName] = countryCode;
    _saveCountrySelected(countryCode, countryName);
      Navigator.pop(context, countryCodes);
  }

    _saveCountrySelected(String countryCode, String countryName) {

    final storage = new FlutterSecureStorage();
    storage.write(key: Country.countryCodeKey, value: countryCode);
    storage.write(key: Country.countryNameKey, value: countryName);
  }



  _loadCountryInfo() {
    Generator().generate().then((Map<String, Map<String, String>> result) {
      setState(() {
        _countries = new Country(result);
        _countries.setSelectedCountryCode(selectedCC);
        _loading = false;
        _loaded = true;
      });
    });
  }
}

class CustomSearchBar extends StatelessWidget with PreferredSizeWidget {
  @override
  final Size preferredSize = Size.fromHeight(75.0);
  CustomSearchBar();
  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: TextEditingController(),
                            cursorColor: Colors.blue,
                            style: TextStyle(
                                height: 1.5), //increases the height of cursor
                            decoration: InputDecoration(
                              hintText: 'Search ...',
                              filled: true,
                              fillColor: Colors.white,
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              contentPadding: const EdgeInsets.all(10.0),

                              suffixIcon: new GestureDetector(
                                onTap: () {},
                                child: new Container(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: new SvgPicture.asset(
                                      'assets/ts_remove_m_black.svg',
                                    color: HexColor("#808080"),
                                    height: 5,
                                    width: 5,
                                  ),
                                ),
                              ),

                            ),
                            //onChanged: onItemChanged, -> you need to handle this via Function(x) or similar
                          ),
                        ),
                        ButtonTheme(
                          minWidth: 10.0,

                          child: TextButton (
                            style: getFlatButton(Colors.white, HexColor("#1f87d8"), EdgeInsets.symmetric(vertical: 5)),
                            onPressed: () => {},
                            child: new SvgPicture.asset(
                              'assets/ts_remove_m_black.svg',
                              color: HexColor("#FFFFFF"),
                              height: 30,
                              width: 30,
                            ),
                          ),

                        ),
                      ])),
            ],
          ),
        ],
      )
    ]);
  }
}


