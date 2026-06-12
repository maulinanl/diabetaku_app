import 'package:flutter/material.dart';

import 'doctor_home_page.dart';
import 'doctor_connection_page.dart';
import 'doctor_history_page.dart';
import 'doctor_profile_page.dart';

import '../widgets/doctor_bottom_nav.dart';

class DoctorMainPage extends StatefulWidget {
  const DoctorMainPage({super.key});

  @override
  State<DoctorMainPage> createState() => _DoctorMainPageState();
}

class _DoctorMainPageState extends State<DoctorMainPage> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const DoctorHomePage(showNavbar: false),
      const DoctorConnectionPage(),
      const DoctorHistoryPage(),
      const DoctorProfilePage(),
    ];

    return Scaffold(
      body: pages[currentIndex],

      bottomNavigationBar: DoctorBottomNavBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}