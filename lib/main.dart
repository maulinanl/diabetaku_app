import 'package:flutter/material.dart';
import 'features/doctor/pages/doctor_home_page.dart';

void main() {
  runApp(const DiabetAkuApp());
}

class DiabetAkuApp extends StatelessWidget {
  const DiabetAkuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'diabetAku',
      debugShowCheckedModeBanner: false,
      home: const DoctorHomePage(),
    );
  }
}



