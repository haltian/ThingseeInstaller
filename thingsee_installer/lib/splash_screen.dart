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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:thingsee_installer/app_localizations.dart';
import 'package:thingsee_installer/landing_page.dart';
import 'package:thingsee_installer/utilities.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _movedOn = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Timer(Duration(seconds: 3), () async {
      if (!_movedOn) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LandingPage()),
        );
        _movedOn = true;
      }
    });
    return Container(
        color: HexColor("#1f87d8"),
        constraints: BoxConstraints.expand(),
        child: Padding(
            padding: EdgeInsets.fromLTRB(40, 20, 0, 0),
            child: Column(children: <Widget>[
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      width: 130,
                      height: 100,
                      child: new SvgPicture.asset(
                        'assets/ts_thingsee_logo_white.svg',
                        color: HexColor("#ffffff"),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Column(children: <Widget>[
                        Text(
                          AppLocalizations.of(context)
                              .translate('login_screen_title'),
                          style: TextStyle(
                              fontFamily: 'Haltian Sans',
                              fontSize: 40,
                              color: HexColor("#ffffff"),
                              fontStyle: FontStyle.normal,
                              decoration: TextDecoration.none),
                        ),
                      ]),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Stack(
                  children: <Widget>[
                    Align(
                      alignment: FractionalOffset.bottomLeft,
                      child: SizedBox(
                        width: 100,
                        height: 130,
                        child: new SvgPicture.asset(
                          'assets/haltian_logo.svg',
                          color: HexColor("#ffffff"),
                        ),
                      ),
                    ),
                    Align(
                      alignment: FractionalOffset.bottomRight,
                      child: SizedBox(
                          width: 140,
                          height: 230,
                          child: Image(
                              image: AssetImage(
                                  'assets/ts_splash_screen_pattern.png'))),
                    ),
                  ],
                ),
              ),
            ])));
  }
}
