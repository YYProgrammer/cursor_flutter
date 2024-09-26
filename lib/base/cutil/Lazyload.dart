import "package:app/base/cutil/Error.dart";
import "package:synchronized/synchronized.dart";
import "package:async/async.dart";

typedef LazyloadHandler<T> = Future<T> Function();

class _HandlerResult<T> {
  final T value;
  final Object? error;

  const _HandlerResult(this.value, this.error);
}

class Lazyload<T> {
  final Lock _lock = Lock();
  late final LazyloadHandler<T> _handler;
  T? _value;
  CancelableOperation<_HandlerResult<T>>? _cancelableOperation;

  Lazyload(LazyloadHandler<T> handler) {
    _handler = handler;
  }

  dirty() {
    _value = null;
  }

  Future<T> renew() async {
    _value = await _handler();
    return _value as T;
  }

  Future<T> get() async {
    if (_value != null) return _value as T;
    return await _lock.synchronized(() async {
      if (_value != null) return _value as T;

      Future<_HandlerResult<T>> wrappedHandler() async {
        try {
          T result = await _handler();
          return _HandlerResult(result, null);
        } catch (e) {
          rethrow;
        }
      }

      _cancelableOperation = CancelableOperation.fromFuture(wrappedHandler());
      _HandlerResult<T>? result = await _cancelableOperation!.valueOrCancellation();

      if (result == null) {
        throw MetaError("User Cancel", "Operation was cancelled");
      }

      _value = result.value;
      return _value as T;
    });
  }

  void cancel() {
    _cancelableOperation?.cancel();
  }

  bool get isDone => _value != null;

  T? get done => _value;
}
