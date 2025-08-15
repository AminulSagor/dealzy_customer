import 'package:get/get.dart';

class NotificationItem {
  final String title;
  final String body;
  final String time;
  NotificationItem({required this.title, required this.body, required this.time});
}

class NotificationController extends GetxController {
  final items = <NotificationItem>[
    NotificationItem(
      title: '50% OFF On Your Favorite Items.',
      body:
      'Hurry! Get up to 50% OFF on your favorite items — only for the next 3 hours!  [Shop Now]',
      time: 'Saturday, 9AM',
    ),
    NotificationItem(
      title: '50% OFF On Your Favorite Items.',
      body:
      'Hurry! Get up to 50% OFF on your favorite items — only for the next 3 hours!  [Shop Now]',
      time: 'Saturday, 9AM',
    ),
    NotificationItem(
      title: '50% OFF On Your Favorite Items.',
      body:
      'Hurry! Get up to 50% OFF on your favorite items — only for the next 3 hours!  [Shop Now]',
      time: 'Saturday, 9AM',
    ),
  ].obs;
}
