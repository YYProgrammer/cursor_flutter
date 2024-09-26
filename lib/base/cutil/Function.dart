import "package:app/base/cutil/Result.dart";

String naming(dynamic object) {
  if (object is String) {
    return object;
  }
  if (object is Type) {
    return (object).toString().replaceAll(RegExp(r"<.*>"), "");
  }
  return object.runtimeType.toString().replaceAll(RegExp(r"<.*>"), "");
}

Object typing(dynamic object) {
  if (object is String) {
    return object;
  }
  if (object is Type) {
    return object;
  }
  return object.runtimeType;
}

Future<Result<T>> runFuture<T>(Future<T> future) async {
  try {
    var result = await future;
    return Result.fromValue(result);
  } catch (error) {
    return Result.fromError(error);
  }
}

Result<T> runBlocking<T>(T Function() block) {
  try {
    var result = block();
    return Result.fromValue(result);
  } catch (error) {
    return Result.fromError(error);
  }
}
