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
      _isFormValid = _nameController.text.trim().isNotEmpty
                    && _usernameController.text.trim().isNotEmpty 
                    && _emailController.text.trim().isNotEmpty
                    && _passwordController.text.trim().isNotEmpty
                    && _repeatPasswordController.text.trim().isNotEmpty
                    && (_passwordController.text.trim() == _repeatPasswordController.text.trim());
    });
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
      else {
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
                errorText: null, // TODO: _nameController.text.trim().isEmpty && !_isFormValid ? 'Campo obbligatorio' : null,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                errorText: null, // TODO: _emailController.text.trim().isEmpty && !_isFormValid ? 'Campo obbligatorio' : null,
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                errorText: null, // TODO: _usernameController.text.trim().isEmpty && !_isFormValid ? 'Campo obbligatorio' : null,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                errorText: null, // TODO: _passwordController.text.trim().isEmpty && !_isFormValid ? 'Campo obbligatorio' : null,
                suffixIcon: IconButton(
                  icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () {
                    setState(() {
                      _showPassword = !_showPassword;
                    });
                  },
                ),
              ),
              obscureText: !_showPassword,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _repeatPasswordController,
              decoration: InputDecoration(
                labelText: 'Ripeti Password',
                errorText: null, // TODO: null, // TODO: _passwordController.text.trim().isEmpty && !_isFormValid ? 'Campo obbligatorio' : null,
                suffixIcon: IconButton(
                  icon: Icon(_showRepeatPassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () {
                    setState(() {
                      _showRepeatPassword = !_showRepeatPassword;
                    });
                  },
                ),
              ),
              obscureText: !_showRepeatPassword,
            ),
            const SizedBox(height: 24),
            if (_error != null) 
              Text(_error!, style: const TextStyle(color: Colors.red)),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_loading || !_isFormValid) ? null : _register,
                child: _loading ? const CircularProgressIndicator() : const Text('Registrati'),
              ),
            ),
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
