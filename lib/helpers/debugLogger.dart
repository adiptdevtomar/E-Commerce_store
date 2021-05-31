import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import 'apiClient.dart';

debugLog(String log) {
  if (!kReleaseMode) {
    print('${DateFormat.yMd().add_Hms().format(DateTime.now())}  - $log');
  }
}

apiLog(String fn, ApiResponse response) {
  debugLog('[ApiClient] \t\t - $fn - $response');
}
