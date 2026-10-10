import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/result.dart';
import '../datasources/assistant_data_sources.dart';
import '../models/chat_mapper.dart';
import '../../domain/entities/chat.dart';
import '../../domain/repositories/assistant_repository.dart';

class AssistantRepositoryImpl implements AssistantRepository {
  final AssistantRemoteDataSource _remote;
  final AssistantLocalDataSource _local;
  const AssistantRepositoryImpl(this._remote, this._local);

  @override
  Future<Result<ChatMessage>> ask(String text, AssistantContext context) async {
    try {
      return Result.ok(ChatMapper.reply(await _remote.chat(text, context)));
    } on ServerException catch (e) {
      return Result.err(ServerFailure(e.message));
    } on NetworkException {
      return const Result.err(NetworkFailure());
    }
  }

  @override
  List<ChatMessage> loadHistory() =>
      _local.readHistory().map((e) => ChatMapper.fromJson((e as Map).cast<String, dynamic>())).toList();

  @override
  Future<void> saveHistory(List<ChatMessage> messages) {
    final last = messages.length > 40 ? messages.sublist(messages.length - 40) : messages;
    return _local.writeHistory(last.map(ChatMapper.toJson).toList());
  }

  @override
  Future<void> clearHistory() => _local.clear();
}
