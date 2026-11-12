# PRM393 — Lab 3: From Design to Working App with Flutter and Firebase
## Đề tài: Expense Tracker (Ứng dụng Quản lý Thu Chi Cá Nhân)

- **Môn học:** PRM393 — Mobile Programming  
- **Sinh viên thực hiện:** Hoàng Thanh Nguyên  
- **Mã số sinh viên (MSSV):** SE180338  
- **Lớp / Nhóm Lab 2:** GR5  
- **Nền tảng:** Flutter (Android · Material 3)  
- **Tài liệu tham chiếu Lab 2:** [Figma Design & Handoff Specifications](../prm323-lab2-gr5/handoff/flutter-handoff.md)  

---

## 1. Giới thiệu dự án
Ứng dụng **Expense Tracker** được phát triển hoàn thiện trong Lab 3 từ bản thiết kế Lab 2 của nhóm GR5. Ứng dụng hỗ trợ ghi nhận nhanh khoản chi tiêu hàng ngày (ưu tiên Persona Minh Anh lưu khoản chi 45.000 VNĐ trong 15 giây), phân tích tỷ trọng chi tiêu theo danh mục (Persona Ngọc Linh) và thiết lập kiểm soát hạn mức ngân sách tháng với cảnh báo 4 cấp độ (Persona Quốc Huy).

Ứng dụng tích hợp đầy đủ hệ sinh thái **Google Firebase**:
- **Firebase Authentication:** Đăng nhập an toàn với tài khoản Google (Google Sign-In).
- **Cloud Firestore:** Cơ sở dữ liệu NoSQL lưu trữ thời gian thực (Real-time streams), bảo vệ bằng Security Rules nghiêm ngặt theo từng `userId`.
- **Firebase Cloud Messaging (FCM):** Nhận thông báo đẩy từ Firebase Console cả ở chế độ foreground và background, tích hợp Notification Center.
- **Firebase Remote Config:** Thay đổi động cấu hình ngưỡng cảnh báo chi tiêu và banner mẹo tài chính theo thời gian thực từ Console.
- **Firebase Crashlytics:** Giám sát lỗi ứng dụng, ghi nhận ngoại lệ có xử lý (Handled Exception) và kiểm thử sự cố (Test Force Crash).
- **Firebase Analytics:** Đo lường 12 sự kiện hành vi người dùng, kiểm chứng trực quan trên DebugView.
- **Xuất Báo Cáo PDF:** Sinh tài liệu PDF định dạng bảng cho chi tiêu tháng và tải lên lưu trữ đám mây Cloudinary / Storage.

---

## 2. Kiến trúc ứng dụng (MVVM Architecture)

Ứng dụng tuân thủ nghiêm ngặt mô hình **MVVM (Model - View - ViewModel)** kết hợp với thư viện quản lý trạng thái **Provider**:

```
lib/
├── main.dart                      # Khởi tạo App, MultiProvider, cấu hình Firebase
├── firebase_options.dart          # Thông số kết nối Firebase các nền tảng
├── theme/                         # Tokens chuyển đổi từ Lab 2 DESIGN.md
│   ├── app_colors.dart            # Mã màu: Primary (#1D4ED8), Expense (#B91C1C), Income (#166534)...
│   ├── app_spacing.dart           # Khoảng cách 4, 8, 12, 16, 24, 32 dp & Bo góc 12/16 dp
│   ├── app_text_styles.dart       # Định nghĩa font chữ chuẩn: 32, 24, 18, 16, 14, 12 dp
│   └── app_theme.dart             # ThemeData Material 3 tích hợp đầy đủ tokens
├── models/                        # Plain Dart classes (Firestore to/from Map)
│   ├── transaction_model.dart     # Giao dịch thu/chi
│   ├── budget_model.dart          # Hạn mức ngân sách danh mục theo tháng
│   ├── category_model.dart        # Danh mục thu/chi kèm icon và màu sắc
│   ├── notification_item.dart     # Thông báo FCM lưu trữ nội bộ
│   └── report_model.dart          # Metadata báo cáo PDF đã xuất
├── services/                      # Tầng duy nhất giao tiếp với Firebase & external APIs
│   ├── auth_service.dart          # Firebase Auth & Google Sign-In
│   ├── firestore_service.dart     # Cloud Firestore CRUD & Seed data
│   ├── fcm_service.dart           # FCM Push Notification listener
│   ├── remote_config_service.dart # Remote Config fetch & fallback defaults
│   ├── crashlytics_service.dart   # Crashlytics logging & crash test
│   ├── analytics_service.dart     # Firebase Analytics events
│   └── pdf_export_service.dart    # Sinh PDF & upload Cloudinary / Storage
├── viewmodels/                    # Quản lý state màn hình & business logic (ChangeNotifier)
│   ├── auth_viewmodel.dart        # Quản lý phiên đăng nhập và profile
│   ├── transaction_viewmodel.dart # Quản lý giao dịch, validate lỗi, tính tổng hôm nay
│   ├── budget_viewmodel.dart      # Tính toán tỷ lệ % hạn mức & 4 trạng thái cảnh báo
│   ├── statistics_viewmodel.dart  # Tổng hợp thu/chi, phân tích tỷ trọng danh mục
│   └── settings_viewmodel.dart    # Quản trị Remote Config, Notification Center, PDF
├── screens/                       # 10 Màn hình giao diện chuẩn Lab 2 & Lab 3
│   ├── main_scaffold.dart         # BottomNavigationBar điều hướng 4 tab chính
│   ├── s01_home_screen.dart       # S01: Trang chủ (Ngân sách còn lại, chi hôm nay)
│   ├── s02_add_transaction_screen.dart # S02: Thêm giao dịch (Validate & Lưu)
│   ├── s03_history_screen.dart    # S03: Lịch sử giao dịch (Nhóm theo ngày)
│   ├── s04_detail_screen.dart     # S04: Chi tiết giao dịch (Sửa ghi chú, Xóa)
│   ├── s05_statistics_screen.dart # S05: Thống kê chi tiêu & Biểu đồ danh mục
│   ├── s06_category_detail_screen.dart # S06: Chi tiêu theo từng danh mục
│   ├── s07_budget_screen.dart     # S07: Ngân sách & Tiến độ các danh mục
│   ├── s08_create_budget_screen.dart   # S08: Tạo ngân sách danh mục (Lưu / Hủy)
│   ├── s09_login_screen.dart      # S09: Đăng nhập với Google
│   └── s10_profile_screen.dart    # S10: Hồ sơ, Notification, Remote Config, Crashlytics, PDF
└── widgets/                       # Thư viện component tái sử dụng (Lab 2 library)
    ├── primary_button.dart        # Nút chính chuẩn 52dp, hiệu ứng "Đang lưu…"
    ├── secondary_button.dart      # Nút viền phụ
    ├── overview_card.dart         # Thẻ ngân sách nổi bật
    ├── transaction_row.dart       # Dòng giao dịch chuẩn căn phải
    ├── category_bar.dart          # Thanh ngang biểu đồ tỷ trọng
    ├── budget_card.dart           # Thẻ ngân sách thanh tiến độ 4 màu
    ├── empty_state.dart           # Trạng thái rỗng
    └── input_field.dart           # Ô nhập liệu chuẩn kèm nhãn và lỗi
```

---

## 3. Hướng dẫn cài đặt & Chạy ứng dụng

### Yêu cầu môi trường
- **Flutter SDK:** 3.50.0 (Dart 3.14.0) trở lên
- **Android SDK:** API Level 34 / 36
- **JDK:** OpenJDK 21 (đã cấu hình `JAVA_HOME`)

### Các bước thực hiện
1. **Di chuyển vào thư mục dự án:**
   ```bash
   cd D:\lab3\PRM393_Lab03_SE180338
   ```

2. **Cài đặt các gói phụ thuộc:**
   ```bash
   flutter pub get
   ```

3. **Kiểm tra chất lượng mã nguồn:**
   ```bash
   flutter analyze
   flutter test
   ```

4. **Chạy ứng dụng trên Thiết bị / Android Emulator:**
   ```bash
   flutter run
   ```

---

## 4. Cấu hình Firebase & Dịch vụ Đám Mây

1. **Firebase Authentication:**
   - Đã bật nhà cung cấp xác thực **Google Sign-In**.
   - Trên Android, đăng ký mã băm chứng chỉ `SHA-1` debug trong Firebase Console:
     ```bash
     keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
     ```

2. **Cloud Firestore Rules:**
   - Tệp quy tắc được lưu tại [`firebase/firestore.rules`](firebase/firestore.rules).
   - Dữ liệu được bảo vệ an toàn: Mỗi người dùng chỉ có quyền đọc và ghi dữ liệu của chính mình tại đường dẫn `users/{userId}/...`.

3. **Dịch vụ Lưu Trữ Tệp Báo Cáo PDF:**
   - Sử dụng **Cloudinary** qua unsigned upload preset `prm393_preset` (hoặc Firebase Storage).
   - Tuyệt đối không lưu API Secret trong ứng dụng để đảm bảo an ninh thông tin.

4. **Kiểm Thử Tự Động Với MobAI:**
   - 10 kịch bản kiểm thử tự động được lưu tại thư mục [`mobai_tests/`](mobai_tests/).
   - Chạy kiểm thử tự động trực tiếp trên MobAI Desktop Agent.

---

## 5. Danh mục tài liệu báo cáo kèm theo
Toàn bộ tài liệu yêu cầu của Lab 3 được lưu trữ tại thư mục `docs/`:
- [`docs/handoff-gaps.md`](docs/handoff-gaps.md): Khoảng trống handoff Lab 2 và giải pháp.
- [`docs/design-change-log.md`](docs/design-change-log.md): Nhật ký thay đổi thiết kế giao diện.
- [`docs/fidelity-check.md`](docs/fidelity-check.md): Đánh giá độ chuẩn xác so với thiết kế.
- [`docs/analytics-plan.md`](docs/analytics-plan.md): Kế hoạch theo dõi sự kiện Firebase Analytics.
- [`docs/implementation-ai-log.md`](docs/implementation-ai-log.md): Nhật ký phát triển cùng AI (6 lượt prompt).
- [`docs/test-report.md`](docs/test-report.md): Báo cáo kiểm thử MobAI và 2 bài tập chuyên sâu.
- [`docs/code-review.md`](docs/code-review.md): Báo cáo rà soát mã nguồn tự động với AI.
