// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Settings _$SettingsFromJson(Map<String, dynamic> json) => Settings(
      packageName: json['packageName'] as String,
      baseUrl: json['baseUrl'] as String,
      languageCode: json['languageCode'] as String,
      mapboxPublicKey: json['mapboxPublicKey'] as String,
      ablyKey: json['ablyKey'] as String,
      payUrl: json['payUrl'] as String,
      payBearToken: json['payBearToken'] as String,
      payExecution: json['payExecution'] as String,
    );

Map<String, dynamic> _$SettingsToJson(Settings instance) => <String, dynamic>{
      'packageName': instance.packageName,
      'baseUrl': instance.baseUrl,
      'languageCode': instance.languageCode,
      'mapboxPublicKey': instance.mapboxPublicKey,
      'ablyKey': instance.ablyKey,
      'payUrl': instance.payUrl,
      'payBearToken': instance.payBearToken,
      'payExecution': instance.payExecution,
    };
