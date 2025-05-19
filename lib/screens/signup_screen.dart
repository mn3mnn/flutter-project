import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_flutter/blocs/signup/signup_bloc.dart';
import 'package:project_flutter/blocs/signup/signup_event.dart';
import 'package:project_flutter/blocs/signup/signup_state.dart';
import 'package:project_flutter/screens/login_screen.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  
  bool? selectedGender;
  int? selectedLevel;

  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text("Success"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 64),
            SizedBox(height: 16),
            Text(message),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text("Continue"),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String errorMessage) {
    String displayMessage = errorMessage;
    List<Widget> actions = [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Text("OK"),
      ),
    ];
    
    if (errorMessage.contains('Email already used before')) {
      displayMessage = 'This email is already registered.';
      actions.add(
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text("Login"),
        ),
      );
    }
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Error"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 64),
            SizedBox(height: 16),
            Text(
              displayMessage,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: actions,
      ),
    );
  }

  SignupSubmitEvent _createSignupEvent() {
    return SignupSubmitEvent(
      name: nameController.text,
      email: emailController.text, 
      gender: selectedGender,
      level: selectedLevel,
      password: passwordController.text,
      confirmPassword: confirmPasswordController.text,
     
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (_) => SignupBloc(),
        child: BlocConsumer<SignupBloc, SignupState>(
          listener: (context, state) {
            if (state is SignupSuccess) {
              _showSuccessDialog(context, state.message);
            }
            if (state is SignupError) {
              _showErrorDialog(context, state.message);
            }
          },
          builder: (context, state) {
            return Stack(
              children: [
                Container(
                  height: double.infinity,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromRGBO(70, 220, 220, 0.773),
                        Color.fromRGBO(45, 139, 227, 0.278),
                      ],
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.only(top: 60.0, left: 22),
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 30,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.only(top: 120.0),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    height: double.infinity,
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 40),
                      child: Form(
                        key: _formKey,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Name field
                              const SizedBox(height: 15),
                              TextFormField(
                                controller: nameController,
                                decoration: const InputDecoration(
                                  labelText: 'Name',
                                  suffixIcon: Icon(Icons.person, color: Colors.grey),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your name';
                                  }
                                  return null;
                                },
                                textInputAction: TextInputAction.next,
                              ),
                              const SizedBox(height: 15),
                              
                              // Gender selection
                              const Text("Gender:"),
                              Row(
                                  children: [
                                    Radio<bool>(
                                      value: true,
                                      groupValue: selectedGender,
                                      onChanged: (value) => setState(() => selectedGender = value),
                                    ),
                                    const Text("Male"),
                                    Radio<bool>(
                                      value: false,
                                      groupValue: selectedGender,
                                      onChanged: (value) => setState(() => selectedGender = value),
                                    ),
                                    const Text("Female"),
                                  ],
                                ),
                              
                              const SizedBox(height: 15),
                              
                              // Email field
                              TextFormField(
                                controller: emailController,
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  suffixIcon: Icon(Icons.email, color: Colors.grey),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  
                                  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                  if (!emailRegex.hasMatch(value)) {
                                    return 'Please enter a valid email address';
                                  }
                                  
                                  return null;
                                },
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                              ),
                              const SizedBox(height: 15),
                              
                              // Level selection
                              DropdownButtonFormField<int>(
                                decoration: const InputDecoration(
                                  labelText: 'Level',
                                ),
                                value: selectedLevel,
                                items: [1, 2, 3, 4].map((level) {
                                  return DropdownMenuItem(
                                    value: level,
                                    child: Text('Level $level'),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedLevel = value;
                                  });
                                },
                                validator: (value) {
                                  return null; // Level is optional in this case
                                },
                              ),
                              const SizedBox(height: 15),
                              
                              // Password field
                              TextFormField(
                                controller: passwordController,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a password';
                                  }
                                  
                                  if (value.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  
                                  return null;
                                },
                                obscureText: _obscurePassword,
                                textInputAction: TextInputAction.next,
                              ),
                              const SizedBox(height: 15),
                              
                              // Confirm Password field
                              TextFormField(
                                controller: confirmPasswordController,
                                decoration: InputDecoration(
                                  labelText: 'Confirm Password',
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureConfirmPassword = !_obscureConfirmPassword;
                                      });
                                    },
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please confirm your password';
                                  }
                                  
                                  if (value != passwordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  
                                  return null;
                                },
                                obscureText: _obscureConfirmPassword,
                                textInputAction: TextInputAction.done,
                              ),
                              const SizedBox(height: 25),
                              
                              Container(
                                height: 50,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color.fromRGBO(70, 220, 220, 0.773),
                                      Color.fromRGBO(45, 139, 227, 0.278),
                                    ],
                                  ),
                                ),
                                child: InkWell(
                                  onTap: state is SignupLoading
                                      ? null
                                      : () {
                                          if (_formKey.currentState?.validate() ?? false) {
                                            context.read<SignupBloc>().add(_createSignupEvent());
                                          }
                                        },
                                  child: Center(
                                    child: state is SignupLoading
                                        ? CircularProgressIndicator(color: Colors.white)
                                        : Text(
                                            'Sign Up',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                              color: Colors.black,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 20),
                              Center(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (context) => LoginScreen()),
                                    );
                                  },
                                  child: const Text(
                                    "Already have an account? Login",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ),
                              ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}