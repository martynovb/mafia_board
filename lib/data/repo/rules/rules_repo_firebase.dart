import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mafia_board/data/constants/firestore_keys.dart';
import 'package:mafia_board/data/entity/rules_entity.dart';
import 'package:mafia_board/data/repo/rules/rules_repo.dart';

class RulesRepoFirebase extends RulesRepo {
  final FirebaseFirestore firestore;

  RulesRepoFirebase({
    required this.firestore,
  });

  @override
  Future<void> createClubRules({required RulesEntity rules}) async {
    await firestore
        .collection(FirestoreKeys.rulesCollectionKey)
        .add(rules.toFirestoreMap());
  }

  @override
  Future<RulesEntity?> getClubRules({required String clubId}) async {
    final rulesDocs = await firestore
        .collection(FirestoreKeys.rulesCollectionKey)
        .where(
          FirestoreKeys.clubIdFieldKey,
          isEqualTo: clubId,
        )
        .get();

    final clubRulesDoc = rulesDocs.docs.firstOrNull;

    if (clubRulesDoc == null) {
      return null;
    }

    return RulesEntity.fromFirestoreMap(
      id: clubRulesDoc.id,
      json: clubRulesDoc.data(),
    );
  }

  @override
  Future<void> updateClubRules({required RulesEntity rules}) async {
    await firestore
        .collection(FirestoreKeys.rulesCollectionKey)
        .doc(rules.id)
        .set(rules.toFirestoreMap());
  }
}
