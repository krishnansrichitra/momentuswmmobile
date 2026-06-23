import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';



Future<String> getDeviceId() async {
  final deviceInfo = DeviceInfoPlugin();

  if (kIsWeb){
    return await getWebDeviceId();
  }
  if (Platform.isAndroid) {
    AndroidDeviceInfo androidInfo =
    await deviceInfo.androidInfo;

    return androidInfo.serialNumber; // Not recommended
  }

  if (Platform.isIOS) {
    IosDeviceInfo iosInfo =
    await deviceInfo.iosInfo;

    return iosInfo.identifierForVendor ?? "";
  }

  return "";
}

Future<String> getWebDeviceId() async {
  final prefs = await SharedPreferences.getInstance();

  String? deviceId = prefs.getString('deviceId');

  if (deviceId == null) {
    deviceId = const Uuid().v4();
    await prefs.setString('deviceId', deviceId);
  }

  return deviceId;
}