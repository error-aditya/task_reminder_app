import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:newtodo/authentication/auth_input_validation.dart';
import 'package:newtodo/authentication/login.dart';
import 'package:newtodo/model/user.dart';

class RegisterUserScreen extends StatefulWidget {
  @override
  _RegisterUserScreenState createState() => _RegisterUserScreenState();
}

class _RegisterUserScreenState extends State<RegisterUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _passwordVisiblityHide = true;
  bool _isLoading = false;

  void _registerUser() async {
    if (_formKey.currentState?.validate() ?? false) {
      final usersBox = Hive.box<User>('users');

      final existingUser = usersBox.values.any(
        (user) => user.email == _emailController.text.trim(),
      );

      if (existingUser) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User already exists!')),
        );
        return;
      }

      final newUser = User(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await usersBox.add(newUser);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User Registered Successfully!')),
      );

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginScreen()));
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register Here'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Username Field
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      labelStyle: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    validator: (username) {
                      String? message =
                          AuthInputValidationMixin.isUsernameValid(username);
                      return message;
                    },
                  ),
                  SizedBox(height: 10),
                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    validator: (email) {
                      String? message =
                          AuthInputValidationMixin.isEmailValid(email);
                      return message;
                    },
                  ),
                  SizedBox(height: 10),
                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.bold,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordVisiblityHide
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: _passwordVisiblityHide
                              ? Colors.grey[650]
                              : Colors.blue,
                        ),
                        onPressed: () {
                          setState(() {
                            _passwordVisiblityHide = !_passwordVisiblityHide;
                          });
                        },
                      ),
                    ),
                    validator: (password) {
                      String? message =
                          AuthInputValidationMixin.isPasswordValid(password);
                      return message;
                    },
                    obscureText: _passwordVisiblityHide,
                  ),
                  SizedBox(height: 10),

                  // Confirm Password Field
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      labelStyle: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    validator: (confirmPassword) {
                      String? message =
                          AuthInputValidationMixin.isConfirmPasswordValid(
                              confirmPassword, _passwordController.text);
                      return message;
                    },
                    obscureText: _passwordVisiblityHide,
                  ),
                  SizedBox(height: 20),

                  // Register Button
                  ElevatedButton(
                    onPressed: _registerUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.blue.shade300,
                      disabledForegroundColor: Colors.white,
                      shadowColor: Colors.blue,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        side: _isLoading
                            ? BorderSide(
                                color: Colors.blue.shade300,
                                width: 2,
                              )
                            : BorderSide(
                                color: Colors.blueAccent,
                                width: 2,
                              ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                      textStyle: TextStyle(fontSize: 18),
                    ),
                    child: Text('Register'),
                  ),
                  SizedBox(height: 10),

                  // Navigate to Login
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoginScreen()));
                    },
                    child: Text('Already have an account? Login'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
