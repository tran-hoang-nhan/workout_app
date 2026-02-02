# Tech Stack - Workout App

Hồ sơ công nghệ được sử dụng trong dự án Workout App.

## 🛠 Nền tảng & Ngôn ngữ (Framework & Language)
*   **Framework:** [Flutter](https://flutter.dev/) - Phiên bản SDK ^3.9.2
*   **Language:** [Dart](https://dart.dev/)

## 🏗 Kiến trúc (Architecture)
Dự án được tổ chức theo mô hình phân lớp rõ rệt (Layered Architecture) nhằm đảm bảo tính dễ bảo trì và mở rộng:
*   **Presentation Layer:** Sử dụng Widgets & Screens để hiển thị giao diện.
*   **State Management:** [Riverpod](https://riverpod.dev/) (Kiến trúc chính) và [Provider](https://pub.dev/packages/provider).
*   **Business Logic Layer:** `services/` xử lý logic nghiệp vụ và tích hợp API bên thứ ba.
*   **Data Layer:** `repositories/` quản lý truy xuất dữ liệu từ Supabase.
*   **Model Layer:** `models/` định nghĩa các đối tượng dữ liệu và mapping JSON.

## ☁️ Backend & Cơ sở dữ liệu (Backend & Database)
*   **Database & Auth:** [Supabase](https://supabase.com/) - Giải pháp Backend-as-a-Service mạnh mẽ cho Auth, Database (PostgreSQL) và Storage.
*   **Configuration:** [Flutter Dotenv](https://pub.dev/packages/flutter_dotenv) quản lý biến môi trường bảo mật.

## 🎨 Giao diện & Trải nghiệm người dùng (UI/UX)
*   **Thiết kế:** Modern UI với hiệu ứng Frosted Glass (kính mờ), Vibrant Gradients và Typography cao cấp.
*   **Typography:** [Google Fonts](https://pub.dev/packages/google_fonts) (Ưu tiên font Inter/Outfit).
*   **Biểu đồ:** [FL Chart](https://pub.dev/packages/fl_chart) hiển thị tiến độ luyện tập và chỉ số sức khỏe.
*   **Hiệu ứng & Animation:** 
    *   [Lottie](https://pub.dev/packages/lottie) cho các animation mượt mà.
    *   [Shimmer](https://pub.dev/packages/shimmer) hiệu ứng loading giả lập.
    *   [Loading Animation Widget](https://pub.dev/packages/loading_animation_widget).
*   **Navigation:** [Google Nav Bar](https://pub.dev/packages/google_nav_bar) cho thanh điều hướng dưới hiện đại.

## 🔋 Tính năng Sức khỏe & Hệ thống (System Features)
*   **Sức khỏe:** [Health](https://pub.dev/packages/health) đồng bộ dữ liệu từ Apple Health/Google Fit.
*   **Cảm biến:** [Pedometer](https://pub.dev/packages/pedometer) theo dõi bước chân.
*   **Vị trí:** [Geolocator](https://pub.dev/packages/geolocator) cho các tính năng liên quan đến địa điểm.
*   **Thông báo:** [Awesome Notifications](https://pub.dev/packages/awesome_notifications) quản lý nhắc nhở tập luyện/uống nước.
*   **Phương tiện:** [Image Picker](https://pub.dev/packages/image_picker) và [Cached Network Image](https://pub.dev/packages/cached_network_image).

## 🛠 Công cụ hỗ trợ & Phát triển (Utilities & Dev Tools)
*   **Thời gian:** [Table Calendar](https://pub.dev/packages/table_calendar), [Intl](https://pub.dev/packages/intl), [Timezone](https://pub.dev/packages/timezone).
*   **Gỡ lỗi:** [Logger](https://pub.dev/packages/logger) và [Device Preview](https://pub.dev/packages/device_preview).
*   **Phân tích mã nguồn:** `flutter_lints` chuẩn hóa code style.
*   **Tiện ích:** `uuid`, `path`, `permission_handler`.
