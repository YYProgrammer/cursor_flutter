typedef ObjectDeserializeHandler<T> = T Function(Map<String, dynamic> data);

class Paged<T> {
  List<T> items = [];
  int pageCount = 0;
  int pageIndex = 0;
  int pageSize = 20;
  int itemCount = 0;

  Paged(
    this.items,
    this.pageCount,
    this.pageIndex,
    this.pageSize,
    this.itemCount,
  );

  factory Paged.fromJson(Map<String, dynamic> json, [ObjectDeserializeHandler<T>? handler]) {
    var pageCount = json["pageCount"] ?? 0;
    var pageIndex = json["pageIndex"] ?? 0;
    var pageSize = json["pageSize"] ?? 0;
    var itemCount = json["itemCount"] ?? 0;

    List<T> items = [];
    List<dynamic> dataJson = json["items"];
    if (handler != null) {
      var result = dataJson.map((item) {
        return handler(item);
      });
      items = result.toList();
    }
    return Paged(items, pageCount, pageIndex, pageSize, itemCount);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "items": items,
      "pageCount": pageCount,
      "pageIndex": pageIndex,
      "pageSize": pageSize,
      "itemCount": itemCount
    };
  }
}
