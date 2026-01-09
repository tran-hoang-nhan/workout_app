# 📊 PROGRESS SCREEN SPECIFICATION

## 1. Tổng quan (Overview)
Màn hình **Progress (Tiến độ)** là trung tâm theo dõi dữ liệu sức khỏe của người dùng.
* **Mục tiêu:** Giúp người dùng hình dung được hành trình tập luyện, duy trì động lực qua các con số và biểu đồ.
* **Phạm vi:** Thống kê chỉ số tập luyện, theo dõi cân nặng, tính toán BMI và lịch sử hoạt động.

---

## 2. Yêu cầu Kỹ thuật (Technical Requirements)

### Dependencies (Packages)
Thêm các thư viện sau vào `pubspec.yaml`:
- `fl_chart`: ^0.66.0 (Vẽ biểu đồ đường và cột)
- `table_calendar`: ^3.1.0 (Hiển thị lịch hoạt động)
- `intl`: ^0.19.0 (Format ngày tháng và số liệu)
- `flutter_riverpod`: (Quản lý State)

### Database Schema (Supabase)
Tạo bảng `daily_stats` để lưu trữ dữ liệu tổng hợp theo ngày.

```sql
-- Chạy lệnh này trong SQL Editor của Supabase
create table public.daily_stats (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users(id) on delete cascade not null,
  date date not null,               -- Ngày ghi nhận (YYYY-MM-DD)
  
  -- Các chỉ số cơ thể
  weight numeric(5,2),              -- Cân nặng (kg)
  height numeric(5,2),              -- Chiều cao (cm) - Có thể lưu ở profile, hoặc lưu đây để track lịch sử
  
  -- Các chỉ số hoạt động trong ngày
  calories_burned int default 0,    -- Tổng calo tiêu thụ
  workout_duration int default 0,   -- Tổng phút tập luyện
  steps_count int default 0,        -- Số bước chân
  water_intake int default 0,       -- Số ml nước đã uống
  
  created_at timestamptz default now(),
  
  -- Constraint: Mỗi user chỉ có 1 dòng dữ liệu cho 1 ngày
  unique(user_id, date)
);