import '../../../../core/error/failure.dart';
import '../../../../core/result.dart';
import '../../../../core/usecase.dart';
import '../../../../core/utils/formatters.dart';
import '../entities/chat.dart';
import '../repositories/assistant_repository.dart';
import '../../../wallet/domain/repositories/wallet_repository.dart';

class SendAssistantMessage extends UseCase<ChatMessage, String> {
  final AssistantRepository _repo;
  final WalletRepository _wallet;
  const SendAssistantMessage(this._repo, this._wallet);

  @override
  Future<Result<ChatMessage>> call(String text) {
    final w = _wallet.current;
    return _repo.ask(text, AssistantContext(wallet: w.balance, points: w.points, plan: w.plan, billPaid: w.billPaid));
  }
}

/// Runs an assistant action button (speed test, restart, pay bill, ...).
class RunAssistantAction extends UseCase<ChatMessage, String> {
  final WalletRepository _wallet;
  static const billAmount = 1299;
  const RunAssistantAction(this._wallet);

  @override
  Future<Result<ChatMessage>> call(String key) async {
    switch (key) {
      case 'speed':
        return const Result.ok(ChatMessage(fromUser: false, textKey: 'assistant.speedResult', actions: [AssistantAction('restart', 'Restart gateway')]));
      case 'restart':
        return const Result.ok(ChatMessage(fromUser: false, textKey: 'assistant.restarting'));
      case 'resettv':
        return const Result.ok(ChatMessage(fromUser: false, textKey: 'assistant.tvReset', actions: [AssistantAction('tech', 'Book technician')]));
      case 'tech':
        return const Result.ok(ChatMessage(fromUser: false, textKey: 'assistant.techBooked'));
      case 'paybill':
        final r = await _wallet.payBill(billAmount);
        return Result.ok(r.fold(
          (f) => f is InsufficientFundsFailure
              ? ChatMessage(fromUser: false, textKey: 'assistant.billShort', args: [rs(f.shortBy)])
              : const ChatMessage(fromUser: false, textKey: 'assistant.billAlready'),
          (_) => const ChatMessage(fromUser: false, textKey: 'assistant.billPaid'),
        ));
    }
    return const Result.err(ValidationFailure('Unknown action'));
  }
}
