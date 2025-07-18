import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:lostu/functions/string.dart';
import 'package:lostu/services/item_service.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:lostu/views/components/claim_request_list.dart';

class AdminItemList extends StatefulWidget {
  const AdminItemList({super.key});

  @override
  State<AdminItemList> createState() => _AdminItemListState();
}

class _AdminItemListState extends State<AdminItemList> {
  String searchQuery = '';
  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      if (searchController.text.isEmpty) {
        setState(() {
          searchQuery = '';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ItemService itemService = ItemService();
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextFormField(
              controller: searchController,

              onFieldSubmitted: (value) {
                setState(() {
                  searchQuery = value.trim().toLowerCase();
                });
              },
              decoration: InputDecoration(
                labelText: "Search",
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.search),
                hintText: "Search items...",
                filled: true,
                fillColor: Colors.white,
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1.5),
                  borderRadius: BorderRadius.all(Radius.circular(100.0)),
                ),
              ),
            ),
            SizedBox(height: 24),
            ClaimRequestList(),
            SizedBox(height: 24),
            Text(
              "Item List",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: "Merriweather",
              ),
            ),
            SizedBox(height: 24),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('item').snapshots(),

              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Text("");
                }

                // Filter docs based on searchQuery
                final docs = snapshot.data!.docs.where((doc) {
                  if (searchQuery.isEmpty) return true;
                  final data = doc.data() as Map<String, dynamic>;
                  final itemName = (data['lostItemName'] ?? '')
                      .toString()
                      .toLowerCase();
                  final location = (data['locationFound'] ?? '')
                      .toString()
                      .toLowerCase();
                  final postedBy = (data['displayName'] ?? '')
                      .toString()
                      .toLowerCase();
                  return itemName.contains(searchQuery) ||
                      location.contains(searchQuery) ||
                      postedBy.contains(searchQuery);
                }).toList();

                if (docs.isEmpty) {
                  return const Center(child: Text('No items found.'));
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final String docId = docs[index].id;

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
                                            data['status']
                                                ? 'Claimed'
                                                : 'Unclaimed',
                                          ),
                                        ),
                                        backgroundColor: data['status']
                                            ? Colors.green
                                            : Colors.grey[300],
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
                                  const SizedBox(height: 2),
                                  Text(
                                    'Posted By: ${data['displayName']}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      SizedBox(width: 10),
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () {
                                          AwesomeDialog(
                                            context: context,
                                            dialogType: DialogType.warning,
                                            title: 'Delete Item',
                                            desc:
                                                'Are you sure you want to delete this item?',
                                            btnOkOnPress: () {
                                              itemService.deleteItem(docId);
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
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
