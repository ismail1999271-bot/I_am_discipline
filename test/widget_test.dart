import 'package:flutter_test/flutter_test.dart';
import 'package:i_am_disiplin/services/xp_engine.dart';

void main() {
  test('Efsane eşiği', () {
    expect(ranks.last.name, 'Efsane');
    expect(ranks.last.xp, 110000);
    expect(ranks.length, 11);
  });
}
