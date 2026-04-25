import 'package:Billy/constants.dart';
import 'package:Billy/services/signin_signup_logout_service.dart';
import 'package:Billy/widgets/components/custom_validated_textfield_widget.dart';
import 'package:Billy/widgets/components/error_alert_widget.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final Logger log = Logger('LoginPage');
  late SigninSignupLogoutService signinSignupLogoutService;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _isFormValid = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    signinSignupLogoutService = SigninSignupLogoutService();

    _emailController.addListener(_onFormChanged);
    _passwordController.addListener(_onFormChanged);
  }

  @override
  void dispose() {
    _emailController.removeListener(_onFormChanged);
    _passwordController.removeListener(_onFormChanged);

    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onFormChanged() {
    setState(() {
      _isFormValid = _emailController.text.trim().isNotEmpty && _passwordController.text.trim().isNotEmpty;
    });
  }

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final res = await signinSignupLogoutService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (res.user == null) {
        setState(() => _errorMessage = 'Login fallito');
      }
      else if (mounted) {
        // Naviga alla homepage e rimuovi la pagina di login dallo stack
        Navigator.of(context).pushReplacementNamed('/');
      }
    } 
    catch (e) {
      setState(() => _errorMessage = e.toString());
    } 
    finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/logo.png', height: 250),
              
              // Email input field
              const SizedBox(height: AppConstants.sizedBoxHeight),
              CustomValidatedTextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                labelText: 'Email',
                prefixIcon: Icon(Icons.email, size: 24),
                validator: (value) => value.trim().isEmpty ? 'Campo obbligatorio' : null,
              ),
              
              // Password input field
              const SizedBox(height: AppConstants.sizedBoxHeight),
              CustomValidatedTextField(
                controller: _passwordController,
                labelText: 'Password',
                obscureText: true,
                prefixIcon: Icon(Icons.key, size: 24),
                onSubmitted: (_) => _login(),
                validator: (value) => value.trim().isEmpty ? 'Campo obbligatorio' : null,
              ),
              
              // Error message
              if (_errorMessage != null) ...[
                ErrorAlertWidget(errorMessage: _errorMessage!),
                const SizedBox(height: 4),
              ],

              // Login button
              const SizedBox(height: AppConstants.sizedBoxHeight),
              if (_loading) ...[
                const CircularProgressIndicator(),
              ] 
              else ...[
                ElevatedButton(
                  onPressed: _isFormValid ? _login : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer, // dark;
                    minimumSize: const Size(double.infinity, 48), // Rende il pulsante full-width
                  ),
                  child: const Text('Login'),
                ),
              ],
              
              // Registration Page Navigation
              const SizedBox(height: AppConstants.sizedBoxHeight),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: const Text('Non hai un account? Registrati'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}