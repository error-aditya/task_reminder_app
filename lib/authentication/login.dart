import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:newtodo/authentication/auth_input_validation.dart';
import 'package:newtodo/authentication/register_user.dart';
import 'package:newtodo/model/user.dart';
import 'package:newtodo/screens/todopage.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _passwordVisibilityHide = true;
  bool _isEmailValid = true;
  bool _isPasswordValid = true;
  bool _isLoading = false;
  late AnimationController _controller;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..forward();
    _fadeInAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    if (_controller != null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(seconds: 1));

      final usersBox = Hive.box<User>('users');
      final user = usersBox.values.firstWhere(
        (user) =>
            user.email == _emailController.text.trim() &&
            user.password == _passwordController.text.trim(),
        orElse: () => User(username: '', email: '', password: ''),
      );

      setState(() => _isLoading = false);

      if (user.username.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid credentials!')),
        );
        return;
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('loggedInUserEmail', user.email);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ToDoPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'GoDo',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.black,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeInAnimation,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelStyle: TextStyle(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.bold,
                          ),
                          labelText: 'Email',
                          filled: true,
                        ),
                        validator: (email) {
                          String? message =
                              AuthInputValidationMixin.isEmailValid(email);
                          setState(() => _isEmailValid = message == null);
                          return message;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _passwordVisibilityHide,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          filled: true,
                          labelStyle: TextStyle(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.bold),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _passwordVisibilityHide
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () => setState(() =>
                                _passwordVisibilityHide =
                                    !_passwordVisibilityHide),
                          ),
                        ),
                        validator: (password) {
                          String? message =
                              AuthInputValidationMixin.isPasswordValid(
                                  password);
                          setState(() => _isPasswordValid = message == null);
                          return message;
                        },
                      ),
                      const SizedBox(height: 20),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: _isLoading
                            ? 50
                            : MediaQuery.of(context).size.width * 0.8,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text("Login"),
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
                                  : const BorderSide(
                                      color: Colors.blueAccent,
                                      width: 2,
                                    ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 60, vertical: 15),
                            textStyle: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RegisterUserScreen()),
                        ),
                        child: const Text(
                          "Don't have an account? Register Here",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
