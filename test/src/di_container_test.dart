import 'package:di_container/di_container.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  test('deve retornar um singleton', () {
    final roulette = Roulette([1, 2, 3]);

    final container = createContainer((builder) {
      builder.add((i) => roulette.next());
    });

    final a = container.get<int>();
    final b = container.get<int>();

    expect(a == b, isTrue);
  });

  test('deve retornar uma nova instância', () {
    final roulette = Roulette([1, 2, 3]);

    final container = createContainer((builder) {
      builder.addFactory((i) => roulette.next());
    });

    final a = container.get<int>();
    final b = container.get<int>();

    expect(a != b, isTrue);
  });

  test('deve retornar um service pelo tipo inferido', () {
    final container = createContainer((builder) {
      builder
        ..add((i) => 1)
        ..add((i) => 2.0);
    });

    expect(container<int>(), 1);
    expect(container<double>(), 2.0);
    expect(() => container<num>(), throwsException);
  });

  test('deve retornar um service pelo tipo definido', () {
    final container = createContainer((builder) {
      builder.add<num>((i) => 1);
    });

    expect(container<num>(), 1);
    expect(() => container<int>(), throwsException);
  });

  test('deve retornar uma nova instância depois do [dispose]', () async {
    final roulette = Roulette([1, 2, 3]);

    final container = createContainer((builder) {
      builder.add((i) => roulette.next());
    });

    final a = container.get<int>();
    await container.dispose();
    final b = container.get<int>();

    expect(a != b, isTrue);
  });

  test('deve retornar um service importado', () {
    final roulette = Roulette<int>([1, 2, 3]);

    final parent = createContainer((builder) {
      builder.add((i) => roulette.next());
    });

    final child = createContainer((builder) {
      builder.import(parent);
    });

    final a = parent.get<int>();
    final b = child.get<int>();

    expect(a == b, isTrue);
  });

  test('deve retornar um service do filho', () {
    final parent = createContainer((builder) {
      builder.add((i) => 'parent');
    });

    final child = createContainer((builder) {
      builder.import(parent);
      builder.add((i) => 'child');
    });

    expect(child.get<String>(), 'child');
  });

  test('deve retornar uma exception caso o tipo não seja encontrado', () {
    final parent = createContainer((builder) {
      builder.add((i) => 1);
    });

    final child = createContainer((builder) {
      builder.import(parent);
      builder.add((i) => 2.0);
    });

    expect(() => child.get<num>(), throwsException);
  });

  test('deve chamar o [dispose] do service', () async {
    final dispose = Disposable();

    final container = createContainer((builder) {
      builder.add((i) => dispose, onDispose: (mock) => mock.dispose());
    });

    container.get<Disposable>();

    verifyNever(() => dispose.dispose());

    container.dispose();

    verify(() => dispose.dispose()).called(1);
  });
}

DiContainer createContainer(Function(DiContainerBuilder builder) delegate) {
  final builder = DiContainerBuilder();
  delegate.call(builder);
  return builder.toContainer();
}

class Roulette<T> {
  Roulette(this.items);

  final List<T> items;

  int _index = 0;

  T next() => items[_index++ % items.length];
}

class Disposable extends Mock {
  void dispose();
}
