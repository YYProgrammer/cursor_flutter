import "package:app/base/cutil/Function.dart";

import "Codable.dart";
import "Msg.dart";

abstract class MsgHandler {
  Future<Codable> execute(Msg msg) async {
    throw UnimplementedError();
  }
}

class ImplMsgHandler extends MsgHandler {
  final Future<Codable> Function(Msg) _handler;

  ImplMsgHandler(this._handler);

  @override
  Future<Codable> execute(Msg msg) async {
    return _handler(msg);
  }
}

class MsgEvent {
  final Map<String, MsgHandler> _subscriptions = {};

  void on(dynamic TMsg, MsgHandler handler) {
    var name = naming(TMsg);
    _subscriptions[name] = handler;
  }

  void off(dynamic TMsg) {
    var name = naming(TMsg);
    _subscriptions.remove(name);
  }

  Future<Codable> emit(Msg msg) async {
    var name = naming(msg);
    var handler = _subscriptions[name];
    if (handler == null) {
      throw Exception("No handler for $name");
    }

    var result = await handler.execute(msg);
    return result;
  }

  dispose() {
    _subscriptions.clear();
  }
}
