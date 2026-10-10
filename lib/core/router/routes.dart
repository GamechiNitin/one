/// Central list of route paths so screens never hard-code strings.
class Routes {
  Routes._();

  static const splash = '/splash';

  // Tab roots
  static const home = '/home';
  static const explore = '/explore';
  static const creators = '/creators';
  static const shop = '/shop';
  static const rewards = '/rewards';
  static const profile = '/profile';

  // Pushed screens
  static const events = '/events';
  static const live = '/live';
  static const offers = '/offers';
  static const pass = '/pass';
  static const settings = '/settings';
  static const help = '/help';
  static const cart = '/cart';
  static const tickets = '/tickets';

  static String item(String id) => '/item/$id';
  static String player(String id) => '/player/$id';
  static String category(String name) => '/category/${Uri.encodeComponent(name)}';
  static String event(String id) => '/event/$id';
  static String checkout(String id, {required int qty, required bool pass}) => '/event/$id/checkout?qty=$qty&pass=${pass ? 1 : 0}';
  static String booked(String ticketId) => '/booked/$ticketId';
  static String ticket(String id) => '/ticket/$id';
  static String product(String id) => '/product/$id';
  static String creator(String id) => '/creator/$id';
  static String reels({int start = 0}) => '/reels?start=$start';
  static String assistant({String? ask}) => ask == null ? '/assistant' : '/assistant?ask=${Uri.encodeQueryComponent(ask)}';
  static String eventsFiltered(String cat) => '/events?cat=${Uri.encodeQueryComponent(cat)}';
}
