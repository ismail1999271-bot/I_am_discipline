import 'package:flutter_test/flutter_test.dart';
import 'package:i_am_disiplin/data/campaigns.dart';

void main() {
  test('sevgililer günü aktif', () {
    expect(activeCampaign(DateTime(2027, 2, 14))?.id, 'sevgililer');
    expect(activeCampaign(DateTime(2027, 2, 15)), isNull);
  });
  test('anneler günü 2. pazar', () {
    expect(nthSunday(2027, 5, 2), DateTime(2027, 5, 9));
    expect(activeCampaign(DateTime(2027, 5, 9))?.id, 'anneler');
  });
  test('efsane cuma 2026', () {
    expect(blackFriday(2026), DateTime(2026, 11, 27));
    expect(activeCampaign(DateTime(2026, 11, 27))?.discount, 60);
  });
  test('indirimli fiyat', () {
    expect(discounted(100, DateTime(2027, 1, 5)), 50);
    expect(discounted(100, DateTime(2027, 7, 1)), 100);
  });
  test('sıradaki kampanya', () {
    expect(nextCampaign(DateTime(2026, 10, 25))?.id, '29_ekim');
  });
}
