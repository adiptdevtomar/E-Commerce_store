
class CustomException implements Exception {
  final String msg;
  const CustomException([this.msg]);

  @override
  String toString() {
    return "CustomException: ${this.msg.toString()}";
  }
}