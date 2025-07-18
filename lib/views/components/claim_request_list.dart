import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:lostu/services/claim_service.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class ClaimRequestList extends StatefulWidget {
  const ClaimRequestList({super.key});

  @override
  State<ClaimRequestList> createState() => _ClaimRequestListState();
}

class _ClaimRequestListState extends State<ClaimRequestList> {
  final ClaimService claimService = ClaimService();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          "Claim Request List",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: "Merriweather",
          ),
        ),
        SizedBox(height: 24),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('claim')
              .where('status', isEqualTo: 'pending')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(
                child: Text(
                  "Error fetching claim requests.",
                  style: TextStyle(color: Colors.red),
                ),
              );
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  "No claim requests found.",
                  style: TextStyle(color: Colors.grey),
                ),
              );
            }
            final claimDocs = snapshot.data!.docs;
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: claimDocs.length,
              itemBuilder: (context, index) {
                final claimDoc = claimDocs[index];
                final claimData = claimDoc.data() as Map<String, dynamic>;
                final String itemId = claimData['itemID'];
                final String userId = claimData['userID'];
                final String claimId = claimDoc.id;
                final String status = claimData['status'] ?? 'pending';

                return FutureBuilder(
                  future: Future.wait([
                    FirebaseFirestore.instance
                        .collection('item')
                        .doc(itemId)
                        .get(),
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(userId)
                        .get(),
                  ]),
                  builder: (context, AsyncSnapshot<List<DocumentSnapshot>> asyncSnapshot) {
                    if (asyncSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const SizedBox.shrink();
                    }
                    if (!asyncSnapshot.hasData ||
                        !asyncSnapshot.data![0].exists ||
                        !asyncSnapshot.data![1].exists) {
                      return const SizedBox.shrink();
                    }
                    final itemData =
                        asyncSnapshot.data![0].data() as Map<String, dynamic>;
                    final userData =
                        asyncSnapshot.data![1].data() as Map<String, dynamic>;

                    final String base64String = itemData['imageBase64'] ?? '';
                    final Uint8List bytes = base64String.isNotEmpty
                        ? base64Decode(base64String)
                        : Uint8List(0);
                    final String itemName =
                        itemData['lostItemName'] ?? 'Unknown Item';
                    final String location =
                        itemData['locationFound'] ?? 'Unknown Location';
                    final String date = itemData['dateItemFound'] ?? 'N/A';
                    final String displayName =
                        userData['displayName'] ?? 'Unknown User';

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 8,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: bytes.isNotEmpty
                                  ? Image.memory(
                                      bytes,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      width: 80,
                                      height: 80,
                                      color: Colors.grey[300],
                                      child: const Icon(
                                        Icons.image_not_supported,
                                      ),
                                    ),
                            ),
                            const SizedBox(width: 16),
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
                                            fontSize: 18,
                                            fontFamily: "Merriweather",
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Location: $location',
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Date Found: $date',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Claim Requested By: $displayName',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 28,
                                  ),
                                  tooltip: 'Accept',
                                  onPressed: status == 'claimed'
                                      ? null
                                      : () {
                                          AwesomeDialog(
                                            context: context,
                                            dialogType: DialogType.success,
                                            title: 'Accept Claim',
                                            desc:
                                                'Are you sure you want to accept this claim? This will reject all other requests for this item.',
                                            btnOkText: 'OK',
                                            btnCancelText: 'Cancel',
                                            btnOkOnPress: () async {
                                              // Accept this claim
                                              await claimService
                                                  .updateClaimStatus(
                                                    claimId,
                                                    'claimed',
                                                  );
                                              // Reject all other claims for the same item
                                              final otherClaims =
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('claim')
                                                      .where(
                                                        'itemID',
                                                        isEqualTo: itemId,
                                                      )
                                                      .get();
                                              for (var otherClaim
                                                  in otherClaims.docs) {
                                                if (otherClaim.id != claimId) {
                                                  await claimService
                                                      .updateClaimStatus(
                                                        otherClaim.id,
                                                        'rejected',
                                                      );
                                                }
                                              }
                                              // Mark the item as claimed
                                              await FirebaseFirestore.instance
                                                  .collection('item')
                                                  .doc(itemId)
                                                  .update({'status': true});
                                              setState(() {});
                                            },
                                            btnCancelOnPress: () {},
                                          ).show();
                                        },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.cancel,
                                    color: Colors.red,
                                    size: 28,
                                  ),
                                  tooltip: 'Reject',
                                  onPressed: () {
                                    AwesomeDialog(
                                      context: context,
                                      dialogType: DialogType.warning,
                                      title: 'Reject Claim',
                                      desc:
                                          'Are you sure you want to reject this claim?',
                                      btnOkText: 'OK',
                                      btnCancelText: 'Cancel',
                                      btnOkOnPress: () async {
                                        await claimService.updateClaimStatus(
                                          claimId,
                                          'rejected',
                                        );
                                        setState(() {});
                                      },
                                      btnCancelOnPress: () {},
                                    ).show();
                                  },
                                ),
                              ],
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
