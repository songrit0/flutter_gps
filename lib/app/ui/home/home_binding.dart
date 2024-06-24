import 'package:flutter_gps/app/ui/home/home_controller.dart';
import 'package:get/get.dart';

 

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
