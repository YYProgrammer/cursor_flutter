import "dart:core";

abstract class LocalizedError implements Exception {
  String get localizedDescription;
}

abstract class RuntimeError implements Exception {
  Error get cause;
}

class MetaError extends LocalizedError {
  MetaError(this.name, this.message, {this.data});

  String name;
  String message;
  dynamic data;

  @override
  String get localizedDescription => message;
}
