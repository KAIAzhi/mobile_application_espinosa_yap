import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';
import 'home.dart';

class LoginnWidget extends StatefulWidget {
  const LoginnWidget({super.key});

  @override
  State<LoginnWidget> createState() => _LoginnWidgetState();
}

class _LoginnWidgetState extends State<LoginnWidget> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool passwordVisible = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Logo
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryBlue, AppTheme.primaryBlueDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryBlue.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.medical_services,
              color: Colors.white,
              size: 60,
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            'RescueHub',
            style: GoogleFonts.interTight(
              fontSize: 32,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Community-led disaster response',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.hintColor,
            ),
          ),
          const SizedBox(height: 32),

          // Email Field
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Email or Mobile Number',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'name@email.com or +63...',
              prefixIcon: const Icon(Icons.contact_mail),
              filled: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Password Field
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Password',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: passwordController,
            obscureText: !passwordVisible,
            decoration: InputDecoration(
              hintText: '••••••••',
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  passwordVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () {
                  setState(() {
                    passwordVisible = !passwordVisible;
                  });
                },
              ),
              filled: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Forgot Password
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {},
              child: Text(
                'Forgot Password?',
                style: GoogleFonts.outfit(
                  color: AppTheme.primaryBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Login Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeWidget()),
                );
              },
              icon: const Icon(Icons.login, size: 22),
              label: const Text('Login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                elevation: 3,
                shadowColor: AppTheme.primaryBlue.withOpacity(0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // OR
          Text(
            'OR',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.hintColor,
            ),
          ),
          const SizedBox(height: 16),

          // Register
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'New to RescueHub?',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.hintColor,
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () {},
                child: Text(
                  'Register',
                  style: GoogleFonts.outfit(
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}