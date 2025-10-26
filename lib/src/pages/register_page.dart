import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  bool _obscure = true;
  String _name = '';
  String _email = '';
  String _username = '';
  String _password = '';
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_add_alt_1, size: 64, color: Colors.blue),
              const SizedBox(height: 16),
              const Text(
                'Register Akun',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Nama',
                        border: OutlineInputBorder(),
                      ),
                      onSaved: (v) => _name = v ?? '',
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Masukkan nama' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      onSaved: (v) => _email = v ?? '',
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Masukkan email' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(),
                      ),
                      onSaved: (v) => _username = v ?? '',
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Masukkan username' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      obscureText: _obscure,
                      onSaved: (v) => _password = v ?? '',
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Masukkan password' : null,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            _formKey.currentState?.save();
                            setState(() => _loading = true);
                            final prov = Provider.of<OrderProvider>(
                              context,
                              listen: false,
                            );
                            // Capture navigator and messenger before any awaits to avoid
                            // using BuildContext after async gaps (fixes lint warnings).
                            final navigator = Navigator.of(context);
                            final messenger = ScaffoldMessenger.of(context);

                            final ok = await prov.registerUser(
                              username: _username.trim(),
                              password: _password,
                              name: _name,
                              email: _email,
                            );
                            setState(() => _loading = false);
                            if (!mounted) return;
                            if (ok) {
                              // auto-login newly registered user
                              final loggedIn = await prov.login(
                                _username.trim(),
                                _password,
                              );
                              if (!mounted) return;
                              if (loggedIn) {
                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Registrasi berhasil! Anda telah otomatis login.',
                                    ),
                                  ),
                                );
                                navigator.pushReplacementNamed('/');
                              } else {
                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Registrasi berhasil, silakan login.',
                                    ),
                                  ),
                                );
                                navigator.pushReplacementNamed('/login');
                              }
                            } else {
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text('Username sudah terpakai'),
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0B57D0),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _loading
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Register',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
