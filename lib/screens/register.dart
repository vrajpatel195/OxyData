import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/demo.dart';
import 'main_page.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _hospitalCompanyController =
      TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _contactNumberController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool get _isSubmitButtonEnabled {
    return _nameController.text.isNotEmpty &&
        _hospitalCompanyController.text.isNotEmpty &&
        _contactNumberController.text.isNotEmpty &&
        _emailController.text.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    _checkFirstRun();
  }

  Future<void> _checkFirstRun() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstRun = prefs.getBool('isFirstRun') ?? true;

    if (!isFirstRun) {
      _navigateToMainPage();
    }
  }

  Future<void> _setFirstRunComplete() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstRun', false);
  }

  void _navigateToMainPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Dashboard(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Image.asset('assets/oxy_logo.png', width: 70, height: 70),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.3,
              height: 10,
            ),
            const Text(
              'User Detail',
              style: TextStyle(color: Colors.black),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.24,
              height: 10,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DemoWid(),
                  ),
                );
              },
              child: Text(
                'Demo Mode',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Color.fromRGBO(231, 223, 223, 100),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                  controller: _nameController,
                  label: 'Name of the user',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
                _buildTextField(
                  controller: _hospitalCompanyController,
                  label: 'Hospital/Company',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your hospital or company';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
                _buildTextField(
                  controller: _cityController,
                  label: 'City',
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
                _buildTextField(
                  controller: _contactNumberController,
                  label: 'Contact Number',
                  keyboardType: TextInputType.phone,
                  // validator: (value) {
                  //   if (value == null || value.isEmpty) {
                  //     return 'Please enter your contact number';
                  //   }
                  //   return null;
                  // },
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
                _buildTextField(
                  controller: _emailController,
                  label: 'Email ID',
                  keyboardType: TextInputType.emailAddress,
                  // validator: (value) {
                  //   if (value == null || value.isEmpty) {
                  //     return 'Please enter your email address';
                  //   }
                  //   // if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                  //   //   return 'Please enter a valid email address';
                  //   // }
                  //   return null;
                  // },
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
                if (_isSubmitButtonEnabled)
                  Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState?.validate() ?? false) {
                          await _setFirstRunComplete();
                          _navigateToMainPage();
                          // Perform form submission
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Form submitted')),
                          );
                        }
                      },
                      child: Text('Submit'),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      height: 40,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
          labelText: label,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            borderSide: BorderSide(color: Colors.grey, width: 0.0),
          ),
          border: OutlineInputBorder(),
          suffixIcon: validator != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    '*',
                    style: TextStyle(color: Colors.red),
                  ),
                )
              : null,
        ),
        validator: validator,
        onChanged: (_) {
          setState(() {});
        },
      ),
    );
  }
}
