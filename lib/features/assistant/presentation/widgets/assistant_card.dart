import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/presentation/responsive.dart';
import '../../../../core/presentation/widgets.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_ext.dart';

/// Entry card shown on Home and Help; opens the assistant, optionally with a first question.
class AssistantCard extends StatelessWidget {
  const AssistantCard({super.key});
  @override
  Widget build(BuildContext context) {
    const chips = ['assistant.chip.fun', 'assistant.chip.internet', 'assistant.chip.billing', 'assistant.chip.gifts'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: AppCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(gradient: AppColors.gradient, shape: BoxShape.circle),
              child: const Icon(Icons.auto_awesome, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(context.t('assistant.title'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                Text(context.t('assistant.subtitle'), style: TextStyle(fontSize: 12.5, color: context.ink2)),
              ]),
            ),
          ]),
          const SizedBox(height: 12),
          Tap(
            onTap: () => context.push(Routes.assistant()),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(color: context.bgc, borderRadius: BorderRadius.circular(14), border: Border.all(color: context.line)),
              child: Row(children: [
                Icon(Icons.search, size: 16, color: context.ink2),
                const SizedBox(width: 8),
                Text(context.t('assistant.askMe'), style: TextStyle(color: context.ink2, fontSize: 13)),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final q in chips)
              Tap(
                radius: 999,
                onTap: () => context.push(Routes.assistant(ask: AppLocalizations.en(q))),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(color: context.card, borderRadius: BorderRadius.circular(999), border: Border.all(color: context.line)),
                  child: Text(context.t(q), style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: context.ink2)),
                ),
              ),
          ]),
        ]),
      ),
    );
  }
}
