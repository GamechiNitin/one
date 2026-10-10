import 'package:equatable/equatable.dart';

class AssistantAction extends Equatable {
  final String key, label;
  const AssistantAction(this.key, this.label);
  @override
  List<Object?> get props => [key];
}

/// A chat bubble. Server replies carry [text]; client-generated replies carry a localizable [textKey].
class ChatMessage extends Equatable {
  final bool fromUser;
  final String text;
  final String? textKey;
  final List<Object> args;
  final List<String> cards;
  final List<AssistantAction> actions;

  const ChatMessage({
    required this.fromUser,
    this.text = '',
    this.textKey,
    this.args = const [],
    this.cards = const [],
    this.actions = const [],
  });

  @override
  List<Object?> get props => [fromUser, text, textKey, args, cards, actions];
}

class AssistantContext extends Equatable {
  final int wallet, points;
  final String plan;
  final bool billPaid;
  const AssistantContext({required this.wallet, required this.points, required this.plan, required this.billPaid});
  @override
  List<Object?> get props => [wallet, points, plan, billPaid];
}
