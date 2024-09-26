import "dart:async";

import "package:app/base/cutil/Msg.dart";
import "package:app/base/cutil/Subscription.dart";

import "Error.dart";
import "Function.dart";

class Event {
  final StreamController _streamController;
  final Map<dynamic, dynamic> listeners = {};

  Event({bool sync = false}) : _streamController = StreamController.broadcast(sync: sync);

  void dispose() {
    listeners.clear();
    _streamController.close();
  }

  Subscription on<T>(dynamic Function(T msg) onData) {
    listeners[typing(T)] = onData;
    var subscription = _listen(onData);
    return Subscription(() {
      subscription.cancel();
      listeners.remove(typing(T));
    });
  }

  // 对所有监听者有效
  void emit(Msg event) {
    _streamController.add(event);
  }

  // 对最后一个监听者有效
  Future<dynamic> ask<T extends Msg>(T event) {
    var onData = listeners[typing(T)];
    if (onData != null) {
      return Future.value(onData(event));
    }
    return Future.error(MetaError("no_listener", "No listener for ${typing(T)}"));
  }

  Subscription _listen<T>(void Function(T msg) onData) {
    Stream<T> stream;
    if (T == dynamic) {
      stream = _streamController.stream as Stream<T>;
    } else {
      stream = _streamController.stream.where((event) => event is T).cast<T>();
    }

    var subscription = stream.listen(onData);
    return Subscription(() {
      subscription.cancel();
    });
  }
}
