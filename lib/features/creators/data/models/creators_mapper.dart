import '../../domain/entities/creator.dart';

class CreatorsMapper {
  CreatorsMapper._();
  static CreatorsData fromJson(Map<String, dynamic> j) => CreatorsData(
        creators: ((j['creators'] as List?) ?? const []).map((e) {
          final m = (e as Map).cast<String, dynamic>();
          return Creator(
            id: m['id'] as String,
            name: m['name'] as String,
            handle: m['handle'] as String,
            role: m['role'] as String,
            followers: m['followers'] as String,
            color: (m['color'] as num).toInt(),
            bio: m['bio'] as String,
            tags: (m['tags'] as List).map((t) => t as String).toList(),
            loc: m['loc'] as String,
          );
        }).toList(),
        opportunities: ((j['opportunities'] as List?) ?? const []).map((e) {
          final m = (e as Map).cast<String, dynamic>();
          return Opportunity(id: m['id'] as String, title: m['title'] as String, sub: m['sub'] as String, meta: m['meta'] as String, creator: m['creator'] as String);
        }).toList(),
      );
}
