import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:newtodo/authentication/auth_input_validation.dart';
import 'package:newtodo/authentication/login.dart';
import 'package:newtodo/model/user.dart';

class RegisterUserScreen extends StatefulWidget {
  @override
  _RegisterUserScreenState createState() => _RegisterUserScreenState();
}

class _RegisterUserScreenState extends State<RegisterUserScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _passwordVisiblityHide = true;
  bool _isLoading = false;

  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _fadeInAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  void _registerUser() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true; // Show loading indicator
      });

      final usersBox = Hive.box<User>('users');
      final existingUser = usersBox.values.any(
        (user) => user.email == _emailController.text.trim(),
      );

      if (existingUser) {
        setState(() {
          _isLoading = false; // Hide loading indicator
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User already exists!')),
        );
        return;
      }

      final newUser = User(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await usersBox.add(newUser);

      setState(() {
        _isLoading = false; // Hide loading indicator
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User Registered Successfully!')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
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
                      // Username Field
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          filled: true,
                          labelStyle: TextStyle(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        validator: (username) {
                          String? message =
                              AuthInputValidationMixin.isUsernameValid(
                                  username);
                          return message;
                        },
                      ),
                      const SizedBox(height: 10),
                      // Email Field
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          filled: true,
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
                      const SizedBox(height: 10),
                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          filled: true,
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
                                _passwordVisiblityHide =
                                    !_passwordVisiblityHide;
                              });
                            },
                          ),
                        ),
                        validator: (password) {
                          String? message =
                              AuthInputValidationMixin.isPasswordValid(
                                  password);
                          return message;
                        },
                        obscureText: _passwordVisiblityHide,
                      ),
                      const SizedBox(height: 10),
                      // Confirm Password Field
                      TextFormField(
                        controller: _confirmPasswordController,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          filled: true,
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
                      const SizedBox(height: 20),
                      // Register Button
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: _isLoading
                            ? 50
                            : MediaQuery.of(context).size.width * 0.8,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _registerUser,
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
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text('Register'),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Navigate to Login
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginScreen()));
                        },
                        child: const Text(
                          'Already have an account? Login',
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
