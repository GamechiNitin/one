import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/presentation/state_views.dart';
import '../../../../core/presentation/responsive.dart';
import '../../../../core/presentation/widgets.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_ext.dart';
import '../../../../core/utils/formatters.dart';
import '../../../catalog/presentation/bloc/catalog_bloc.dart';
import '../../../catalog/presentation/pages/catalog_detail_pages.dart' show BackCircle;
import '../../../creators/presentation/bloc/creators_bloc.dart';
import '../../domain/entities/event.dart';
import '../bloc/events_bloc.dart';
import '../widgets/event_widgets.dart';
import '../../../wallet/presentation/bloc/wallet_bloc.dart';

// ======================= Events list =======================
class EventsPage extends StatefulWidget {
  final String initialCategory;
  const EventsPage({super.key, this.initialCategory = 'All'});
  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  late String _cat = widget.initialCategory;
  @override
  Widget build(BuildContext context) {
    final state = context.watch<EventsBloc>().state;
    final list = state.events.where((e) => _cat == 'All' || e.cat == _cat).toList();
    return Scaffold(
      appBar: AppBar(title: Text(context.t('home.events'))),
      body: state.events.isEmpty && state.status == LoadStatus.failure
          ? ErrorView(onRetry: () => context.read<EventsBloc>().add(const EventsRequested()))
          : ListView(children: [
              ChipRow(options: const ['All', 'Concerts', 'Sports', 'Movies', 'Gaming'], selected: _cat, labelOf: (o) => context.t('events.cat.$o'), onSelect: (v) => setState(() => _cat = v)),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 30),
                child: Column(children: [for (final e in list) Padding(padding: const EdgeInsets.only(bottom: 12), child: EventCard(e))]),
              ),
            ]),
    );
  }
}

// ======================= Event detail =======================
class EventDetailPage extends StatefulWidget {
  final String eventId;
  const EventDetailPage({super.key, required this.eventId});
  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  int _qty = 2;
  bool _pass = true;
  bool _offer = false;

  @override
  Widget build(BuildContext context) {
    final event = context.watch<EventsBloc>().state.event(widget.eventId);
    if (event == null) return Scaffold(appBar: AppBar(), body: const LoadingView());
    final wallet = context.watch<WalletBloc>().state.wallet;
    final creator = event.creator == null ? null : context.watch<CreatorsBloc>().state.byId[event.creator];
    final quote = EventQuote.of(event, qty: _qty, applyPass: _pass, planIsPaid: wallet.isPaid);

    Widget line(IconData ic, Widget child) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 11),
          child: Row(children: [Icon(ic, size: 20, color: context.ink2), const SizedBox(width: 12), Expanded(child: child)]),
        );

    return Scaffold(
      body: Column(children: [
        Expanded(
          child: ListView(padding: EdgeInsets.zero, children: [
            SizedBox(
              height: 300,
              child: Stack(fit: StackFit.expand, children: [
                CustomPaint(painter: ArtPainter(event.art)),
                const Shade(),
                const BackCircle(),
                Positioned(
                  left: 18,
                  right: 18,
                  bottom: 18,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                    TagChip(context.t('events.cat.${event.cat}')),
                    const SizedBox(height: 8),
                    Text(event.title, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
                    Text(event.when, style: const TextStyle(color: Colors.white70)),
                  ]),
                ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
              child: Column(children: [
                line(Icons.place_outlined, Text(event.venue)),
                Divider(height: 1, color: context.line),
                line(
                  Icons.groups_outlined,
                  Row(children: [
                    for (var k = 0; k < event.friends.length; k++) Padding(padding: const EdgeInsets.only(right: 4), child: Avatar(event.friends[k], AppColors.spectrum[(k * 2 + 1) % 6], size: 30)),
                    const SizedBox(width: 6),
                    Expanded(child: Text(event.friends.length > 1 ? context.t('events.friendsGoing', [event.friends.first, event.friends.length - 1]) : context.t('events.friendGoing', [event.friends.first]))),
                  ]),
                ),
                Divider(height: 1, color: context.line),
                line(Icons.card_giftcard, Row(children: [Expanded(child: Text(event.offer)), Switch(value: _offer, onChanged: (v) => setState(() => _offer = v))])),
                Divider(height: 1, color: context.line),
                line(
                  Icons.star_outline,
                  Row(children: [
                    Expanded(child: Text(wallet.isPaid ? context.t('events.passOff', [wallet.plan]) : context.t('events.getPassOff'))),
                    if (wallet.isPaid) Switch(value: _pass, onChanged: (v) => setState(() => _pass = v)) else GBtn(context.t('events.upgrade'), small: true, onTap: () => context.push(Routes.pass)),
                  ]),
                ),
                Divider(height: 1, color: context.line),
                line(
                  Icons.confirmation_number_outlined,
                  Row(children: [
                    Expanded(child: Text(context.t('events.tickets'))),
                    _Step(Icons.remove, () => setState(() => _qty = math.max(1, _qty - 1))),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 14), child: Text('$_qty', style: const TextStyle(fontWeight: FontWeight.w800))),
                    _Step(Icons.add, () => setState(() => _qty = math.min(6, _qty + 1))),
                  ]),
                ),
                if (creator != null) ...[
                  const SizedBox(height: 10),
                  AppCard(
                    onTap: () => context.push(Routes.creator(creator.id)),
                    child: Row(children: [
                      Avatar(creator.name, Color(creator.color)),
                      const SizedBox(width: 12),
                      Expanded(child: Row(children: [Text(creator.name, style: const TextStyle(fontWeight: FontWeight.w700)), const Verified()])),
                      const Icon(Icons.chevron_right),
                    ]),
                  ),
                ],
                const SizedBox(height: 14),
                Row(children: [
                  GBtn(context.t('events.exportCard'), small: true, outline: true, icon: Icons.ios_share, onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.t('events.exported'))))),
                  const SizedBox(width: 10),
                  GBtn(context.t('events.addCalendar'), small: true, outline: true, icon: Icons.event_outlined, onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.t('events.calendarAdded'))))),
                ]),
                const SizedBox(height: 12),
                Align(alignment: Alignment.centerLeft, child: Text(context.t('events.earn', [quote.points]), style: TextStyle(color: context.ink2, fontSize: 12.5))),
                const SizedBox(height: 24),
              ]),
            ),
          ]),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(18, 12, 18, 12 + MediaQuery.of(context).padding.bottom),
          decoration: BoxDecoration(color: context.card, border: Border(top: BorderSide(color: context.line))),
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(quote.discount > 0 ? '${rs(quote.base)} · ${context.t('events.passApplied')}' : context.t('events.total'), style: TextStyle(fontSize: 12, color: context.ink2)),
                Text(rs(quote.total), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              ]),
            ),
            GBtn(context.t('events.bookNow'), onTap: () => context.push(Routes.checkout(event.id, qty: _qty, pass: _pass))),
          ]),
        ),
      ]),
    );
  }
}

class _Step extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _Step(this.icon, this.onTap);
  @override
  Widget build(BuildContext context) => Tap(
        radius: 16,
        onTap: onTap,
        child: Container(width: 32, height: 32, decoration: BoxDecoration(color: context.card, shape: BoxShape.circle, border: Border.all(color: context.line)), child: Icon(icon, size: 16)),
      );
}

// ======================= Checkout =======================
class CheckoutPage extends StatelessWidget {
  final String eventId;
  final int qty;
  final bool pass;
  const CheckoutPage({super.key, required this.eventId, required this.qty, required this.pass});

  @override
  Widget build(BuildContext context) {
    final events = context.watch<EventsBloc>().state;
    final event = events.event(eventId);
    if (event == null) return Scaffold(appBar: AppBar(), body: const LoadingView());
    final wallet = context.watch<WalletBloc>().state.wallet;
    final q = EventQuote.of(event, qty: qty, applyPass: pass, planIsPaid: wallet.isPaid);

    Widget row(String l, String r, {Color? c, bool bold = false}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(l, style: TextStyle(fontWeight: bold ? FontWeight.w800 : FontWeight.w500)),
            Text(r, style: TextStyle(fontWeight: FontWeight.w800, color: c, fontSize: bold ? 18 : 14)),
          ]),
        );

    return BlocListener<EventsBloc, EventsState>(
      listenWhen: (a, b) => a.booking != b.booking,
      listener: (context, s) {
        if (s.booking == BookingStatus.success && s.lastTicketId != null) context.pushReplacement(Routes.booked(s.lastTicketId!));
      },
      child: Scaffold(
        appBar: AppBar(title: Text(context.t('checkout.title'))),
        body: ListView(padding: const EdgeInsets.all(18), children: [
          AppCard(
            child: Column(children: [
              Row(children: [
                SizedBox(width: 60, height: 60, child: Poster(event.art, aspect: 1, radius: 14)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(event.title, style: const TextStyle(fontWeight: FontWeight.w800)), Text(event.when, style: TextStyle(fontSize: 12, color: context.ink2))])),
              ]),
              const SizedBox(height: 8),
              row(context.t('checkout.nTickets', [qty]), rs(q.base)),
              if (q.discount > 0) row(context.t('checkout.passDiscount', [wallet.plan]), '\u2212${rs(q.discount)}', c: AppColors.ok),
              Divider(color: context.line),
              row(context.t('events.total'), rs(q.total), bold: true),
            ]),
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Row(children: [
              const IconTile(Icons.account_balance_wallet_outlined),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(context.t('wallet.title'), style: const TextStyle(fontWeight: FontWeight.w700)), Text(context.t('wallet.balance', [rs(wallet.balance)]), style: TextStyle(fontSize: 12, color: context.ink2))])),
              Pill(context.t('checkout.selected')),
            ]),
          ),
          const SizedBox(height: 14),
          Text(context.t('events.earn', [q.points]), style: TextStyle(color: context.ink2)),
          const SizedBox(height: 14),
          GBtn(context.t('checkout.pay', [rs(q.total)]), expand: true, onTap: events.booking == BookingStatus.submitting ? null : () => context.read<EventsBloc>().add(BookingSubmitted(event, qty, pass))),
          if (wallet.balance < q.total) Padding(padding: const EdgeInsets.only(top: 10), child: Text(context.t('msg.lowBalance'), style: const TextStyle(color: AppColors.live, fontSize: 12.5))),
        ]),
      ),
    );
  }
}

// ======================= Booked =======================
class BookedPage extends StatelessWidget {
  final String ticketId;
  const BookedPage({super.key, required this.ticketId});

  @override
  Widget build(BuildContext context) {
    final events = context.watch<EventsBloc>().state;
    final catalog = context.watch<CatalogBloc>().state.catalog;
    final t = events.ticket(ticketId);
    final e = t == null ? null : events.event(t.eventId);
    if (t == null || e == null) return Scaffold(appBar: AppBar(), body: const LoadingView());
    final up = catalog.item(e.up);
    return Scaffold(
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.all(18), children: [
          const SizedBox(height: 30),
          Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: .3, end: 1),
              duration: const Duration(milliseconds: 500),
              curve: Curves.elasticOut,
              builder: (_, v, child) => Transform.scale(scale: v, child: child),
              child: Container(width: 72, height: 72, decoration: const BoxDecoration(color: AppColors.ok, shape: BoxShape.circle), child: const Icon(Icons.check, color: Colors.white, size: 40)),
            ),
          ),
          const SizedBox(height: 16),
          Center(child: Text(context.t('booked.title'), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800))),
          Center(child: Text(context.t('booked.subtitle', [t.qty, e.title]), style: TextStyle(color: context.ink2))),
          const SizedBox(height: 20),
          Center(
            child: TweenAnimationBuilder<int>(
              tween: IntTween(begin: 0, end: t.qty * 125),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOutCubic,
              builder: (_, v, __) => Text('+$v', style: TextStyle(fontSize: 40, fontWeight: FontWeight.w800, color: context.acc)),
            ),
          ),
          Center(child: Text(context.t('booked.pointsAdded'), style: TextStyle(color: context.ink2, fontSize: 12.5))),
          const SizedBox(height: 22),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(children: [
              SizedBox(height: 84, child: Poster(e.art, aspect: 4, radius: 16)),
              Padding(padding: const EdgeInsets.all(14), child: Align(alignment: Alignment.centerLeft, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(e.when, style: const TextStyle(fontWeight: FontWeight.w700)), Text(e.venue, style: TextStyle(fontSize: 12, color: context.ink2))]))),
            ]),
          ),
          if (up != null) ...[
            const SizedBox(height: 22),
            Text(context.t('booked.upNext'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            Text(context.t('booked.because', [e.title]), style: TextStyle(fontSize: 12.5, color: context.ink2)),
            const SizedBox(height: 8),
            AppCard(
              onTap: () => context.push(Routes.item(up.id)),
              padding: const EdgeInsets.all(8),
              child: Row(children: [
                SizedBox(width: 50, height: 50, child: Poster(up.art, aspect: 1, radius: 10)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(up.title, style: const TextStyle(fontWeight: FontWeight.w700)), Text(up.meta, style: TextStyle(fontSize: 12, color: context.ink2))])),
                const Icon(Icons.chevron_right),
              ]),
            ),
          ],
          const SizedBox(height: 18),
          Row(children: [
            Expanded(child: GBtn(context.t('booked.viewTicket'), expand: true, onTap: () => context.pushReplacement(Routes.ticket(ticketId)))),
            const SizedBox(width: 10),
            Expanded(child: GBtn(context.t('common.done'), expand: true, outline: true, onTap: () => context.go(Routes.home))),
          ]),
        ]),
      ),
    );
  }
}

// ======================= Ticket =======================
class _QrPainter extends CustomPainter {
  final int seed;
  _QrPainter(this.seed);
  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / 21;
    final p = Paint()..color = const Color(0xFF111111);
    var x = seed * 9301 + 49297;
    for (var r = 0; r < 21; r++) {
      for (var c = 0; c < 21; c++) {
        x = (x * 1103515245 + 12345) & 0x7fffffff;
        final finder = (r < 7 && c < 7) || (r < 7 && c > 13) || (r > 13 && c < 7);
        bool on;
        if (finder) {
          final rr = r < 7 ? r : r - 14;
          final cc = c < 7 ? c : c - 14;
          on = rr == 0 || rr == 6 || cc == 0 || cc == 6 || (rr > 1 && rr < 5 && cc > 1 && cc < 5);
        } else {
          on = x % 100 < 48;
        }
        if (on) canvas.drawRect(Rect.fromLTWH(c * cell, r * cell, cell, cell), p);
      }
    }
  }

  @override
  bool shouldRepaint(_QrPainter o) => o.seed != seed;
}

class TicketPage extends StatelessWidget {
  final String ticketId;
  const TicketPage({super.key, required this.ticketId});
  @override
  Widget build(BuildContext context) {
    final events = context.watch<EventsBloc>().state;
    final t = events.ticket(ticketId);
    final e = t == null ? null : events.event(t.eventId);
    if (t == null || e == null) return Scaffold(appBar: AppBar(), body: const LoadingView());
    return Scaffold(
      appBar: AppBar(title: Text(context.t('ticket.title'))),
      body: ListView(padding: const EdgeInsets.all(18), children: [
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(children: [
            SizedBox(height: 110, child: Poster(e.art, aspect: 4, radius: 16)),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(e.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text('${e.when}\n${e.venue}', style: TextStyle(color: context.ink2, fontSize: 12.5)),
                const SizedBox(height: 12),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(context.t('checkout.nTickets', [t.qty]), style: TextStyle(color: context.ink2, fontSize: 12.5)),
                  Text(context.t('ticket.order', [t.id]), style: TextStyle(color: context.ink2, fontSize: 12.5)),
                ]),
                const SizedBox(height: 14),
                Center(child: Container(width: 166, height: 166, padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)), child: CustomPaint(painter: _QrPainter(t.seed)))),
                const SizedBox(height: 10),
                Center(child: Text(context.t('ticket.showCode'), style: TextStyle(color: context.ink2, fontSize: 12.5))),
              ]),
            ),
          ]),
        ),
      ]),
    );
  }
}

class TicketsPage extends StatelessWidget {
  const TicketsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final s = context.watch<EventsBloc>().state;
    return Scaffold(
      appBar: AppBar(title: Text(context.t('home.events'))),
      body: ListView(padding: const EdgeInsets.all(18), children: [
        if (s.tickets.isEmpty)
          AppCard(child: Column(children: [
            Text(context.t('tickets.none'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 6),
            Text(context.t('tickets.noneBody'), style: TextStyle(color: context.ink2)),
            const SizedBox(height: 12),
            GBtn(context.t('tickets.browse'), small: true, onTap: () => context.push(Routes.events)),
          ]))
        else
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Divided([
              for (final t in s.tickets)
                if (s.event(t.eventId) != null)
                  ListRow(
                    leading: SizedBox(width: 50, height: 50, child: Poster(s.event(t.eventId)!.art, aspect: 1)),
                    title: s.event(t.eventId)!.title,
                    sub: '${s.event(t.eventId)!.when} · ${context.t('checkout.nTickets', [t.qty])}',
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push(Routes.ticket(t.id)),
                  ),
            ]),
          ),
      ]),
    );
  }
}
