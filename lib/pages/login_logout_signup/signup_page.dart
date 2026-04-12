import 'package:Billy/constants.dart';
import 'package:Billy/services/signin_signup_logout_service.dart';
import 'package:Billy/widgets/components/custom_icon_widget.dart';
import 'package:Billy/widgets/components/custom_validated_textfield_widget.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final Logger log = Logger('SignupPage');
  late SigninSignupLogoutService signinSignupLogoutService;
  
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();
  bool _loading = false;
  bool _isFormValid = false;
  bool _showPassword = false;
  bool _showRepeatPassword = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    signinSignupLogoutService = SigninSignupLogoutService();

    _nameController.addListener(_onFormChanged);
    _usernameController.addListener(_onFormChanged);
    _emailController.addListener(_onFormChanged);
    _passwordController.addListener(_onFormChanged);
    _repeatPasswordController.addListener(_onFormChanged);
  }

  void _onFormChanged() {
    setState(() {
      _isFormValid = _usernameController.text.trim().isNotEmpty 
                    && _emailController.text.trim().isNotEmpty
                    && _passwordController.text.trim().isNotEmpty
                    && _repeatPasswordController.text.trim().isNotEmpty
                    && (_passwordController.text.trim() == _repeatPasswordController.text.trim());
    });
  }

  String? passwordsMatchErrorValidator(String value) {
    if (_repeatPasswordController.text.trim().isEmpty) {
      return 'Campo obbligatorio';
    }
    if (_passwordController.text.trim() != _repeatPasswordController.text.trim()) {
      return 'Le password non corrispondono';
    }
    return null;
  }

  Future<void> _register() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await signinSignupLogoutService.signup(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        username: _usernameController.text.trim(),
        name: _nameController.text.trim(),
      );

      if (res.user == null) {
        setState(() => _error = 'Registrazione fallita');
      }      
      else if (mounted) {
        // Naviga alla login e rimuovi la pagina di registrazione dallo stack
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } 
    catch (e) {
      log.severe("Registration error: ${e.toString()}");
      setState(() => _error = e.toString());
    } 
    finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrazione')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomValidatedTextField(
              controller: _nameController,
              labelText: 'Nome',
              prefixIcon: Icon(Icons.person, size: 24),
            ),
            
            const SizedBox(height: AppConstants.sizedBoxHeight),
            CustomValidatedTextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              labelText: 'Email',
              prefixIcon: Icon(Icons.email, size: 24),
              validator: (value) => value.trim().isEmpty ? 'Campo obbligatorio' : null,
            ),
            
            const SizedBox(height: AppConstants.sizedBoxHeight),
            CustomValidatedTextField(
              controller: _usernameController,
              labelText: 'Username',
              prefixIcon: Icon(Icons.person, size: 24),
              validator: (value) => value.trim().isEmpty ? 'Campo obbligatorio' : null,
            ),
            
            const SizedBox(height: AppConstants.sizedBoxHeight),
            CustomValidatedTextField(
              controller: _passwordController,
              labelText: 'Password',
              obscureText: !_showPassword,
              prefixIcon: Icon(Icons.key, size: 24),
              suffixIcon: IconButton(
                icon: CustomIconWidget(
                  assetPath: 'assets/images/icons/${_showPassword ? 'eye_closed.PNG' : 'eye_open.PNG'}',
                  size: 24
                ),
                onPressed: () {
                  setState(() {
                    _showPassword = !_showPassword;
                  });
                },
              ),
              validator: (value) => value.trim().isEmpty ? 'Campo obbligatorio' : null,
            ),
            
            const SizedBox(height: AppConstants.sizedBoxHeight),
            CustomValidatedTextField(
              controller: _repeatPasswordController,
              labelText: 'Ripeti Password',
              prefixIcon: Icon(Icons.key, size: 24),
              suffixIcon: IconButton(
                icon: CustomIconWidget(
                  assetPath: 'assets/images/icons/${_showRepeatPassword ? 'eye_closed.PNG' : 'eye_open.PNG'}',
                  size: 24
                ),
                onPressed: () {
                  setState(() {
                    _showRepeatPassword = !_showRepeatPassword;
                  });
                },
              ),
              validator: (value) => passwordsMatchErrorValidator(value),
            ),

            const SizedBox(height: 24),
            if (_error != null) ...[
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],

            // Registration button
            const SizedBox(height: AppConstants.sizedBoxHeight),
            if (_loading) ...[
              const CircularProgressIndicator(),
            ] 
            else ...[
              ElevatedButton(
                onPressed: _isFormValid ? _register : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  minimumSize: const Size(double.infinity, 48), // Rende il pulsante full-width
                ),
                child: const Text('Registrati'),
              ),
            ],

            // Login Page navigation
            const SizedBox(height: AppConstants.sizedBoxHeight),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Hai già un account? Login'),
            ),
          ],
        ),
      ),
    );
  }
}
