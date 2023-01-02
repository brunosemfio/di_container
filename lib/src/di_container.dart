import 'dart:async';

import 'di_wrapper.dart';

class DiContainer {
  DiContainer({
    required Map<Type, DiWrapper> services,
    Map<Type, DiWrapper> imports = const {},
  })  : _services = services,
        _imports = imports;

  final Map<Type, DiWrapper> _imports;

  final Map<Type, DiWrapper> _services;

  Map<Type, DiWrapper> get services =>
      Map<Type, DiWrapper>.unmodifiable(_services);

  T get<T extends Object>() {
    if (_services.containsKey(T)) return _services[T]!.call(this) as T;
    if (_imports.containsKey(T)) return _imports[T]!.call(this) as T;
    throw Exception("service '$T' not found");
  }

  T call<T extends Object>() => get<T>();

  Future<void> dispose() async {
    await Future.wait(_services.values.map((e) => e.dispose()));
  }
}
