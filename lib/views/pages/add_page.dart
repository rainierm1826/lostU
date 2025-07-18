import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:lostu/services/auth_service.dart';
import 'package:lostu/services/item_service.dart';
import 'package:lostu/services/user_provider.dart';
import 'package:provider/provider.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final TextEditingController _lostItemNameController = TextEditingController();
  final ItemService _itemService = ItemService();
  final TextEditingController _locationFoundController =
      TextEditingController();
  final TextEditingController _dateTimeController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final List<String> itemTypes = [
    'ID Card',
    'Wallet',
    'Phone',
    'Notebook',
    'Keys',
    'Umbrella',
    'Water Bottle',
    'Earphones',
    'Charger',
    'Bag',
  ];

  String? _selectedTypeController;
  Uint8List? _imageBytes;
  bool _isAdding = false;

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null && result.files.first.bytes != null) {
      setState(() {
        _imageBytes = result.files.first.bytes!;
      });
    }
  }

  Future<void> _selectDateTime() async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      if (!mounted) return;
      TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (selectedTime != null) {
        final DateTime fullDateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );

        final formatted = DateFormat(
          'yyyy-MM-dd – hh:mm a',
        ).format(fullDateTime);

        setState(() {
          _dateTimeController.text = formatted;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final GoogleAuthService authService = GoogleAuthService();
    final user = Provider.of<UserProvider>(context).user;

    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Stack(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[200],
                      ),
                      child: _imageBytes == null
                          ? Center(
                              child: Icon(
                                Icons.add_photo_alternate,
                                size: 50,
                                color: Colors.grey[600],
                              ),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.memory(
                                  _imageBytes!,
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24),
              TextFormField(
                controller: _lostItemNameController,
                decoration: InputDecoration(
                  labelText: "Lost Item",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.post_add),
                  hintText: "Enter the lost item name",
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1.5),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please fill up this';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Select Item Type',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Icon(Icons.category),
                ),
                value: _selectedTypeController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please fill up this';
                  }
                  return null;
                },
                items: itemTypes.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedTypeController = newValue!;
                  });
                },
              ),
              SizedBox(height: 24),
              TextFormField(
                controller: _locationFoundController,
                decoration: InputDecoration(
                  labelText: "Location",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                  hintText: "Enter the location where it was lost",
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1.5),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please fill up this';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              TextFormField(
                controller: _dateTimeController,
                readOnly: true,
                onTap: _selectDateTime,
                decoration: InputDecoration(
                  labelText: "Date & Time",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                  hintText: "Select date and time",
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1.5),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please fill up this';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;

                    final userId = user?["id"] ?? authService.currentUser?.uid;
                    final name =
                        user?["displayName"] ??
                        authService.currentUser?.displayName;

                    try {
                      setState(() => _isAdding = true);
                      await _itemService.addLostItem(
                        lostItemName: _lostItemNameController.text.trim(),
                        locationFound: _locationFoundController.text.trim(),
                        itemType: _selectedTypeController ?? 'Others',
                        dateItemFound: _dateTimeController.text.trim(),
                        userID: userId,
                        displayName: name,
                        imageBytes: _imageBytes,
                      );
                      AwesomeDialog(
                        // ignore: use_build_context_synchronously
                        context: context,
                        dialogType: DialogType.success,
                        animType: AnimType.scale,
                        title: 'Item Added',
                        desc: 'Your lost item has been successfully added!',
                        btnOkOnPress: () {},
                      ).show();

                      _formKey.currentState?.reset();
                      setState(() {
                        _lostItemNameController.clear();
                        _locationFoundController.clear();
                        _imageBytes = null;
                        _selectedTypeController = null;
                        _dateTimeController.clear();
                      });
                      setState(() => _isAdding = false);
                    } catch (e) {
                      //  errors
                    }
                  },

                  child: _isAdding
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text("Add Item"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
