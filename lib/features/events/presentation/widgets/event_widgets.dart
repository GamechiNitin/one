import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/presentation/widgets.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/theme_ext.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/event.dart';

class EventCard extends StatelessWidget {
  final Event event;
  const EventCard(this.event, {super.key});
  @override
  Widget build(BuildContext context) => AppCard(
        padding: const EdgeInsets.all(12),
        onTap: () => context.push(Routes.event(event.id)),
        child: Row(children: [
          SizedBox(width: 84, height: 84, child: Poster(event.art, aspect: 1)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(event.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
              Text(event.when, style: TextStyle(fontSize: 12, color: context.ink2)),
              Text(context.t('events.from', [rs(event.price)]), style: TextStyle(fontSize: 12, color: context.ink2)),
              const SizedBox(height: 8),
              GBtn(context.t('events.bookNow'), small: true, onTap: () => context.push(Routes.event(event.id))),
            ]),
          ),
        ]),
      );
}
