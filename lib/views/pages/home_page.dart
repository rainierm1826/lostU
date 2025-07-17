import 'package:flutter/material.dart';
import 'package:lostu/views/components/card_item.dart';
import 'package:lostu/views/components/carousel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _query = TextEditingController();
  String searchQuery = '';

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _query.addListener(() {
      if (_query.text.isEmpty) {
        setState(() {
          searchQuery = '';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _query,
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

            SizedBox(height: 20),
            const Carousel(),
            SizedBox(height: 24),
            CardItem(searchQuery: searchQuery),
          ],
        ),
      ),
    );
  }
}
