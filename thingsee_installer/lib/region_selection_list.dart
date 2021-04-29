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

import 'package:thingsee_installer/utilities.dart';

class RegionListView extends StatelessWidget {
  final Country country;
  final Function onTap;

  RegionListView(this.country, this.onTap);

  Widget _buildCountryName (BuildContext context, int index) {

    String countryName = this.country.countryCodes.keys.elementAt(index);
    String countryCode = this.country.countryCodes[countryName];
    bool selected = false;

    if (countryCode == this.country.getSelectedCountryCode())
      selected = true;


    return Column(children: <Widget>[

      CustomInkWell(
        child: _checkListTile(selected, index, countryName, countryCode),
        onTap: () => onTap(countryName, countryCode),

      ),

      Divider(
      color: Colors.black,
      indent: 80,
      ),
    ]);
  }

  _checkListTile(bool selected, int index, String countryName, String countryCode) {
      return ListTile(
          leading: _checkForLead(selected, index),
          title: Text(countryCode + " - " + countryName,
              style: new TextStyle(
                  fontFamily: 'Haltian Sans',
                  fontSize: 20,
                  color: HexColor("#000000"),
                  fontStyle: FontStyle.normal,
                  decoration: TextDecoration.none),
          ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemBuilder: _buildCountryName, itemCount: country.countryCodes.length);
  }


_checkForLead(bool showLead, int index) {
  Color indicatorColor = Colors.grey;
  Color indicatorColor2 = Colors.white;
  if (showLead) {
    indicatorColor = HexColor("#1f87d8");
    indicatorColor2 = HexColor("#1f87d8");
  }
  return GestureDetector(
      onTap: () {
        this.onTap(index);
      },
      child: Stack(children: <Widget>[
        new SizedBox(
            width: 40,
            height: 40,
            child: new Container(
            )),
        new SizedBox(
            width: 40,
            height: 40,
            child: Padding(
                padding: EdgeInsets.all(10),
                child: new Container(
                    width: 20,
                    height: 20,
                    decoration: new BoxDecoration(
                      color: indicatorColor,
                      shape: BoxShape.circle,
                    )))),
        new SizedBox(
            width: 40,
            height: 40,
            child: Padding(
                padding: EdgeInsets.all(11),
                child: new Container(
                    width: 20,
                    height: 20,
                    decoration: new BoxDecoration(
                      color: indicatorColor2,
                      shape: BoxShape.circle,
                    ))))
      ]));
}

}
