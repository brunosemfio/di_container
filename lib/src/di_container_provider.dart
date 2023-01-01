import 'package:di_container/src/di_container.dart';
import 'package:flutter/material.dart';

class DiProvider extends StatefulWidget {
  const DiProvider({
    super.key,
    required this.builder,
    required this.child,
  });

  final DiContainerBuilder builder;

  final Widget child;

  @override
  State<DiProvider> createState() => _DiProviderState();
}

class _DiProviderState extends State<DiProvider> {
  late final DiContainer _container;

  @override
  void initState() {
    super.initState();
    final parent = context.findAncestorWidgetOfExactType<DiScope>();
    if (parent != null) widget.builder.import(parent.container);
    _container = widget.builder.toContainer();
  }

  @override
  Widget build(BuildContext context) {
    return DiScope(
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

class DiScope extends InheritedWidget {
  const DiScope({
    super.key,
    required this.container,
    required super.child,
  });

  final DiContainer container;

  @override
  bool updateShouldNotify(covariant DiScope oldWidget) {
    return oldWidget.container != container;
  }

  static DiContainer of(BuildContext context, {bool listen = false}) {
    final scope = listen
        ? context.dependOnInheritedWidgetOfExactType<DiScope>()
        : context.getElementForInheritedWidgetOfExactType<DiScope>()?.widget
            as DiScope?;

    if (scope == null) throw Exception('DiProvider não encontrado');

    return scope.container;
  }
}

extension DiProviderExp on BuildContext {
  T read<T extends Object>() => DiScope.of(this).get<T>();
}
