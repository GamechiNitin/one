import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/presentation/responsive.dart';
import '../../../../core/presentation/widgets.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_ext.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/chat.dart';
import '../bloc/assistant_bloc.dart';
import '../../../catalog/presentation/bloc/catalog_bloc.dart';
import '../../../events/presentation/bloc/events_bloc.dart';
import '../../../marketplace/presentation/bloc/market_blocs.dart';
import '../../../marketplace/presentation/widgets/product_tile.dart';
import '../../../wallet/presentation/bloc/wallet_bloc.dart';

class AssistantPage extends StatefulWidget {
  final String? initialQuestion;
  const AssistantPage({super.key, this.initialQuestion});
  @override
  State<AssistantPage> createState() => _AssistantPageState();
}

class _AssistantPageState extends State<AssistantPage> {
  final _ctl = TextEditingController();
  final _sc = ScrollController();

  @override
  void initState() {
    super.initState();
    final q = widget.initialQuestion;
    if (q != null && q.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.read<AssistantBloc>().add(AssistantMessageSent(q));
      });
    }
  }

  @override
  void dispose() {
    _ctl.dispose();
    _sc.dispose();
    super.dispose();
  }

  void _send(String text) {
    final v = text.trim();
    if (v.isEmpty) return;
    _ctl.clear();
    context.read<AssistantBloc>().add(AssistantMessageSent(v));
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AssistantBloc>().state;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_sc.hasClients) {
        _sc.animateTo(_sc.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
      }
    });
    final maxW = MediaQuery.sizeOf(context).width.clamp(0, 720) * .84;

    Widget bubble(ChatMessage m, {bool typing = false}) {
      final text = typing
          ? '\u2022 \u2022 \u2022'
          : (m.textKey != null ? context.t(m.textKey!, m.args) : m.text);
      return Align(
        alignment: m.fromUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          constraints: BoxConstraints(maxWidth: maxW.toDouble()),
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
          decoration: BoxDecoration(
            gradient: m.fromUser ? AppColors.gradient : null,
            color: m.fromUser ? null : context.card,
            border: m.fromUser ? null : Border.all(color: context.line),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(m.fromUser ? 16 : 5),
              bottomRight: Radius.circular(m.fromUser ? 5 : 16),
            ),
          ),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(text,
                    style: TextStyle(
                        color: m.fromUser ? Colors.white : context.ink,
                        fontSize: 14)),
                for (final c in m.cards) _ChatCard(c),
                if (m.actions.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Wrap(spacing: 8, runSpacing: 8, children: [
                      for (final a in m.actions)
                        GBtn(context.t('assistant.act.${a.key}'),
                            small: true, outline: true, onTap: () {
                          if (a.key == 'upgrade') {
                            context.push(Routes.pass);
                          } else {
                            context
                                .read<AssistantBloc>()
                                .add(AssistantActionTapped(a));
                          }
                        }),
                    ]),
                  ),
              ]),
        ),
      );
    }

    const suggestions = [
      'assistant.chip.fun',
      'assistant.chip.internet',
      'assistant.chip.billing',
      'assistant.chip.gifts',
      'assistant.chip.rewards'
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () =>
                context.canPop() ? context.pop() : context.go(Routes.home)),
        title: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.auto_awesome, size: 18, color: context.acc),
          const SizedBox(width: 6),
          Text(context.t('assistant.title'))
        ]),
        actions: [
          if (state.messages.isNotEmpty)
            IconButton(
                tooltip: context.t('assistant.clear'),
                icon: const Icon(Icons.delete_outline),
                onPressed: () => context
                    .read<AssistantBloc>()
                    .add(const AssistantCleared())),
        ],
      ),
      body: Column(children: [
        Expanded(
          child: ListView(
              controller: _sc,
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
              children: [
                if (state.messages.isEmpty) ...[
                  bubble(const ChatMessage(
                      fromUser: false, textKey: 'assistant.hello')),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    for (final q in suggestions)
                      Tap(
                        radius: 999,
                        onTap: () => _send(AppLocalizations.en(q)),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                              color: context.card,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: context.line)),
                          child: Text(context.t(q),
                              style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: context.ink2)),
                        ),
                      ),
                  ]),
                ],
                for (final m in state.messages) bubble(m),
                if (state.typing)
                  bubble(const ChatMessage(fromUser: false), typing: true),
              ]),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 10),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _ctl,
                  onSubmitted: _send,
                  textInputAction: TextInputAction.send,
                  decoration: InputDecoration(
                    hintText: context.t('assistant.hint'),
                    filled: true,
                    fillColor: context.card,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: context.line)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: context.line)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Tap(
                radius: 24,
                onTap: () => _send(_ctl.text),
                child: Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                        gradient: AppColors.gradient, shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_upward, color: Colors.white)),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}

/// Suggestion card inside a chat bubble. Resolves ids across catalog, events, and products.
class _ChatCard extends StatelessWidget {
  final String id;
  const _ChatCard(this.id);

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogBloc>().state.catalog;
    final events = context.watch<EventsBloc>().state;
    final market = context.watch<MarketBloc>().state;
    final paid = context.select((WalletBloc b) => b.state.wallet.isPaid);

    Widget thumb;
    String title, sub, route;
    final e = events.event(id);
    final p = market.product(id);
    final i = catalog.item(id);
    if (e != null) {
      thumb = CustomPaint(painter: ArtPainter(e.art));
      title = e.title;
      sub =
          '${e.when} · ${rs(e.price)}${paid ? ' · ${context.t('assistant.passPrice', [
                  rs(e.price * .8)
                ])}' : ''}';
      route = Routes.event(id);
    } else if (p != null) {
      thumb = productArt(p, badgeSize: 34);
      title = p.title;
      sub = rs(p.unitPrice(planIsPaid: paid));
      route = Routes.product(id);
    } else if (i != null) {
      thumb = CustomPaint(painter: ArtPainter(i.art));
      title = i.title;
      sub = i.meta;
      route = Routes.item(id);
    } else {
      return const SizedBox.shrink();
    }
    return Tap(
      onTap: () => context.push(route),
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: context.bgc,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: context.line)),
        child: Row(children: [
          SizedBox(
              width: 50,
              height: 50,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(10), child: thumb)),
          const SizedBox(width: 12),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: context.ink)),
              Text(sub,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11.5, color: context.ink2)),
            ]),
          ),
          Icon(Icons.chevron_right, color: context.ink2),
        ]),
      ),
    );
  }
}
