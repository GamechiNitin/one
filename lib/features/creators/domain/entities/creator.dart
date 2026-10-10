import 'package:equatable/equatable.dart';

class Creator extends Equatable {
  final String id, name, handle, role, followers, bio, loc;
  final int color;
  final List<String> tags;
  const Creator({
    required this.id,
    required this.name,
    required this.handle,
    required this.role,
    required this.followers,
    required this.color,
    required this.bio,
    required this.tags,
    required this.loc,
  });
  @override
  List<Object?> get props => [id];
}

class Opportunity extends Equatable {
  final String id, title, sub, meta, creator;
  const Opportunity({required this.id, required this.title, required this.sub, required this.meta, required this.creator});
  @override
  List<Object?> get props => [id];
}

class CreatorsData extends Equatable {
  final List<Creator> creators;
  final List<Opportunity> opportunities;
  const CreatorsData({this.creators = const [], this.opportunities = const []});

  Creator? creator(String id) {
    for (final c in creators) {
      if (c.id == id) return c;
    }
    return null;
  }

  @override
  List<Object?> get props => [creators, opportunities];
}

class CreatorPrefs extends Equatable {
  final Set<String> following;
  final Set<String> applied;
  const CreatorPrefs({this.following = const {}, this.applied = const {}});
  CreatorPrefs copyWith({Set<String>? following, Set<String>? applied}) =>
      CreatorPrefs(following: following ?? this.following, applied: applied ?? this.applied);
  @override
  List<Object?> get props => [following, applied];
}
