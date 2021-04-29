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
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StackIdentifier {
  int id = -1;
  String name = "";
  String clientId = "";
  bool isActive = false;

  StackIdentifier();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'client_id': clientId,
        'isActive': isActive,
      };

  StackIdentifier.fromMappedJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        clientId = json['client_id'],
        isActive = json['isActive'];
}

class DeviceInfo {
  String tuid = "";
  String battLvl = "";
  String timestamp = "";
  String installationStatus = "";

  String error = "";

  DeviceInfo(String deviceTuid, String battLevel, String ts) {
    tuid = deviceTuid;
    battLvl = battLevel;
    timestamp = ts;
  }

  DeviceInfo.fromError(String networkError) {
    error = networkError;
  }
}

class DeploymentGroupInfo {
  String groupId = "";
  String desciption = "";

  String error = "";

  DeploymentGroupInfo(String id, String desc) {
    groupId = id;
    desciption = desc;
  }

  DeploymentGroupInfo.fromError(String networkError) {
    error = networkError;
  }
}

class ThingseeNetworkAPIs {
  static Future<bool> testStack(
      String url, String clientId, String secret) async {
    return await _NetworkOperations._nwTestStack(url, clientId, secret);
  }

  static Future<StackIdentifier> addStack(String stackName, String url,
      String clientId, String secret, bool setAsActive) {
    return _NetworkOperations.addStack(
        stackName, url, clientId, secret, setAsActive);
  }

  static StackIdentifier getCurrentStack() {
    int id = _NetworkOperations.getActiveStackId();
    if (id != -1) {
      return _NetworkOperations.getStack(id);
    }
    return null;
  }

  static void removeStack(int stckId) {
    _NetworkOperations.removeStack(stckId);
  }

  static Future<List<StackIdentifier>> getStacks() async {
    return await _NetworkOperations.getStacks();
  }

  static void setActiveStack(int stckId) {
    _NetworkOperations.setActiveStack(stckId);
  }

  static Future<bool> doWeHaveStacksDefined() async {
    return await _NetworkOperations.doWeHaveStacks();
  }

  static Future<String> nwGetBearerToken(int stackId) async {
    var reqBody = {};
    reqBody["client_id"] =
        _NetworkOperations.getActiveStack().identifier.clientId;
    reqBody["client_secret"] = _NetworkOperations.getActiveStack().secret;

    HttpClientRequest request = await _NetworkOperations.getHttpClient()
        .postUrl(Uri.parse(
            _NetworkOperations.getStackPath(stackId) + 'auth/client-token'));
    request.headers.set('content-type', 'application/json');
    request.add(utf8.encode(json.encode(reqBody)));
    HttpClientResponse response = await request.close();
    String reply = await response.transform(utf8.decoder).join();
    print(reply);
    var bodyAsJson = json.decode(reply);
    var data = bodyAsJson['data'];
    String token = data['token'];
    return token;
  }

  static Future<DeviceInfo> nwCheckDeviceInfoAndState(String tuid) async {
    DeviceInfo devInfo;
    try {
      int stackId = _NetworkOperations.getActiveStackId();
      String token = await nwGetBearerToken(stackId);
      HttpClientRequest request = await _NetworkOperations.getHttpClient()
          .getUrl(Uri.parse(
              _NetworkOperations.getStackPath(stackId) + "things/" + tuid));
      request.headers.set('content-type', 'application/json');
      request.headers.set('Authorization', "Bearer " + token);
      HttpClientResponse response = await request.close();
      String reply = await response.transform(utf8.decoder).join();
      print(reply);
      if (response.statusCode == 200) {
        var bodyAsJson = json.decode(reply);
        var data = bodyAsJson['data'];
        String battLevel = "";
        int batt = data['battery_level'];
        if (batt != null) battLevel = batt.toString();

        String timestamp = "";
        var ts = data['timestamp'];
        if (ts != null) {
          DateTime date = new DateTime.fromMillisecondsSinceEpoch(ts * 1000);
          if (date != null) timestamp = date.toLocal().toIso8601String();
        }
        devInfo = new DeviceInfo(tuid, battLevel, timestamp);
      } else {
        devInfo = new DeviceInfo.fromError("Error: " +
            response.statusCode.toString() +
            " " +
            response.reasonPhrase);
      }
    } catch (e) {
      print(e);
      devInfo = new DeviceInfo.fromError("Error: " + e.toString());
    }

    _NetworkOperations.getHttpClient().close();

    return devInfo;
  }

  static Future<DeviceInfo> nwGetDeviceInstallationStatus(
      DeviceInfo deviceInfo) async {
    try {
      int stackId = _NetworkOperations.getActiveStackId();
      String token = await nwGetBearerToken(stackId);
      HttpClientRequest request = await _NetworkOperations.getHttpClient()
          .getUrl(Uri.parse(_NetworkOperations.getStackPath(stackId) +
              "things/" +
              deviceInfo.tuid +
              "/installations?limit=1"));
      request.headers.set('content-type', 'application/json');
      request.headers.set('Authorization', "Bearer " + token);
      HttpClientResponse response = await request.close();
      String reply = await response.transform(utf8.decoder).join();
      print(reply);
      if (response.statusCode == 200) {
        var bodyAsJson = json.decode(reply);
        var data = bodyAsJson['data'];
        var latestStatus = data[0];
        deviceInfo.installationStatus = latestStatus['installation_status'];
      } else {
        deviceInfo = new DeviceInfo.fromError("Error: " +
            response.statusCode.toString() +
            " " +
            response.reasonPhrase);
      }
    } catch (e) {
      print(e);
      deviceInfo = new DeviceInfo.fromError("Error: " + e.toString());
    }

    _NetworkOperations.getHttpClient().close();

    return deviceInfo;
  }

  static Future<Map<String, dynamic>> nwSetDeviceInstallationStatus(
      String tuid, String status) async {
    Map<String, dynamic> codedResponse = {};

    try {
      int stackId = _NetworkOperations.getActiveStackId();
      String token = await nwGetBearerToken(stackId);
      HttpClientRequest request = await _NetworkOperations.getHttpClient()
          .postUrl(Uri.parse(_NetworkOperations.getStackPath(stackId) +
              "things/" +
              tuid +
              "/installations"));
      request.headers.set('content-type', 'application/json');
      request.headers.set('Authorization', "Bearer " + token);
      Map jsonMap = {'installation_status': status};
      request.add(utf8.encode(json.encode(jsonMap)));
      HttpClientResponse response = await request.close();
      String reply = await response.transform(utf8.decoder).join();

      codedResponse["responseCode"] = response.statusCode;
      codedResponse["responseBody"] = reply;
    } catch (e) {
      print(e);
      codedResponse["responseCode"] = 7;
      codedResponse["responseBody"] = e.toString();
    }

    _NetworkOperations.getHttpClient().close();

    return codedResponse;
  }

  static Future<List<DeploymentGroupInfo>> nwGetDeploymentGroups() async {
    List<DeploymentGroupInfo> _deploymentGroups = [];

    try {
      int stackId = _NetworkOperations.getActiveStackId();
      String token = await nwGetBearerToken(stackId);
      HttpClientRequest request = await _NetworkOperations.getHttpClient()
          .getUrl(
              Uri.parse(_NetworkOperations.getStackPath(stackId) + "groups"));
      request.headers.set('content-type', 'application/json');
      request.headers.set('Authorization', "Bearer " + token);
      HttpClientResponse response = await request.close();
      String reply = await response.transform(utf8.decoder).join();
      print(reply);
      if (response.statusCode == 200) {
        var bodyAsJson = json.decode(reply);
        List<dynamic> data = bodyAsJson['data'];
        data.forEach((group) {
          bool groupIdFound = false;
          String groupId;
          bool groupDescFound = false;
          String groupDesc;
          (group as Map<String, dynamic>).forEach((key, value) {
            if (key == "group_id") {
              groupId = value;
              groupIdFound = true;
            } else if (key == "group_description") {
              groupDesc = value;
              groupDescFound = true;
            }
            if (groupIdFound && groupDescFound) {
              DeploymentGroupInfo depInfo =
                  new DeploymentGroupInfo(groupId, groupDesc);
              _deploymentGroups.add(depInfo);
              groupIdFound = false;
              groupDescFound = false;
            }
          });
        });
      } else {
        DeploymentGroupInfo depInfo = new DeploymentGroupInfo.fromError(reply);
        _deploymentGroups.add(depInfo);
      }
    } catch (e) {
      print(e);
      DeploymentGroupInfo depInfo =
          new DeploymentGroupInfo.fromError(e.toString());
      _deploymentGroups.add(depInfo);
    }

    _NetworkOperations.getHttpClient().close();

    return _deploymentGroups;
  }

  static Future<List<String>> nwGetDevicesInDeploymentGroup(
      String groupId) async {
    List<String> devices = [];

    try {
      int stackId = _NetworkOperations.getActiveStackId();
      String token = await nwGetBearerToken(stackId);
      HttpClientRequest request = await _NetworkOperations.getHttpClient()
          .getUrl(Uri.parse(_NetworkOperations.getStackPath(stackId) +
              "groups/" +
              groupId +
              "/things"));
      request.headers.set('content-type', 'application/json');
      request.headers.set('Authorization', "Bearer " + token);
      HttpClientResponse response = await request.close();
      String reply = await response.transform(utf8.decoder).join();
      print(reply);
      if (response.statusCode == 200) {
        var bodyAsJson = json.decode(reply);
        var data = bodyAsJson['data'];
        List<dynamic> tuids = data['tuids'];
        tuids.forEach((item) {
          devices.add(item);
        });
      } else {
        devices = null;
      }
    } catch (e) {
      print(e);
      devices = null;
    }

    _NetworkOperations.getHttpClient().close();

    return devices;
  }

  static Future<Map<String, dynamic>> nwCreateDeploymentGroup(
      String groupId, String description) async {
    Map<String, dynamic> codedResponse = {};

    try {
      int stackId = _NetworkOperations.getActiveStackId();
      String token = await nwGetBearerToken(stackId);
      HttpClientRequest request = await _NetworkOperations.getHttpClient()
          .postUrl(
              Uri.parse(_NetworkOperations.getStackPath(stackId) + "groups"));
      request.headers.set('content-type', 'application/json');
      request.headers.set('Authorization', "Bearer " + token);
      Map jsonMap = {'group_id': groupId.toLowerCase(), 'group_description': description};
      request.add(utf8.encode(json.encode(jsonMap)));
      print(request.toString());
      HttpClientResponse response = await request.close();
      String reply = await response.transform(utf8.decoder).join();
      print(reply);
      codedResponse["responseCode"] = response.statusCode;
      codedResponse["responseBody"] = reply;
    } catch (e) {
      print(e);
      codedResponse["responseCode"] = 7;
      codedResponse["responseBody"] = e.toString();
    }

    _NetworkOperations.getHttpClient().close();

    return codedResponse;
  }

  static Future<Map<String, dynamic>> nwRenameDeploymentGroup(
      String oldGroupId, String newGroupId) async {
    Map<String, dynamic> codedResponse = {};

    try {
      int stackId = _NetworkOperations.getActiveStackId();
      String token = await nwGetBearerToken(stackId);
      HttpClientRequest request = await _NetworkOperations.getHttpClient()
          .postUrl(Uri.parse(_NetworkOperations.getStackPath(stackId) +
              "groups/" +
          oldGroupId +
              "/rename"));
      request.headers.set('content-type', 'application/json');
      request.headers.set('Authorization', "Bearer " + token);
      Map jsonMap = {'group_id': newGroupId.toLowerCase()};
      request.add(utf8.encode(json.encode(jsonMap)));
      HttpClientResponse response = await request.close();
      String reply = await response.transform(utf8.decoder).join();

      codedResponse["responseCode"] = response.statusCode;
      codedResponse["responseBody"] = reply;
    } catch (e) {
      print(e);
      codedResponse["responseCode"] = 7;
      codedResponse["responseBody"] = e.toString();
    }

    _NetworkOperations.getHttpClient().close();

    return codedResponse;
  }

  static Future<bool> nwDeleteDeploymentGroup(
      String groupId) async {

    bool deleted = false;

    try {
      int stackId = _NetworkOperations.getActiveStackId();
      String token = await nwGetBearerToken(stackId);
      HttpClientRequest request = await _NetworkOperations.getHttpClient()
          .deleteUrl(Uri.parse(
              _NetworkOperations.getStackPath(stackId) + "groups/" + groupId));
      request.headers.set('content-type', 'application/json');
      request.headers.set('Authorization', "Bearer " + token);
      HttpClientResponse response = await request.close();
      String reply = await response.transform(utf8.decoder).join();
      print(reply);
      if (response.statusCode == 200) {
        var bodyAsJson = json.decode(reply);
        var data = bodyAsJson['data'];
        deleted = data['deleted'];
      }
    } catch (e) {
      print(e);
    }

    _NetworkOperations.getHttpClient().close();
    return deleted;
  }

  static Future<Map<String, dynamic>> nwGetDeviceDeploymentGroup(
      String tuid) async {
    Map<String, dynamic> codedResponse = {};

    try {
      int stackId = _NetworkOperations.getActiveStackId();
      String token = await nwGetBearerToken(stackId);
      HttpClientRequest request = await _NetworkOperations.getHttpClient()
          .getUrl(Uri.parse(_NetworkOperations.getStackPath(stackId) +
              "things/" +
              tuid +
              "/group"));
      request.headers.set('content-type', 'application/json');
      request.headers.set('Authorization', "Bearer " + token);
      HttpClientResponse response = await request.close();
      String reply = await response.transform(utf8.decoder).join();

      codedResponse["responseCode"] = response.statusCode;
      codedResponse["responseBody"] = reply;
    } catch (e) {
      print(e);
      codedResponse["responseCode"] = 7;
      codedResponse["responseBody"] = e.toString();
    }

    _NetworkOperations.getHttpClient().close();

    return codedResponse;
  }

  static Future<Map<String, dynamic>> nwGetDeviceMessages(
      String tuid, int limit) async {
    Map<String, dynamic> codedResponse = {};

    try {
      int stackId = _NetworkOperations.getActiveStackId();
      String token = await nwGetBearerToken(stackId);
      HttpClientRequest request = await _NetworkOperations.getHttpClient()
          .getUrl(Uri.parse(_NetworkOperations.getStackPath(stackId) +
          "things/" +
          tuid +
          "/messages?limit=" + limit.toString()));
      request.headers.set('content-type', 'application/json');
      request.headers.set('Authorization', "Bearer " + token);
      HttpClientResponse response = await request.close();
      String reply = await response.transform(utf8.decoder).join();
      print(reply);
      codedResponse["responseCode"] = response.statusCode;
      codedResponse["responseBody"] = reply;
    } catch (e) {
      print(e);
      codedResponse["responseCode"] = 7;
      codedResponse["responseBody"] = e.toString();
    }

    _NetworkOperations.getHttpClient().close();

    return codedResponse;
  }

  static Future<Map<String, dynamic>> nwSetDeviceDeploymentGroup(
      String tuid, String groupId) async {
    Map<String, dynamic> codedResponse = {};

    try {
      int stackId = _NetworkOperations.getActiveStackId();
      String token = await nwGetBearerToken(stackId);
      HttpClientRequest request = await _NetworkOperations.getHttpClient()
          .postUrl(Uri.parse(_NetworkOperations.getStackPath(stackId) +
              "things/" +
              tuid +
              "/group"));
      request.headers.set('content-type', 'application/json');
      request.headers.set('Authorization', "Bearer " + token);
      Map jsonMap = {'group_id': groupId};
      request.add(utf8.encode(json.encode(jsonMap)));
      HttpClientResponse response = await request.close();
      String reply = await response.transform(utf8.decoder).join();

      codedResponse["responseCode"] = response.statusCode;
      codedResponse["responseBody"] = reply;
    } catch (e) {
      print(e);
      codedResponse["responseCode"] = 7;
      codedResponse["responseBody"] = e.toString();
    }

    _NetworkOperations.getHttpClient().close();

    return codedResponse;
  }
}

String _stackKey = "ThingseeStacksXXXYYYZZZ";

class _Stack {
  StackIdentifier identifier = new StackIdentifier();
  String url = "";
  String secret = "";

  _Stack();

  Map<String, dynamic> toJson() =>
      {'identifier': identifier.toJson(), 'url': url, 'secret': secret};

  _Stack.fromMappedJson(Map<String, dynamic> json)
      : identifier = StackIdentifier.fromMappedJson(json['identifier']),
        url = json['url'],
        secret = json['secret'];
}

class _NetworkOperations {
  static List<_Stack> _nwStacks = [];
  static StackIdentifier _activeStack;

  static HttpClient getHttpClient() {
    HttpClient client = new HttpClient()
      ..badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);

    return client;
  }

  static Future<bool> doWeHaveStacks() async {
    final storage = new FlutterSecureStorage();
    String stacks = await storage.read(key: _stackKey);
    if (stacks != null && _stacksFromJsonString(stacks).length > 0) {
      if (_nwStacks.length == 0) {
        if (stacks != null && stacks.length > 0) {
          _nwStacks = _stacksFromJsonString(stacks);
        }
      }
      return true;
    }
    return false;
  }

  static Future<StackIdentifier> addStack(String stacksName, String url,
      String clientId, String secret, bool setAsActive) async {
    _Stack newStack = new _Stack();
    newStack.identifier.name = stacksName;
    newStack.url = url;
    newStack.identifier.clientId = clientId;
    newStack.secret = secret;
    newStack.identifier.isActive = setAsActive;
    newStack.identifier.id = _nwStacks.length;

    if (_activeStack == null) {
      //Set new stack as the active one
      newStack.identifier.isActive = true;
      _activeStack = newStack.identifier;
    } else if (setAsActive && _activeStack != null) {
      newStack.identifier.isActive = true;
      for (_Stack stack in _nwStacks) {
        if (stack.identifier.isActive) {
          stack.identifier.isActive = false;
        }
      }
      _activeStack = newStack.identifier;
    }
    _nwStacks.add(newStack);

    saveStacks();
    return newStack.identifier;
  }

  static String _stacksToJsonString() {
    String allStacksAsJson = '{"stacks": [';
    if (_nwStacks.length > 0) {
      for (_Stack stack in _nwStacks) {
        allStacksAsJson += json.encode(stack.toJson());
        allStacksAsJson += ',';
      }

      allStacksAsJson =
          allStacksAsJson.substring(0, allStacksAsJson.length - 1);
      allStacksAsJson += ']}';
    } else {
      allStacksAsJson = '{"stacks": []}';
    }
    return allStacksAsJson;
  }

  static List<_Stack> _stacksFromJsonString(String stacks) {
    final stackMap = jsonDecode(stacks);
    print(stackMap.runtimeType);

    final jsonStacks = stackMap['stacks'];
    print(jsonStacks.runtimeType);

    List<_Stack> decodedStacks = [];
    for (final prof in jsonStacks) {
      _Stack decodedStack = _Stack.fromMappedJson(prof);
      decodedStacks.add(decodedStack);
    }
    return decodedStacks;
  }

  static void saveStacks() {
    final storage = new FlutterSecureStorage();
    storage.write(key: _stackKey, value: _stacksToJsonString());
  }

  static Future<List<StackIdentifier>> getStacks() async {
    List<StackIdentifier> stacks = [];

    if (_nwStacks.length == 0) {
      final storage = new FlutterSecureStorage();
      String stacks = await storage.read(key: _stackKey);
      if (stacks != null && stacks.length > 0) {
        _nwStacks = _stacksFromJsonString(stacks);
      }
    }

    for (_Stack stack in _nwStacks) {
      StackIdentifier value = new StackIdentifier();
      value.id = stack.identifier.id;
      value.name = stack.identifier.name;
      value.isActive = stack.identifier.isActive;
      value.clientId = stack.identifier.clientId;
      stacks.add(value);
    }
    return stacks;
  }

  static _Stack getActiveStack() {
    for (_Stack stack in _nwStacks) {
      if (stack.identifier.isActive) {
        return stack;
      }
    }
    return null;
  }

  static void removeStack(int stckId) {
    for (_Stack stack in _nwStacks) {
      if (stack.identifier.id == stckId) {
        if (stack.identifier.isActive && _nwStacks.length > 1) {
          _nwStacks.remove(stack);
          _nwStacks[0].identifier.isActive = true;
          _activeStack = _nwStacks[0].identifier;
        } else {
          _nwStacks.remove(stack);
        }
        saveStacks();
        return;
      }
    }
  }

  static void setActiveStack(int stackId) {
    for (_Stack stack in _nwStacks) {
      if (stack.identifier.id != stackId) {
        if (stack.identifier.isActive) {
          stack.identifier.isActive = false;
        }
      } else {
        stack.identifier.isActive = true;
        _activeStack = stack.identifier;
      }
    }
  }

  static Future<bool> _nwTestStack(
      String url, String clientId, String secret) async {
    bool validStack = false;
    var reqBody = {};
    reqBody["client_id"] = clientId;
    reqBody["client_secret"] = secret;

    try {
      HttpClientRequest request =
          await getHttpClient().postUrl(Uri.parse(url + 'auth/client-token'));
      request.headers.set('content-type', 'application/json');
      request.add(utf8.encode(json.encode(reqBody)));
      HttpClientResponse response = await request.close();
      String reply = await response.transform(utf8.decoder).join();
      print(reply);
      if (response.statusCode == 200) validStack = true;
    } catch (e) {
      print(e);
    }
    getHttpClient().close();
    return validStack;
  }

  static int getActiveStackId() {
    int activeStackId = -1;
    for (_Stack stack in _nwStacks) {
      if (stack.identifier.isActive) {
        activeStackId = stack.identifier.id;
        break;
      }
    }
    //If stack available but no active stack selected -> select first one
    if (_nwStacks.isNotEmpty && activeStackId == -1)
      activeStackId = _nwStacks.first.identifier.id;
    return activeStackId;
  }

  static StackIdentifier getStack(int id) {
    for (_Stack stack in _nwStacks) {
      if (stack.identifier.id == id) {
        return stack.identifier;
      }
    }
    return null;
  }

  static String getStackPath(int stackId) {
    for (_Stack stack in _nwStacks) {
      if (stack.identifier.id == stackId) {
        return stack.url;
      }
    }
    return null;
  }
}
