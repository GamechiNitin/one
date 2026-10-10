import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/presentation/responsive.dart';
import '../../../../core/presentation/widgets.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/theme_ext.dart';
import '../../../catalog/presentation/bloc/catalog_bloc.dart';
import '../../../catalog/presentation/widgets/catalog_widgets.dart';
import '../../domain/entities/creator.dart';
import '../bloc/creators_bloc.dart';
import '../../../events/presentation/widgets/event_widgets.dart';
import '../../../events/presentation/bloc/events_bloc.dart';

class OpportunityRow extends StatelessWidget {
  final Opportunity opportunity;
  const OpportunityRow(this.opportunity, {super.key});
  @override
  Widget build(BuildContext context) {
    final state = context.watch<CreatorsBloc>().state;
    final c = state.byId[opportunity.creator];
    final done = state.prefs.applied.contains(opportunity.id);
    return ListRow(
      leading: c == null
          ? const SizedBox(width: 36)
          : Avatar(c.name, Color(c.color)),
      title: opportunity.title,
      sub: '${opportunity.sub}\n${opportunity.meta}',
      trailing: GBtn(
          done ? context.t('creators.applied') : context.t('creators.apply'),
          small: true,
          outline: done,
          onTap: () => context
              .read<CreatorsBloc>()
              .add(OpportunityApplied(opportunity.id))),
    );
  }
}

// ======================= Creator hub (tab) =======================
class CreatorsPage extends StatefulWidget {
  const CreatorsPage({super.key});
  @override
  State<CreatorsPage> createState() => _CreatorsPageState();
}

class _CreatorsPageState extends State<CreatorsPage> {
  String _t = 'forYou';
  @override
  Widget build(BuildContext context) {
    final state = context.watch<CreatorsBloc>().state;
    final catalog = context.watch<CatalogBloc>().state.catalog;
    final showCreators = _t == 'forYou' || _t == 'creators';
    final showOpps = _t != 'creators';
    return ListView(padding: const EdgeInsets.only(bottom: 100), children: [
      PageTitle(context.t('creators.title')),
      ChipRow(
        options: const ['forYou', 'creators', 'opportunities', 'brands'],
        selected: _t,
        labelOf: (o) => context.t('creators.tab.$o'),
        onSelect: (v) => setState(() => _t = v),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
        child: GradCard(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(context.t('creators.banner'),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(context.t('creators.bannerSub'),
                style: const TextStyle(color: Colors.white70, fontSize: 12.5)),
            const SizedBox(height: 14),
            GBtn(context.t('creators.join'),
                small: true,
                light: true,
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(context.t('creators.waitlist'))))),
          ]),
        ),
      ),
      if (showCreators) ...[
        SectionHeader(context.t('creators.featured')),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: GridView.count(
            crossAxisCount: context.cols(m: 2, t: 3, d: 4),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: .86,
            children: [
              for (final c in state.data.creators)
                AppCard(
                  onTap: () => context.push(Routes.creator(c.id)),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Avatar(c.name, Color(c.color), size: 70),
                        const SizedBox(height: 8),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                  child: Text(c.name,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13))),
                              const Verified(),
                            ]),
                        Text('${c.role} · ${c.followers}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                                TextStyle(fontSize: 11.5, color: context.ink2)),
                        const SizedBox(height: 10),
                        FollowButton(c.id),
                      ]),
                ),
            ],
          ),
        ),
        SectionHeader(context.t('creators.newFrom')),
        HRow(height: 168, children: [
          for (final i in catalog.byIds(const ['chapter', 'city', 'sess']))
            WideCard(i)
        ]),
      ],
      if (showOpps) ...[
        SectionHeader(_t == 'brands'
            ? context.t('creators.brandCollabs')
            : context.t('creators.latestOpps')),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Divided([
                for (final o in state.data.opportunities) OpportunityRow(o)
              ])),
        ),
      ],
    ]);
  }
}

class FollowButton extends StatelessWidget {
  final String creatorId;
  final bool expand;
  const FollowButton(this.creatorId, {super.key, this.expand = true});
  @override
  Widget build(BuildContext context) {
    final following = context.select(
        (CreatorsBloc b) => b.state.prefs.following.contains(creatorId));
    return GBtn(
        following ? context.t('common.following') : context.t('common.follow'),
        small: true,
        outline: following,
        expand: expand,
        onTap: () =>
            context.read<CreatorsBloc>().add(FollowToggled(creatorId)));
  }
}

// ======================= Creator profile =======================
class CreatorProfilePage extends StatefulWidget {
  final String creatorId;
  const CreatorProfilePage({super.key, required this.creatorId});
  @override
  State<CreatorProfilePage> createState() => _CreatorProfilePageState();
}

class _CreatorProfilePageState extends State<CreatorProfilePage> {
  String _t = 'portfolio';
  @override
  Widget build(BuildContext context) {
    final creators = context.watch<CreatorsBloc>().state;
    final c = creators.byId[widget.creatorId];
    if (c == null) return Scaffold(appBar: AppBar(), body: const SizedBox());
    final catalog = context.watch<CatalogBloc>().state.catalog;
    final works = catalog.items.where((i) => i.creator == c.id).toList();
    final events = context
        .watch<EventsBloc>()
        .state
        .events
        .where((e) => e.creator == c.id)
        .toList();
    final ops =
        creators.data.opportunities.where((o) => o.creator == c.id).toList();
    return Scaffold(
      appBar: AppBar(title: Text(context.t('creators.profile'))),
      body: ListView(padding: const EdgeInsets.only(bottom: 30), children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
          child: Row(children: [
            Avatar(c.name, Color(c.color), size: 76),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Flexible(
                          child: Text(c.name,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w800))),
                      const Verified()
                    ]),
                    Text(c.handle,
                        style: TextStyle(color: context.ink2, fontSize: 12.5)),
                    Text(c.loc,
                        style: TextStyle(color: context.ink2, fontSize: 12)),
                  ]),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
          child: AppCard(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(children: [
              for (final x in [
                ['86', context.t('profile.posts')],
                [c.followers, context.t('profile.followers')],
                ['210', context.t('profile.following')]
              ])
                Expanded(
                    child: Column(children: [
                  Text(x[0],
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 16)),
                  Text(x[1],
                      style: TextStyle(fontSize: 11.5, color: context.ink2))
                ])),
            ]),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
          child: Row(children: [
            Expanded(child: FollowButton(c.id)),
            const SizedBox(width: 10),
            Expanded(
                child: GBtn(context.t('creators.message'),
                    expand: true,
                    small: true,
                    outline: true,
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(context
                                .t('creators.messageSent', [c.name])))))),
          ]),
        ),
        Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
            child: Text(c.bio, style: TextStyle(color: context.ink2))),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [for (final t in c.tags) Pill(t)])),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
          child: Row(children: [
            for (final t in const ['portfolio', 'opportunities', 'about'])
              Expanded(
                child: Tap(
                  onTap: () => setState(() => _t = t),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                                color: _t == t ? context.acc : context.line,
                                width: 2.5))),
                    child: Text(context.t('creators.$t'),
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: _t == t ? context.acc : context.ink2)),
                  ),
                ),
              ),
          ]),
        ),
        if (_t == 'portfolio') ...[
          SectionHeader(context.t('creators.featuredWork')),
          if (works.isEmpty)
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: AppCard(
                    child: Center(
                        child: Text(context.t('creators.comingSoon'),
                            style: TextStyle(color: context.ink2)))))
          else
            HRow(height: 168, children: [for (final w in works) WideCard(w)]),
          if (events.isNotEmpty) ...[
            SectionHeader(context.t('creators.upcoming')),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(children: [
                  for (final e in events)
                    Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: EventCard(e))
                ])),
          ],
        ] else if (_t == 'opportunities')
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
            child: ops.isEmpty
                ? AppCard(
                    child: Center(
                        child: Text(context.t('creators.noRoles'),
                            style: TextStyle(color: context.ink2))))
                : AppCard(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Divided([for (final o in ops) OpportunityRow(o)])),
          )
        else
          Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
              child: AppCard(
                  child: Text(
                      '${c.bio}\n\n${context.t('creators.verifiedNote')}',
                      style: TextStyle(color: context.ink2)))),
      ]),
    );
  }
}
