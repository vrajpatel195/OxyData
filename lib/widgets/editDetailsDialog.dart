// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api, file_names

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditDetailsDialog extends StatefulWidget {
  const EditDetailsDialog({super.key});

  @override
  _EditDetailsDialogState createState() => _EditDetailsDialogState();
}

class _EditDetailsDialogState extends State<EditDetailsDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _hospitalCompanyController =
      TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _contactNumberController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _nameController.text = prefs.getString('name') ?? '';
    _hospitalCompanyController.text = prefs.getString('hospital_name') ?? '';
    _cityController.text = prefs.getString('city') ?? '';
    _contactNumberController.text = prefs.getString('contactNumber') ?? '';
    _emailController.text = prefs.getString('email') ?? '';
  }

  Future<void> _saveFormData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', _nameController.text);
    await prefs.setString('hospital_name', _hospitalCompanyController.text);
    await prefs.setString('city', _cityController.text);
    await prefs.setString('contactNumber', _contactNumberController.text);
    await prefs.setString('email', _emailController.text);
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        final isLandscape = orientation == Orientation.landscape;
        final dialogWidth = isLandscape
            ? MediaQuery.of(context).size.width * 0.8
            : MediaQuery.of(context).size.width * 0.9;

        return AlertDialog(
          scrollable: true,
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.only(top: 5),
                width: dialogWidth,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFullScreenTextField(
                        controller: _nameController,
                        label: 'Name of the user',
                        icon: const Icon(Icons.person),
                      ),
                      SizedBox(height: isLandscape ? 10 : 15),
                      _buildFullScreenTextField(
                        controller: _hospitalCompanyController,
                        label: 'Hospital/Company',
                        icon: const Icon(Icons.local_hospital),
                      ),
                      SizedBox(height: isLandscape ? 10 : 15),
                      _buildFullScreenTextField(
                        controller: _cityController,
                        label: 'City',
                        icon: const Icon(Icons.location_city),
                      ),
                      SizedBox(height: isLandscape ? 10 : 15),
                      _buildFullScreenTextField(
                        controller: _contactNumberController,
                        label: 'Contact Number',
                        icon: const Icon(Icons.contact_phone),
                        keyboardType: TextInputType.phone,
                      ),
                      SizedBox(height: isLandscape ? 10 : 15),
                      _buildFullScreenTextField(
                        controller: _emailController,
                        label: 'Email ID',
                        icon: const Icon(Icons.email),
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState?.validate() ?? false) {
                  await _saveFormData();
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Details updated successfully')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Function to build a text field that opens full-screen input
  Widget _buildFullScreenTextField({
    required TextEditingController controller,
    required String label,
    required Icon icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return InkWell(
      onTap: () async {
        // Navigate to a full-screen input page when tapped
        final updatedValue = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FullScreenInputPage(
              initialValue: controller.text,
              label: label,
              keyboardType: keyboardType,
            ),
          ),
        );
        if (updatedValue != null) {
          setState(() {
            controller.text = updatedValue;
          });
        }
      },
      child: TextFormField(
        style: const TextStyle(color: Colors.black),
        controller: controller,
        enabled: false,
        decoration: InputDecoration(
          prefixIcon: icon,
          labelText: label,
          hintStyle: const TextStyle(color: Colors.black),
          labelStyle: const TextStyle(color: Colors.black),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}

// A separate page that is opened for full-screen input
class FullScreenInputPage extends StatelessWidget {
  final String initialValue;
  final String label;
  final TextInputType keyboardType;

  const FullScreenInputPage({
    super.key,
    required this.initialValue,
    required this.label,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller =
        TextEditingController(text: initialValue);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Edit $label'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          autofocus: true,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: label,
          ),
          onFieldSubmitted: (value) {
            Navigator.pop(context, value); // Automatically close on "Done"
          },
        ),
      ),
    );
  }
}
