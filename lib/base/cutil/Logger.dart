import "package:app/base/cutil/Function.dart";
import "package:app/base/kernel/Properties.dart";
import "package:dartx/dartx.dart";
import "package:flutter/foundation.dart";
import "package:logger/logger.dart" as logg;
import "package:logger/logger.dart";
import "package:web_socket_channel/web_socket_channel.dart";

class LoggerConfiguration {
  late String tag;
  final LogOutput output;
  final bool clearOutput;
  late final logg.Logger logger;

  LoggerConfiguration({
    required dynamic tag,
    required this.output,
    this.clearOutput = false,
  }) {
    this.tag = naming(tag);
    var printer = clearOutput ? LoggerClearPrinter(tag: [this.tag]) : LoggerPrettyPrinter(tag: [this.tag]);
    logger = logg.Logger(
      filter: kDebugMode || kProfileMode ? logg.DevelopmentFilter() : logg.ProductionFilter(),
      printer: printer,
      output: kIsWeb ? null : output,
    );
  }
}

class LoggerFactory {
  static List<LoggerConfiguration> _configs = [];
  static late LoggerConfiguration _defaultConfig;
  static LoggerConfiguration? _streamConfig;

  static Future<void> configure({
    required LoggerConfiguration defaultConfig,
    required List<LoggerConfiguration> configs,
  }) async {
    if (kReleaseMode) {
      logg.Logger.level = Level.info;
    } else {
      logg.Logger.level = properties.logLevel ?? Level.all;
    }

    _defaultConfig = defaultConfig;
    _configs = configs;

    if (properties.findOutput != null) {
      var output = await createOutput(properties.findOutput!);
      _streamConfig = LoggerConfiguration(
        tag: "",
        output: output,
      );
    }
  }

  static Logger getLogger(dynamic object) {
    var tag = naming(object);
    var config = _configs.firstOrNullWhere((element) => tag == element.tag);
    var printer = LoggerPrettyPrinter(tag: [tag]);
    var consoleLogger =
        kDebugMode || kProfileMode ? logg.Logger(filter: logg.DevelopmentFilter(), printer: printer) : null;
    var fileLogger = config?.logger;
    var defaultFileLogger = "api_detail" == tag ? null : _defaultConfig.logger;
    var streamLogger = "api_detail" == tag ? null : _streamConfig?.logger;
    return Logger(
      defaultFileLogger: defaultFileLogger,
      fileLogger: fileLogger,
      consoleLogger: consoleLogger,
      streamLogger: streamLogger,
    );
  }
}

class Logger {
  late final logg.Logger? _defaultFileLogger;
  late final logg.Logger? _fileLogger;
  late final logg.Logger? _consoleLogger;
  late final logg.Logger? _streamLogger;

  Logger({
    logg.Logger? defaultFileLogger,
    logg.Logger? fileLogger,
    logg.Logger? consoleLogger,
    logg.Logger? streamLogger,
  }) {
    _defaultFileLogger = defaultFileLogger;
    _fileLogger = fileLogger;
    _consoleLogger = consoleLogger;
    _streamLogger = streamLogger;
  }

  void t(dynamic message, [dynamic error, StackTrace? stackTrace, List<String> tag = const []]) {
    _defaultFileLogger?.t(message, error: error, stackTrace: stackTrace);
    _fileLogger?.t(message, error: error, stackTrace: stackTrace);
    _consoleLogger?.t(message, error: error, stackTrace: stackTrace);
    _streamLogger?.t(message, error: error, stackTrace: stackTrace);
  }

  void d(dynamic message, [dynamic error, StackTrace? stackTrace, List<String> tag = const []]) {
    _defaultFileLogger?.d(message, error: error, stackTrace: stackTrace);
    _fileLogger?.d(message, error: error, stackTrace: stackTrace);
    _consoleLogger?.d(message, error: error, stackTrace: stackTrace);
    _streamLogger?.d(message, error: error, stackTrace: stackTrace);
  }

  void i(dynamic message, [dynamic error, StackTrace? stackTrace, List<String> tag = const []]) {
    _defaultFileLogger?.i(message, error: error, stackTrace: stackTrace);
    _fileLogger?.i(message, error: error, stackTrace: stackTrace);
    _consoleLogger?.i(message, error: error, stackTrace: stackTrace);
    _streamLogger?.i(message, error: error, stackTrace: stackTrace);
  }

  void w(dynamic message, [dynamic error, StackTrace? stackTrace, List<String> tag = const []]) {
    _defaultFileLogger?.w(message, error: error, stackTrace: stackTrace);
    _fileLogger?.w(message, error: error, stackTrace: stackTrace);
    _consoleLogger?.w(message, error: error, stackTrace: stackTrace);
    _streamLogger?.w(message, error: error, stackTrace: stackTrace);
  }

  void e(dynamic message, [dynamic error, StackTrace? stackTrace, List<String> tag = const []]) {
    _defaultFileLogger?.e(message, error: error, stackTrace: stackTrace);
    _fileLogger?.e(message, error: error, stackTrace: stackTrace);
    _consoleLogger?.e(message, error: error, stackTrace: stackTrace);
    _streamLogger?.e(message, error: error, stackTrace: stackTrace);
  }
}

class LoggerPrettyPrinter extends logg.PrettyPrinter {
  List<String> tag;

  LoggerPrettyPrinter({this.tag = const []})
      : super(
          stackTraceBeginIndex: 0,
          methodCount: 3,
          errorMethodCount: 1,
          lineLength: 120,
          colors: false,
          printEmojis: true,
          printTime: true,
          excludeBox: const {},
          noBoxingByDefault: true,
        );

  @override
  List<String> log(logg.LogEvent event) {
    var list = super.log(event);
    list.removeAt(0);
    list.removeAt(0);
    var source = list.removeAt(0);
    if (source.length > 5) source = source.replaceRange(0, 5, "");
    var time = list.removeAt(0);

    var icon = "";
    var messages = [];
    for (var i = 0; i < list.length; i++) {
      var message = list[i];
      if (message.length > 2) {
        icon = message.substring(0, 2);
        message = message.replaceRange(0, 2, "");
      }
      messages.add(message);
    }

    var tagStr = "";
    if (tag.isNotEmpty) {
      tagStr = "${tag.join(",")} ";
    }

    var out = "$icon$time $source $tagStr${messages.join("\n")}";
    return [out];
  }
}

class LoggerClearPrinter extends logg.PrettyPrinter {
  List<String> tag;

  LoggerClearPrinter({this.tag = const []})
      : super(
          stackTraceBeginIndex: 0,
          methodCount: 3,
          errorMethodCount: 1,
          lineLength: 120,
          colors: false,
          printEmojis: true,
          printTime: true,
          excludeBox: const {},
          noBoxingByDefault: true,
        );

  @override
  List<String> log(logg.LogEvent event) {
    var list = super.log(event);
    list.removeAt(0);
    list.removeAt(0);
    list.removeAt(0);
    list.removeAt(0);

    var icon = "";
    var messages = [];
    for (var i = 0; i < list.length; i++) {
      var message = list[i];
      if (message.length > 2) {
        icon = message.substring(0, 2);
        message = message.replaceRange(0, 2, "");
      }
      messages.add(message);
    }

    var out = "$icon${messages.join("\n")}";
    return [out];
  }
}

Future<logg.LogOutput> createOutput(String uri) async {
  final wsUrl = Uri.parse(uri);
  final channel = WebSocketChannel.connect(wsUrl);

  await channel.ready;

  var output = StreamOutput();
  output.stream.listen((event) {
    for (var line in event) {
      channel.sink.add(line);
    }
  });
  return output;
}
