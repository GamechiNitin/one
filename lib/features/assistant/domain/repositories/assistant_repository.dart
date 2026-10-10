import '../../../../core/result.dart';
import '../entities/chat.dart';

abstract class AssistantRepository {
  Future<Result<ChatMessage>> ask(String text, AssistantContext context);
  List<ChatMessage> loadHistory();
  Future<void> saveHistory(List<ChatMessage> messages);
  Future<void> clearHistory();
}
