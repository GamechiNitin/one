import 'package:flutter_test/flutter_test.dart';
import 'package:one_app/core/domain/art.dart';
import 'package:one_app/core/error/failure.dart';
import 'package:one_app/core/result.dart';
import 'package:one_app/core/utils/formatters.dart';
import 'package:one_app/features/events/domain/entities/event.dart';
import 'package:one_app/features/marketplace/domain/entities/product.dart';

void main() {
  const art = Art('moons', [0xFF000000, 0xFF111111, 0xFF222222]);

  group('formatters', () {
    test('uses Indian digit grouping', () {
      expect(rs(999), '\u20B9999');
      expect(rs(1299), '\u20B91,299');
      expect(rs(123456), '\u20B91,23,456');
    });
  });

  group('Result', () {
    test('fold routes success and failure', () {
      const ok = Result<int>.ok(3);
      const err = Result<int>.err(ServerFailure('boom'));
      expect(ok.fold((f) => -1, (v) => v), 3);
      expect(err.fold((f) => f.message, (v) => 'x'), 'boom');
    });
  });

  group('EventQuote', () {
    const event = Event(
      id: 'e1',
      title: 'Show',
      cat: 'Concerts',
      venue: 'Hall',
      when: 'Fri',
      price: 1500,
      art: art,
      friends: [],
      offer: '',
      up: 'x',
    );

    test('applies 20% off for paid plans', () {
      final q = EventQuote.of(event, qty: 2, applyPass: true, planIsPaid: true);
      expect(q.base, 3000);
      expect(q.discount, 600);
      expect(q.total, 2400);
      expect(q.points, 250);
    });

    test('no discount on free plan or when pass is off', () {
      expect(
        EventQuote.of(
          event,
          qty: 2,
          applyPass: true,
          planIsPaid: false,
        ).discount,
        0,
      );
      expect(
        EventQuote.of(
          event,
          qty: 2,
          applyPass: false,
          planIsPaid: true,
        ).discount,
        0,
      );
    });
  });

  group('CartSummary', () {
    const hoodie = Product(
      id: 'p2',
      title: 'Hoodie',
      price: 3000,
      cat: 'Merch',
      brand: 'one',
      desc: '',
      member: true,
    );
    const mug = Product(
      id: 'p5',
      title: 'Mug',
      price: 500,
      cat: 'Merch',
      brand: 'one',
      desc: '',
    );

    test('member items get 10% off on paid plans', () {
      final s = CartSummary.compute(
        const {'p2': 1, 'p5': 2},
        const [hoodie, mug],
        planIsPaid: true,
      );
      expect(s.full, 4000);
      expect(s.total, 3700);
      expect(s.savings, 300);
      expect(s.count, 3);
    });

    test('ignores unknown products and empty quantities', () {
      final s = CartSummary.compute(
        const {'nope': 2, 'p5': 0},
        const [mug],
        planIsPaid: false,
      );
      expect(s.lines, isEmpty);
      expect(s.total, 0);
    });
  });
}
