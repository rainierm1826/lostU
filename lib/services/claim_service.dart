import 'package:cloud_firestore/cloud_firestore.dart';

class ClaimService {
  Future<void> claimLostItem(String userID, String itemID) async {
    await FirebaseFirestore.instance.collection('claim').add({
      'userID': userID,
      'itemID': itemID,
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateClaimStatus(String claimID, String status) async {
    await FirebaseFirestore.instance.collection('claim').doc(claimID).update({
      'status': status,
    });
  }

  Future<List<Map<String, dynamic>>> fetchAllClaims() async {
    final claimSnapshot = await FirebaseFirestore.instance
        .collection('claim')
        .orderBy('timestamp', descending: true)
        .get();

    List<Map<String, dynamic>> allClaims = [];

    for (var claimDoc in claimSnapshot.docs) {
      final claimData = claimDoc.data();
      final itemID = claimData['itemID'];
      final userID = claimData['userID'];

      final itemDoc = await FirebaseFirestore.instance
          .collection('item')
          .where('status', isEqualTo: 'pending')
          .get();

      if (itemDoc.docs.isNotEmpty) {
        final itemData = itemDoc.docs[0].data();
        allClaims.add({
          'claimID': claimDoc.id,
          'userID': userID,
          'itemID': itemID,
          'claimTimestamp': claimData['timestamp'],
          'itemData': itemData,
        });
      }
    }

    return allClaims;
  }

  Future<List<Map<String, dynamic>>> fetchClaimRequestsMadeByUser(
    String userID,
  ) async {
    final claimSnapshot = await FirebaseFirestore.instance
        .collection('claim')
        .where('userID', isEqualTo: userID)
        .orderBy('timestamp', descending: true)
        .get();

    List<Map<String, dynamic>> claimRequests = [];

    for (var doc in claimSnapshot.docs) {
      final claimData = doc.data();
      final itemID = claimData['itemID'] as String?;

      if (itemID == null) continue;

      final itemSnapshot = await FirebaseFirestore.instance
          .collection('item')
          .doc(itemID)
          .get();

      final itemData = itemSnapshot.data() ?? {};

      claimRequests.add({
        'claimID': doc.id,
        'timestamp': claimData['timestamp'],
        'itemID': itemID,
        'itemData': itemData,
      });
    }

    return claimRequests;
  }
}
