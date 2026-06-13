import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class FamilyEditProfilePage extends StatefulWidget {
  const FamilyEditProfilePage({super.key});

  @override
  State<FamilyEditProfilePage> createState() =>
      _FamilyEditProfilePageState();
}

class _FamilyEditProfilePageState
    extends State<FamilyEditProfilePage> {
  final _nameController =
      TextEditingController(text: 'Angelica Sabi Gita');

  final _emailController =
      TextEditingController(text: 'angelicaSabiGit@gmail.com');

  final _phoneController =
      TextEditingController(text: '081234567890');

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              16,
              topPad + 14,
              16,
              18,
            ),
            color: AppColors.primaryBlue,
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                ),
                const Expanded(
                  child: Text(
                    'Ubah Profil',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.person,
                        color: AppColors.primaryBlue,
                        size: 18,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Data Diri',
                        style: TextStyle(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  _buildField(
                    label: 'Nama Lengkap',
                    controller: _nameController,
                  ),

                  const SizedBox(height: 18),

                  _buildField(
                    label: 'Email',
                    controller: _emailController,
                    keyboardType:
                        TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 18),

                  _buildField(
                    label: 'Nomor Telepon',
                    controller: _phoneController,
                    keyboardType:
                        TextInputType.phone,
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text(
                        'Simpan Perubahan',
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Batal',
                        style: TextStyle(
                          color:
                              AppColors.primaryBlue,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType =
        TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.dark2,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(6),
              borderSide: const BorderSide(
                color: AppColors.light1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(6),
              borderSide: const BorderSide(
                color: AppColors.light1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
