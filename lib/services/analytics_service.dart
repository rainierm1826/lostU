import 'package:cloud_firestore/cloud_firestore.dart';

class AnalyticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<int> totalNumberOfLostItemsStream() {
    return _firestore
        .collection('item')
        .where('status', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Stream<int> totalNumberOfFoundItemsStream() {
    return _firestore
        .collection('item')
        .where('status', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Stream<double> successRateOfClaimsStream() {
    return _firestore.collection('item').snapshots().map((snapshot) {
      final totalItems = snapshot.docs.length;
      if (totalItems == 0) return 0.0;
      final foundItems = snapshot.docs
          .where((doc) => doc.data()["status"] == true)
          .length;
      return foundItems / totalItems;
    });
  }

  Stream<Map<String, int>> mostFrequentlyLostItemCategoriesStream() {
    return _firestore.collection('item').snapshots().map((snapshot) {
      final Map<String, int> categoryCount = {};
      for (var doc in snapshot.docs) {
        final itemType = doc.data()['itemType'] ?? 'Unknown';
        categoryCount[itemType] = (categoryCount[itemType] ?? 0) + 1;
      }
      return categoryCount;
    });
  }

  Stream<Map<String, int>> mostFrequentlyLostItemLocationsStream() {
    return _firestore.collection('item').snapshots().map((snapshot) {
      final Map<String, int> locationCount = {};
      for (var doc in snapshot.docs) {
        final location = doc.data()['locationFound'] ?? 'Unknown';
        locationCount[location] = (locationCount[location] ?? 0) + 1;
      }
      return locationCount;
    });
  }
}
