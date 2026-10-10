import '../../domain/entities/wallet.dart';

class WalletMapper {
  WalletMapper._();

  static Map<String, dynamic> snapshotToJson(WalletSnapshot s) => {
        'points': s.points,
        'balance': s.balance,
        'plan': s.plan,
        'missionDone': s.missionDone,
        'joinedParty': s.joinedParty,
        'billPaid': s.billPaid,
        'tx': s.tx.map((t) => [t.title, t.amount]).toList(),
      };

  static WalletSnapshot snapshotFromJson(Map<String, dynamic> j) => WalletSnapshot(
        points: (j['points'] as num).toInt(),
        balance: (j['balance'] as num).toInt(),
        plan: j['plan'] as String,
        missionDone: j['missionDone'] == true,
        joinedParty: j['joinedParty'] == true,
        billPaid: j['billPaid'] == true,
        tx: ((j['tx'] as List?) ?? const []).map((e) => TxEntry((e as List)[0] as String, e[1] as String)).toList(),
      );

  static WalletCatalog catalogFromJson(Map<String, dynamic> j) => WalletCatalog(
        (j['rewards'] as List).map((e) {
          final m = e as Map<String, dynamic>;
          return Reward(m['id'] as String, m['title'] as String, m['sub'] as String, (m['cost'] as num).toInt(), m['icon'] as String);
        }).toList(),
        (j['plans'] as List).map((e) {
          final m = e as Map<String, dynamic>;
          return Plan(m['name'] as String, (m['price'] as num).toInt(), m['desc'] as String, popular: m['popular'] == true);
        }).toList(),
      );
}
