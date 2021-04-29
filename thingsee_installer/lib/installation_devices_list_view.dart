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
import 'package:thingsee_installer/data_classes.dart';

class InstallationDevicesListView extends StatelessWidget {
  final List<Device> devices;
  final Function onTapped;

  InstallationDevicesListView(this.devices, this.onTapped);

  Widget _buildDeviceItem(BuildContext context, int index) {
    SensorType type = getSensorType(devices[index].tuid);
    String name = getSensorName(type);
    AssetImage nokStatus = new AssetImage('assets/ts_checked_nok.png');
    AssetImage okStatus = new AssetImage('assets/ts_checked_ok.png');

    if (devices[index].messagesCheckedTs.isEmpty) {
      return FlatButtonWithRipple(leading: getSensorImage(this.devices[index].tuid), title: this.devices[index].tuid, subtitle: name, onTap: () => onTapped(index),);
    } else {
      DateTime tsDate = DateTime.parse(devices[index].messagesLatestTs);
      DateTime now = DateTime.now();
      if (devices[index].hasMessages && now.toUtc().microsecondsSinceEpoch - tsDate.toUtc().microsecondsSinceEpoch < 43200000) { //43 200 000ms => 12h
        return FlatButtonWithRipple(
          leading: getSensorImage(this.devices[index].tuid),
          title: this.devices[index].tuid,
          subtitle: name,
          trailingIcon: okStatus,
          onTap: () => onTapped(index),);
      } else {
        return FlatButtonWithRipple(
          leading: getSensorImage(this.devices[index].tuid),
          title: this.devices[index].tuid,
          subtitle: name,
          trailingIcon: nokStatus,
          onTap: () => onTapped(index),);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: _buildDeviceItem,
      itemCount: devices.length,
    );
  }
}