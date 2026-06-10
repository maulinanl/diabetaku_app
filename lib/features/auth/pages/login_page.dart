import 'package:flutter/material.dart';
import 'role_selection_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 20,
          ),
          child: Column(
            children: [
              const SizedBox(height: 20),

              Image.asset(
                'assets/images/logo.png',
                width: 140,
              ),

              const SizedBox(height: 12),

              const Text(
                'Selamat Datang\nMasuk Akun',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 32),

              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Email atau phone',
                  filled: true,
                  fillColor: const Color(0xFFF5F7FB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Password',
                  filled: true,
                  fillColor: const Color(0xFFF5F7FB),
                  suffixIcon: const Icon(Icons.visibility_off),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Lupa kata sandi?',
                  ),
                ),
              ),

              const SizedBox(height: 8),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F80ED),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Masuk'),
                ),
              ),

              const SizedBox(height: 20),

              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10),
                    child: Text('atau'),
                  ),
                  Expanded(child: Divider()),
                ],
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const RoleSelectionPage(),
      ),
    );
  },
  child: const Text('Daftar Akun Baru'),
),
              ),

              const SizedBox(height: 30),

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  const Text(
                    'Butuh bantuan? ',
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: const Text(
                      'Hubungi admin',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}