import "dart:convert";

import "package:app/base/cutil/Msg.dart";
import "package:flutter/services.dart";
import "package:app/base/cutil/Logger.dart";
import "package:app/base/cutil/Function.dart";

import "package:app/base/cutil/Empty.dart";

typedef _FromJsonFunction = Msg Function(Map<String, dynamic> json);

class MsgRegistry {
  static final _logger = LoggerFactory.getLogger(MsgRegistry);

  static Msg get({
    required String name,
    required dynamic arguments,
  }) {
    _logger.i("get Msg, name $name, arguments: $arguments");

    _FromJsonFunction? func = _map[name];
    if (func != null) {
      if (arguments is String) {
        arguments = json.decode(arguments);
      }
      Msg msg = func(arguments);
      return msg;
    }

    _logger.i("PlatformException Method $name");
    throw PlatformException(code: "Unimplemented", details: "Method $name not implemented");
  }

  static final Map<String, _FromJsonFunction> _map = {
    naming(Empty): Empty.fromJson,
  };
}
