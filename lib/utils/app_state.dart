import 'package:flutter/foundation.dart';

class AppState {
  // Global state for reservations
  static final ValueNotifier<List<Map<String, dynamic>>> reservedFrames = ValueNotifier([]);

  static void addReservation(Map<String, dynamic> frame) {
    // Check if already reserved
    bool exists = reservedFrames.value.any((item) => item['id'] == frame['id']);
    if (!exists) {
      reservedFrames.value = [...reservedFrames.value, frame];
    }
  }
}
