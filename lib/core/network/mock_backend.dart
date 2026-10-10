import '../error/exceptions.dart';

/// Stand-in for the real ONE API. Same JSON contract the HTTP client expects.
class MockBackend {
  dynamic handleGet(String path) {
    switch (path) {
      case '/catalog':
        return {'items': _items, 'reels': _reels, 'offers': _offers, 'channels': _channels};
      case '/creators':
        return {'creators': _creators, 'opportunities': _opps};
      case '/events':
        return _events;
      case '/products':
        return _products;
      case '/rewards':
        return {'rewards': _rewards, 'plans': _plans};
    }
    throw ServerException('Not found: $path', 404);
  }

  dynamic handlePost(String path, Map<String, dynamic> body) {
    if (path == '/assistant/chat') {
      return _assistantReply((body['text'] as String?) ?? '', (body['context'] as Map?)?.cast<String, dynamic>() ?? const {});
    }
    throw ServerException('Not found: $path', 404);
  }
}

Map<String, dynamic> _a(String type, List<int> c) => {
      'type': type,
      'colors': c.map((x) => 0xFF000000 | x).toList(),
    };

Map<String, dynamic> _item(String id, String kind, String title, String sub, String meta, Map<String, dynamic> art, String desc,
        {bool live = false, double progress = 0, String? creator, int price = 0, String? on, List<String> cast = const []}) =>
    {
      'id': id, 'kind': kind, 'title': title, 'sub': sub, 'meta': meta, 'art': art, 'desc': desc,
      'live': live, 'progress': progress, 'creator': creator, 'price': price, 'on': on, 'cast': cast,
    };

final List<Map<String, dynamic>> _items = [
  _item('dunes', 'Movie', 'Sand Empire: Part Two', 'Action · Sci-Fi · 2026', 'Action · Sci-Fi · 2026 · 2h 46m', _a('dunes', [0x3a1f0e, 0xb45f2b, 0xffcf8a]),
      'Exiled heir Kael unites the desert tribes to reclaim his house and face a greater threat.', on: 'peacock', cast: ['Ravi Menon', 'Zoya Khan', 'Elias Hart', 'Mira Shah']),
  _item('neon', 'Movie', 'Neon Harbour', 'Thriller · 2026', 'Thriller · 2h 04m', _a('harbour', [0x0b1d3a, 0x12c2b8, 0xff3d8b]),
      'A night-shift port inspector finds a shipping manifest that should not exist, and one dawn to decide who to trust.', on: 'peacock', cast: ['Anjali Rao', 'Sam Whitlock', 'Karthik Iyer', 'Leena Das']),
  _item('monsoon', 'Movie', 'Monsoon Heist', 'Caper · 2026', 'Caper · 2h 11m', _a('monsoon', [0x1b2a41, 0x324a5f, 0xf4b942]),
      'Five strangers, one flooded city, and a vault that opens only when the water is at its highest.', on: 'xumo', cast: ['Dev Anand K', 'Nisha Pillai', 'Omar Ali', 'Tara Joshi']),
  _item('moons', 'Movie', 'Paper Moons', 'Family · 2025', 'Family · 1h 38m', _a('moons', [0x2d1e5f, 0xff7eb6, 0xffd166]),
      'A girl folds a paper moon every night. One evening, the moons start folding back.', on: 'peacock', cast: ['Aarohi Nair', 'Vik Soni', 'Pia Mehta']),
  _item('orbit', 'Movie', 'Edge of Orbit', 'Sci-Fi · 2026', 'Sci-Fi · 2h 19m', _a('space', [0x050a24, 0x1b2a7a, 0x8ab4ff]),
      'The last crew on a failing station has ninety minutes of oxygen and one working shuttle.', on: 'peacock', cast: ['Ishan Verma', 'Lia Chen', 'Marcus Bell']),
  _item('signal', 'Show', 'The Last Signal', 'S1 · E5 · 56m', 'Mystery · S1 · E5 · 56m', _a('forest', [0x0a1f1a, 0x1d4d3f, 0xe6f0c8]),
      'A ranger in a remote valley picks up a radio signal that stops exactly when someone dies.', progress: .62, on: 'nbc', cast: ['Nikhil Bose', 'Rhea D\u2019Souza', 'Tom Alder']),
  _item('harbourS', 'Show', 'Harbour Lights', 'S2 · E12 · 24m', 'Drama · S2 · E12 · 24m', _a('harbour', [0x1a1033, 0x6d28d9, 0xfb923c]),
      'Season two follows the dockside crew as the city\u2019s last cargo line goes private.', progress: .35, on: 'sky', cast: ['Sana Qureshi', 'Jay Kulkarni', 'Beth Morrow']),
  _item('spirit', 'Anime', 'Spirit Hunters', 'S2 · Action · Supernatural', 'S2 · Action · Supernatural', _a('burst', [0x0b1a3a, 0x2b4bd6, 0x7ee0ff]),
      'Students at a hidden academy hunt the spirits born from human fear, and one of them is hiding a secret.', on: 'xumo', cast: ['Yuto Hara (voice)', 'Mei Tanaka (voice)', 'Ren Okada (voice)']),
  _item('blade', 'Anime', 'Blade of Dawn', 'S2 · Action', 'S2 · Action · 480p', _a('burst', [0x3a0f1a, 0xc2331f, 0xffb35c]),
      'A swordsman crosses a burning continent to reach the dawn that never comes.', on: 'xumo', cast: ['Kenji Mori (voice)', 'Aya Sato (voice)']),
  _item('shadow', 'Anime', 'Shadow Rank', 'S1 · Action', 'S1 · Action · 12+', _a('burst', [0x150a30, 0x5b21b6, 0xc4b5fd]),
      'The weakest hunter in the guild finds a dungeon that levels only him.', on: 'xumo', cast: ['Hiro Sasaki (voice)', 'Nao Kimura (voice)']),
  _item('chapter', 'Short film', 'The Last Chapter', 'Short film · 8 min', 'Short film · 8 min', _a('train', [0x101820, 0x2c3e50, 0xffb347]),
      'Two strangers share the final night train before the line closes forever.', creator: 'aarav', price: 99, on: 'one', cast: ['Aarav Sharma (director)']),
  _item('city', 'Short film', 'City Lights', 'Short film · 6 min', 'Short film · 6 min', _a('harbour', [0x1b1038, 0x7c3aed, 0xfbbf24]),
      'One taxi, one night, five fares.', creator: 'aarav', on: 'one', cast: ['Aarav Sharma (director)']),
  _item('match', 'Live', 'Metro FC vs Northgate', 'Premier Division · Live', 'Premier Division · Today 7:30 PM', _a('football', [0x0b3d2e, 0x14804f, 0xffffff]),
      'Matchday 9. Follow live stats, polls and highlights while you watch.', live: true, on: 'sky'),
  _item('cricket', 'Live', 'India vs Australia', 'Cricket · Live', 'Cricket · Live', _a('football', [0x0a2a4a, 0x1565c0, 0xffffff]), 'Third ODI, live from the stadium.', live: true, on: 'sky'),
  _item('news', 'Live', 'News at 9', 'News · 9:00 PM', 'News · 9:00 PM', _a('harbour', [0x0b1d3a, 0x2d8cff, 0xffffff]), 'The day\u2019s headlines.', live: true, on: 'nbc'),
  _item('nights', 'Live', 'Kaveri Nights', 'Drama · 9:00 PM', 'Drama · 9:00 PM', _a('moons', [0x3a0f2a, 0xc2255c, 0xffd166]), 'Tonight\u2019s episode.', live: true, on: 'peacock'),
  _item('sess', 'Live session', 'Rhea: Live Session', 'Concert · 48m', 'Concert · 48m', _a('concert', [0x1a0b3b, 0x7c3aed, 0xff8a3d]),
      'Recorded last week at Marina Arena. Eleven songs, no audience edits.', creator: 'rhea', live: true, on: 'one'),
];

Map<String, dynamic> _reel(String who, Map<String, dynamic> art, String caption, String tags, String likes, String comments, String label, String type, String id, String icon) =>
    {'who': who, 'art': art, 'caption': caption, 'tags': tags, 'likes': likes, 'comments': comments, 'ctaLabel': label, 'ctaType': type, 'ctaId': id, 'ctaIcon': icon};

final List<Map<String, dynamic>> _reels = [
  _reel('rhea', _a('concert', [0x1a0b3b, 0x7c3aed, 0xff8a3d]), 'Soundcheck at Marina Arena. Doors open Friday.', '#RheaLive #Chennai', '12.4K', '482', 'Book tickets', 'event', 'e1', 'ticket'),
  _reel('dev', _a('comedy', [0x2a0f1c, 0x8e2a4f, 0xffd166]), 'Chennai traffic, explained in 40 seconds.', '#Standup #Chennai', '8.1K', '219', 'Book Midnight Standup', 'event', 'e2', 'ticket'),
  _reel('one', _a('dunes', [0x3a1f0e, 0xb45f2b, 0xffcf8a]), 'First look at Sand Empire: Part Two.', '#SandEmpire #NowStreaming', '45K', '1.2K', 'Watch now', 'item', 'dunes', 'play'),
  _reel('ritu', _a('burst', [0x0b1a3a, 0x2b4bd6, 0x7ee0ff]), 'Painting Spirit Hunters key art, start to finish.', '#Anime #DigitalArt', '6.7K', '140', 'Shop art prints', 'product', 'p5', 'bag'),
  _reel('aarav', _a('train', [0x101820, 0x2c3e50, 0xffb347]), 'Shooting The Last Chapter on a moving train.', '#IndieFilm #BTS', '9.3K', '301', 'Unlock film · ₹99', 'item', 'chapter', 'play'),
  _reel('sky', _a('football', [0x0b3d2e, 0x14804f, 0xffffff]), 'Matchday build-up, live from the stands.', '#MetroFC #Live', '21K', '890', 'Watch live', 'item', 'match', 'live'),
  _reel('peacock', _a('space', [0x050a24, 0x1b2a7a, 0x8ab4ff]), 'New this week. Gift three months to a friend.', '#Peacock #GiftIdeas', '5.2K', '96', 'Get a gift card', 'product', 'p6', 'gift'),
];

Map<String, dynamic> _offer(String id, String brandText, String title, String sub, String cat, {String? brand, int? color}) =>
    {'id': id, 'brandText': brandText, 'title': title, 'sub': sub, 'cat': cat, 'brand': brand, 'color': color == null ? null : 0xFF000000 | color};

final List<Map<String, dynamic>> _offers = [
  _offer('o1', 'Cinema Pass', 'Flat 20% off', 'On movie tickets', 'Movies', color: 0x1A2B6B),
  _offer('o5', 'Peacock', '1 month free', 'New ONE Plus members', 'Movies', brand: 'peacock'),
  _offer('o2', 'Sky Sports', '₹149 day pass', 'Live matches, no contract', 'Sports', brand: 'sky'),
  _offer('o3', 'Shopmart', 'Up to 40% off', 'On select products', 'Shopping', color: 0xC2410C),
  _offer('o6', 'Xumo', 'Free Stream Box setup', 'With ONE Ultra', 'Shopping', brand: 'xumo'),
  _offer('o4', 'Foodly', '20% cashback', 'On food orders', 'Food', color: 0xD91E43),
];

const List<Map<String, dynamic>> _channels = [
  {'number': 101, 'name': 'Sky Sports 1', 'itemId': 'match', 'time': '7:30 PM - 10:00 PM', 'cat': 'Sports', 'brand': 'sky'},
  {'number': 102, 'name': 'NBC News', 'itemId': 'news', 'time': '9:00 PM - 10:00 PM', 'cat': 'News', 'brand': 'nbc'},
  {'number': 103, 'name': 'Sky Sports Cricket', 'itemId': 'cricket', 'time': '7:30 PM - 11:00 PM', 'cat': 'Sports', 'brand': 'sky'},
  {'number': 104, 'name': 'Peacock Originals', 'itemId': 'nights', 'time': '9:00 PM - 10:00 PM', 'cat': 'Movies', 'brand': 'peacock'},
  {'number': 105, 'name': 'Xumo Kids', 'itemId': 'moons', 'time': '6:00 PM - 7:45 PM', 'cat': 'Kids', 'brand': 'xumo'},
];

Map<String, dynamic> _creator(String id, String name, String handle, String role, String followers, int color, String bio, List<String> tags, String loc) =>
    {'id': id, 'name': name, 'handle': handle, 'role': role, 'followers': followers, 'color': 0xFF000000 | color, 'bio': bio, 'tags': tags, 'loc': loc};

final List<Map<String, dynamic>> _creators = [
  _creator('aarav', 'Aarav Sharma', '@aarav.films', 'Filmmaker', '2.4M', 0x2D6BFF, 'Filmmaker | Director | Storyteller. Passionate about short films, indie projects and creative collaborations.', ['Film Making', 'Direction', 'Editing', 'Screenwriting'], 'Mumbai, India'),
  _creator('rhea', 'Rhea Kapoor', '@rhea.sings', 'Singer', '1.8M', 0xE64A8C, 'Singer-songwriter. Live sessions, original music, and one very loud guitar.', ['Vocals', 'Songwriting', 'Live shows'], 'Chennai, India'),
  _creator('dev', 'Dev Menon', '@devmenon', 'Stand-up comedian', '210K', 0xE5703D, 'Stand-up comedian. Observational humour about Chennai traffic and filter coffee.', ['Stand-up', 'Writing'], 'Chennai, India'),
  _creator('ritu', 'Ritu Sharma', '@ritu.draws', 'Digital artist', '91K', 0x0F9D8A, 'Digital artist and anime illustrator. Posters, key art, and character design.', ['Illustration', 'Anime art', 'Poster design'], 'Bengaluru, India'),
];

const List<Map<String, dynamic>> _opps = [
  {'id': 'op1', 'title': 'Casting Call - Short Film', 'sub': 'Looking for: Male Lead (age 20-30)', 'meta': 'Mumbai · ₹10K - ₹25K', 'creator': 'aarav'},
  {'id': 'op2', 'title': 'Music Video: Lead Dancers', 'sub': 'Looking for: 6 dancers (age 18-28)', 'meta': 'Chennai · ₹5K - ₹12K', 'creator': 'rhea'},
  {'id': 'op3', 'title': 'Brand Collab: Sneaker Launch', 'sub': 'Looking for: Digital artists', 'meta': 'Remote · ₹40K+', 'creator': 'ritu'},
];

Map<String, dynamic> _event(String id, String title, String cat, String venue, String when, int price, Map<String, dynamic> art, List<String> friends, String offer, String up, {String? creator}) =>
    {'id': id, 'title': title, 'cat': cat, 'venue': venue, 'when': when, 'price': price, 'art': art, 'friends': friends, 'offer': offer, 'up': up, 'creator': creator};

final List<Map<String, dynamic>> _events = [
  _event('e1', 'Rhea Kapoor Live', 'Concerts', 'Marina Arena, Chennai', 'Fri, Oct 9 · 7:30 PM', 1499, _a('concert', [0x1a0b3b, 0x7c3aed, 0xff8a3d]), ['Arjun', 'Meera', 'Kabir'], 'Pre-show dinner, 20% off at Biryani Boulevard', 'sess', creator: 'rhea'),
  _event('e2', 'Midnight Standup', 'Concerts', 'The Black Box, Alwarpet', 'Sat, Oct 10 · 9:00 PM', 599, _a('comedy', [0x2a0f1c, 0x8e2a4f, 0xffd166]), ['Meera'], 'Filter coffee refill on entry', 'monsoon', creator: 'dev'),
  _event('e3', 'City Cup Final Fan Night', 'Sports', 'Fan Zone, Phoenix Mall', 'Sat, Oct 10 · 10:00 PM', 399, _a('football', [0x0b3d2e, 0x14804f, 0xffffff]), ['Arjun', 'Kabir'], 'Two for one on match snacks', 'cricket'),
  _event('e4', 'The Last Chapter Premiere', 'Movies', 'Sathyam Cinemas, Royapettah', 'Sun, Oct 25 · 6:00 PM', 349, _a('train', [0x101820, 0x2c3e50, 0xffb347]), ['Meera'], 'Meet the director after the screening', 'chapter', creator: 'aarav'),
  _event('e5', 'Anime Expo India', 'Gaming', 'Chennai Trade Centre', 'Sat, Nov 14 · 11:00 AM', 799, _a('burst', [0x150a30, 0x5b21b6, 0xc4b5fd]), ['Kabir'], 'Free artist alley pass', 'spirit', creator: 'ritu'),
];

Map<String, dynamic> _product(String id, String title, int price, String cat, String brand, String desc, {Map<String, dynamic>? art, int? bg, bool member = false, String? tag}) =>
    {'id': id, 'title': title, 'price': price, 'cat': cat, 'brand': brand, 'desc': desc, 'art': art, 'bg': bg == null ? null : 0xFF000000 | bg, 'member': member, 'tag': tag};

final List<Map<String, dynamic>> _products = [
  _product('p1', 'Neon Harbour tee', 1299, 'Merch', 'one', 'Soft cotton tee with the harbour skyline print.', art: _a('harbour', [0x0b1d3a, 0x12c2b8, 0xff3d8b])),
  _product('p2', 'Rhea tour hoodie', 2999, 'Merch', 'one', 'Limited tour hoodie with a numbered tag inside.', art: _a('concert', [0x1a0b3b, 0x7c3aed, 0xff8a3d]), member: true, tag: 'Members drop'),
  _product('p3', 'Paper Moons plush', 899, 'Collectibles', 'one', 'A soft, foldable moon you can actually hug.', art: _a('moons', [0x2d1e5f, 0xff7eb6, 0xffd166])),
  _product('p4', 'The Last Chapter signed print', 1499, 'Collectibles', 'one', 'A3 print signed by director Aarav Sharma.', art: _a('train', [0x101820, 0x2c3e50, 0xffb347]), member: true, tag: 'Only 120 made'),
  _product('p5', 'Spirit Hunters art prints', 1199, 'Collectibles', 'one', 'Set of three prints by digital artist Ritu Sharma.', art: _a('burst', [0x0b1a3a, 0x2b4bd6, 0x7ee0ff])),
  _product('p6', 'Peacock Premium, 3 months', 899, 'Gift cards', 'peacock', 'A three-month Peacock Premium gift. Delivered instantly by email.', bg: 0x14141c),
  _product('p7', 'Xumo Stream Box', 3499, 'Devices', 'xumo', '4K streaming box with free channels and your ONE apps built in.', bg: 0xE7EEFF),
  _product('p8', 'Sky Sports match-day scarf', 1099, 'Merch', 'sky', 'Knitted scarf in match-day colours.', art: _a('football', [0x0b2a6b, 0x1F3FD8, 0xffffff])),
  _product('p9', 'NBCUniversal studio tour pass', 2499, 'Experiences', 'nbc', 'A behind-the-scenes studio tour for one guest.', bg: 0xEEF2FF, member: true),
  _product('p10', 'Xfinity Wi-Fi pod, 2-pack', 4999, 'Devices', 'xfinity', 'Extend whole-home coverage so every room streams smoothly.', bg: 0xF1F5FF, member: true),
];

const List<Map<String, dynamic>> _rewards = [
  {'id': 'r1', 'title': 'Cinema voucher', 'sub': 'Flat 20% off movie tickets', 'cost': 500, 'icon': 'ticket'},
  {'id': 'r2', 'title': 'Sky Sports, 1 month', 'sub': 'Premium plan', 'cost': 1200, 'icon': 'tv'},
  {'id': 'r3', 'title': 'Merch discount', 'sub': '10% off creator merch', 'cost': 400, 'icon': 'gift'},
  {'id': 'r4', 'title': 'Early access', 'sub': 'Presale for Rhea\u2019s encore', 'cost': 800, 'icon': 'star'},
];

const List<Map<String, dynamic>> _plans = [
  {'name': 'Free', 'price': 0, 'desc': 'Basic access, with ads', 'popular': false},
  {'name': 'Plus', 'price': 199, 'desc': 'Ad-free, exclusive content, more rewards', 'popular': true},
  {'name': 'Ultra', 'price': 399, 'desc': 'All-in-one entertainment and premium perks', 'popular': false},
];

String _rs(num n) {
  final s = n.round().toString();
  if (s.length <= 3) return '\u20B9$s';
  final last3 = s.substring(s.length - 3);
  final rest = s.substring(0, s.length - 3);
  final b = StringBuffer();
  for (var i = 0; i < rest.length; i++) {
    if (i > 0 && (rest.length - i) % 2 == 0) b.write(',');
    b.write(rest[i]);
  }
  return '\u20B9${b.toString()},$last3';
}

Map<String, dynamic> _reply(String text, {List<String> cards = const [], List<List<String>> acts = const []}) =>
    {'text': text, 'cards': cards, 'acts': acts.map((a) => {'key': a[0], 'label': a[1]}).toList()};

/// Server-side "assistant" (intent rules). The client sends wallet context so replies stay accurate.
Map<String, dynamic> _assistantReply(String raw, Map<String, dynamic> ctx) {
  final q = raw.toLowerCase();
  bool m(String p) => RegExp(p).hasMatch(q);
  final wallet = (ctx['wallet'] as num?)?.toInt() ?? 0;
  final points = (ctx['points'] as num?)?.toInt() ?? 0;
  final paid = (ctx['plan'] as String? ?? 'Free') != 'Free';
  final billPaid = ctx['billPaid'] == true;
  if (m(r'internet|wi-?fi|slow|speed|router|modem|gateway')) {
    return _reply('I checked your Xfinity Internet (1 Gbps). Your gateway has been running for 41 days, and a restart often clears slowdowns. Want to test your speed first?',
        acts: [['speed', 'Run speed test'], ['restart', 'Restart gateway']]);
  }
  if (m(r'bill|billing|payment|due|invoice')) {
    if (billPaid) return _reply('You\u2019re all paid up. Your next bill is due Nov 28.');
    return _reply('Your next bill is \u20B91,299, due Oct 28: Xfinity Internet \u20B9799, Mobile \u20B9400, Streaming \u20B9100. Your wallet has ${_rs(wallet)}.', acts: [['paybill', 'Pay \u20B91,299 now']]);
  }
  if (m(r'tv.*(not|work|issue|problem)|buffer|box|no signal|channel')) {
    return _reply('Sorry your TV is acting up. Your Xumo box hasn\u2019t checked in for three hours. I can send a reset from here.', acts: [['resettv', 'Reset my box'], ['tech', 'Book technician']]);
  }
  if (m(r'set ?up|activate|new device|install')) {
    return _reply('To set up a device, open Settings, then Devices & Sessions, and scan the code shown on your TV. Want a technician to do it for you?', cards: ['p7'], acts: [['tech', 'Book technician']]);
  }
  if (m(r'add.*service|new service|upgrade|add-?on|sky sports')) {
    return _reply('You can move up to ONE Ultra for Xfinity, Peacock, Sky Sports, and Xumo on one bill, or buy a Sky Sports day pass.', acts: [['upgrade', 'View ONE Pass']]);
  }
  if (m(r'gift|buy|shop|merch|hoodie|gadget|store')) {
    return _reply('Popular picks right now. ONE Plus members get 10% off drops.', cards: ['p2', 'p6', 'p5']);
  }
  if (m(r'exciting|tonight|friends|fun|party')) {
    return _reply('Friday night in Chennai looks good. Arjun and Meera are already going to Rhea Kapoor Live${paid ? ', and your Pass takes 20% off' : ''}.', cards: ['e1', 'neon', 'e3']);
  }
  if (m(r'family|kid|sunday')) return _reply('Paper Moons is rated for every age and runs 1h 38m. Press play when everyone is settled.', cards: ['moons', 'e4']);
  if (m(r'laugh|comedy|funny|standup')) return _reply('Dev Menon\u2019s late show is Saturday at 9. It\u2019s close to you and includes a coffee refill.', cards: ['e2']);
  if (m(r'anime')) return _reply('Spirit Hunters is the pick if you liked Neon Harbour\u2019s mood. Event fans: Anime Expo India is in November.', cards: ['spirit', 'e5']);
  if (m(r'weekend|event|near|happening')) return _reply('Three things this weekend near you.', cards: ['e1', 'e2', 'e3']);
  if (m(r'movie|watch|show|stream|film')) return _reply('Based on what you\u2019ve been watching, try these.', cards: ['dunes', 'orbit', 'signal']);
  if (m(r'reward|point|pass|wallet')) return _reply('You have ${points.toString()} points and ${_rs(wallet)} in your wallet. Open Rewards to redeem.');
  return _reply('I can plan your evening, find a gift, or help with your internet, TV, and billing. Try \u201Csomething fun tonight\u201D or \u201Cmy internet is slow\u201D.');
}
