import 'package:flutter/material.dart';
import 'package:flutter_gps/app/ui/home/home_binding.dart';
import 'package:flutter_gps/app/ui/home/home_page.dart';
import 'package:get/get.dart';


void main() {
  runApp(MyApp());
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
