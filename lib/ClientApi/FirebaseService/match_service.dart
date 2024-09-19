import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MatchService {
  static String getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  static Future<void> updateUserPoints(String userId, int points, String matchId) async {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);

    try {
      final docSnapshot = await userDoc.get();
      final currentPoints = docSnapshot.data()?['points'] as int? ?? 0;
      final wonMatches = List<String>.from(docSnapshot.data()?['wonMatches'] ?? []);

      if (!wonMatches.contains(matchId)) {
        await userDoc.update({
          'points': currentPoints + points,
          'wonMatches': FieldValue.arrayUnion([matchId]),
        });
      }
    } catch (e) {
      print('Fehler beim Aktualisieren der Punkte: $e');
    }
  }

  static Future<Map<String, Map<String, int>?>> getMatchDetailsAndPredictions() async {
    final userId = getCurrentUserId();
    final predictionsCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('predictions');

    try {
      final querySnapshot = await predictionsCollection.get();
      final matchDetailsAndPredictions = <String, Map<String, int>?>{};

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final matchId = data['matchId'] as String?;
        final predictedScore = data['predictedScore'] as Map<String, dynamic>?;

        if (matchId != null) {
          matchDetailsAndPredictions[matchId] = {
            'home': predictedScore?['home'] as int? ?? 0,
                        'away': predictedScore?['away'] as int? ?? 0,
          };
        }
      }

      print("Matchdetails und Vorhersagen: $matchDetailsAndPredictions");
      return matchDetailsAndPredictions;
    } catch (e) {
      print('Fehler beim Abrufen der Matchdetails und Vorhersagen: $e');
      return {};
    }
  }
}

