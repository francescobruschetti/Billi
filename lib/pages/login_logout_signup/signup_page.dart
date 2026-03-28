import 'package:Billy/widgets/components/custom_icon_widget.dart';
import 'package:Billy/widgets/components/custom_validated_textfield_widget.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logging/logging.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {  
  final Logger log = Logger('SignupPage');
  
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
      final SupabaseClient supabase = Supabase.instance.client;

      final res = await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        data: {
          'username': _usernameController.text.trim(),
          'name': _nameController.text.trim(),
        },
      );
      
      if (res.user == null) {
        setState(() => _error = 'Registrazione fallita');
      }      
      else if (mounted) {
        // Naviga alla login e rimuovi la pagina di registrazione dallo stack
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } 
    on AuthException catch (e) {
      log.severe("Registration error: ${e.message}");
      setState(() => _error = e.message);
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
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nome',
                border: const OutlineInputBorder(),
              ),
            ),
            
            const SizedBox(height: 16),
            CustomValidatedTextField(
              controller: _emailController,
              labelText: 'Email',
              validator: (value) => value.trim().isEmpty ? 'Campo obbligatorio' : null,
              keyboardType: TextInputType.emailAddress,
            ),
            
            const SizedBox(height: 16),
            CustomValidatedTextField(
              controller: _usernameController,
              labelText: 'Username',
              validator: (value) => value.trim().isEmpty ? 'Campo obbligatorio' : null,
            ),
            
            const SizedBox(height: 16),
            CustomValidatedTextField(
              controller: _passwordController,
              labelText: 'Password',
              validator: (value) => value.trim().isEmpty ? 'Campo obbligatorio' : null,
              obscureText: !_showPassword,
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
            ),
            
            const SizedBox(height: 16),
            CustomValidatedTextField(
              controller: _repeatPasswordController,
              labelText: 'Ripeti Password',
              validator: (value) => passwordsMatchErrorValidator(value),
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
            ),

            const SizedBox(height: 24),
            if (_error != null) ...[
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],

            // Registration button
            const SizedBox(height: 16),
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
            const SizedBox(height: 16),
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
