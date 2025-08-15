import 'package:dealzy/home/home_controller.dart';
import 'package:dealzy/home/home_view.dart';
import 'package:dealzy/notification/notification_controller.dart';
import 'package:dealzy/notification/notification_view.dart';
import 'package:dealzy/product_details/product_details_controller.dart';
import 'package:dealzy/product_details/product_details_view.dart';
import 'package:dealzy/profile_setting/profile_setting_controller.dart';
import 'package:dealzy/profile_setting/profile_setting_view.dart';
import 'package:dealzy/store_details/store_details_controller.dart';
import 'package:dealzy/store_details/store_details_view.dart';
import 'package:dealzy/store_search/store_search_controller.dart';
import 'package:get/get.dart';
import '../app_setting/app_setting_controller.dart';
import '../app_setting/app_setting_view.dart';
import '../location_permission/location_permission_controller.dart';
import '../location_permission/location_permission_view.dart';
import '../see_all product/collection_controller.dart';
import '../see_all product/collection_view.dart';
import '../sign_in/sign_in_controller.dart';
import '../sign_in/sign_in_view.dart';
import '../signup/sign_up_controller.dart';
import '../signup/sign_up_view.dart';
import '../store_search/store_search_view.dart';
import '../user_profile/user_profile_controller.dart';
import '../user_profile/user_profile_view.dart';
import '../welcome/welcome_controller.dart';
import '../welcome/welcome_view.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.welcome,
      page: () => const WelcomeView(),
      binding: BindingsBuilder(() {
        Get.put(WelcomeController());
      }),
    ),

    GetPage(
      name: AppRoutes.location,
      page: () => const LocationPermissionView(),
      binding: BindingsBuilder(() {
        Get.put(LocationPermissionController());
      }),
    ),

    GetPage(
      name: AppRoutes.signUp,
      page: () => const SignUpView(),
      binding: BindingsBuilder(() {
        Get.put(SignUpController());
      }),
    ),

    GetPage(
      name: AppRoutes.signIn,
      page: () => const SignInView(),
      binding: BindingsBuilder(() {
        Get.put(SignInController());
      }),
    ),

    GetPage(
      name: AppRoutes.profileSetting,
      page: () => const ProfileSettingView(),
      binding: BindingsBuilder(() {
        Get.put(ProfileSettingController());
      }),
    ),

    GetPage(
      name: AppRoutes.appSetting,
      page: () => const AppSettingView(),
      binding: BindingsBuilder(() {
        Get.put(AppSettingController());
      }),
    ),

    GetPage(
      name: AppRoutes.notification,
      page: () => const NotificationView(),
      binding: BindingsBuilder(() {
        Get.put(NotificationController());
      }),
    ),

    GetPage(
      name: AppRoutes.storeSearch,
      page: () => StoreSearchView(),
      binding: BindingsBuilder(() {
        Get.put(StoreSearchController());
      }),
    ),

    GetPage(
      name: AppRoutes.userProfile,
      page: () => const UserProfileView(),
      binding: BindingsBuilder(() {
        Get.put(UserProfileController());
      }),
    ),

    GetPage(
      name: AppRoutes.collection,
      page: () => const CollectionView(),
      binding: BindingsBuilder(() {
        Get.put(CollectionController());
      }),
    ),

    GetPage(
      name: AppRoutes.storeDetails,
      page: () => const StoreDetailsView(),
      binding: BindingsBuilder(() {
        Get.put(StoreDetailsController());
      }),
    ),

    GetPage(
      name: AppRoutes.productDetails,
      page: () => const ProductDetailsView(),
      binding: BindingsBuilder(() {
        Get.put(ProductDetailsController());
      }),
    ),

    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: BindingsBuilder(() {
        Get.put(HomeController());
      }),
    ),




  ];
}
