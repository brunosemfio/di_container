import 'dart:async';

typedef Dispose<T> = FutureOr<void> Function(T);

typedef Factory<T> = T Function(DiContainer i);

class Wrapper<T> {
  Wrapper._(this._factory, this._singleton, [this._onDispose]);

  final T Function(DiContainer) _factory;

  final bool _singleton;

  final Dispose<T>? _onDispose;

  T? _instance;

  T call(DiContainer injector) {
    if (_singleton) return _instance ??= _factory(injector);
    return _factory(injector);
  }

  Future<void> dispose() async {
    if (_instance != null) {
      await _onDispose?.call(_instance as T);
      _instance = null;
    }
  }
}

class DiContainer {
  DiContainer._(this._services, this._imports);

  final Map<Type, Wrapper> _imports;

  final Map<Type, Wrapper> _services;

  Map<Type, Wrapper> get services => Map<Type, Wrapper>.unmodifiable(_services);

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

class DiContainerBuilder {
  DiContainerBuilder();

  final Map<Type, Wrapper> _imports = {};

  final Map<Type, Wrapper> _services = {};

  void import(DiContainer container) {
    container.services.forEach((key, value) {
      _imports.putIfAbsent(key, () => value);
    });
  }

  void add<T>(Factory<T> factory, {Dispose<T>? onDispose}) {
    _services.putIfAbsent(T, () => Wrapper<T>._(factory, true, onDispose));
  }

  void addFactory<T>(Factory<T> factory) {
    _services.putIfAbsent(T, () => Wrapper<T>._(factory, false));
  }

  DiContainer toContainer() {
    return DiContainer._(_services, _imports);
  }
}
