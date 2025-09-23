import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
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
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _prenomController.dispose();
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
      _prenomController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text.trim(),
      _phoneController.text.trim(),
      _cityController.text.trim(),
    );

    if (success) {
      // Show success snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('signup_success'.tr()),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainWrapperScreen()),
            (route) => false,
      );
    } else {
      // Show failure snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('signup_failed'.tr()),
          backgroundColor: Colors.red,
        ),
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
                'signup_title'.tr(),
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
                          decoration: InputDecoration(
                            labelText: 'name'.tr(),
                            prefixIcon: const Icon(Icons.person),
                          ),
                          validator: (val) =>
                          val!.isEmpty ? 'enter_name'.tr() : null,
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: _prenomController,
                          decoration: InputDecoration(
                            labelText: 'prenom'.tr(),
                            prefixIcon: const Icon(Icons.person),
                          ),
                          validator: (val) =>
                          val!.isEmpty ? 'enter_prenom'.tr() : null,
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'email'.tr(),
                            prefixIcon: const Icon(Icons.email),
                          ),
                          validator: (val) =>
                          val!.isEmpty ? 'enter_email'.tr() : null,
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'password'.tr(),
                            prefixIcon: const Icon(Icons.lock),
                          ),
                          obscureText: true,
                          validator: (val) =>
                          val!.isEmpty ? 'enter_password'.tr() : null,
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: _phoneController,
                          decoration: InputDecoration(
                            labelText: 'phone'.tr(),
                            prefixIcon: const Icon(Icons.phone),
                          ),
                          validator: (val) =>
                          val!.isEmpty ? 'enter_phone'.tr() : null,
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: _cityController,
                          decoration: InputDecoration(
                            labelText: 'city'.tr(),
                            prefixIcon: const Icon(Icons.location_city),
                          ),
                          validator: (val) =>
                          val!.isEmpty ? 'enter_city'.tr() : null,
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
                              : Text('signup_button'.tr()),
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
                    'already_account'.tr(),
                    style: TextStyle(color: Colors.grey.shade800),
                  ),
                  TextButton(
                    onPressed: () {
                      provider.setPage(AppPage.login);
                    },
                    child: Text(
                      'login_button'.tr(),
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
