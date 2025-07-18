import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ItemService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addLostItem({
    required String lostItemName,
    required String locationFound,
    required String itemType,
    required String dateItemFound,
    required String userID,
    required String displayName,
    required Uint8List? imageBytes,
  }) async {
    String? base64Image;

    if (imageBytes != null) {
      final compressed = await compressImage(imageBytes);
      if (compressed != null) {
        base64Image = base64Encode(compressed);
      }
    }

    await _firestore.collection('item').add({
      'lostItemName': lostItemName,
      'locationFound': locationFound,
      'itemType': itemType,
      'dateItemFound': dateItemFound,
      'userID': userID,
      'displayName': displayName,
      'timestamp': FieldValue.serverTimestamp(),
      'imageBase64': base64Image,
      'status': false,
    });
  }

  Future<Uint8List?> compressImage(Uint8List imageBytes) async {
    final compressedBytes = await FlutterImageCompress.compressWithList(
      imageBytes,
      format: CompressFormat.jpeg,
    );
    return compressedBytes;
  }

  Future<void> updateItemStatus(String itemID, bool status) async {
    await _firestore.collection('item').doc(itemID).update({'status': status});
  }

  Future<void> deleteItem(String itemID) async {
    await _firestore.collection('item').doc(itemID).delete();
  }
}
