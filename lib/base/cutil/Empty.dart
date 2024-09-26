import "package:app/base/cutil/Msg.dart";

class Empty extends Msg {
  Empty();

  @override
  factory Empty.fromJson(Map<String, dynamic> json) {
    return Empty();
  }
}
