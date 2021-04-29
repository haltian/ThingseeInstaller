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

import 'package:thingsee_installer/thingsee_network_apis.dart';
import 'package:thingsee_installer/utilities.dart';

class StacksListView extends StatelessWidget {
  final List<StackIdentifier> _profiles;
  final Function onTapped;
  final Function onTappedSetActive;

  StacksListView(this._profiles, this.onTapped, this.onTappedSetActive);

  Widget _buildWorkorderItem(BuildContext context, int index) {
    return FlatButtonWithRippleIndicatorAndArrow(
        showLead: this._profiles[index].isActive,
        title: this._profiles[index].name,
        subtitle: this._profiles[index].clientId,
        onTap: () => onTapped(index),
    onTapLead: () => onTappedSetActive(index),);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: _buildWorkorderItem,
      itemCount: _profiles.length,
    );
  }
}