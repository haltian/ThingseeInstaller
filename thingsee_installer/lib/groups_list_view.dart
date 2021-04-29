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

import 'package:thingsee_installer/thingsee_network_apis.dart';
import 'package:flutter/material.dart';

import 'package:thingsee_installer/utilities.dart';
import 'package:thingsee_installer/app_localizations.dart';

class GroupsListView extends StatelessWidget {
  final List<DeploymentGroupInfo> groups;
  final Function onTapped;

  GroupsListView(this.groups, this.onTapped);

  Widget _buildGroupItem(BuildContext context, int index) {
    String description = this.groups[index].desciption;
    if (description.isEmpty)
      description = AppLocalizations.of(context).translate('no_description');
    return FlatButtonWithRipple(
      leading: AssetImage('assets/ts_work_order_black.png'),
      title: this.groups[index].groupId,
      subtitle: description,
      onTap: () => onTapped(index),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: _buildGroupItem,
      itemCount: groups.length,
    );
  }
}
