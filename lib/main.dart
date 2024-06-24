import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_gps/app/ui/home/home_binding.dart';
import 'package:flutter_gps/app/ui/home/home_page.dart';
import 'package:flutter_gps/service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:get/get.dart';

final service = FlutterBackgroundService();

void main() {
  runApp(MyApp());
  initializeService();
  initLocalNotifications();
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialBinding: HomeBinding(),
      home: HomeView(),
    );
  }
}
