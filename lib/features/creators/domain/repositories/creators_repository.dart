import '../../../../core/result.dart';
import '../entities/creator.dart';

abstract class CreatorsRepository {
  Future<Result<CreatorsData>> getCreators();
  CreatorPrefs loadPrefs();
  Future<CreatorPrefs> toggleFollow(String creatorId);

  /// Returns false when already applied.
  Future<bool> markApplied(String opportunityId);
}
