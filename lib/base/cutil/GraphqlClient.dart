import "dart:async";

import "package:json_annotation/json_annotation.dart";

import "RestClient.dart";

part "GraphqlClient.g.dart";

abstract class GraphqlClient {
  Future<RestResponse> query(GraphqlQuery query);

  Future<RestResponse> mutation(GraphqlMutation mutation);

  Future<RestResponse> mutationV2({required GraphqlMutation mutation});

  Future<RestResponse> hasura({required GraphqlQuery graphqlQuery});
}

@JsonSerializable()
class GraphqlQuery {
  late String operationName;
  late String query;
  late Map<String, dynamic> variables;

  GraphqlQuery({
    required this.operationName,
    required this.query,
    required this.variables,
  });

  factory GraphqlQuery.fromJson(Map<String, dynamic> json) => _$GraphqlQueryFromJson(json);

  Map<String, dynamic> toJson() => _$GraphqlQueryToJson(this);
}

@JsonSerializable()
class GraphqlMutation extends GraphqlQuery {
  GraphqlMutation({required super.operationName, required super.query, required super.variables});

  factory GraphqlMutation.fromJson(Map<String, dynamic> json) => _$GraphqlMutationFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$GraphqlMutationToJson(this);
}
