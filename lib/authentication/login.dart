import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:newtodo/authentication/auth_input_validation.dart';
// import 'package:newtodo/authentication/auth_service.dart';
import 'package:newtodo/authentication/register_user.dart';
import 'package:newtodo/model/user.dart';
import 'package:newtodo/screens/todopage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _passwordVisiblityHide = true;
  bool _isEmailValid = true;
  // ignore: unused_field
  bool _isPasswordValid = true;
  bool _isLoading = false;

  void _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      final usersBox = Hive.box<User>('users');

      final user = usersBox.values.firstWhere(
        (user) =>
            user.email == _emailController.text.trim() &&
            user.password == _passwordController.text.trim(),
        orElse: () => User(username: '', email: '', password: ''),
      );

      if (user.username.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid credentials!')),
        );
        return;
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('loggedInUserEmail', user.email);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ToDoPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Login',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.bold,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey[800]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.purple),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                      suffixIcon: _isEmailValid
                          ? null
                          : Icon(Icons.error_outline_outlined),
                    ),
                    validator: (email) {
                      String? message =
                          AuthInputValidationMixin.isEmailValid(email);
                      if (message == null) {
                        setState(() {
                          _isEmailValid = true;
                        });
                        return null;
                      } else {
                        setState(() {
                          _isEmailValid = false;
                        });
                        return message;
                      }
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _passwordVisiblityHide,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.bold,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey[800]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.purple),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
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
                      if (message == null) {
                        setState(() {
                          _isPasswordValid = true;
                        });
                        return null;
                      } else {
                        setState(() {
                          _isPasswordValid = false;
                        });
                        return message;
                      }
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _login,
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
                    child: Text('Login'),
                  ),
                  SizedBox(height: 10),
                  TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RegisterUserScreen()));
                      },
                      child: Text('Register User')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
