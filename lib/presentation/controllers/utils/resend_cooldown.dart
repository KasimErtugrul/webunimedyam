import 'dart:async';
import 'package:get/get.dart';

class ResendCooldown {
  ResendCooldown({this.duration = 60});

  final int duration;
  final seconds = 0.obs;
  Timer? _timer;

  bool get isActive => seconds.value > 0;

  void start() {
    _timer?.cancel();
    seconds.value = duration;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (seconds.value <= 1) {
        seconds.value = 0;
        t.cancel();
      } else {
        seconds.value--;
      }
    });
  }

  void dispose() => _timer?.cancel();
}