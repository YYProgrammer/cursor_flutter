class Result<T> {
  final T? _value;
  final Object? _error;

  Result(this._value, this._error);

  factory Result.fromError(Object error) => Result(null, error);

  factory Result.fromValue(T value) => Result(value, null);

  bool get isOk => _error == null;

  bool get isErr => _error != null;

  T? get ok {
    if (isOk) {
      return _value;
    } else {
      return null;
    }
  }

  Object? get err {
    if (isErr) {
      return _error;
    } else {
      return null;
    }
  }

  T getOrDefault(T defaultValue) {
    if (isOk) {
      return _value ?? defaultValue;
    } else {
      return defaultValue;
    }
  }

  T getOrElse(T Function(Object error) fun) {
    if (isOk) {
      return _value ?? fun("No value");
    } else {
      return fun(_error!);
    }
  }

  T? cast<T>() {
    return _value as T?;
  }
}
