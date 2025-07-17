import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';

import 'package:lostu/functions/string.dart';
import 'package:lostu/services/auth_service.dart';
import 'package:lostu/services/user_provider.dart';
import 'package:provider/provider.dart';

class ActivityList extends StatelessWidget {
  const ActivityList({super.key});
  @override
  Widget build(BuildContext context) {
    final GoogleAuthService authService = GoogleAuthService();
    final user = Provider.of<UserProvider>(context).user;
    final userID = authService.currentUser?.uid ?? user["id"];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          "Post History",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: "Merriweather",
          ),
        ),
        SizedBox(height: 24),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('item')
              .where('userID', isEqualTo: userID)
              .snapshots(),

          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Text("");
            }

            final docs = snapshot.data!.docs;

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final data = docs[index].data() as Map<String, dynamic>;

                final String base64String = data['imageBase64'] ?? '';
                final Uint8List bytes = base64String.isNotEmpty
                    ? base64Decode(base64String)
                    : Uint8List(0);

                final String itemName = stringClass.toCapitalize(
                  data['lostItemName'] ?? 'Unknown Item',
                );
                final String location = stringClass.toCapitalize(
                  data['locationFound'] ?? 'Unknown Location',
                );
                final String date = data['dateItemFound'] ?? 'N/A';

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: bytes.isNotEmpty
                              ? Image.memory(
                                  bytes,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.fill,
                                )
                              : Container(
                                  width: 100,
                                  height: 100,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.image_not_supported),
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                itemName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Location: $location',
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Date Found: $date',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
