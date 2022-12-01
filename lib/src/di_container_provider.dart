import 'package:di_container/src/di_container.dart';
import 'package:flutter/material.dart';

class DiContainerProvider extends StatefulWidget {
  const DiContainerProvider({
    super.key,
    required this.builder,
    required this.child,
  });

  final DiContainerBuilder builder;

  final Widget child;

  @override
  State<DiContainerProvider> createState() => _DiContainerProviderState();
}

class _DiContainerProviderState extends State<DiContainerProvider> {
  late final DiContainer _container;

  @override
  void initState() {
    super.initState();

    final parent = context.findAncestorWidgetOfExactType<DiContainerScope>();

    if (parent != null) widget.builder.import(parent.container);

    _container = widget.builder.toContainer();
  }

  @override
  Widget build(BuildContext context) {
    return DiContainerScope(
      container: _container,
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _container.dispose();
    super.dispose();
  }
}

class DiContainerScope extends InheritedWidget {
  const DiContainerScope({
    super.key,
    required this.container,
    required super.child,
  });

  final DiContainer container;

  @override
  bool updateShouldNotify(covariant DiContainerScope oldWidget) {
    return oldWidget.container != container;
  }

  static DiContainer of(BuildContext context, {bool listen = false}) {
    final scope = listen
        ? context.dependOnInheritedWidgetOfExactType<DiContainerScope>()
        : context
            .getElementForInheritedWidgetOfExactType<DiContainerScope>()
            ?.widget as DiContainerScope?;

    if (scope == null) throw Exception('DiProvider não encontrado');

    return scope.container;
  }
}

extension DiProviderExp on BuildContext {
  T read<T extends Object>() => DiContainerScope.of(this).get<T>();
}
