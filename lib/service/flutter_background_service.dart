import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';

void startBackgroundService() {
  final service = FlutterBackgroundService();
  service.startService();
}

void stopBackgroundService() {
  final service = FlutterBackgroundService();
  service.invoke("stop");
}

AndroidConfiguration androidConfigurationinfo = AndroidConfiguration(
  autoStart: true,
  onStart: onStart,
  isForegroundMode: true,
  autoStartOnBoot: true,
  foregroundServiceNotificationId: 888,
  initialNotificationContent: 'Background Service กำลังทำงาน',
  initialNotificationTitle: 'Background Service',
  // notificationChannelId: 'Background Service',
);
Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
    ),
    androidConfiguration: androidConfigurationinfo,
  );
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  service.on("stop").listen((event) {
    service.stopSelf();
    print("กระบวนการ background หยุดทำงานแล้ว");
  });
  service.on("start").listen((event) {});
  Timer.periodic(const Duration(seconds: 1), (timer) async {
    print(
        "บริการทำงานได้สำเร็จ ${DateTime.now().hour} : ${DateTime.now().minute} : ${DateTime.now().second}  ${getCurrentLocation()}");

    // showNotification(1, 'สำเร็จ',
    //     ' ${DateTime.now().hour} : ${DateTime.now().minute} : ${DateTime.now().second}');
  });
}

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initLocalNotifications() async {
  var android = AndroidInitializationSettings('@mipmap/ic_launcher');
  var initializationSettings = InitializationSettings(
    android: android,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

Future<void> showNotification(id, title, body) async {
  const NotificationDetails platformChannelDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      'Notification_01',
      'แจ้งเตือนทั่วไป',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      playSound: false,
    ),
  );
  flutterLocalNotificationsPlugin.show(
      id, title.toString(), body.toString(), platformChannelDetails);
}

// พิกัดตำแหน่งหน้างานที่กำหนด
double workLatitude = 35.4606708;
double workLongitude = 127.6171883;
setworklocation(double latitude, double longitude) {
  workLatitude = latitude;
  workLongitude = longitude;
  print('$latitude $longitude');
}

// ฟังก์ชันคำนวณระยะทางระหว่างสองตำแหน่ง
double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const double R = 6371; // Earth radius in kilometers
  double dLat = (lat2 - lat1) * pi / 180;
  double dLon = (lon2 - lon1) * pi / 180;
  double a = sin(dLat / 2) * sin(dLat / 2) +
      cos(lat1 * pi / 180) *
          cos(lat2 * pi / 180) *
          sin(dLon / 2) *
          sin(dLon / 2);
  double c = 2 * atan2(sqrt(a), sqrt(1 - a));
  double distance = R * c;
  return distance;
}

Future<String> getCurrentLocation() async {
  bool serviceEnabled;
  LocationPermission permission;
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    print("Location services are disabled.");
    // return;
  }
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      print("Location permissions are denied.");
      // return;
    }
  }
  if (permission == LocationPermission.deniedForever) {
    print("Location permissions are permanently denied.");
    // return;
  }

  // Get current position
  Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);

  double currentLatitude = position.latitude;
  double currentLongitude = position.longitude;

  print("Latitude: $currentLatitude, Longitude: $currentLongitude");

  // คำนวณระยะทางจากตำแหน่งปัจจุบันไปยังหน้างาน
  double distanceToWork = calculateDistance(
      currentLatitude, currentLongitude, workLatitude, workLongitude);

  // กำหนดระยะทาง (กิโลเมตร) ที่ถือว่าอยู่ในพื้นที่หน้างาน
  const double thresholdDistance = 0.5; // ตัวอย่างคือ 500 เมตร

  if (distanceToWork <= thresholdDistance) {
    // showNotification(1, 'ตำแหน่งงานปัจจุบัน $workLatitude $workLongitude',
    //     'อยู่หน้างาน $currentLatitude $currentLongitude ');
    print("อยู่หน้างาน");
    return 'อยู่หน้างาน';
  } else {
    // showNotification(1, 'ตำแหน่งงานปัจจุบัน $workLatitude $workLongitude',
    //     'ออกจากหน้างานแล้ว $currentLatitude $currentLongitude');
    print("ออกจากหน้างานแล้ว");
    return 'ออกจากหน้างานแล้ว';
  }
}
