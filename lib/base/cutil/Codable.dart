abstract class Codable {
  Codable();

  Map<String, dynamic> toJson() => <String, dynamic>{};

  factory Codable.fromJson(Map<String, dynamic> json) {
    throw UnimplementedError();
  }
}
