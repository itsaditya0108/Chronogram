import 'dart:io';
import 'package:chronogram/app_helper/app_helper.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

class DeviceHelper {
  static Future<Map<String, dynamic>> getDeviceData() async {
    final deviceInfo = DeviceInfoPlugin();
    final packageInfo = await PackageInfo.fromPlatform();

    String deviceId = "";
    String deviceModel = "";
    String osVersion = "";

    if (Platform.isAndroid) {
      AndroidDeviceInfo android = await deviceInfo.androidInfo;
      deviceId = android.id;
      deviceModel = android.model;
      osVersion = android.version.release;
    } else if (Platform.isIOS) {
      IosDeviceInfo ios = await deviceInfo.iosInfo;
      deviceId = ios.identifierForVendor ?? "";
      deviceModel = ios.model;
      osVersion = ios.systemVersion;
    }

    final uuid = await AppHelper().getDeviceUUID();

    return {
      "deviceId": deviceId,
      "deviceName": deviceModel,
      "simSerial": uuid,
      "deviceModel": deviceModel,
      "osName": Platform.isAndroid ? "Android" : "iOS",
      "osVersion": osVersion,
      "appVersion": packageInfo.version,
      "latitude": 0,
      "longitude": 0,
    };
  }
}
