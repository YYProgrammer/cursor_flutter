import "dart:async";
import "dart:io";
import "dart:typed_data";

import "package:app/base/cutil/JsonUtil.dart";
import "package:dartx/dartx.dart";
import "package:dio/dio.dart";
import "package:json_annotation/json_annotation.dart";

import "RestClient.dart";

part "StreamClient.g.dart";

class StreamClient {
  Dio dio;

  StreamClient(this.dio);

  Future<StreamResponse> request(
    String path,
    String method, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    ContentType? contentType,
  }) async {
    try {
      var res = await dio.request(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(
          method: method,
          headers: headers,
          contentType: contentType?.toString(),
          responseType: ResponseType.stream,
        ),
      );
      return _parseResponse(res);
    } catch (error) {
      return _parseError(error);
    }
  }

  Future<StreamResponse> _parseResponse(Response<dynamic> response) {
    var headers = <String, String>{};
    response.headers.forEach((name, values) {
      headers.putIfAbsent(name, () => values.first);
    });
    var statusCode = response.statusCode ?? 999;
    if (statusCode >= 200 && statusCode < 300) {
      return Future.value(StreamResponse(response));
    } else {
      var data = response.data;
      var statusMessage = response.statusMessage ?? "";
      return Future.error(RestRequestError(statusCode, statusMessage, headers, data));
    }
  }

  Future<StreamResponse> _parseError(Object error) {
    if (error is DioException) {
      if (error.response != null) {
        return _parseResponse(error.response!);
      }
    }
    return Future.error(error);
  }
}

String _getFulltext(List<String> dataItems) {
  var fulltext = "";
  for (var dataItem in dataItems) {
    var map = JsonUtil.parse(dataItem);
    if (map == null) continue;
    if (map["choices"] == null) continue;
    var dataItemTyped = StreamDataItem.fromJson(map);
    var choices = dataItemTyped.choices;
    var text = choices.isEmpty ? "" : choices[0].text ?? choices[0].delta?.content ?? "";
    fulltext += text;
  }
  return fulltext;
}

class StreamResponse {
  final StreamController _streamController = StreamController.broadcast(sync: true);
  final Response<dynamic> _response;
  String _bodyString = "";
  String _receiveString = "";
  String _lastReceiveString = "";
  String _fulltext = "";
  StreamParseResult _parseResult = StreamParseResult(false, [], "");
  List<String> _originItems = [];

  StreamResponse(this._response) {
    var responseBody = _response.data as ResponseBody;

    Future.delayed(const Duration(seconds: 0), () {
      late StreamSubscription<Uint8List> subscription;

      subscription = responseBody.stream.listen(
        (event) {
          try {
            var resString = String.fromCharCodes(event);
            if (resString.trim().isEmpty) {
              _receiveString = _lastReceiveString;
            } else if (resString.trim() == "[DONE]") {
              _receiveString = "$_lastReceiveString\n$resString";
            } else {
              _receiveString += resString;
              _lastReceiveString = _receiveString;
            }
            _bodyString += resString;

            _parseResult = StreamUtil.parse(_receiveString);
            _originItems = _parseResult.dataItems;
            if (_parseResult.done) {
              _fulltext += _getFulltext(_parseResult.dataItems);

              if (_fulltext.trim().isEmpty) {
                Future.delayed(const Duration(milliseconds: 500), () {
                  _streamController.add(StreamReadResult(_parseResult.done, _fulltext, "", _originItems));
                });
              } else {
                _streamController.add(StreamReadResult(_parseResult.done, _fulltext, "", _originItems));
              }

              Future.delayed(const Duration(seconds: 3), () {
                // 对于 Ask Brain，done 后面还有一段内容, 等待接收完
                subscription.cancel();
              });

              return;
            }
            _receiveString = _parseResult.remainder;

            for (var dataItem in _parseResult.dataItems) {
              var map = JsonUtil.parse(dataItem);
              if (map == null) continue;
              var dataItemTyped = StreamDataItem.fromJson(map);
              var choices = dataItemTyped.choices;
              var text = choices.isEmpty ? "" : choices[0].text ?? choices[0].delta?.content ?? "";
              _fulltext += text;

              if (text.isEmpty) continue;
              _streamController.add(StreamReadResult(_parseResult.done, _fulltext, text, _originItems));
            }
          } catch (error) {
            _streamController.add(StreamReadResult(false, _fulltext, "", _originItems));
          }
        },
        onDone: () {
          if (_parseResult.done == false) {
            Future.delayed(const Duration(milliseconds: 0), () {
              _streamController.add(StreamReadResult(true, _fulltext, "", _originItems));
            });
          }
        },
      );
    });
  }

  Stream<StreamReadResult> get stream {
    return _streamController.stream.cast<StreamReadResult>();
  }

  String get bodyString {
    return _bodyString;
  }

  bool get isSuccess {
    var statusCode = _response.statusCode ?? 999;
    return statusCode >= 200 && statusCode < 300;
  }
}

class StreamUtil {
  static StreamParseResult parse(String source) {
    List<String> dataItems = [];
    List<String> chars = [];
    bool done = false;

    for (var char in source.characters) {
      if (char == "\n" || char == "\r\n") {
        if (chars.isNotEmpty) {
          var str1 = chars.join("").trim();

          /// 删除数据项开头的字符：data:
          if (str1.startsWith("data: ")) {
            str1 = str1.substring(6);
          }

          if (str1 != "[DONE]") {
            dataItems.add(str1);
          } else {
            done = true;
            break;
          }
          chars = [];
        }
      } else {
        chars.add(char);
      }
    }

    var remainder = chars.join("");
    return StreamParseResult(done, dataItems, remainder);
  }
}

class StreamParseResult {
  bool done;
  List<String> dataItems;
  String remainder;

  StreamParseResult(this.done, this.dataItems, this.remainder);
}

@JsonSerializable()
class StreamDataItem {
  final String? id;
  final String? object;
  final num? created;
  final List<StreamDataItemChoices> choices;
  final String? model;

  StreamDataItem(this.id, this.object, this.created, this.choices, this.model);

  factory StreamDataItem.fromJson(Map<String, dynamic> json) => _$StreamDataItemFromJson(json);

  Map<String, dynamic> toJson() => _$StreamDataItemToJson(this);
}

@JsonSerializable()
class StreamDataItemChoices {
  final String? text;
  final int? index;
  final StreamDataChoiceMessage? message;
  final StreamDataChoiceMessage? delta;

  StreamDataItemChoices(this.text, this.index, this.message, this.delta);

  factory StreamDataItemChoices.fromJson(Map<String, dynamic> json) => _$StreamDataItemChoicesFromJson(json);

  Map<String, dynamic> toJson() => _$StreamDataItemChoicesToJson(this);
}

@JsonSerializable()
class StreamDataChoiceMessage {
  final String? content;
  final String? role;

  StreamDataChoiceMessage(this.content, this.role);

  factory StreamDataChoiceMessage.fromJson(Map<String, dynamic> json) => _$StreamDataChoiceMessageFromJson(json);

  Map<String, dynamic> toJson() => _$StreamDataChoiceMessageToJson(this);
}

@JsonSerializable()
class StreamReadResult {
  final bool done;
  final String? fulltext;
  final String? choiceText;
  final List<String> originTextItems;

  StreamReadResult(this.done, this.fulltext, this.choiceText, this.originTextItems);

  factory StreamReadResult.fromJson(Map<String, dynamic> json) => _$StreamReadResultFromJson(json);

  Map<String, dynamic> toJson() => _$StreamReadResultToJson(this);
}
