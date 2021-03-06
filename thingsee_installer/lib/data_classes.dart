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

import 'dart:convert';
import 'package:thingsee_installer/utilities.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AutogeneratedMessageData {
  List<Message> messages = [];

  AutogeneratedMessageData({this.messages});

  AutogeneratedMessageData.fromJson(String jsonString) {
    var _json = json.decode(jsonString);
    if (_json['data'] != null) {
      messages = [];
      _json['data'].forEach((v) {
        messages.add(new Message.fromJson(v));
      });
    }
  }
}

class Message {
  int tsmId;
  int tsmTs;
  String name = "";

  Message({this.tsmId, this.tsmTs, this.name});

  Message.fromJson(Map<String, dynamic> json) {
    if (json['tsmId'] != null) tsmId = json['tsmId'];
    if (json['tsmTs'] != null) tsmTs = json['tsmTs'];

    if (tsmId != null) {
      if (tsmId == 17100) {
        name = "Distance: ";
        name += json['dist'].toString();
      } else if (tsmId == 1110) {
        name = "Battery level: ";
        name += json['batl'].toString();
        name += "%";
      } else if (tsmId == 1202) {
        name = "RSSI: ";
        name += json['rssi'].toString();
      } else if (tsmId == 13102) {
        name = "Count: ";
        name += json['count'].toString();
      } else if (tsmId == 1113 || tsmId == 18101) {
        name = "Temperature: ";
        name += json['temp'].toString();
      } else if (tsmId == 1220 ||
          tsmId == 1313 ||
          tsmId == 1221 ||
          tsmId == 11311 ||
          tsmId == 1000 ||
          tsmId == 1400) {
        name = "System message ";
      } else if (tsmId == 1312) {
        name = "SW version message";
      } else if (tsmId == 1111) {
        name = "Accelerometer - x:";
        name += json['accx'].toString();
        name += " y:";
        name += json['accy'].toString();
        name += " z:";
        name += json['accz'].toString();
      } else if (tsmId == 12100) {
        name = "Env - ";
        if (json['airp'] != null) {
          name += "AirP:";
          name += json['airp'].toString();
          name += " ";
        }
        if (json['humd'] != null) {
          name += "Humd:";
          name += json['humd'].toString();
          name += " ";
        }
        if (json['lght'] != null) {
          name += "Light:";
          name += json['lght'].toString();
          name += " ";
        }
        if (json['temp'] != null) {
          name += "Temp:";
          name += json['temp'].toString();
        }
      } else if (tsmId == 12102) {
        name = "Res: ";
        name += json['resistance'].toString();
      } else if (tsmId == 2100) {
        name = "State: ";
        name += json['state'].toString();
      } else if (tsmId == 18100) {
        name = "Angle: ";
        name += json['angle'].toString();
      } else if (tsmId == 12101) {
        name = "Hall: ";
        name += json['hall'].toString();
      } else if (tsmId == 24101) {
        name = "Env - TVOC: ";
        name += json['tvoc'].toString();
      } else if (tsmId == 24100) {
        name = "Status: ";
        name += json['status'].toString();
      } else if (tsmId == 1211) {
        name = "Cell - Lac:";
        name += json['cellLac'].toString();
        name += " Rat:";
        name += json['cellRat'].toString();
        name += " RSSI:";
        name += json['cellRssi'].toString();
      } else if (tsmId == 1212) {
        name = "Cell - MCC/MNC:";
        name += json['mcc_mnc'].toString();
        name += " Oper:";
        name += json['operatorName'].toString();
      }
    } else {
      name = "";
    }
  }
}

String _installationsKey = "ThingseeInstallationsXXXYYYZZZ";

class Installations {
  List<InstallationInfo> installations = [];

  List<InstallationInfo> _installationsFromJsonString(String jsonAsString) {
    final installationsMap = jsonDecode(jsonAsString);
    print(installationsMap.runtimeType);

    final jsonInstallations = installationsMap['installations'];
    print(jsonInstallations.runtimeType);

    List<InstallationInfo> decodedInstallations = [];
    for (final inst in jsonInstallations) {
      InstallationInfo decodedInstallation =
          InstallationInfo.fromMappedJson(inst);
      decodedInstallations.add(decodedInstallation);
    }
    return decodedInstallations;
  }

  String _installationsToJsonString() {
    String allInstsallationsAsJson = '{"installations": [';
    if (installations.length > 0) {
      for (InstallationInfo installation in installations) {
        allInstsallationsAsJson += json.encode(installation.toJson());
        allInstsallationsAsJson += ',';
      }

      allInstsallationsAsJson = allInstsallationsAsJson.substring(
          0, allInstsallationsAsJson.length - 1);
      allInstsallationsAsJson += ']}';
    } else {
      allInstsallationsAsJson = '{"installations": []}';
    }
    return allInstsallationsAsJson;
  }

  Future<void> loadInstallations() async {
    final storage = new FlutterSecureStorage();
    String _installations = await storage.read(key: _installationsKey);
    if (_installations != null && _installations.length > 0) {
      installations = _installationsFromJsonString(_installations);
    }
  }

  void saveInstallations() async {
    final storage = new FlutterSecureStorage();
    await storage.write(
        key: _installationsKey, value: _installationsToJsonString());
  }
}

class InstallationInfo {
  String name = "";
  String description = "";
  String deploymentGroupId = "";
  bool deploymentGroupIdExists = false;

  List<Device> devices = [];

  InstallationInfo(String instName, String groupId, String desc) {
    name = instName;
    description = desc;
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'group_id': deploymentGroupId,
        'devices': devicesToJson()
      };

  String devicesToJson() {
    String allDevicesAsJson = '[';
    if (devices.length > 0) {
      for (Device device in devices) {
        allDevicesAsJson += json.encode(device.toJson());
        allDevicesAsJson += ',';
      }
      allDevicesAsJson =
          allDevicesAsJson.substring(0, allDevicesAsJson.length - 1);
      allDevicesAsJson += ']';
    } else {
      allDevicesAsJson = '[]';
    }
    return allDevicesAsJson;
  }

  InstallationInfo.fromMappedJson(Map<String, dynamic> json)
      : name = json['name'],
        description = json['description'],
        deploymentGroupId = json['group_id'],
        devices = _devicesFromJson(json['devices']);

  static List<Device> _devicesFromJson(String devicesAsJsonString) {
    print(devicesAsJsonString);
    List<Device> _devices = [];
    if (devicesAsJsonString != null && devicesAsJsonString.isNotEmpty) {
      List<dynamic> jsonData = json.decode(devicesAsJsonString);
      jsonData.forEach((device) {
        Device dev = Device.fromMappedJson(device);
        _devices.add(dev);
      });
    }
    return _devices;
  }
}

class Device {
  String tuid = "";
  SensorType deviceType = SensorType.sensorTypeUnknown;
  String description = "";

  String battLvl = "";
  String messagesCheckedTs = "";
  String messagesLatestTs = "";
  bool hasMessages = false;

  String installationStatus = "";

  String wasReplacedBy = "";

  Device(String deviceTuid, SensorType type, String desc,
      String installationStatus) {
    this.tuid = deviceTuid;
    this.deviceType = type;
    this.description = desc;
    this.installationStatus = installationStatus;
  }

  Map<String, dynamic> toJson() => {
        'tuid': tuid,
        'description': description,
        'installation_status': installationStatus,
        'batt_level': battLvl,
        'checked_timestamp': messagesCheckedTs,
    'latest_timestamp': messagesLatestTs,
        'has_messages': hasMessages,
        'was_replaced_by': wasReplacedBy
      };

  Device.fromMappedJson(Map<String, dynamic> json)
      : tuid = json['tuid'],
        description = json['description'],
        deviceType = getSensorType(json['tuid']),
        installationStatus = json['installation_status'],
        battLvl = json['batt_level'],
        messagesCheckedTs = json['checked_timestamp'],
        messagesLatestTs = json['latest_timestamp'],
        hasMessages = json['has_messages'],
        wasReplacedBy = json['was_replaced_by'];
}
