import 'package:equatable/equatable.dart';

class TxEntry extends Equatable {
  final String title;
  final String amount;
  const TxEntry(this.title, this.amount);
  @override
  List<Object?> get props => [title, amount];
}

class WalletSnapshot extends Equatable {
  final int points;
  final int balance;
  final String plan;
  final List<TxEntry> tx;
  final bool missionDone;
  final bool joinedParty;
  final bool billPaid;

  const WalletSnapshot({
    required this.points,
    required this.balance,
    required this.plan,
    required this.tx,
    this.missionDone = false,
    this.joinedParty = false,
    this.billPaid = false,
  });

  static const initial = WalletSnapshot(
    points: 2450,
    balance: 5000,
    plan: 'Plus',
    tx: [TxEntry('Welcome reward', '+100 pts'), TxEntry('Wallet top-up', '+\u20B95,000')],
  );

  bool get isPaid => plan != 'Free';
  int get level => points ~/ 1000 + 1;
  int get levelProgress => points % 1000;

  WalletSnapshot copyWith({int? points, int? balance, String? plan, List<TxEntry>? tx, bool? missionDone, bool? joinedParty, bool? billPaid}) =>
      WalletSnapshot(
        points: points ?? this.points,
        balance: balance ?? this.balance,
        plan: plan ?? this.plan,
        tx: tx ?? this.tx,
        missionDone: missionDone ?? this.missionDone,
        joinedParty: joinedParty ?? this.joinedParty,
        billPaid: billPaid ?? this.billPaid,
      );

  @override
  List<Object?> get props => [points, balance, plan, tx, missionDone, joinedParty, billPaid];
}

class Reward extends Equatable {
  final String id, title, sub, icon;
  final int cost;
  const Reward(this.id, this.title, this.sub, this.cost, this.icon);
  @override
  List<Object?> get props => [id];
}

class Plan extends Equatable {
  final String name, desc;
  final int price;
  final bool popular;
  const Plan(this.name, this.price, this.desc, {this.popular = false});
  @override
  List<Object?> get props => [name];
}

class WalletCatalog extends Equatable {
  final List<Reward> rewards;
  final List<Plan> plans;
  const WalletCatalog(this.rewards, this.plans);
  @override
  List<Object?> get props => [rewards, plans];
}
