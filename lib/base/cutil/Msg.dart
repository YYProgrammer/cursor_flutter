import "Codable.dart";

abstract class Msg extends Codable {
  String get naming {
    return "";
  }
}
