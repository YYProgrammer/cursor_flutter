typedef LateloadHandler<T> = T Function();

class Lateload<T> {
  late LateloadHandler<T> _handler;
  T? _value;

  Lateload(LateloadHandler<T> handler) {
    _handler = handler;
  }

  T get() {
    _value ??= _handler();
    return _value!;
  }
}
