import 'di_container.dart';
import 'di_wrapper.dart';
import 'types.dart';

class DiContainerBuilder {
  DiContainerBuilder();

  final Map<Type, DiWrapper> _imports = {};

  final Map<Type, DiWrapper> _services = {};

  void import(DiContainer container) {
    container.services.forEach((key, value) {
      _imports.putIfAbsent(key, () => value);
    });
  }

  void add<T>(Factory<T> factory, {Dispose<T>? onDispose}) {
    _services.putIfAbsent(T, () {
      return DiWrapper<T>(factory, onDispose: onDispose);
    });
  }

  void addFactory<T>(Factory<T> factory) {
    _services.putIfAbsent(T, () {
      return DiWrapper<T>.factory(factory);
    });
  }

  void addContainer(DiContainer container) {
    _services.addAll(container.services);
  }

  DiContainer toContainer() {
    return DiContainer(
      services: _services,
      imports: _imports,
    );
  }
}
