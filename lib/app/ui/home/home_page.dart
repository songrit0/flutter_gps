import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_gps/app/ui/home/home_controller.dart';
import 'package:flutter_gps/service/flutter_background_service.dart';
import 'package:get/get.dart';

class HomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find();
    RxString isrun = RxString('stopService');
    return Scaffold(
      appBar: AppBar(
        title: const Text('GetX Example'),
      ),
      body: Column(
        children: [
          // Center(
          //   child: Obx(() {
          //     return Text(
          //       'Clicks: ${controller.count}',
          //       style: TextStyle(fontSize: 24),
          //     );
          //   }),
          // ),
          ElevatedButton(
              onPressed: () {
                controller.getCurrentLocation();
              },
              child: const Text('getCurrentLocation')),
          const Text('latitude'),
          TextField(
            controller: controller.latitude,
          ),
          const Text('longitude'),
          TextField(
            controller: controller.longitude,
          ),
          ElevatedButton(
              onPressed: () {
                if (controller.latitude.text != '' &&
                    controller.longitude.text != '') {}
                setworklocation(double.parse(controller.latitude.text),
                    double.parse(controller.longitude.text));
              },
              child: const Text('set new')),
          ElevatedButton(
            onPressed: () {
              // FlutterBackgroundService().invoke('start');
              FlutterBackgroundService().invoke('setAsForeground');
            },
            child: const Text('setAsForeground'),
          ),
          ElevatedButton(
            onPressed: () {
              // FlutterBackgroundService().invoke('start');
              FlutterBackgroundService().invoke('setAsBackground');
            },
            child: const Text('setAsBackground'),
          ),
          Obx(() => ElevatedButton(
                onPressed: () async {
                  final service = FlutterBackgroundService();
                  bool isRunning = await service.isRunning();
                  if (isRunning) {
                    service.invoke('stopService');
                  } else {
                    service.startService();
                  }
                  if (!isRunning) {
                    isrun.value = 'stop Service';
                  } else {
                    isrun.value = 'start Service';
                  }
                },
                child: Text('${isrun.value}'),
              )),
        ],
      ),
      floatingActionButton: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton(
            onPressed: () {
              getCurrentLocation();
            },
            child: const Icon(Icons.e_mobiledata),
          ),
        ],
      ),
    );
  }
}
