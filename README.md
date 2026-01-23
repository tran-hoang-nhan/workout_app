# Workout App

Ứng dụng tập luyện thể hình được xây dựng bằng Flutter với backend Supabase, giúp người dùng theo dõi và quản lý hành trình fitness của mình.

## Tính năng chính

- **Xác thực người dùng**: Đăng ký, đăng nhập với email
- **Quản lý bài tập**: Tạo và theo dõi các bài tập cá nhân
- **Theo dõi tiến độ**: Ghi lại và phân tích kết quả tập luyện
- **Chỉ số sức khỏe**: Theo dõi các thông số cơ thể
- **Hồ sơ cá nhân**: Quản lý thông tin và cài đặt người dùng

## Công nghệ sử dụng

### Frontend
- **Flutter** - Framework phát triển ứng dụng đa nền tảng
- **Dart** - Ngôn ngữ lập trình chính

### Backend & Database
- **Supabase** - Backend-as-a-Service với PostgreSQL
- **PostgreSQL** - Cơ sở dữ liệu quan hệ

## Cấu trúc dự án

```
lib/
├── config/              # Cấu hình ứng dụng
├── constants/           # Hằng số và theme
├── models/              # Data models
├── providers/           # State management providers
├── screens/             # UI screens
│   ├── auth/           # Authentication screens
│   ├── health/         # Health tracking
│   ├── home/           # Dashboard
│   ├── profile/        # User profile
│   ├── progress/       # Progress tracking
│   └── workouts/|      # Workout management
├── services/           # Business logic services
├── utils/              # Utility functions
├── widgets/            # Reusable UI components
└── main.dart           # Entry point
```

## Yêu cầu hệ thống

- **Flutter SDK**: >=3.9.2
- **Dart SDK**: >=3.0.0
- **Android**: API level 21+
- **iOS**: 12.0+
- **Web**: Modern browsers
- **Desktop**: Windows 10+, macOS 10.14+, Linux

## Cài đặt

### 1. Clone repository

```bash
git clone https://github.com/tran-hoang-nhan/workout_app.git
cd workout_app
```

### 2. Cài đặt dependencies

```bash
flutter pub get
```

### 3. Cấu hình môi trường

Tạo file `.env` từ template:

```bash
cp .env.example .env
```

Cập nhật thông tin Supabase trong file `.env`:

```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

### 4. Chạy ứng dụng

```bash
# Development mode
flutter run

# Specific platform
flutter run -d chrome        # Web
flutter run -d android       # Android
flutter run -d ios           # iOS
```

## Build Production

### Android APK
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

### Desktop
```bash
# Windows
flutter build windows --release

# macOS
flutter build macos --release

# Linux
flutter build linux --release
```

## Cấu hình Supabase

### 1. Tạo project Supabase mới
- Truy cập [supabase.com](https://supabase.com)
- Tạo project mới
- Lấy URL và anon key từ Settings > API

## Scripts hữu ích

### Phân tích code
```bash
flutter analyze
```

### Chạy tests
```bash
flutter test
```

### Format code
```bash
dart format .
```

### Clean build
```bash
flutter clean
flutter pub get
```

## Đóng góp

1. Fork repository
2. Tạo feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Tạo Pull Request

## License

Dự án này được phân phối dưới giấy phép MIT. Xem file `LICENSE` để biết thêm chi tiết.

## Liên hệ

- **Email**: tranhoangnhan10e@gmail.com
- **GitHub**: https://github.com/tran-hoang-nhan
