import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.8.225:8000/api';
  
  static Future<void> registerDoctor({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
    required String confirmPassword,
    required String gender,
    required int specializationId,
    required String strNumber,
    required String institution,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register/doctor'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'full_name': fullName,
        'email': email,
        'phone_number': phoneNumber,
        'gender': gender,
        'password': password,
        'password_confirmation': confirmPassword,
        'specialization_id': specializationId,
        'str_number': strNumber,
        'institution': institution,
      }),
    );

    print('REGISTER DOCTOR STATUS: ${response.statusCode}');
    print('REGISTER DOCTOR BODY: ${response.body}');

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return;
    }

    if (response.statusCode == 422 && data['errors'] != null) {
      final errors = data['errors'] as Map<String, dynamic>;
      final firstError = errors.values.first;

      if (firstError is List && firstError.isNotEmpty) {
        throw Exception(firstError.first.toString());
      }
    }

    if (data['error'] != null) {
      throw Exception(data['error'].toString());
    }

    throw Exception(data['message'] ?? 'Registrasi dokter gagal');
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'email': email, 'password': password}),
    );

    final data = jsonDecode(response.body);

    print('LOGIN STATUS: ${response.statusCode}');
    print('LOGIN BODY: ${response.body}');

    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('token', data['token']);
      await prefs.setInt('user_id', data['user']['user_id']);
      await prefs.setInt('role_id', data['user']['role_id']);
      await prefs.setString('full_name', data['user']['full_name']);

      if (data['doctor'] != null) {
        await prefs.setInt(
          'doctor_id',
          int.parse(data['doctor']['doctor_id'].toString()),
        );
      }

      if (data['patient'] != null) {
        await prefs.setInt(
          'patient_id',
          int.parse(data['patient']['patient_id'].toString()),
        );
      }

      if (data['family'] != null) {
        await prefs.setInt(
          'family_id',
          int.parse(data['family']['family_id'].toString()),
        );
      }

      return data;
    }

    final status = data['status']?.toString();
    final message = data['message']?.toString() ?? 'Login gagal';

    if (status != null) {
      throw Exception(
        '$status|$message|${data['locked_until'] ?? ''}|${data['role_id'] ?? ''}',
      );
    }

    throw Exception(message);
  }

  static Future<bool> checkEmailExists(String email) async {
    final uri = Uri.parse(
      '$baseUrl/auth/check-email',
    ).replace(queryParameters: {'email': email.trim().toLowerCase()});

    final response = await http.get(
      uri,
      headers: {'Accept': 'application/json'},
    );

    print('CHECK EMAIL STATUS: ${response.statusCode}');
    print('CHECK EMAIL BODY: ${response.body}');

    if (response.body.trim().startsWith('<')) {
      throw Exception('Endpoint check-email belum ditemukan di Laravel');
    }

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data['exists'] == true;
    }

    throw Exception(data['message'] ?? 'Gagal memeriksa email');
  }

  static Future<void> registerPatient({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
    required String confirmPassword,
    required String gender,
    required String diabetesType,
    required DateTime birthDate,
    required DateTime diagnosisDate,
    required double heightCm,
    required int bloodTypeId,
    required int rhesusTypeId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register/patient'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'full_name': fullName,
        'email': email,
        'phone_number': phoneNumber,
        'password': password,
        'password_confirmation': confirmPassword,
        'gender': gender,
        'diabetes_type': diabetesType,
        'date_of_birth': birthDate.toIso8601String().split('T').first,
        'diagnosis_date': diagnosisDate.toIso8601String().split('T').first,
        'height_cm': heightCm,
        'blood_type_id': bloodTypeId,
        'rhesus_type_id': rhesusTypeId,
      }),
    );

    print('REGISTER PATIENT STATUS: ${response.statusCode}');
    print('REGISTER PATIENT BODY: ${response.body}');

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return;
    }

    if (response.statusCode == 422 && data['errors'] != null) {
      final errors = data['errors'] as Map<String, dynamic>;
      final firstError = errors.values.first;

      if (firstError is List && firstError.isNotEmpty) {
        throw Exception(firstError.first.toString());
      }
    }

    throw Exception(data['message'] ?? 'Registrasi pasien gagal');
  }

  static Future<void> registerFamily({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
    required String confirmPassword,
    required String gender,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register/family'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'full_name': fullName,
        'email': email,
        'phone_number': phoneNumber,
        'password': password,
        'password_confirmation': confirmPassword,
        'gender': gender,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return;
    }

    if (response.statusCode == 422 && data['errors'] != null) {
      final errors = data['errors'] as Map<String, dynamic>;
      final firstError = errors.values.first;

      if (firstError is List && firstError.isNotEmpty) {
        throw Exception(firstError.first.toString());
      }
    }

    throw Exception(data['message'] ?? 'Registrasi keluarga gagal');
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<Map<String, String>> _authHeaders() async {
    final token = await getToken();

    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<void> saveFcmToken(String fcmToken) async {
    final response = await http.post(
      Uri.parse('$baseUrl/notifications/fcm-token'),
      headers: await _authHeaders(),
      body: jsonEncode({'fcm_token': fcmToken}),
    );

    final data = response.body.isNotEmpty ? jsonDecode(response.body) : {};

    print('SAVE FCM TOKEN STATUS: ${response.statusCode}');
    print('SAVE FCM TOKEN BODY: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Gagal menyimpan FCM token');
    }
  }

  static Future<List<Map<String, dynamic>>> getDoctorPatients(
    int doctorId,
  ) async {
    final url = Uri.parse('$baseUrl/doctor/patients/$doctorId');

    final token = await getToken();

    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(data['data']);
    } else {
      throw Exception(data['message'] ?? 'Gagal mengambil daftar pasien');
    }
  }

  static Future<Map<String, dynamic>> getPatientDashboard(int patientId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/doctor/patients/$patientId/dashboard'),
      headers: await _authHeaders(),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(body['data']);
    }

    throw Exception(body['message'] ?? 'Gagal mengambil dashboard pasien');
  }

  static Future<List<Map<String, dynamic>>> getPatientGlucoseRecords(
    int patientId,
  ) async {
    final url = Uri.parse('$baseUrl/doctor/patients/$patientId/glucose');

    final token = await getToken();

    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(data['data']);
    }

    throw Exception(data['message'] ?? 'Gagal mengambil data glukosa');
  }

  static Future<List<Map<String, dynamic>>> getPatientPhysiologicalRecords(
    int patientId,
  ) async {
    final url = Uri.parse('$baseUrl/doctor/patients/$patientId/physiological');

    final token = await getToken();

    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(data['data']);
    }

    throw Exception(data['message'] ?? 'Gagal mengambil data fisiologis');
  }

  static Future<Map<String, dynamic>> getPatientBehavioralRecords(
    int patientId,
  ) async {
    final url = Uri.parse('$baseUrl/doctor/patients/$patientId/behavioral');

    final token = await getToken();

    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(data['data']);
    }

    throw Exception(data['message'] ?? 'Gagal mengambil data perilaku');
  }

  static Future<List<Map<String, dynamic>>> getPatientMedicationRecords(
    int patientId,
  ) async {
    final url = Uri.parse('$baseUrl/doctor/patients/$patientId/medication');

    final token = await getToken();

    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(data['data']);
    }

    throw Exception(data['message'] ?? 'Gagal mengambil data obat');
  }

  static Future<List<Map<String, dynamic>>> getPatientThresholds(
    int patientId,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final doctorId = prefs.getInt('doctor_id');

    final url = Uri.parse(
      '$baseUrl/doctor/patients/$patientId/thresholds',
    ).replace(queryParameters: {'doctor_id': doctorId.toString()});

    final response = await http.get(url, headers: await _authHeaders());

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(data['data']);
    }

    throw Exception(data['message'] ?? 'Gagal mengambil batas normal pasien');
  }

  static Future<void> updatePatientThreshold({
    required int patientId,
    required int parameterId,
    required double minValue,
    required double maxValue,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final doctorId = prefs.getInt('doctor_id');

    if (doctorId == null) {
      throw Exception('Doctor ID tidak ditemukan');
    }

    final response = await http.put(
      Uri.parse('$baseUrl/doctor/patients/$patientId/thresholds/$parameterId'),
      headers: await _authHeaders(),
      body: jsonEncode({
        'doctor_id': doctorId,
        'custom_min': minValue,
        'custom_max': maxValue,
      }),
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Gagal memperbarui batas normal');
    }
  }

  static Future<void> resetPatientThreshold({
    required int patientId,
    required int parameterId,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final doctorId = prefs.getInt('doctor_id');

    if (doctorId == null) {
      throw Exception('Doctor ID tidak ditemukan');
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/doctor/patients/$patientId/thresholds/$parameterId'),
      headers: await _authHeaders(),
      body: jsonEncode({'doctor_id': doctorId}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Gagal reset batas normal');
    }
  }

  static Future<void> disconnectDoctorPatient(int patientId) async {
    final prefs = await SharedPreferences.getInstance();
    final doctorId = prefs.getInt('doctor_id') ?? 1;

    final response = await http.delete(
      Uri.parse('$baseUrl/doctor/patients/$patientId'),
      headers: await _authHeaders(),
      body: jsonEncode({'doctor_id': doctorId}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Gagal memutus relasi pasien');
    }
  }

  static Future<int> storeClinicalNote({
    required int patientId,
    required int doctorId,
    required String patientCondition,
    required String doctorNote,
    required String treatmentPlan,
    DateTime? followUpDate,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/doctor/patients/$patientId/clinical-notes'),
      headers: await _authHeaders(),
      body: jsonEncode({
        'doctor_id': doctorId,
        'patient_condition': patientCondition,
        'doctor_note': doctorNote,
        'treatment_plan': treatmentPlan,
        'follow_up_date': followUpDate == null
            ? null
            : followUpDate.toIso8601String().split('T').first,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201 || response.statusCode == 200) {
      final clinicalNoteId = data['data']?['clinical_note_id'];

      if (clinicalNoteId == null) {
        throw Exception('clinical_note_id tidak ditemukan dari server');
      }

      return int.parse(clinicalNoteId.toString());
    }

    throw Exception(data['message'] ?? 'Gagal menyimpan catatan klinis');
  }

  static Future<List<Map<String, dynamic>>> getPatientFamilies(
    int patientId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/doctor/patients/$patientId/families'),
      headers: await _authHeaders(),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(data['data']);
    }

    throw Exception(data['message'] ?? 'Gagal mengambil data keluarga pasien');
  }

  static Future<List<Map<String, dynamic>>> getDoctorConnectionRequests(
    int doctorId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/doctor/connection-requests/$doctorId'),
      headers: await _authHeaders(),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(data['data']);
    }

    throw Exception(data['message'] ?? 'Gagal mengambil permintaan koneksi');
  }

  static Future<void> acceptConnectionRequest({
    required int doctorId,
    required int patientId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/doctor/connection-requests/$patientId/accept'),
      headers: await _authHeaders(),
      body: jsonEncode({'doctor_id': doctorId}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Gagal menerima permintaan koneksi');
    }
  }

  static Future<void> rejectConnectionRequest({
    required int doctorId,
    required int patientId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/doctor/connection-requests/$patientId/reject'),
      headers: await _authHeaders(),
      body: jsonEncode({'doctor_id': doctorId}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Gagal menolak permintaan koneksi');
    }
  }

  static Future<List<Map<String, dynamic>>> getRejectedConnectionRequests(
    int doctorId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/doctor/connection-requests/$doctorId/rejected'),
      headers: await _authHeaders(),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(data['data']);
    }

    throw Exception(data['message'] ?? 'Gagal mengambil koneksi ditolak');
  }

  static Future<List<Map<String, dynamic>>> getNotifications(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/notifications/user/$userId'),
      headers: await _authHeaders(),
    );

    final body = response.body.isNotEmpty ? jsonDecode(response.body) : {};

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(body['data'] ?? []);
    }

    throw Exception(body['message'] ?? 'Gagal mengambil notifikasi');
  }

  static Future<void> markNotificationAsRead(int notificationId) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/notifications/$notificationId/read'),
      headers: await _authHeaders(),
    );

    final body = response.body.isNotEmpty ? jsonDecode(response.body) : {};

    if (response.statusCode == 200) {
      return;
    }

    throw Exception(
      body['message'] ?? 'Gagal menandai notifikasi sebagai dibaca',
    );
  }

  static Future<void> markAllNotificationsAsRead(int userId) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/notifications/user/$userId/read-all'),
      headers: await _authHeaders(),
    );

    final body = response.body.isNotEmpty ? jsonDecode(response.body) : {};

    if (response.statusCode == 200) {
      return;
    }

    throw Exception(
      body['message'] ?? 'Gagal menandai semua notifikasi sebagai dibaca',
    );
  }

  static Future<Map<String, dynamic>> getNotificationDetail(
    int notificationId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/notifications/$notificationId'),
      headers: await _authHeaders(),
    );

    final body = response.body.isNotEmpty ? jsonDecode(response.body) : {};

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(body['data'] ?? {});
    }

    throw Exception(body['message'] ?? 'Gagal mengambil detail notifikasi');
  }

  static Future<Map<String, dynamic>> getDoctorPatientConnectionStatus({
    required int patientId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final doctorId = prefs.getInt('doctor_id') ?? 1;

    final response = await http.get(
      Uri.parse(
        '$baseUrl/doctor/connections/status/$patientId?doctor_id=$doctorId',
      ),
      headers: await _authHeaders(),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(data['data']);
    }

    throw Exception(data['message'] ?? 'Gagal mengambil status koneksi pasien');
  }

  static Future<void> storeRecommendations({
    required int clinicalNoteId,
    required List<Map<String, String>> recommendations,
    required List<int> recipientUserIds,
  }) async {
    final response = await http.post(
      Uri.parse(
        '$baseUrl/doctor/clinical-notes/$clinicalNoteId/recommendation',
      ),
      headers: await _authHeaders(),
      body: jsonEncode({
        'recommendations': recommendations.map((item) {
          return {
            'category': item['category'],
            'recommendation_text': item['text'],
          };
        }).toList(),
        'recipient_user_ids': recipientUserIds,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Gagal mengirim rekomendasi');
    }
  }

  static Future<Map<String, dynamic>> getRecommendationDetail(
    int clinicalNoteId,
  ) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/doctor/clinical-notes/$clinicalNoteId/recommendation',
      ),
      headers: await _authHeaders(),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(data['data']);
    }

    throw Exception(data['message'] ?? 'Gagal mengambil detail rekomendasi');
  }

  static Future<List<Map<String, dynamic>>> getDoctorHistory(
    int doctorId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/doctor/history/$doctorId'),
      headers: await _authHeaders(),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(data['data']);
    }

    throw Exception(data['message'] ?? 'Gagal mengambil riwayat dokter');
  }

  static Future<Map<String, dynamic>> getDoctorProfile(int doctorId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/doctor/profile/$doctorId'),
      headers: await _authHeaders(),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(data['data']);
    }

    throw Exception(data['message'] ?? 'Gagal mengambil profil dokter');
  }

  static Future<void> updateDoctorProfile({
    required int doctorId,
    required String fullName,
    required String phoneNumber,
    required String gender,
    required int specializationId,
    required String institution,
    String? dateOfBirth,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/doctor/profile/$doctorId'),
      headers: await _authHeaders(),
      body: jsonEncode({
        'full_name': fullName,
        'phone_number': phoneNumber,
        'date_of_birth': dateOfBirth,
        'gender': gender,
        'specialization_id': specializationId,
        'institution': institution,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Gagal memperbarui profil dokter');
    }
  }

  static Future<List<Map<String, dynamic>>> getSpecializations() async {
    final response = await http.get(
      Uri.parse('$baseUrl/master/specializations'),
      headers: await _authHeaders(),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(data['data']);
    }

    throw Exception(data['message'] ?? 'Gagal mengambil data spesialisasi');
  }

  static Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/auth/change-password'),
      headers: await _authHeaders(),
      body: jsonEncode({
        'current_password': currentPassword,
        'new_password': newPassword,
        'new_password_confirmation': confirmPassword,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Gagal mengubah kata sandi');
    }
  }

  static Future<void> resendVerificationEmail(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/email/resend'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'email': email}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(
        data['message'] ?? 'Gagal mengirim ulang email verifikasi',
      );
    }
  }

  static Future<bool> checkEmailVerification(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/email/check'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'email': email}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data['status'] == 'verified';
    }

    throw Exception(data['message'] ?? 'Gagal mengecek verifikasi email');
  }

  static Future<void> forgotPassword({required String email}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/forgot-password'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'email': email}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Gagal mengirim email reset password');
    }
  }

  static Future<void> resetPassword({
    required String token,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/reset-password'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'token': token,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Gagal mengubah kata sandi');
    }
  }

  static Future<Map<String, dynamic>> getPatientProfile(int patientId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/patient/profile/$patientId'),
      headers: await _authHeaders(),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(data['data']);
    }
    throw Exception(data['message'] ?? 'Gagal mengambil profil pasien');
  }

  static Future<Map<String, dynamic>?> getPatientLatestRecommendation(
    int patientId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/patient/latest-recommendation/$patientId'),
      headers: await _authHeaders(),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data['data'] == null
          ? null
          : Map<String, dynamic>.from(data['data']);
    }

    throw Exception(data['message'] ?? 'Gagal mengambil rekomendasi terbaru');
  }

  static Future<void> updatePatientProfile({
    required int patientId,
    required String fullName,
    required String phoneNumber,
    required String gender,
    required String diabetesType,
    required String diagnosisDate,
    required double heightCm,
    required int bloodTypeId,
    required int rhesusTypeId,
    String? dateOfBirth,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/patient/profile/$patientId'),
      headers: await _authHeaders(),
      body: jsonEncode({
        'full_name': fullName,
        'phone_number': phoneNumber,
        'date_of_birth': dateOfBirth,
        'gender': gender,
        'diabetes_type': diabetesType,
        'diagnosis_date': diagnosisDate,
        'height_cm': heightCm,
        'blood_type_id': bloodTypeId,
        'rhesus_type_id': rhesusTypeId,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Gagal memperbarui profil pasien');
    }
  }

  static Future<int> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');

    if (userId == null) {
      throw Exception('User ID tidak ditemukan. Coba login ulang.');
    }

    return userId;
  }

  static Future<void> storeGlucose({
    required int patientId,
    required String measurementType,
    required double glucoseValue,
    required DateTime measuredAt,
  }) async {
    final userId = await _getUserId();

    final response = await http.post(
      Uri.parse('$baseUrl/patient/health/glucose'),
      headers: await _authHeaders(),
      body: jsonEncode({
        'patient_id': patientId,
        'input_by_user_id': userId,
        'measurement_type': measurementType,
        'glucose_value': glucoseValue,
        'measured_at': measuredAt.toIso8601String(),
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Gagal menyimpan data glukosa');
    }
  }

  static Future<void> storePhysiological({
    required int patientId,
    int? systolic,
    int? diastolic,
    double? weightKg,
    double? bmi,
    required DateTime measuredAt,
  }) async {
    final userId = await _getUserId();

    final response = await http.post(
      Uri.parse('$baseUrl/patient/health/physiological'),
      headers: await _authHeaders(),
      body: jsonEncode({
        'patient_id': patientId,
        'input_by_user_id': userId,
        'systolic': systolic,
        'diastolic': diastolic,
        'weight_kg': weightKg,
        'bmi': bmi,
        'measured_at': measuredAt.toIso8601String(),
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Gagal menyimpan data fisiologis');
    }
  }

  static int _mealTypeIdFromName(String mealType) {
    switch (mealType) {
      case 'Sarapan':
        return 1;
      case 'Makan siang':
        return 2;
      case 'Makan malam':
        return 3;
      case 'Camilan':
        return 4;
      default:
        return 1;
    }
  }

  static Future<void> storeMeal({
    required int patientId,
    required String mealType,
    double? carbohydrateGram,
    double? calories,
    String? description,
    required DateTime mealDate,
  }) async {
    final userId = await _getUserId();

    final response = await http.post(
      Uri.parse('$baseUrl/patient/health/meal'),
      headers: await _authHeaders(),
      body: jsonEncode({
        'patient_id': patientId,
        'input_by_user_id': userId,
        'meal_type_id': _mealTypeIdFromName(mealType),
        'food_description': description,
        'carbohydrate_estimate': carbohydrateGram,
        'calories': calories,
        'meal_date':
            '${mealDate.year}-${mealDate.month.toString().padLeft(2, '0')}-${mealDate.day.toString().padLeft(2, '0')}',
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Gagal menyimpan data pola makan');
    }
  }

  static Future<void> storeActivity({
    required int patientId,
    required int activityTypeId,
    required int durationMinutes,
    required String intensity,
    required DateTime activityDate,
  }) async {
    final userId = await _getUserId();

    final response = await http.post(
      Uri.parse('$baseUrl/patient/health/activity'),
      headers: await _authHeaders(),
      body: jsonEncode({
        'patient_id': patientId,
        'input_by_user_id': userId,
        'activity_type_id': activityTypeId,
        'duration_minutes': durationMinutes,
        'intensity': intensity,
        'activity_date': activityDate.toIso8601String().split('T').first,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Gagal menyimpan data aktivitas');
    }
  }

  static Future<void> storeMedication({
    required int patientId,
    required int prescriptionId,
    required int scheduleId,
    required String status,
    String? note,
    required DateTime consumedAt,
  }) async {
    final userId = await _getUserId();

    final response = await http.post(
      Uri.parse('$baseUrl/patient/health/medication'),
      headers: await _authHeaders(),
      body: jsonEncode({
        'prescription_id': prescriptionId,
        'patient_id': patientId,
        'input_by_user_id': userId,
        'schedule_id': scheduleId,
        'log_date': consumedAt.toIso8601String().split('T').first,
        'status': status,
        'note': note,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Gagal menyimpan kepatuhan obat');
    }
  }

  static Future<List<Map<String, dynamic>>> getActivePrescriptions(
    int patientId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/patient/prescriptions/$patientId/active'),
      headers: await _authHeaders(),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(data['data']);
    }

    throw Exception(data['message'] ?? 'Gagal mengambil resep aktif');
  }

  static Future<List<Map<String, dynamic>>> getConnectedDoctors(
    int patientId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/patient/connections/doctors/$patientId'),
      headers: await _authHeaders(),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(data['data']);
    }

    throw Exception(data['message'] ?? 'Gagal mengambil dokter terhubung');
  }

  static Future<List<Map<String, dynamic>>> getConnectedFamilies(
    int patientId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/patient/connections/families/$patientId'),
      headers: await _authHeaders(),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(data['data']);
    }

    throw Exception(data['message'] ?? 'Gagal mengambil keluarga terhubung');
  }

  static Future<List<Map<String, dynamic>>> getIncomingFamilyRequests(
    int patientId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/patient/connections/requests/$patientId'),
      headers: await _authHeaders(),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(data['data']);
    }

    throw Exception(data['message'] ?? 'Gagal mengambil permintaan koneksi');
  }

  static Future<List<Map<String, dynamic>>> searchDoctors({
    required int patientId,
    required String keyword,
  }) async {
    final uri = Uri.parse('$baseUrl/patient/doctors/search').replace(
      queryParameters: {'patient_id': patientId.toString(), 'keyword': keyword},
    );

    final response = await http.get(uri, headers: await _authHeaders());

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(data['data']);
    }

    throw Exception(data['message'] ?? 'Gagal mencari dokter');
  }

  static Future<void> requestDoctorConnection({
    required int patientId,
    required int doctorId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/patient/doctors/$doctorId/request'),
      headers: await _authHeaders(),
      body: jsonEncode({'patient_id': patientId}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(data['message'] ?? 'Gagal mengajukan koneksi dokter');
    }
  }

  static Future<void> acceptFamilyRequest({
    required int patientId,
    required int familyId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/patient/family-requests/accept'),
      headers: await _authHeaders(),
      body: jsonEncode({'patient_id': patientId, 'family_id': familyId}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Gagal menerima permintaan');
    }
  }

  static Future<void> rejectFamilyRequest({
    required int patientId,
    required int familyId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/patient/family-requests/reject'),
      headers: await _authHeaders(),
      body: jsonEncode({'patient_id': patientId, 'family_id': familyId}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Gagal menolak permintaan');
    }
  }

  static Future<void> disconnectDoctorConnection({
    required int patientId,
    required int doctorId,
  }) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/patient/connections/doctors/$doctorId'),
      headers: await _authHeaders(),
      body: jsonEncode({'patient_id': patientId}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Gagal memutus relasi dokter');
    }
  }

  static Future<void> disconnectFamilyConnection({
    required int patientId,
    required int familyId,
  }) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/patient/connections/families/$familyId'),
      headers: await _authHeaders(),
      body: jsonEncode({'patient_id': patientId}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Gagal memutus relasi keluarga');
    }
  }

  static Future<Map<String, dynamic>> getPatientHealthHistory(
    int patientId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/patient/health-history/$patientId'),
      headers: await _authHeaders(),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(data['data']);
    }

    throw Exception(data['message'] ?? 'Gagal mengambil riwayat kesehatan');
  }

  static Future<List<Map<String, dynamic>>> getPatientRecommendations(
    int patientId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/patient/recommendations/$patientId'),
      headers: await _authHeaders(),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(data['data'] ?? []);
    }

    throw Exception(data['message'] ?? 'Gagal mengambil rekomendasi');
  }

  static Future<Map<String, dynamic>> getPatientHomeSummary(
    int patientId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/patient/home-summary/$patientId'),
      headers: await _authHeaders(),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(data['data']);
    }

    throw Exception(data['message'] ?? 'Gagal mengambil ringkasan home pasien');
  }

  static Future<List<Map<String, dynamic>>> getPatientPendingValidations(
    int patientId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/patient/pending-validations/$patientId'),
      headers: await _authHeaders(),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(data['data'] ?? []);
    }

    throw Exception(data['message'] ?? 'Gagal mengambil data validasi');
  }

  static Future<void> respondPatientValidation({
    required String recordType,
    required int recordId,
    required String status,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/patient/respond-validation'),
      headers: await _authHeaders(),
      body: jsonEncode({
        'record_type': recordType,
        'record_id': recordId,
        'status': status,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Gagal memproses validasi');
    }
  }

  static Future<Map<String, dynamic>> getFamilyProfile(int familyId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/family/profile/$familyId'),
      headers: await _authHeaders(),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(data['data'] ?? {});
    }

    throw Exception(data['message'] ?? 'Gagal mengambil profil keluarga');
  }

  static Future<List<Map<String, dynamic>>> getFamilyPatients(
    int familyId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/family/patients/$familyId'),
      headers: await _authHeaders(),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(data['data']);
    }

    throw Exception(data['message'] ?? 'Gagal mengambil pasien keluarga');
  }

  static Future<Map<String, dynamic>> getFamilyPatientDashboard(
    int patientId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/family/patients/$patientId/dashboard'),
      headers: await _authHeaders(),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(data['data']);
    }

    throw Exception(data['message'] ?? 'Gagal mengambil dashboard pasien');
  }

  static Future<Map<String, dynamic>> getFamilyPatientHealthData(
    int patientId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/family/patients/$patientId/health-data'),
      headers: await _authHeaders(),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(data['data']);
    }

    throw Exception(data['message'] ?? 'Gagal mengambil data kesehatan pasien');
  }

  static Future<List<Map<String, dynamic>>> getFamilyPatientRecommendations(
    int patientId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/family/patients/$patientId/recommendations'),
      headers: await _authHeaders(),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(data['data']);
    }

    throw Exception(data['message'] ?? 'Gagal mengambil rekomendasi pasien');
  }

  static Future<void> storeFamilyGlucose({
    required int patientId,
    required String measurementType,
    required double glucoseValue,
    required DateTime measuredAt,
  }) async {
    final userId = await _getUserId();

    final response = await http.post(
      Uri.parse('$baseUrl/family/patients/$patientId/glucose'),
      headers: await _authHeaders(),
      body: jsonEncode({
        'input_by_user_id': userId,
        'measurement_type': measurementType,
        'glucose_value': glucoseValue,
        'measured_at': measuredAt.toIso8601String(),
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Gagal menyimpan data glukosa');
    }
  }

  static Future<void> storeFamilyPhysiological({
    required int patientId,
    int? systolic,
    int? diastolic,
    double? weightKg,
    double? bmi,
    required DateTime measuredAt,
  }) async {
    final userId = await _getUserId();

    final response = await http.post(
      Uri.parse('$baseUrl/family/patients/$patientId/physiological'),
      headers: await _authHeaders(),
      body: jsonEncode({
        'input_by_user_id': userId,
        'systolic': systolic,
        'diastolic': diastolic,
        'weight_kg': weightKg,
        'bmi': bmi,
        'measured_at': measuredAt.toIso8601String(),
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Gagal menyimpan data fisiologis');
    }
  }

  static Future<void> storeFamilyActivity({
    required int patientId,
    required int activityTypeId,
    required int durationMinutes,
    required String intensity,
    required DateTime activityDate,
  }) async {
    final userId = await _getUserId();

    final response = await http.post(
      Uri.parse('$baseUrl/family/patients/$patientId/activity'),
      headers: await _authHeaders(),
      body: jsonEncode({
        'input_by_user_id': userId,
        'activity_type_id': activityTypeId,
        'duration_minutes': durationMinutes,
        'intensity': intensity,
        'activity_date': activityDate.toIso8601String().split('T').first,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Gagal menyimpan data aktivitas');
    }
  }

  static Future<void> storeFamilyMeal({
    required int patientId,
    required int mealTypeId,
    double? carbohydrateGram,
    double? calories,
    String? description,
    required DateTime mealDate,
  }) async {
    final userId = await _getUserId();

    final response = await http.post(
      Uri.parse('$baseUrl/family/patients/$patientId/meal'),
      headers: await _authHeaders(),
      body: jsonEncode({
        'input_by_user_id': userId,
        'meal_type_id': mealTypeId,
        'food_description': description,
        'carbohydrate_estimate': carbohydrateGram,
        'calories': calories,
        'meal_date': mealDate.toIso8601String().split('T').first,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Gagal menyimpan data makan');
    }
  }

  static Future<Map<String, dynamic>> getFamilyPatientHistories(
    int patientId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/family/patients/$patientId/histories'),
      headers: await _authHeaders(),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(data['data'] ?? {});
    }

    throw Exception(data['message'] ?? 'Gagal mengambil riwayat pasien');
  }

  static Future<List<Map<String, dynamic>>> getRelationTypes() async {
    final response = await http.get(
      Uri.parse('$baseUrl/master/relation-types'),
      headers: await _authHeaders(),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(data['data'] ?? []);
    }

    throw Exception(data['message'] ?? 'Gagal mengambil tipe relasi');
  }

  static Future<List<Map<String, dynamic>>> findFamilyPatient({
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final familyId = prefs.getInt('family_id');

    if (familyId == null) {
      throw Exception('Family ID tidak ditemukan. Coba login ulang.');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/family/find-patient'),
      headers: await _authHeaders(),
      body: jsonEncode({
        'email': email.trim().toLowerCase(),
        'family_id': familyId,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(data['data'] ?? []);
    }

    throw Exception(data['message'] ?? 'Gagal mencari pasien');
  }

  static Future<void> requestFamilyConnection({
    required int familyId,
    required int patientId,
    required int relationTypeId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/family/request-connection'),
      headers: await _authHeaders(),
      body: jsonEncode({
        'family_id': familyId,
        'patient_id': patientId,
        'relation_type_id': relationTypeId,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(data['message'] ?? 'Gagal mengajukan koneksi pasien');
    }
  }

  static Future<void> storeFamilyMedication({
    required int patientId,
    int? prescriptionId,
    int? scheduleId,
    required String status,
    String? note,
    required DateTime logDate,
  }) async {
    final userId = await _getUserId();

    final response = await http.post(
      Uri.parse('$baseUrl/family/patients/$patientId/medication'),
      headers: await _authHeaders(),
      body: jsonEncode({
        'input_by_user_id': userId,
        'prescription_id': prescriptionId,
        'schedule_id': scheduleId,
        'log_date': logDate.toIso8601String().split('T').first,
        'status': status,
        'note': note,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Gagal menyimpan kepatuhan obat');
    }
  }

  static Future<void> updateFamilyProfile({
    required int familyId,
    required String fullName,
    required String phoneNumber,
    required String gender,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/family/profile/$familyId'),
      headers: await _authHeaders(),
      body: jsonEncode({
        'full_name': fullName,
        'phone_number': phoneNumber,
        'gender': gender,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Gagal memperbarui profil keluarga');
    }
  }

  static Future<List<Map<String, dynamic>>> getDoctorPatientActivePrescriptions(
    int patientId,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final doctorId = prefs.getInt('doctor_id');

    if (doctorId == null) {
      throw Exception('Doctor ID tidak ditemukan. Coba login ulang.');
    }

    final uri = Uri.parse(
      '$baseUrl/doctor/patients/$patientId/prescriptions/active',
    ).replace(queryParameters: {'doctor_id': doctorId.toString()});

    final response = await http.get(uri, headers: await _authHeaders());

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(data['data'] ?? []);
    }

    throw Exception(data['message'] ?? 'Gagal mengambil resep aktif pasien');
  }

  static Future<List<Map<String, dynamic>>> getDoctorPatientPrescriptionHistory(
    int patientId,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final doctorId = prefs.getInt('doctor_id');

    if (doctorId == null) {
      throw Exception('Doctor ID tidak ditemukan. Coba login ulang.');
    }

    final uri = Uri.parse(
      '$baseUrl/doctor/patients/$patientId/prescriptions/history',
    ).replace(queryParameters: {'doctor_id': doctorId.toString()});

    final response = await http.get(uri, headers: await _authHeaders());

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(data['data'] ?? []);
    }

    throw Exception(data['message'] ?? 'Gagal mengambil riwayat resep pasien');
  }

  static Future<List<Map<String, dynamic>>> searchMedications(
    String keyword,
  ) async {
    final uri = Uri.parse(
      '$baseUrl/doctor/medications/search',
    ).replace(queryParameters: {'keyword': keyword});

    final response = await http.get(uri, headers: await _authHeaders());

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(data['data'] ?? []);
    }

    throw Exception(data['message'] ?? 'Gagal mencari obat');
  }

  static Future<List<Map<String, dynamic>>> getMedicationSessions() async {
    final response = await http.get(
      Uri.parse('$baseUrl/doctor/medication-sessions'),
      headers: await _authHeaders(),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(data['data'] ?? []);
    }

    throw Exception(data['message'] ?? 'Gagal mengambil sesi minum obat');
  }

  static Future<int> storeDoctorPrescription({
    required int patientId,
    required int medicationId,
    required String dosage,
    required String form,
    String? indication,
    String? mealRule,
    String? notes,
    required String validFrom,
    required String validUntil,
    required List<Map<String, dynamic>> schedules,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final doctorId = prefs.getInt('doctor_id');

    if (doctorId == null) {
      throw Exception('Doctor ID tidak ditemukan. Coba login ulang.');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/doctor/patients/$patientId/prescriptions'),
      headers: await _authHeaders(),
      body: jsonEncode({
        'doctor_id': doctorId,
        'medication_id': medicationId,
        'dosage': dosage,
        'form': form,
        'indication': indication,
        'meal_rule': mealRule,
        'notes': notes,
        'valid_from': validFrom,
        'valid_until': validUntil,
        'schedules': schedules,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201 || response.statusCode == 200) {
      return int.parse(data['data']['prescription_id'].toString());
    }

    throw Exception(data['message'] ?? 'Gagal menyimpan resep');
  }

  static Future<void> updatePrescription({
    required int prescriptionId,
    required int doctorId,
    required int patientId,
    required int medicationId,
    required String dosage,
    required String form,
    String? indication,
    String? mealRule,
    String? notes,
    required String validFrom,
    required String validUntil,
    required List<Map<String, dynamic>> schedules,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/doctor/prescriptions/$prescriptionId'),
      headers: await _authHeaders(),
      body: jsonEncode({
        'doctor_id': doctorId,
        'patient_id': patientId,
        'medication_id': medicationId,
        'dosage': dosage,
        'form': form,
        'indication': indication,
        'meal_rule': mealRule,
        'notes': notes,
        'valid_from': validFrom,
        'valid_until': validUntil,
        'schedules': schedules,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode >= 400) {
      throw Exception(data['message'] ?? 'Gagal memperbarui resep');
    }
  }

  static Future<void> stopPrescription({
    required int prescriptionId,
    required int doctorId,
    String? reason,
  }) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/doctor/prescriptions/$prescriptionId/stop'),
      headers: await _authHeaders(),
      body: jsonEncode({'doctor_id': doctorId, 'reason': reason}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode >= 400) {
      throw Exception(data['message'] ?? 'Gagal menghentikan resep');
    }
  }

  static Future<List<String>> getPrescriptionMealRules() async {
    final response = await http.get(
      Uri.parse('$baseUrl/master/prescription-meal-rules'),
      headers: await _authHeaders(),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return List<String>.from(data['data'] ?? []);
    }

    throw Exception(data['message'] ?? 'Gagal mengambil aturan minum');
  }

  static Future<Map<String, dynamic>> getFamilyPatientDetail(
    int patientId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/family/patient-detail/$patientId'),
      headers: await _authHeaders(),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(data['data'] ?? {});
    }

    throw Exception(data['message'] ?? 'Gagal mengambil detail pasien');
  }

  static Future<void> disconnectFamilyPatient({required int patientId}) async {
    final prefs = await SharedPreferences.getInstance();
    final familyId = prefs.getInt('family_id');

    if (familyId == null) {
      throw Exception('Family ID tidak ditemukan. Coba login ulang.');
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/family/patients/$patientId/disconnect'),
      headers: await _authHeaders(),
      body: jsonEncode({'family_id': familyId}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Gagal memutus relasi pasien');
    }
  }
}
