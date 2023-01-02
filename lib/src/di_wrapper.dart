import 'di_container.dart';
import 'types.dart';

class DiWrapper<T> {
  DiWrapper(
    this._factory, {
    this.onDispose,
  }) : singleton = true;

  DiWrapper.factory(this._factory)
      : singleton = false,
        onDispose = null;

  final T Function(DiContainer) _factory;

  final bool singleton;

  final Dispose<T>? onDispose;

  T? _instance;

  T call(DiContainer injector) {
    if (singleton) return _instance ??= _factory(injector);
    return _factory(injector);
  }

  Future<void> dispose() async {
    if (_instance != null) {
      await onDispose?.call(_instance as T);
      _instance = null;
    }
  }
}
