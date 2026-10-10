import '../../domain/entities/chat.dart';

class ChatMapper {
  ChatMapper._();

  static ChatMessage reply(Map<String, dynamic> j) => ChatMessage(
        fromUser: false,
        text: j['text'] as String? ?? '',
        cards: ((j['cards'] as List?) ?? const []).map((e) => e as String).toList(),
        actions: ((j['acts'] as List?) ?? const []).map((e) {
          final m = (e as Map).cast<String, dynamic>();
          return AssistantAction(m['key'] as String, m['label'] as String);
        }).toList(),
      );

  static Map<String, dynamic> toJson(ChatMessage m) => {
        'user': m.fromUser,
        'text': m.text,
        'textKey': m.textKey,
        'args': m.args.map((e) => '$e').toList(),
        'cards': m.cards,
        'acts': m.actions.map((a) => {'key': a.key, 'label': a.label}).toList(),
      };

  static ChatMessage fromJson(Map<String, dynamic> j) => ChatMessage(
        fromUser: j['user'] == true,
        text: j['text'] as String? ?? '',
        textKey: j['textKey'] as String?,
        args: ((j['args'] as List?) ?? const []).map((e) => e as Object).toList(),
        cards: ((j['cards'] as List?) ?? const []).map((e) => e as String).toList(),
        actions: ((j['acts'] as List?) ?? const []).map((e) {
          final m = (e as Map).cast<String, dynamic>();
          return AssistantAction(m['key'] as String, m['label'] as String);
        }).toList(),
      );
}
