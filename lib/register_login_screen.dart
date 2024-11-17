import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:travelcompanionfinder/navigation_home_screen.dart';
import 'app_theme.dart';

class RegisterLoginScreen extends StatefulWidget {
  const RegisterLoginScreen({super.key});

  @override
  State<RegisterLoginScreen> createState() => _RegisterLoginScreenState();
}

class _RegisterLoginScreenState extends State<RegisterLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isLoginMode = true;
  bool isVerificationMode = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmationCodeController = TextEditingController();

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _registerUser() async {
    try {
      final result = await Amplify.Auth.signUp(
        username: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        options: SignUpOptions(userAttributes: {
          AuthUserAttributeKey.email: _emailController.text.trim(),
        }),
      );

      if (result.isSignUpComplete) {
        _showSnackBar('Registration successful! Please confirm your email.');
      } else {
        _showSnackBar('Registration pending confirmation.');
        setState(() {
          isVerificationMode = true;
        });
      }
    } catch (e) {
      _showSnackBar('Error: $e');
    }
  }

  void _verifyUser(String username, String confirmationCode) async {
    try {
      final result = await Amplify.Auth.confirmSignUp(
        username: username,
        confirmationCode: confirmationCode,
      );

      if (result.isSignUpComplete) {
        _showSnackBar('Verification successful!');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const NavigationHomeScreen()),
        );
      } else {
        _showSnackBar('Verification failed. Please try again.');
      }
    } catch (e) {
      _showSnackBar('Error: $e');
    }
  }

  void _loginUser() async {
    try {
      final result = await Amplify.Auth.signIn(
        username: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (result.isSignedIn) {
        _showSnackBar('Login successful!');
        Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const NavigationHomeScreen()),
          );
      } else {
        _showSnackBar('Login failed. Please try again.');
      }
    } on UserNotFoundException catch (_) {
      _showSnackBar('Email not registered.');
    } on AuthNotAuthorizedException catch (_) {
      _showSnackBar('Incorrect password. Please try again');
    } catch (e) {
      _showSnackBar('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: Text(isLoginMode ? 'Login' : 'Register', style: AppTheme.headline),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (!isVerificationMode) ...[
                _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email,
                  validator: _validateEmail,
                ),
                _buildTextField(
                  controller: _passwordController,
                  label: 'Password',
                  icon: Icons.lock,
                  obscureText: true,
                  validator: _validatePassword,
                ),
                _buildSubmitButton(),
                _buildToggleButton(),
              ] else ...[
                _buildTextField(
                  controller: _confirmationCodeController,
                  label: 'Confirmation Code',
                  icon: Icons.code,
                ),
                ElevatedButton(
                  onPressed: () {
                    _verifyUser(
                      _emailController.text.trim(),
                      _confirmationCodeController.text.trim(),
                    );
                  },
                  child: const Text('Verify'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
      validator: validator,
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: () {
        if (_formKey.currentState?.validate() ?? false) {
          if (isLoginMode) {
            _loginUser();
          } else {
            _registerUser();
          }
        }
      },
      child: Text(isLoginMode ? 'Login' : 'Register'),
    );
  }

  Widget _buildToggleButton() {
    return TextButton(
      onPressed: () {
        setState(() {
          isLoginMode = !isLoginMode;
        });
      },
      child: Text(
        isLoginMode ? "Don't have an account? Register" : 'Already have an account? Login',
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email cannot be empty';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.trim().length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }
}
