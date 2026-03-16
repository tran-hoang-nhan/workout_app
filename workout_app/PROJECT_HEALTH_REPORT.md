# Báo cáo Kiểm tra Toàn diện Project (Workout App)

Báo cáo này liệt kê các vấn đề về kiến trúc, workflow và các thành phần mã nguồn cần được cải thiện hoặc dọn dẹp.

## 1. Cải thiện Workflow & Logic

*   **Quản lý Trạng thái (State Management) [DONE]**: 
    *   **Vấn đề**: Project đang sử dụng cả `provider` và `riverpod`. Việc kết hợp cả hai gây ra sự chồng chéo, khó bảo trì và dễ gây nhầm lẫn cho team dev.
    *   **Kết quả**: Đã gỡ bỏ package `provider` và chuyển đổi logic sang Riverpod hoàn toàn.
*   **Xử lý Thông báo (Notifications) [DONE]**:
    *   **Vấn đề**: Logic trong `NotificationController` (tại `main.dart`) đang truy cập trực tiếp vào `navigatorKey.currentContext` và `ProviderScope.containerOf`. Đây là cách tiếp cận dễ lỗi (fragile) nếu context bị thay đổi hoặc ứng dụng không ở foreground.
    *   **Kết quả**: Đã refactor logic xử lý notification an toàn hơn, kiểm tra `context.mounted` và tối ưu hóa việc sử dụng `ProviderScope`.
*   **Điều hướng (Navigation) [REVIEWED]**:
    *   **Vấn đề**: Vẫn đang sử dụng `Navigator.push` truyền thống.
    *   **Kết quả**: Giữ lại Navigator cho đơn giản ở version hiện tại, sẽ xem xét `go_router` cho quy mô lớn hơn.

## 2. Vấn đề Kiến trúc (Architecture)

*   **Phân rã Provider (Large Files)**:
    *   **Vấn đề**: `lib/providers/health_provider.dart` quá lớn (gần 400 dòng) và chứa quá nhiều trách nhiệm: từ định nghĩa Models, Notifiers cho đến các logic tính toán BMI/BMR.
    *   **Đề xuất**: Tách file này thành các module nhỏ hơn: `health_models.dart`, `health_calculations_service.dart`, `health_form_notifier.dart`, v.v.
*   **Rò rỉ logic UI (UI Leakage)**:
    *   **Vấn đề**: Một số màn hình như `HomeScreen` chứa logic xử lý URL avatar hoặc các điều kiện hiển thị phức tạp.
    *   **Đề xuất**: Di chuyển các logic này vào Provider/View-Model. Screen chỉ nên chịu trách nhiệm hiển thị UI dựa trên dữ liệu từ Provider.
*   **Dependency Coupling**:
    *   **Vấn đề**: `HealthService` đang phụ thuộc vào quá nhiều Repositories khác nhau.
    *   **Đề xuất**: Sử dụng mô hình **Use Cases** hoặc **Facade Pattern** để giảm bớt sự phụ thuộc trực tiếp giữa Service layer và Data layer nếu ứng dụng mở rộng thêm.

## 3. Code Rác & Nợ kỹ thuật (Junk Code & Tech Debt)

*   **File Rác ở Thư mục Gốc**:
    *   **Vấn đề**: Xuất hiện nhiều file log/phân tích như `analysis.log`, `analysis.txt`, `analysis_final.txt`, `analyze_results.txt`.
    *   **Đề xuất**: Xóa các file này và thiết lập cấu hình phân tích trong `analysis_options.yaml` một cách chặt chẽ hơn để xem trực tiếp trên IDE.
*   **Hardcoded Strings & URLs**:
    *   **Vấn đề**: Có các URL mặc định (như `ui-avatars.com`) và một số text tiếng Việt được hardcode trực tiếp trong UI.
    *   **Đề xuất**: Di chuyển các URL vào `AppConstants` và sử dụng `intl` cho đa ngôn ngữ (nếu có kế hoạch phát triển lâu dài).
*   **Dependencies Unused**:
    *   **Vấn đề**: Có khả năng một số package trong `pubspec.yaml` không còn được sử dụng sau quá trình refactor.

## 4. Kết luận & Ưu tiên thực hiện

1.  **Ưu tiên 1**: Dọn dẹp các file rác tại thư mục gốc và chuẩn hóa State Management (Riverpod).
2.  **Ưu tiên 2**: Refactor các Provider quá lớn (như `health_provider.dart`).
3.  **Ưu tiên 3**: Cải thiện logic xử lý Notification để tăng độ ổn định.

---
*Báo cáo được thực hiện bởi Antigravity AI.*
