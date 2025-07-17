import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> claimLostItem(String userID, String itemID) async {
  await FirebaseFirestore.instance.collection('claim').add({
    'userID': userID,
    'itemID': itemID,
    'timestamp': FieldValue.serverTimestamp(),
  });
}

Future<List<Map<String, dynamic>>> fetchUserClaims(String userID) async {
  final claimSnapshot = await FirebaseFirestore.instance
      .collection('claim')
      .where('userID', isEqualTo: userID)
      .orderBy('timestamp', descending: true)
      .get();

  List<Map<String, dynamic>> claimedItems = [];

  for (var claimDoc in claimSnapshot.docs) {
    final claimData = claimDoc.data();
    final itemID = claimData['itemID'];

    final itemDoc = await FirebaseFirestore.instance
        .collection('item')
        .doc(itemID)
        .get();

    if (itemDoc.exists) {
      final itemData = itemDoc.data();
      if (itemData != null) {
        claimedItems.add({
          'claimID': claimDoc.id,
          'itemID': itemID,
          'claimTimestamp': claimData['timestamp'],
          'itemData': itemData,
        });
      }
    }
  }

  return claimedItems;
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
