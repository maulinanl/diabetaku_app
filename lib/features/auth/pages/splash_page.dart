import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/services/medication_reminder_service.dart';
import '../../../data/services/push_notification_service.dart';
import '../../caregiver/pages/caregiver_main_page.dart';
import '../../doctor/pages/doctor_main_page.dart';
import '../../patient/pages/patient_main_page.dart';
import 'login_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkSessionAndNavigate();
  }

  Future<void> _checkSessionAndNavigate() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final roleId = prefs.getInt('role_id');

    Widget nextPage = const LoginPage();

    if (token != null && token.isNotEmpty && roleId != null) {
      if (roleId == 2) {
        nextPage = const DoctorMainPage();
      } else if (roleId == 3) {
        nextPage = const PatientMainPage();

        try {
          await MedicationReminderService.syncMedicationReminders();
        } catch (e) {
          debugPrint('SYNC MEDICATION REMINDER SAAT RESTORE SESSION ERROR: $e');
        }
      } else if (roleId == 4) {
        nextPage = const CaregiverMainPage();
      }

      try {
        await PushNotificationService.registerTokenToBackend();
      } catch (e) {
        debugPrint('REGISTER FCM TOKEN SAAT RESTORE SESSION ERROR: $e');
      }
    }

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => nextPage),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/background_splash.png',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/images/logo.png', width: 200),
                const SizedBox(height: 80),
                Image.asset('assets/images/blood.png', width: 160),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
