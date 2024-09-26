import "dart:io";

import "package:app/base/cutil/JsonUtil.dart";
import "package:dio/dio.dart";

import "Error.dart";
import "Logger.dart";

abstract class RestClient {
  Future<RestResponse> request(
    String path,
    String method, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    ContentType? contentType,
  });

  Future<RestResponse> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    ContentType? contentType,
  });

  Future<RestResponse> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    ContentType? contentType,
  });

  Future<RestResponse> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    ContentType? contentType,
  });

  Future<RestResponse> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    ContentType? contentType,
  });

  Future<RestResponse> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    ContentType? contentType,
  });
}

class RestClientBase extends RestClient {
  Dio dio;

  RestClientBase(this.dio);

  @override
  Future<RestResponse> request(
    String path,
    String method, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    ContentType? contentType,
  }) async {
    try {
      var res = await dio.request(path,
          data: data,
          queryParameters: queryParameters,
          options: Options(
            method: method,
            headers: headers,
            contentType: contentType?.toString(),
          ));
      return _parseResponse(res);
    } catch (error) {
      return _parseError(error);
    }
  }

  @override
  Future<RestResponse> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    ContentType? contentType,
  }) async {
    return request(path, "GET", queryParameters: queryParameters, headers: headers, contentType: contentType);
  }

  @override
  Future<RestResponse> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    ContentType? contentType,
  }) async {
    return request(path, "POST",
        data: data, queryParameters: queryParameters, headers: headers, contentType: contentType);
  }

  @override
  Future<RestResponse> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    ContentType? contentType,
  }) async {
    return request(path, "PUT",
        data: data, queryParameters: queryParameters, headers: headers, contentType: contentType);
  }

  @override
  Future<RestResponse> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    ContentType? contentType,
  }) async {
    return request(path, "PATCH",
        data: data, queryParameters: queryParameters, headers: headers, contentType: contentType);
  }

  @override
  Future<RestResponse> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    ContentType? contentType,
  }) async {
    return request(path, "DELETE",
        data: data, queryParameters: queryParameters, headers: headers, contentType: contentType);
  }

  Future<RestResponse> _parseResponse(Response response) {
    var headers = <String, String>{};
    response.headers.forEach((name, values) {
      headers.putIfAbsent(name, () => values.first);
    });
    var statusCode = response.statusCode ?? 999;
    var statusMessage = response.statusMessage ?? "";
    var data = response.data;
    if (statusCode >= 200 && statusCode < 300) {
      return Future.value(RestResponse(statusCode, statusMessage, headers, data));
    } else {
      return Future.error(RestRequestError(statusCode, statusMessage, headers, data));
    }
  }

  Future<RestResponse> _parseError(Object error) {
    if (error is DioException) {
      if (error.response != null) {
        return _parseResponse(error.response!);
      }
    }
    return Future.error(error);
  }
}

extension RestClientExtension on Future<RestResponse> {
  Future<RestResponse<T>> toModel<T>(T Function(Map<String, dynamic>) parser) {
    return then((value) {
      dynamic data = value.data;
      if (data is String) {
        data = JsonUtil.parse(data);
      }
      var model = parser(data);
      return Future.value(RestResponse<T>(value.statusCode, value.statusMessage, value.headers, model));
    });
  }

  Future<RestResponse<Map<String, dynamic>>> toMap() {
    return then((value) {
      return Future.value(RestResponse(value.statusCode, value.statusMessage, value.headers, value.data));
    });
  }

  Future<RestResponse<T>> extractModel<T>(T Function(Map<String, dynamic>) handler) {
    return then((value) {
      var model = handler(value.data);
      return Future.value(RestResponse(value.statusCode, value.statusMessage, value.headers, model));
    });
  }

  Future<RestResponse<Map<String, dynamic>>> extractMap(Map<String, dynamic> Function(Map<String, dynamic>) handler) {
    return then((value) {
      var model = handler(value.data);
      return Future.value(RestResponse(value.statusCode, value.statusMessage, value.headers, model));
    });
  }

  Future<RestResponse> parseError(String? Function(RestResponse) handler) async {
    return onError((error, stackTrace) {
      if (error is RestRequestError) {
        error.setHandler(handler);
      }
      return Future.error(error!, stackTrace);
    });
  }
}

class RestResponse<T> {
  RestResponse(this.statusCode, this.statusMessage, this.headers, this.data);

  final int statusCode;
  final String statusMessage;
  final Map<String, String> headers;
  final T data;

  bool isOk() {
    return statusCode >= 200 && statusCode < 300;
  }
}

class RestRequestError extends RestResponse<dynamic> implements Exception, LocalizedError {
  RestRequestError(super.statusCode, super.statusMessage, super.headers, super.data);

  late final _logger = LoggerFactory.getLogger(this);

  String? Function(RestResponse)? _parseErrorHandler;

  void setHandler(String? Function(RestResponse) parseErrorHandler) {
    _parseErrorHandler = parseErrorHandler;
  }

  @override
  String get localizedDescription {
    if (_parseErrorHandler != null) {
      try {
        var message = _parseErrorHandler!(this);
        if (message != null) {
          return message;
        }
      } catch (error) {
        _logger.e("parseErrorHandler: $error");
      }
    }
    return "Sorry this operation could not be completed. Please try again.";
  }
}
