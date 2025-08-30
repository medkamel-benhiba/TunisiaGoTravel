import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tunisiagotravel/screens/signup_screen.dart';
import 'package:tunisiagotravel/theme/color.dart';
import '../providers/auth_provider.dart';
import '../providers/global_provider.dart';
import 'main_wrapper_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await context.read<AuthProvider>().login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainWrapperScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Échec de la connexion")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;
    final provider = Provider.of<GlobalProvider>(context);

    return Scaffold(
      body: Container(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Image.asset(
                  'assets/icon/img.png',
                height: 90,
              ),
              const SizedBox(height: 16),
              Text(
                "Bienvenue sur Tunisia Go Travel",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColorstatic.buttonbg,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "Connectez-vous pour explorer la Tunisie",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: "Email",
                            prefixIcon: Icon(Icons.email, color: AppColorstatic.buttonbg),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (val) => val!.isEmpty ? "Entrez votre email" : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: "Mot de passe",
                            prefixIcon: Icon(Icons.lock, color: AppColorstatic.buttonbg),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          obscureText: true,
                          validator: (val) => val!.isEmpty ? "Entrez votre mot de passe" : null,
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Fonctionnalité à venir")),
                              );
                            },
                            child: Text(
                              "Mot de passe oublié ?",
                              style: TextStyle(color: AppColorstatic.buttonbg),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColorstatic.buttonbg,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text("Se connecter"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Vous n'avez pas encore de compte?",
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  TextButton(
                    onPressed: () {
                      provider.setPage(AppPage.signup);
                    },
                    child: Text(
                      "Créer un compte",
                      style: TextStyle(color: AppColorstatic.buttonbg),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}