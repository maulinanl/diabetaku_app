import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/auth/login');

    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'email': email, 'password': password}),
    );

    final data = jsonDecode(response.body);

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

    throw Exception(data['message'] ?? 'Email atau password salah');
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
    final url = Uri.parse('$baseUrl/doctor/patients/$patientId/dashboard');

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

    throw Exception(data['message'] ?? 'Gagal mengambil detail pasien');
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
    final url = Uri.parse('$baseUrl/doctor/patients/$patientId/thresholds');

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

    throw Exception(data['message'] ?? 'Gagal mengambil batas normal pasien');
  }

  static Future<void> updatePatientThreshold({
    required int patientId,
    required int parameterId,
    required double minValue,
    required double maxValue,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final doctorId = prefs.getInt('doctor_id') ?? 1;

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

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(data['data']);
    }

    throw Exception(data['message'] ?? 'Gagal mengambil notifikasi');
  }

  static Future<void> markNotificationAsRead(int notificationId) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/notifications/$notificationId/read'),
      headers: await _authHeaders(),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Gagal menandai notifikasi');
    }
  }

  static Future<void> markAllNotificationsAsRead(int userId) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/notifications/user/$userId/read-all'),
      headers: await _authHeaders(),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Gagal menandai semua notifikasi');
    }
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
}
