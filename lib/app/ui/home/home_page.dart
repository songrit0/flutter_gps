import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_gps/app/ui/home/home_controller.dart';
import 'package:flutter_gps/service/flutter_background_service.dart';
import 'package:get/get.dart';

class HomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: Text('GetX Example'),
      ),
      body: Center(
        child: Obx(() {
          return Text(
            'Clicks: ${controller.count}',
            style: TextStyle(fontSize: 24),
          );
        }),
      ),
      floatingActionButton: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton(
            onPressed: () {
              // FlutterBackgroundService().invoke('start');
              startBackgroundService();
            },
            child: Icon(Icons.add),
          ),
          FloatingActionButton(
            onPressed: () {
              stopBackgroundService();
            },
            child: Icon(Icons.stop),
          ),
          FloatingActionButton(
            onPressed: () {
              showNotification(1, 'test', 'showNotification');
            },
            child: Icon(Icons.e_mobiledata),
          ),
        ],
      ),
    );
  }
}
