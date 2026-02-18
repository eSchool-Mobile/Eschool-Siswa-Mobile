# 🎓 E-School Management System (SIAKAD)

## 📱 Sistem Informasi Akademik Digital untuk Siswa & Orang Tua

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)

![E-School Banner](assets/images/splashScreen.png)

## 🌟 Tentang Aplikasi

E-School Management System adalah aplikasi mobile yang dikembangkan dengan Flutter untuk mempermudah `pengelolaan aktivitas akademik di sekolah. Aplikasi ini menyediakan platform terintegrasi untuk **siswa**, **orang tua**, dan **guru** dalam mengelola berbagai aspek pendidikan.

### 📊 Versi Aplikasi
- **Versi:** 1.0.7+7
- **Target Platform:** Android & iOS
- **Framework:** Flutter 3.0.2+
- **Bahasa:** Dart

---

## ✨ Fitur Utama

### 👨‍🎓 **Portal Siswa**
- 📚 **Manajemen Mata Pelajaran**
  - Melihat daftar mata pelajaran
  - Akses materi pembelajaran digital
  - Download file dan video pembelajaran
  
- 📝 **Sistem Tugas (Assignment)**
  - Upload dan submit tugas
  - Tracking status pengumpulan tugas
  - Filter tugas berdasarkan tanggal dan status
  - Notifikasi deadline tugas
  
- 📊 **Kehadiran & Jadwal**
  - Absensi harian dan per mata pelajaran
  - Jadwal pelajaran interaktif
  - Laporan kehadiran bulanan
  
- 🏆 **Ujian & Nilai**
  - Ujian online terintegrasi
  - Riwayat nilai dan ranking
  - Laporan perkembangan akademik
  
- 💬 **Komunikasi**
  - Chat real-time dengan guru
  - Pengumuman sekolah
  - Notifikasi push

### 👨‍👩‍👧‍👦 **Portal Orang Tua**
- 👶 **Monitoring Anak**
  - Dashboard akademik anak
  - Laporan kehadiran real-time
  - Progress pembelajaran
  
- 💰 **Pembayaran Sekolah**
  - Tagihan SPP dan biaya sekolah
  - Pembayaran online (Stripe, Razorpay)
  - Riwayat transaksi dan receipt
  - Sistem cicilan pembayaran
  
- 📋 **Laporan Komprehensif**
  - Laporan nilai per mata pelajaran
  - Analisis performa akademik
  - Export laporan PDF
  
- 📞 **Komunikasi dengan Sekolah**
  - Chat langsung dengan guru
  - Konsultasi akademik
  - Notifikasi kegiatan sekolah

### 🏫 **Fitur Sekolah**
- 📸 **Galeri Sekolah**
  - Album foto kegiatan
  - Filter berdasarkan tahun ajaran
  - Dokumentasi event sekolah
  
- 📅 **Kalender Akademik**
  - Jadwal libur nasional
  - Event dan kegiatan sekolah
  - Reminder penting
  
- 🔔 **Sistem Notifikasi**
  - Push notification real-time
  - Email notification
  - Pengumuman darurat

---

## 🛠️ Teknologi yang Digunakan

### 📱 **Frontend (Mobile)**
```yaml
dependencies:
  flutter: SDK Flutter
  flutter_bloc: ^8.1.3          # State Management
  dio: ^5.3.1                   # HTTP Client
  cached_network_image: ^3.2.3  # Image Caching
  lottie: ^3.1.2               # Animations
  google_fonts: ^6.1.0         # Typography
  hive: ^2.2.3                 # Local Storage
  intl: ^4.0.0                 # Internationalization
```

### 🎨 **UI/UX Components**
- **Material Design 3**
- **Custom Animations** dengan Flutter Animate
- **Responsive Design** untuk berbagai ukuran layar
- **Dark/Light Theme** support
- **Multi-language** support (Indonesia/English)

### 🔧 **Fitur Teknis**
- **State Management:** BLoC Pattern
- **Local Storage:** Hive Database
- **Image Handling:** Cached Network Images
- **File Upload:** MultiPart Upload
- **Real-time:** WebSocket & Socket.IO
- **Security:** JWT Authentication
- **Payment:** Stripe & Razorpay Integration

---

## 🚀 Instalasi & Setup

### 📋 **Prasyarat**
- Flutter SDK 3.0.2 atau lebih baru
- Dart SDK 2.17.0 atau lebih baru
- Android Studio / VS Code
- Git

### 🔧 **Langkah Instalasi**

1. **Clone Repository**
```bash
git clone https://github.com/username/siakad-eschool.git
cd siakad-eschool
```

2. **Install Dependencies**
```bash
flutter pub get
```

3. **Konfigurasi Firebase**
```bash
# Download google-services.json dari Firebase Console
# Letakkan di android/app/
```

4. **Setup Environment**
```bash
# Buat file .env di root directory
echo "API_BASE_URL=https://your-api-url.com" > .env
echo "STRIPE_PUBLISHABLE_KEY=pk_test_xxx" >> .env
```

5. **Run Application**
```bash
flutter run
```

### 🔐 **Konfigurasi Credentials Default**

Untuk development, ubah di `lib/utils/constants.dart`:

```dart
// Student Login
const String defaultStudentGRNumber = "2024/12345";
const String defaultStudentPassword = "password123";

// Parent Login  
const String defaultParentEmail = "parent@email.com";
const String defaultParentPassword = "password123";

// School Code
const String defaultSchoolCode = "SCH2024";
```

---

## 📱 Screenshots & Demo

### 🏠 **Dashboard Utama**
| Siswa | Orang Tua |
|-------|-----------|
| ![Student Dashboard](assets/images/student_dashboard.png) | ![Parent Dashboard](assets/images/parent_dashboard.png) |

### 📚 **Fitur Pembelajaran**
| Tugas | Ujian Online | Chat |
|-------|-------------|------|
| ![Assignments](assets/images/assignments.png) | ![Online Exam](assets/images/online_exam.png) | ![Chat](assets/images/chat.png) |

---

## 🏗️ Arsitektur Aplikasi

```
lib/
├── 📂 app/              # App configuration & routing
├── 📂 cubits/           # BLoC state management
├── 📂 data/             # Data layer (models, repositories)
│   ├── 📂 models/       # Data models
│   └── 📂 repositories/ # API repositories
├── 📂 ui/               # User Interface
│   ├── 📂 screens/      # App screens
│   └── 📂 widgets/      # Reusable widgets
└── 📂 utils/            # Utilities & constants
```

### 🔄 **State Management Pattern**
```dart
// Example BLoC implementation
class AssignmentsCubit extends Cubit<AssignmentsState> {
  final AssignmentRepository repository;
  
  AssignmentsCubit(this.repository) : super(AssignmentsInitial());
  
  Future<void> fetchAssignments() async {
    emit(AssignmentsFetchInProgress());
    try {
      final assignments = await repository.fetchAssignments();
      emit(AssignmentsFetchSuccess(assignments));
    } catch (e) {
      emit(AssignmentsFetchFailure(e.toString()));
    }
  }
}
```

---

## 🎯 Fitur Unggulan

### 📊 **Real-time Analytics**
- Dashboard dengan grafik interaktif
- Tracking performa akademik real-time
- Analisis kehadiran dan nilai
- Progress indicator untuk tugas

### 💳 **Payment Gateway**
```dart
// Stripe Integration
await Stripe.instance.initPaymentSheet(
  paymentSheetParameters: SetupPaymentSheetParameters(
    paymentIntentClientSecret: clientSecret,
    merchantDisplayName: 'School Name',
  ),
);
```

### 🔔 **Smart Notifications**
- Push notifications berbasis role
- Notifikasi deadline tugas
- Reminder pembayaran
- Update nilai real-time

### 📱 **Offline Support**
```dart
// Hive local storage
final box = await Hive.openBox('assignments');
box.put('assignments_cache', assignmentsList);
```

---

## 🌐 API Integration

### 🔗 **Backend Endpoints**
```dart
class ApiEndpoints {
  static String studentLogin = "${baseUrl}student/login";
  static String getAssignments = "${baseUrl}student/assignments";
  static String submitAssignment = "${baseUrl}student/submit-assignment";
  static String parentLogin = "${baseUrl}parent/login";
  static String paymentSubmit = "${baseUrl}parent/fees/pay";
}
```

### 📡 **HTTP Client Setup**
```dart
final dio = Dio();
dio.interceptors.add(AuthInterceptor());
dio.interceptors.add(LoggingInterceptor());
```

---

## 🚀 Deployment

### 📦 **Build Release APK**
```bash
flutter build apk --release --split-per-abi
```

### 🏪 **Build App Bundle**
```bash
flutter build appbundle --release
```

### 📱 **iOS Build**
```bash
flutter build ios --release
```

---

## 🧪 Testing

### 🔍 **Unit Tests**
```bash
flutter test
```

### 🏃‍♂️ **Integration Tests**
```bash
flutter test integration_test/
```

### 📊 **Code Coverage**
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

---

## 📋 To-Do List

- [ ] 🌙 Dark mode enhancement
- [ ] 🌍 Multi-language expansion
- [ ] 📱 Tablet UI optimization
- [ ] 🔊 Voice messages in chat
- [ ] 📊 Advanced analytics dashboard
- [ ] 🎥 Video call integration
- [ ] 🤖 AI-powered study recommendations
- [ ] 📱 Progressive Web App (PWA)

---

## 🤝 Contributing

Kami sangat terbuka untuk kontribusi! Silakan ikuti langkah berikut:

1. Fork repository ini
2. Buat branch fitur (`git checkout -b feature/amazing-feature`)
3. Commit perubahan (`git commit -m 'Add amazing feature'`)
4. Push ke branch (`git push origin feature/amazing-feature`)
5. Buat Pull Request

### 📝 **Contribution Guidelines**
- Ikuti coding style yang konsisten
- Tambahkan unit tests untuk fitur baru
- Update dokumentasi jika diperlukan
- Gunakan commit message yang deskriptif

---

## 📞 Support & Contact

### 🆘 **Bantuan Teknis**
- 📧 Email: support@eschool.com
- 💬 Discord: [E-School Community](https://discord.gg/eschool)
- 📱 WhatsApp: +62 xxx-xxxx-xxxx

### 🐛 **Bug Reports**
Laporkan bug melalui [GitHub Issues](https://github.com/username/siakad-eschool/issues)

### 💡 **Feature Requests**
Request fitur baru melalui [GitHub Discussions](https://github.com/username/siakad-eschool/discussions)

---

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.

---

## 👏 Acknowledgments

- Flutter Team untuk framework yang luar biasa
- Material Design untuk panduan UI/UX
- Community Flutter Indonesia
- Semua kontributor open source

---

## 📈 Stats

![GitHub stars](https://img.shields.io/github/stars/username/siakad-eschool?style=social)
![GitHub forks](https://img.shields.io/github/forks/username/siakad-eschool?style=social)
![GitHub issues](https://img.shields.io/github/issues/username/siakad-eschool)
![GitHub last commit](https://img.shields.io/github/last-commit/username/siakad-eschool)

---

<div align="center">

**Made with ❤️ for Education**

[⬆ Back to Top](#-e-school-management-system-siakad)

</div>