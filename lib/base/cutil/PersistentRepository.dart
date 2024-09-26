import "package:app/base/cutil/Function.dart";
import "package:hive_flutter/hive_flutter.dart";

class PersistentFactory {
  static bool _init = false;
  static registerAdapter<T>(TypeAdapter<T> adapter) {
    Hive.registerAdapter<T>(adapter);
  }

  static Future<Box<T>> _openBox<T>() async {
    if (!_init) {
      _init = true;
      await Hive.initFlutter();
    }

    return await Hive.openBox<T>(naming(T));
  }

  static PersistentRepository<T> getRepository<T extends PersistentKey>() {
    return PersistentRepository<T>();
  }
}

class PersistentKey {
  PersistentKey({required this.persistentKey});
  @HiveField(0, defaultValue: "")
  String persistentKey = "";
}

class PersistentRepository<T extends PersistentKey> {
  var _box = PersistentFactory._openBox<T>();

  Future<Box<T>> _getBox() async {
    var box = await _box;
    if (!box.isOpen) {
      _box = PersistentFactory._openBox<T>();
      box = await _box;
    }
    return box;
  }

  // 删除定义和记录
  Future<void> clear() async {
    var box = await _getBox();
    await box.deleteFromDisk();
    _box = PersistentFactory._openBox<T>();
  }

  Future<void> save(List<T> values) async {
    var box = await _getBox();
    var map = <String, T>{};
    for (var element in values) {
      map[element.persistentKey] = element;
    }

    await box.putAll(map);
    await box.flush();
  }

  Future<void> remove(List<T> values) async {
    var box = await _getBox();
    var keys = values.map((e) => e.persistentKey).toList();
    await box.deleteAll(keys);
    await box.flush();
  }

  Future<void> removeByKey(List<String> keys) async {
    var box = await _getBox();
    await box.deleteAll(keys);
    await box.flush();
  }

  // 删除所有记录
  Future<int> removeAll() async {
    var box = await _getBox();
    var count = await box.clear();
    await box.flush();
    return count;
  }

  Future<T?> get(bool Function(T) filter) async {
    var box = await _getBox();
    var list = box.values;
    list = list.where((element) => filter(element)).toList();
    return list.firstOrNull;
  }

  Future<T?> getByKey(String key) async {
    var box = await _getBox();
    var item = box.get(key);
    return item;
  }

  Future<List<T>> find(bool Function(T) filter) async {
    var box = await _getBox();
    var list = box.values.toList();
    list = list.where((element) => filter(element)).toList();
    return list;
  }
}
