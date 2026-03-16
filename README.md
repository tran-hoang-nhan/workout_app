# Workout Tracker Ecosystem

Hệ sinh thái ứng dụng theo dõi tập luyện toàn diện, bao gồm ứng dụng di động (Flutter), backend (Dart Frog) và thư viện chia sẻ (Shared Models).

## Cấu trúc dự án

Dự án được tổ chức theo mô hình mono-repo đơn giản:

- **[workout_app](./workout_app)**: Ứng dụng di động được xây dựng bằng **Flutter**. Sử dụng Riverpod để quản trị trạng thái và Supabase cho dữ liệu thời gian thực.
- **[workout_backend](./workout_backend)**: Backend API xây dựng bằng **Dart Frog**. Xử lý logic nghiệp vụ phức tạp, tích hợp AI và quản lý dữ liệu tập trung qua Supabase.
- **[shared](./shared)**: Thư viện Dart chứa các Models (`Workout`, `BodyMetric`, `HealthData`, v.v.) dùng chung cho cả App và Backend, đảm bảo sự đồng bộ dữ liệu tuyệt đối.

## Tính năng chính

- 🔐 **Xác thực**: Đăng ký, đăng nhập và bảo mật phiên làm việc qua Supabase Auth.
- 🏋️ **Quản lý Bài tập**: Phân loại bài tập thông minh (Toàn thân, Ngực, Lưng, HIIT...) với cơ chế tìm kiếm và lọc mạnh mẽ.
- 📈 **Theo dõi Tiến độ**: Ghi lại lịch sử tập luyện, tính toán lượng calo tiêu thụ.
- ⚖️ **Sức khỏe & BMI**: Theo dõi cân nặng, tự động tính toán BMI và biểu đồ biến thiên theo thời gian.
- 🔔 **Nhắc nhở**: Hệ thống nhắc nhở uống nước và tập luyện cá nhân hóa.

## Công nghệ sử dụng

- **Frontend**: Flutter, Riverpod, Supabase Flutter SDK.
- **Backend**: Dart Frog, Supabase Dart SDK.
- **AI**: Tích hợp gợi ý bài tập thông minh (AI-assisted generation).
- **Database**: PostgreSQL (Supabase).

## Hướng dẫn cài đặt & Chạy dự án

### 1. Chuẩn bị
- Cài đặt [Flutter SDK](https://docs.flutter.dev/get-started/install) (>= 3.0.0).
- Cài đặt [Dart SDK](https://dart.dev/get-dart).
- Tạo project trên [Supabase](https://supabase.com).

### 2. Cài đặt các thư viện (Dependencies)
Bạn cần chạy lệnh cài đặt cho từng phần của dự án:
```bash
# Cài đặt thư viện Shared
cd shared
flutter pub get
cd ..

# Cài đặt Backend
cd workout_backend
dart pub get
cd ..

# Cài đặt App
cd workout_app
flutter pub get
```

### 3. Cấu hình môi trường
- Tạo file `.env` trong thư mục `workout_app` và `workout_backend` (nếu cần).
- Cập nhật `SUPABASE_URL` và `SUPABASE_ANON_KEY`.

### 4. Chạy dự án
Nên chạy Backend trước, sau đó đến App.

**Chạy Backend:**
```bash
cd workout_backend
dart_frog dev
```

**Chạy App:**
```bash
cd workout_app
flutter run
```

## Đóng góp
Nếu bạn muốn đóng góp cho dự án, vui lòng fork repository này và tạo pull request.

## License
Phân phối dưới giấy phép MIT. Xem file `LICENSE` (nếu có) để biết thêm chi tiết.
