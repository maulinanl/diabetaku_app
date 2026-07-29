# Diabetaku Mobile App

A Flutter-based mobile application for diabetes health monitoring that supports collaboration between patients, caregivers, and doctors.

Diabetaku is designed to help users manage diabetes-related health information through digital health monitoring, medication tracking, health activity recording, and healthcare support.

This repository contains the **frontend/mobile application** of the Diabetaku Health Monitoring System developed using Flutter.

---

# 📌 About Diabetaku

Diabetaku is a digital health application developed to support diabetes management through technology-based health monitoring.

The application provides a platform that connects:

- **Patients** to manage their personal health conditions.
- **Caregivers** to assist and support patient health monitoring.
- **Doctors** to review patient health information and provide healthcare management support.

The mobile application communicates with the backend system through REST API for data processing, information management, and system interaction.

---

# 🔗 Related Repository

This repository is part of the **Diabetaku Health Monitoring System**.

The system consists of:

- **Frontend/Mobile Application** → Flutter-based mobile application
- **Backend API** → Laravel-based REST API service

## Frontend Repository

[Diabetaku Mobile App](https://github.com/maulinanl/diabetaku_app)

## Backend Repository

The backend provides API services for:

- User authentication
- User management
- Health data management
- Patient-caregiver relationship
- Doctor monitoring
- Notification management

[Diabetaku Backend](https://github.com/maulinanl/diabetaku-backend)

---

# ✨ Application Features

## Authentication

The authentication system manages user access and role-based authorization.

Features:

- User registration
- User login
- Email verification
- Password management
- Role-based authentication
- Session management

Supported roles:

- Doctor
- Patient
- Caregiver
- Administrator

---

## Doctor Features

Doctors can:

- Register and login
- Manage doctor profile
- View connected patients
- Monitor patient health information
- View patient health history
- Create clinical notes
- Manage prescriptions
- Provide health recommendations
- Set patient monitoring parameters
- Receive notifications

---

## Patient Features

Patients can:

- Register and login
- Manage personal profile
- View personal health dashboard
- Record blood glucose information
- Record medication usage
- Record meal information
- Record physical activity
- Record physiological data
- View health monitoring history
- View health recommendations
- Receive notifications
- Connect with caregiver and doctor

---

## Caregiver Features

Caregivers can:

- Register and login
- Manage caregiver profile
- Connect with patient
- View connected patient information
- Monitor patient health data
- Record patient health information
- Record medication information
- Record meal information
- Record activity information
- View patient health history
- View patient recommendations
- Receive notifications

---

## Administrator Features

Administrators can:

- Login as administrator
- Access administrator services
- Support user management processes

---

# 🛠 Technology Stack

## Mobile Application

| Technology | Description |
|---|---|
| Flutter | Mobile application framework |
| Dart | Programming language |
| Riverpod | State management |
| Go Router | Navigation and routing |
| Dio | REST API communication |
| HTTP | HTTP request handling |
| Shared Preferences | Local storage |

---

## Supporting Services

| Technology | Description |
|---|---|
| Firebase Core | Firebase integration |
| Firebase Cloud Messaging | Push notification service |
| Flutter Local Notifications | Local notification service |
| Timezone | Notification scheduling |
| FL Chart | Health data visualization |
| Google Fonts | Application typography |

---

# 🏗 Project Architecture

The application uses a feature-based architecture to maintain scalability, readability, and code organization.

```
lib/
│
├── core/
│   ├── constants/
│   ├── navigation/
│   ├── routes/
│   ├── theme/
│   ├── utils/
│   └── widgets/
│
├── data/
│   └── services/
│       ├── api_service.dart
│       ├── push_notification_service.dart
│       └── medication_reminder_service.dart
│
└── features/
    │
    ├── auth/
    │
    ├── patient/
    │
    ├── caregiver/
    │
    └── doctor/
```

---

# 🔄 System Flow

```
                    User
                     |
              Authentication
                     |
    ------------------------------------
    |          |          |            |
 Patient  Caregiver   Doctor   Administrator
    |          |          |            |
    ------------------------------------
                     |
                 REST API
                     |
             Backend Server
                     |
                 Database
```

---

# 🔔 Notification System

Diabetaku provides notification services to support diabetes monitoring activities.

Notification features include:

- Medication reminders
- Health-related updates
- Application notifications

Technologies used:

- Firebase Cloud Messaging
- Flutter Local Notifications
- Timezone scheduling

Notification flow:

```
Backend Server
       |
       |
Firebase Cloud Messaging
       |
       |
Flutter Application
       |
       |
User Device
```

---

# 🚀 Getting Started

## Prerequisites

Before running this project, make sure you have installed:

- Flutter SDK
- Dart SDK
- Android Studio or Visual Studio Code
- Android Emulator or Android Device

Check Flutter installation:

```bash
flutter doctor
```

---

# 📥 Installation

Clone this repository:

```bash
git clone https://github.com/maulinanl/diabetaku_app.git
```

Navigate to project directory:

```bash
cd diabetaku_app
```

Install dependencies:

```bash
flutter pub get
```

---

# ⚙️ Configuration

The application communicates with the Diabetaku backend API.

API configuration is located at:

```
lib/data/services/api_service.dart
```

Configure the API base URL according to your backend environment.

Example:

```dart
baseUrl = "https://your-server-url/api";
```

Production backend server:

```
https://si.its.ac.id/labs/ikti/diabetaku/
```

Make sure the backend server is running before launching the application.

---

# 🔗 Backend Integration

The Flutter application communicates with the backend system using REST API.

Backend services include:

- Authentication
- User management
- Health data management
- Patient-caregiver relationship
- Doctor monitoring
- Notification management

Backend repository:

[Diabetaku Backend](https://github.com/maulinanl/diabetaku-backend)

---

# ▶️ Running Application

Run the application:

```bash
flutter run
```

Check available devices:

```bash
flutter devices
```

Run on specific device:

```bash
flutter run -d <device_id>
```

---

# 🔨 Build Application

Build Android APK:

```bash
flutter build apk
```

Build release APK:

```bash
flutter build apk --release
```

---

# 🧪 Testing

Run Flutter tests:

```bash
flutter test
```

---

# 📌 Development Commands

| Command | Description |
|---|---|
| `flutter pub get` | Install dependencies |
| `flutter run` | Run application |
| `flutter clean` | Clean project build |
| `flutter test` | Run tests |
| `flutter build apk` | Build Android APK |

---

# 👥 Contributors

## Developer

**Maulina Nur Laila**  

## Supervisor

**Prof. Dr. Eng. Febriliyan Samopa, S.Kom., M.Kom.**  

---

# 📄 License

This project is developed as part of the Final Project (Tugas Akhir) at Institut Teknologi Sepuluh Nopember (ITS).

Developed for academic and research purposes.
