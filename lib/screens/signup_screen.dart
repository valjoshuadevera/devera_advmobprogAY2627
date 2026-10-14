import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../services/user_service.dart';
import '../widgets/custom_text.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _fNameController = TextEditingController();
  final TextEditingController _lNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _contactNoController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailAddressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _fNameController.dispose();
    _lNameController.dispose();
    _ageController.dispose();
    _contactNoController.dispose();
    _usernameController.dispose();
    _emailAddressController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userData = await UserService().createAccount(
        fName: _fNameController.text.trim(),
        lName: _lNameController.text.trim(),
        age: int.parse(_ageController.text.trim()),
        contactNo: _contactNoController.text.trim(),
        username: _usernameController.text.trim(),
        emailAddress: _emailAddressController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
        (route) => false,
        arguments: userData,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Signup failed: ${e.toString()}')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String? _requiredValidator(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required';
    }
    return null;
  }

  String? _passwordValidator(String? value) {
    final password = value ?? '';

    if (password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Password must contain an uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Password must contain a lowercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Password must contain a number';
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      return 'Password must contain a special character';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // Enhancement 2: Firebase signup screen with the required Lab 5 fields.
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6FF),
      appBar: AppBar(title: const Text('Sign Up')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.all(22.r),
            children: [
              CustomText(
                text: 'Create Firebase Account',
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
              ),
              SizedBox(height: 20.h),
              _SignupTextField(
                controller: _fNameController,
                labelText: 'fName',
                validator: (value) => _requiredValidator(value, 'fName'),
              ),
              _SignupTextField(
                controller: _lNameController,
                labelText: 'lName',
                validator: (value) => _requiredValidator(value, 'lName'),
              ),
              _SignupTextField(
                controller: _ageController,
                labelText: 'age',
                keyboardType: TextInputType.number,
                validator: (value) {
                  final error = _requiredValidator(value, 'age');
                  if (error != null) return error;
                  if (int.tryParse(value!.trim()) == null) {
                    return 'age must be a number';
                  }
                  return null;
                },
              ),
              _SignupTextField(
                controller: _contactNoController,
                labelText: 'contactNo',
                keyboardType: TextInputType.phone,
                validator: (value) => _requiredValidator(value, 'contactNo'),
              ),
              _SignupTextField(
                controller: _usernameController,
                labelText: 'username',
                validator: (value) => _requiredValidator(value, 'username'),
              ),
              _SignupTextField(
                controller: _emailAddressController,
                labelText: 'emailAddress',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  final error = _requiredValidator(value, 'emailAddress');
                  if (error != null) return error;
                  if (!value!.contains('@')) {
                    return 'emailAddress must be valid';
                  }
                  return null;
                },
              ),
              _SignupTextField(
                controller: _passwordController,
                labelText: 'password',
                obscureText: true,
                validator: _passwordValidator,
              ),
              SizedBox(height: 14.h),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3F51A3),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                onPressed: _isLoading ? null : _createAccount,
                child: _isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SignupTextField extends StatelessWidget {
  const _SignupTextField({
    required this.controller,
    required this.labelText,
    required this.validator,
    this.keyboardType,
    this.obscureText = false,
  });

  final TextEditingController controller;
  final String labelText;
  final FormFieldValidator<String> validator;
  final TextInputType? keyboardType;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: labelText,
        ),
        validator: validator,
      ),
    );
  }
}
