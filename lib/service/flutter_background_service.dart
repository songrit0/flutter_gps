import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
      autoStart: true,
    ),
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
  DartPluginRegistrant.ensureInitialized();
  print('Service started');

  if (service is AndroidServiceInstance) {
    service.on("setAsForeground").listen((event) {
      print("Received 'setAsForeground' event");
      service.setAsForegroundService();
    });

    service.on("setAsBackground").listen((event) {
      print("Received 'setAsBackground' event");
      service.setAsBackgroundService();
    });

    service.on("stopService").listen((event) {
      print("Received 'stopService' event");
      service.stopSelf();
    });

    // Ensure the service starts as a foreground service
    service.setAsForegroundService();

    Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (await service.isForegroundService()) {
        service.setForegroundNotificationInfo(
          title: 'Service Running',
          content:
              "Time: ${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}",
        );
        print(
            "Service Running at ${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}");
      }
      // Update the service state
      service.invoke('update');
    });
  }
}

Future<void> initLocalNotifications() async {
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.high,
  );

  var android = AndroidInitializationSettings('@mipmap/ic_launcher');
  var initializationSettings = InitializationSettings(
    android: android,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Future<void> initLocalNotifications() async {
//   var android = AndroidInitializationSettings('@mipmap/ic_launcher');
//   var initializationSettings = InitializationSettings(
//     android: android,
//   );
//   await flutterLocalNotificationsPlugin.initialize(initializationSettings);
// }

Future<void> showNotification(int id, String title, String body) async {
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
  flutterLocalNotificationsPlugin.show(id, title, body, platformChannelDetails);
}

// พิกัดตำแหน่งหน้างานที่กำหนด
double workLatitude = 35.4606708;
double workLongitude = 127.6171883;

void setworklocation(double? latitude, double? longitude) {
  workLatitude = latitude ?? 0;
  workLongitude = longitude ?? 0;
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
    return "Location services are disabled.";
  }
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      print("Location permissions are denied.");
      return "Location permissions are denied.";
    }
  }
  if (permission == LocationPermission.deniedForever) {
    print("Location permissions are permanently denied.");
    return "Location permissions are permanently denied.";
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
    print("อยู่หน้างาน");
    return 'อยู่หน้างาน';
  } else {
    print("ออกจากหน้างานแล้ว");
    return 'ออกจากหน้างานแล้ว';
  }
}
