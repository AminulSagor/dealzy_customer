import 'package:dealzy/home/home_controller.dart';
import 'package:dealzy/home/home_view.dart';
import 'package:dealzy/notification/notification_controller.dart';
import 'package:dealzy/notification/notification_view.dart';
import 'package:dealzy/product_details/product_details_controller.dart';
import 'package:dealzy/product_details/product_details_view.dart';
import 'package:dealzy/store_details/store_details_controller.dart';
import 'package:dealzy/store_details/store_details_view.dart';
import 'package:dealzy/store_search/store_search_controller.dart';
import 'package:get/get.dart';
import '../app_setting/app_setting_controller.dart';
import '../app_setting/app_setting_view.dart';
import '../forget_password/forget_password_controller.dart';
import '../forget_password/forget_password_view.dart';
import '../location_permission/location_permission_controller.dart';
import '../location_permission/location_permission_view.dart';
import '../no_internet_view.dart';
import '../otp/otp_verification_controller.dart';
import '../otp/otp_verification_view.dart';
import '../see_all product/collection_controller.dart';
import '../see_all product/collection_view.dart';
import '../sign_in/sign_in_controller.dart';
import '../sign_in/sign_in_view.dart';
import '../signup/sign_up_controller.dart';
import '../signup/sign_up_view.dart';
import '../store_search/store_search_view.dart';
import '../terms_and_condition/user_agreement_page.dart';
import '../update_password/update_password_controller.dart';
import '../update_password/update_password_view.dart';
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
        if (Get.isRegistered<CollectionController>()) {
          Get.delete<CollectionController>(force: true);
        }
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
      name: '/product-details/:id',
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


    GetPage(
      name: AppRoutes.noInternet,
      page: () => const NoInternetView(),
    ),
    GetPage(
      name: '/forget-password',
      page: () => const ForgetPasswordView(),
      binding: BindingsBuilder(() {
        Get.put(ForgetPasswordController());
      }),
    ),

    GetPage(
      name: AppRoutes.otpVerification,
      page: () => const OtpVerificationView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<OtpVerificationController>(() => OtpVerificationController(), fenix: true);
      }),
    ),
    GetPage(
      name: AppRoutes.updatePassword,
      page: () => const UpdatePasswordView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<UpdatePasswordController>(
              () => UpdatePasswordController(),
          fenix: true,
        );
      }),

    ),
    GetPage(
      name: AppRoutes.userAgreement,
      page: () => const DealzyloopUserAgreementPage(),
    ),



  ];
}
