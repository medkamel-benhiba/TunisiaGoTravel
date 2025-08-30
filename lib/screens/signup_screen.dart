import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/global_provider.dart';
import '../theme/color.dart';
import 'main_wrapper_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await context.read<AuthProvider>().signUp(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text.trim(),
      _phoneController.text.trim(),
      _cityController.text.trim(),
    );

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Inscription réussie, connectez-vous !")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Échec de l'inscription")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;
    final provider = Provider.of<GlobalProvider>(context);

    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset(
                'assets/icon/img.png',
                height: 70,
              ),
              const SizedBox(height: 10),
              Text(
                "Créer un compte",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColorstatic.buttonbg,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
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
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: "Nom",
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator: (val) =>
                          val!.isEmpty ? "Entrez votre nom" : null,
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: "Email",
                            prefixIcon: Icon(Icons.email),
                          ),
                          validator: (val) =>
                          val!.isEmpty ? "Entrez votre email" : null,
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: _passwordController,
                          decoration: const InputDecoration(
                            labelText: "Mot de passe",
                            prefixIcon: Icon(Icons.lock),
                          ),
                          obscureText: true,
                          validator: (val) =>
                          val!.isEmpty ? "Entrez un mot de passe" : null,
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: _phoneController,
                          decoration: const InputDecoration(
                            labelText: "Téléphone",
                            prefixIcon: Icon(Icons.phone),
                          ),
                          validator: (val) =>
                          val!.isEmpty ? "Entrez votre téléphone" : null,
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: _cityController,
                          decoration: const InputDecoration(
                            labelText: "Ville",
                            prefixIcon: Icon(Icons.location_city),
                          ),
                          validator: (val) =>
                          val!.isEmpty ? "Entrez votre ville" : null,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: isLoading ? null : _signUp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColorstatic.buttonbg,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(
                              color: Colors.white)
                              : const Text("S'inscrire"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Vous avez déjà un compte?",
                    style: TextStyle(color: Colors.grey.shade800),
                  ),
                  TextButton(
                    onPressed: () {
                      provider.setPage(AppPage.login);
                    },
                    child: Text(
                      "Se connecter",
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
