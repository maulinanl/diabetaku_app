import 'package:diabetaku_app/core/widgets/role_card.dart';
import 'package:flutter/material.dart';
import 'register_doctor_step1_page.dart';
import 'register_patient_page.dart';
import 'register_caregiver_page.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Daftar Akun",
          style: TextStyle(
            color: Color(0xFF3A86D1),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Pilih peran yang sesuai untuk membuka akun"),
            ),

            const SizedBox(height: 20),

            RoleCard(
              icon: Icons.medical_services,
              title: "Daftar sebagai Dokter",
              subtitle: "Pantau pasien dan kelola data kesehatan",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RegisterDoctorStep1Page(),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            RoleCard(
              icon: Icons.person,
              title: "Daftar sebagai Pasien",
              subtitle: "Catat dan pantau kondisi kesehatan",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RegisterPatientPage(),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            RoleCard(
              icon: Icons.groups,
              title: "Daftar sebagai Keluarga",
              subtitle: "Bantu memantau kondisi anggota keluarga",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterCaregiverPage()),
                );
              },
            ),

            const Spacer(),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Sudah punya akun? "),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Masuk",
                    style: TextStyle(
                      color: Color(0xFF3A86D1),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
