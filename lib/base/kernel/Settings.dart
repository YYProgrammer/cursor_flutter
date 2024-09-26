import "package:app/base/cutil/Codable.dart";
import "package:json_annotation/json_annotation.dart";

part "Settings.g.dart";

enum AppEnv {
  production,
  development;

  static AppEnv fromPackageName(String packageName) {
    return _prodNames.contains(packageName) ? AppEnv.production : AppEnv.development;
  }
}

@JsonSerializable()
class Settings extends Codable {
  static Settings fromPackageName(String packageName) {
    var map = {
      "packageName": packageName,
      "baseUrl": "https://api-dev.braininc.net",
      "languageCode": "en",
      "mapboxPublicKey": "pk.eyJ1IjoiemhycmVuIiwiYSI6ImNqZmNpYW80NjIweWQzM216d2R5YnRrMnAifQ.NrFQhodO9IQFGIMkROeykg",
      "ablyKey": "9DARAA.YTQa9g:slBfNNHkwGHkLchf-Ih1XMvvHVmcQ2iR3Az-mMUdtTg",
      "payUrl": PayConstant.payUrlDev,
      "payBearToken": PayConstant.bearerTokenDev,
      "payExecution": "/be/exec/v2",
    };

    var env = AppEnv.fromPackageName(packageName);
    if (env == AppEnv.production) {
      map.addAll({
        "baseUrl": "https://api.braininc.net",
        "ablyKey": "xj3FbQ.JEMyoA:qCAuEQCzaIAt9xZHs0UpxZIJat0QPklXx19OmbHdviw",
        "payUrl": PayConstant.payUrlRelease,
        "payBearToken": PayConstant.bearerTokenRelease,
      });
    }
    return Settings.fromJson(map);
  }

  final String packageName;
  final String baseUrl;
  final String languageCode;
  final String mapboxPublicKey;
  final String ablyKey;

  String payUrl; // 支付url
  String payBearToken; // strip token
  String payExecution;

  Settings({
    required this.packageName,
    required this.baseUrl,
    required this.languageCode,
    required this.mapboxPublicKey,
    required this.ablyKey,
    required this.payUrl,
    required this.payBearToken,
    required this.payExecution,
  });

  factory Settings.fromJson(Map<String, dynamic> json) => _$SettingsFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SettingsToJson(this);

  AppEnv get env {
    return AppEnv.fromPackageName(packageName);
  }

  bool get isMock {
    return payUrl == PayConstant.payUrlDev;
  }

  bool get fromNative {
    return _prodNames.contains(packageName) || _devNames.contains(packageName);
  }

  StripeConfiguration get stripe {
    return StripeConfiguration(
      publishableKey: "pk_live_WjLjQrtjBqhtJjW1jxz2CIuP",
      appleMerchantIdentifier: "merchant.ai.natural",
    );
  }
}

var _prodNames = [
  "ai.brain.natural",
  "ai.brain.natural-adhoc",
  "ai.brain.imagine",
  "ai.brain.imagine-adhoc",
  "im.natural.app",
  "im.natural-qa.app",
  "natural.android.demo",
  "memory.braininc.net"
];
var _devNames = [
  "ai.brain.natural.dev",
  "ai.brain.natural-adhoc.dev",
  "ai.brain.imagine.dev",
  "ai.brain.imagine-adhoc.dev",
  "natural.android.demo.dev",
  "memory.brainllc.net"
];

class StripeConfiguration {
  String publishableKey;
  String appleMerchantIdentifier;
  String baseUrl = "https://api.stripe.com";

  StripeConfiguration({
    required this.publishableKey,
    required this.appleMerchantIdentifier,
  });
}

/// 支付里面用到的常量
class PayConstant {
  /// 真卡模式 支付 url
  static const payUrlRelease = "/payment";

  /// 假卡模式 支付url
  static const payUrlDev = "/payment-dev";

  /// 真卡模式 bearer token
  static const bearerTokenRelease = "Bearer pk_live_WjLjQrtjBqhtJjW1jxz2CIuP";

  /// 假卡模式 bearer token
  static const bearerTokenDev = "Bearer pk_test_NIze8HhvhrRznYeDZttRT3I6";
}

late Settings settings;
