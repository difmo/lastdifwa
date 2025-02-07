import 'package:difwa/routes/store_bottom_bar.dart';
import 'package:difwa/routes/user_bottom_bar.dart';
import 'package:difwa/screens/admin_screens/create_store_screen.dart';
import 'package:difwa/screens/auth/login_screen.dart';
import 'package:difwa/screens/auth/otp_screnn.dart';
import 'package:difwa/screens/available_service_select.dart';
import 'package:difwa/screens/book_now_screen.dart';
import 'package:difwa/screens/profile_screen.dart';
import 'package:difwa/screens/splash_screen.dart';
import 'package:difwa/screens/subscription_screen.dart';
import 'package:get/get.dart';

class AppRoutes {
  static const home = '/';
  static const profile = '/profile';
  static const splash = '/splash';
  static const availableservices = '/availableservices';
  static const login = '/login';
  static const otp = '/otp';
  static const userbottom = '/userbottom';
  static const subscription = '/subscription';

  //////// Admin stuff////////
  static const additem = '/additem';
  static const createstore = '/createstore';
  static const storebottombar = '/storebottombar';
  static const store_home = '/store_home';
  static const store_profile = '/store_profile';

  static final List<GetPage> pages = [
    GetPage(
      name: splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: home,
      page: () => const BookNowScreen(),
    ),
    GetPage(
      name: profile,
      page: () => const ProfileScreen(),
    ),
    GetPage(
      name: availableservices,
      page: () => const AvailableServiceSelect(),
    ),
    GetPage(
      name: login,
      page: () =>  MobileNumberPage(),
    ),
    GetPage(
      name: otp,
      page: () => const OTPVerificationPage(),
    ),
    GetPage(
      name: userbottom,
      page: () => const BottomUserHomePage(),
    ),
    GetPage(
      name: subscription,
      page: () => const SubscriptionScreen(),
    ),

/////////////////////////Admin Routes/////////////////
    // GetPage(
    //   name: additem,
    //   page: () =>  AddItemPage(),
    // ),
// //
    GetPage(
      name: createstore,
      page: () => const CreateStorePage(),
    ),
    GetPage(
      name: storebottombar,
      page: () => const BottomStoreHomePage(),
    ),
  ];
}
