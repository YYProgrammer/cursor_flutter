// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'GraphqlClient.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GraphqlQuery _$GraphqlQueryFromJson(Map<String, dynamic> json) => GraphqlQuery(
      operationName: json['operationName'] as String,
      query: json['query'] as String,
      variables: json['variables'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$GraphqlQueryToJson(GraphqlQuery instance) => <String, dynamic>{
      'operationName': instance.operationName,
      'query': instance.query,
      'variables': instance.variables,
    };

GraphqlMutation _$GraphqlMutationFromJson(Map<String, dynamic> json) => GraphqlMutation(
      operationName: json['operationName'] as String,
      query: json['query'] as String,
      variables: json['variables'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$GraphqlMutationToJson(GraphqlMutation instance) => <String, dynamic>{
      'operationName': instance.operationName,
      'query': instance.query,
      'variables': instance.variables,
    };
