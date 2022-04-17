//Exception is an abstract class... ie a class that cant be directly instatiated
//implement implies all function of the class but be overwritten or implemented
class HttpException implements Exception {
  final String message;
  HttpException(this.message);

  @override
  String toString() {
    return message;
  }
}
