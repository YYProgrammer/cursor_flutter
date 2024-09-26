import "package:logger/logger.dart";

class Properties {
  String? findProxy;
  String? findOutput;
  String? initialLocation;
  String? initialToken;
  bool isTry = false;
  String? logDir;
  Level? logLevel;
  bool? showFps;
  bool enableNetworkLogger = true;
  bool locationImplReturnDetailCoordinate = true;
}

Properties properties = Properties();
