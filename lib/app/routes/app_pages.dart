import 'package:flutter_gps/app/routes/app_routes.dart';
import 'package:flutter_gps/app/ui/home/home_binding.dart';
import 'package:flutter_gps/app/ui/home/home_page.dart';
import 'package:get/get.dart';


class AppPages {
  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: Paths.HOME,
      page: () => HomeView(),
      binding: HomeBinding(),
    ),
  ];
}
