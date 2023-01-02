import 'dart:async';

import 'di_container.dart';

typedef Dispose<T> = FutureOr<void> Function(T);

typedef Factory<T> = T Function(DiContainer i);
