
import "package:spike_demo/helpers/CustomException.dart";

class NoInternetException implements CustomException {
  final String msg;
  const NoInternetException([this.msg]);

  @override
  String toString() {
    return "NoInternetException";
  }
}
