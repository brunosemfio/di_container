import 'package:flutter/material.dart';

import 'di_container.dart';
import 'di_container_builder.dart';

class DiProvider extends StatefulWidget {
  const DiProvider({
    super.key,
    required this.container,
    required this.child,
  });

  final DiContainer container;

  final Widget child;

  @override
  State<DiProvider> createState() => _DiProviderState();
}

class _DiProviderState extends State<DiProvider> {
  late final DiContainer _container;

  @override
  void initState() {
    super.initState();
    final parent = context.findAncestorWidgetOfExactType<DiProviderScope>();
    final builder = DiContainerBuilder()..addContainer(widget.container);
    if (parent != null) builder.import(parent.container);
    _container = builder.toContainer();
  }

  @override
  Widget build(BuildContext context) {
    return DiProviderScope(
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

class DiProviderScope extends InheritedWidget {
  const DiProviderScope({
    super.key,
    required this.container,
    required super.child,
  });

  final DiContainer container;

  @override
  bool updateShouldNotify(DiProviderScope oldWidget) {
    return oldWidget.container != container;
  }

  static DiContainer of(BuildContext context) {
    final scope = context
        .getElementForInheritedWidgetOfExactType<DiProviderScope>()
        ?.widget as DiProviderScope?;

    if (scope == null) throw Exception('DiProvider não encontrado');

    return scope.container;
  }
}

extension DiProviderExp on BuildContext {
  T di<T extends Object>() => DiProviderScope.of(this).get<T>();
}
