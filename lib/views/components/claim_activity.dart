import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lostu/functions/string.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:lostu/services/auth_service.dart';
import 'package:lostu/services/user_provider.dart';
import 'package:provider/provider.dart';

class ClaimActivity extends StatefulWidget {
  const ClaimActivity({super.key});

  @override
  State<ClaimActivity> createState() => _ClaimActivityState();
}

class _ClaimActivityState extends State<ClaimActivity> {
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
          "Claim Activity",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: "Merriweather",
          ),
        ),
        SizedBox(height: 24),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('claim')
              .where('userID', isEqualTo: userID)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Text("");
            }

            final claimDocs = snapshot.data!.docs;

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: claimDocs.length,
              itemBuilder: (context, index) {
                final claimData =
                    claimDocs[index].data() as Map<String, dynamic>;
                final itemID = claimData['itemID'];

                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('item')
                      .doc(itemID)
                      .get(),
                  builder: (context, itemSnapshot) {
                    if (!itemSnapshot.hasData || !itemSnapshot.data!.exists) {
                      return const SizedBox();
                    }

                    final itemData =
                        itemSnapshot.data!.data() as Map<String, dynamic>;

                    final String base64String = itemData['imageBase64'] ?? '';
                    final Uint8List bytes = base64String.isNotEmpty
                        ? base64Decode(base64String)
                        : Uint8List(0);

                    final String itemName = stringClass.toCapitalize(
                      itemData['lostItemName'] ?? 'Unknown Item',
                    );
                    final String location = stringClass.toCapitalize(
                      itemData['locationFound'] ?? 'Unknown Location',
                    );
                    final String date = itemData['dateItemFound'] ?? 'N/A';

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
                                      child: const Icon(
                                        Icons.image_not_supported,
                                      ),
                                    ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          itemName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Badge(
                                        label: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          child: Text(
                                            stringClass.toCapitalize(
                                              claimData['status'],
                                            ),
                                          ),
                                        ),
                                        backgroundColor:
                                            claimData['status'] == 'claimed'
                                            ? Colors.green
                                            : claimData['status'] == 'pending'
                                            ? Colors.grey
                                            : Colors.red,
                                      ),
                                    ],
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
            );
          },
        ),
      ],
    );
  }
}
