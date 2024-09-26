import "dart:convert";

import "package:app/base/cutil/Logger.dart";
import "package:flutter/foundation.dart";
import "package:tuple/tuple.dart";

class JsonUtil {
  static final Logger _logger = LoggerFactory.getLogger(JsonUtil);

  static String stringify(Object? object, {bool pretty = false}) {
    if (pretty) {
      return const JsonEncoder.withIndent("  ").convert(object);
    } else {
      return jsonEncode(object);
    }
  }

  static Future<String> stringifyAsync(Object? object, {bool pretty = false}) {
    var params = Tuple2(object, pretty);
    return compute((params) {
      if (params.item2) {
        return const JsonEncoder.withIndent("  ").convert(params.item1);
      } else {
        return jsonEncode(params.item1);
      }
    }, params);
  }

  static Map<String, dynamic>? parse(String source) {
    try {
      return jsonDecode(source);
    } catch (e) {
      _logger.e("parse json error: $e");
      return null;
    }
  }

  static List<Map<String, dynamic>>? parseList(String source) {
    try {
      return (jsonDecode(source) as List).map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      _logger.e("parse json list error: $e");
      return null;
    }
  }

  static Future<Map<String, dynamic>?> parseAsync(String source) async {
    var params = source;
    try {
      return await compute((params) {
        return jsonDecode(params);
      }, params);
    } catch (e) {
      _logger.e("parse json error: $e");
      return null;
    }
  }

  static String pretty(String content) {
    var map = JsonUtil.parse(content);
    if (map == null) return content;
    return JsonUtil.stringify(map, pretty: true);
  }

  static Future<String> prettyAsync(String content) {
    var params = content;
    return compute((params) {
      var map = JsonUtil.parse(params);
      if (map == null) return params;
      return JsonUtil.stringify(map, pretty: true);
    }, params);
  }

  static Map<String, dynamic> clone(Map<String, dynamic> map) {
    return jsonDecode(jsonEncode(map));
  }

  static Future<Map<String, dynamic>> cloneAsync(Map<String, dynamic> map) {
    var params = map;
    return compute((params) {
      return jsonDecode(jsonEncode(params));
    }, params);
  }
}
