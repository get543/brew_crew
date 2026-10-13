import 'package:flutter/material.dart';
import 'package:brew_crew/services/auth.dart';
import 'package:brew_crew/shared/constant.dart';
import 'package:brew_crew/shared/loading.dart';

class Register extends StatefulWidget {
  final VoidCallback toggleView;

  const Register({super.key, required this.toggleView});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  bool obscurePassword = true;
  String email = '';
  String password = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return loading
        ? const Loading()
        : Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              backgroundColor: Colors.brown[400],
              foregroundColor: Colors.brown[50],
              elevation: 0,
              title: const Text('Brew Crew'),
              actions: [
                TextButton.icon(
                  onPressed: widget.toggleView,
                  icon: const Icon(Icons.login),
                  label: const Text('Sign in'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.brown[50],
                  ),
                ),
              ],
            ),
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: Card(
                      elevation: 4,
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      child: Padding(
                        padding: const EdgeInsets.all(28),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const CircleAvatar(
                                radius: 32,
                                backgroundColor: Colors.white,
                                child: Padding(
                                  padding: EdgeInsets.all(7),
                                  child: Image(
                                    image: AssetImage('assets/brewcrew_512x512.png'),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              Text(
                                'Create your account',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Save your coffee preferences and order faster',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 28),
                              TextFormField(
                                keyboardType: TextInputType.emailAddress,
                                decoration: textInputDecoration(
                                  isDark,
                                ).copyWith(labelText: 'Email', prefixIcon: const Icon(Icons.email_outlined)),
                                onChanged: (value) => email = value,
                                validator: (value) => value == null || value.trim().isEmpty ? 'Enter an email' : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                obscureText: obscurePassword,
                                decoration: textInputDecoration(isDark).copyWith(
                                  labelText: 'Password',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    tooltip: obscurePassword ? 'Show password' : 'Hide password',
                                    onPressed: () => setState(() => obscurePassword = !obscurePassword),
                                    icon: Icon(
                                      obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                    ),
                                  ),
                                ),
                                onChanged: (value) => password = value,
                                validator: (value) =>
                                    value == null || value.length < 8 ? 'Use at least 8 characters' : null,
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                height: 52,
                                child: ElevatedButton.icon(
                                  onPressed: _register,
                                  icon: const Icon(Icons.person_add_alt_1),
                                  label: const Text('Create account'),
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: Colors.pink[400],
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  ),
                                ),
                              ),
                              if (error.isNotEmpty) ...[
                                const SizedBox(height: 14),
                                Text(
                                  error,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => loading = true);
    final result = await _auth.registerWithEmailAndPassword(email, password);
    if (result == null && mounted) {
      setState(() {
        error = 'Could not create the account. Check your details.';
        loading = false;
      });
    }
  }
}
