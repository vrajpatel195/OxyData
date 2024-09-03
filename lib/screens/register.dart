import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_page.dart';
import '../Demo/demo.dart';

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

  @override
  void initState() {
    super.initState();
    // _checkFirstRun();
  }

  Future<void> _checkFirstRun() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstRun = prefs.getBool('isFirstRun') ?? true;
    print("first runnnnn: $isFirstRun");

    if (!isFirstRun) {
      _navigateToMainPage();
    }
  }

  Future<void> _setFirstRunComplete() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstRun', false);
  }

  Future<void> _saveFormData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', _nameController.text);
    await prefs.setString('hospital_name', _hospitalCompanyController.text);
    await prefs.setString('city', _cityController.text);
    await prefs.setString('contactNumber', _contactNumberController.text);
    await prefs.setString('email', _emailController.text);
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
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.only(right: 10, left: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                  controller: _nameController,
                  label: 'Name of the user',
                  icon: Icon(Icons.person),
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
                  icon: Icon(Icons.local_hospital),
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
                    icon: Icon(Icons.location_city)),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
                _buildTextField(
                    controller: _contactNumberController,
                    label: 'Contact Number',
                    keyboardType: TextInputType.phone,
                    icon: Icon(Icons.contact_phone)),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
                _buildTextField(
                    controller: _emailController,
                    label: 'Email ID',
                    keyboardType: TextInputType.emailAddress,
                    icon: Icon(Icons.email)),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        await _saveFormData();
                        await _setFirstRunComplete();
                        _navigateToMainPage();
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
    required Icon icon,
  }) {
    return Container(
      height: 40,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 10.0), // Adjust padding as needed
            child: icon,
          ),
          prefixIconConstraints: BoxConstraints(
            minWidth: 0, // Adjust this value if needed
            minHeight: 0, // Adjust this value if needed
          ),
          contentPadding:
              EdgeInsets.symmetric(vertical: 10), // Adjust vertical padding
          labelText: label,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(15.0)),
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
