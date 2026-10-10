import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'widgets.dart';
import '../theme/theme_ext.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()));
}

class ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const ErrorView({super.key, required this.onRetry});
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.cloud_off, size: 40, color: context.ink2),
            const SizedBox(height: 12),
            Text(context.t('state.errorTitle'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 6),
            Text(context.t('state.errorBody'), textAlign: TextAlign.center, style: TextStyle(color: context.ink2)),
            const SizedBox(height: 16),
            GBtn(context.t('state.retry'), small: true, onTap: onRetry),
          ]),
        ),
      );
}
