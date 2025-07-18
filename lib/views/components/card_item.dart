import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lostu/functions/string.dart';
import 'package:lostu/services/claim_service.dart';
import 'package:provider/provider.dart';
import 'package:lostu/services/auth_service.dart';
import 'package:lostu/services/user_provider.dart';

class CardItem extends StatefulWidget {
  final String searchQuery;

  const CardItem({super.key, required this.searchQuery});

  @override
  State<CardItem> createState() => _CardItemState();
}

class _CardItemState extends State<CardItem> {
  late String userID;
  Set<String> claimedItemIDs = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final GoogleAuthService authService = GoogleAuthService();
    final user = Provider.of<UserProvider>(context).user;
    userID = authService.currentUser?.uid ?? user["id"];
    _loadClaimedItems();
  }

  Future<void> _loadClaimedItems() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('claim')
        .where('userID', isEqualTo: userID)
        .get();

    setState(() {
      claimedItemIDs = snapshot.docs
          .map((doc) => doc['itemID'] as String)
          .toSet();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Lost Items",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: "Merriweather",
          ),
        ),
        const SizedBox(height: 24),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('item')
              .where("status", isEqualTo: false)
              .where("status", isEqualTo: null)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data!.docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final name = (data['lostItemName'] ?? '')
                  .toString()
                  .toLowerCase();
              return name.contains(widget.searchQuery.toLowerCase());
            }).toList();

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.65,
              ),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final doc = docs[index];
                final data = doc.data() as Map<String, dynamic>;
                return ClaimCard(
                  data: data,
                  itemID: doc.id,
                  userID: userID,
                  isAlreadyClaimed: claimedItemIDs.contains(doc.id),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class ClaimCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final String itemID;
  final String userID;
  final bool isAlreadyClaimed;

  const ClaimCard({
    super.key,
    required this.data,
    required this.itemID,
    required this.userID,
    required this.isAlreadyClaimed,
  });

  @override
  State<ClaimCard> createState() => _ClaimCardState();
}

class _ClaimCardState extends State<ClaimCard> {
  bool _isClaiming = false;
  final ClaimService claimService = ClaimService();

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final imageBytes = base64Decode(data['imageBase64'] ?? '');
    final itemName = stringClass.toCapitalize(data['lostItemName'] ?? '');
    final location = stringClass.toCapitalize(data['locationFound'] ?? '');
    final date = data['dateItemFound'] ?? 'N/A';

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: ClipRRect(
              child: SizedBox(
                width: double.infinity,
                child: Image.memory(
                  imageBytes,
                  fit: BoxFit.fill,
                  errorBuilder: (_, __, ___) => const Icon(Icons.error),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        itemName,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Merriweather",
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "Location: $location",
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "Date: $date",
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 28,
                    child: ElevatedButton(
                      onPressed: _isClaiming
                          ? null
                          : () async {
                              if (widget.isAlreadyClaimed) {
                                AwesomeDialog(
                                  context: context,
                                  dialogType: DialogType.warning,
                                  animType: AnimType.scale,
                                  title: 'Already Claimed',
                                  desc:
                                      'You have already claimed this item. Please check your claims.',
                                  btnOkOnPress: () {},
                                ).show();
                                return;
                              }

                              setState(() => _isClaiming = true);
                              try {
                                await claimService.claimLostItem(
                                  widget.userID,
                                  widget.itemID,
                                );
                                if (mounted) {
                                  AwesomeDialog(
                                    // ignore: use_build_context_synchronously
                                    context: context,
                                    dialogType: DialogType.info,
                                    animType: AnimType.scale,
                                    title: 'On Process',
                                    desc: 'Please go to lost and found!',
                                    btnOkOnPress: () {},
                                  ).show();
                                }
                              } catch (e) {
                                debugPrint('Claim error: $e');
                              } finally {
                                if (mounted) {
                                  setState(() => _isClaiming = false);
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      child: _isClaiming
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              "Claim Item",
                              style: TextStyle(fontSize: 10),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
