// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'StreamClient.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StreamDataItem _$StreamDataItemFromJson(Map<String, dynamic> json) => StreamDataItem(
      json['id'] as String?,
      json['object'] as String?,
      json['created'] as num?,
      (json['choices'] as List<dynamic>).map((e) => StreamDataItemChoices.fromJson(e as Map<String, dynamic>)).toList(),
      json['model'] as String?,
    );

Map<String, dynamic> _$StreamDataItemToJson(StreamDataItem instance) => <String, dynamic>{
      'id': instance.id,
      'object': instance.object,
      'created': instance.created,
      'choices': instance.choices,
      'model': instance.model,
    };

StreamDataItemChoices _$StreamDataItemChoicesFromJson(Map<String, dynamic> json) => StreamDataItemChoices(
      json['text'] as String?,
      (json['index'] as num?)?.toInt(),
      json['message'] == null ? null : StreamDataChoiceMessage.fromJson(json['message'] as Map<String, dynamic>),
      json['delta'] == null ? null : StreamDataChoiceMessage.fromJson(json['delta'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$StreamDataItemChoicesToJson(StreamDataItemChoices instance) => <String, dynamic>{
      'text': instance.text,
      'index': instance.index,
      'message': instance.message,
      'delta': instance.delta,
    };

StreamDataChoiceMessage _$StreamDataChoiceMessageFromJson(Map<String, dynamic> json) => StreamDataChoiceMessage(
      json['content'] as String?,
      json['role'] as String?,
    );

Map<String, dynamic> _$StreamDataChoiceMessageToJson(StreamDataChoiceMessage instance) => <String, dynamic>{
      'content': instance.content,
      'role': instance.role,
    };

StreamReadResult _$StreamReadResultFromJson(Map<String, dynamic> json) => StreamReadResult(
      json['done'] as bool,
      json['fulltext'] as String?,
      json['choiceText'] as String?,
      (json['originTextItems'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$StreamReadResultToJson(StreamReadResult instance) => <String, dynamic>{
      'done': instance.done,
      'fulltext': instance.fulltext,
      'choiceText': instance.choiceText,
      'originTextItems': instance.originTextItems,
    };
