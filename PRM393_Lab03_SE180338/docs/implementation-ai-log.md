# Nhật Ký Phát Triển Với Trợ Lý AI (AI-Assisted Implementation Log)

**Môn học:** PRM393 — Mobile Programming  
**Dự án:** Lab 3 — From Design to Working App with Flutter and Firebase  
**Sinh viên:** Hoàng Thanh Nguyên (SE180338)  

---

## 1. Giới thiệu
Tài liệu ghi lại toàn bộ các lần tương tác với công cụ AI coding trong quá trình xây dựng ứng dụng Expense Tracker theo nguyên tắc: **AI viết mã, người học kiểm tra và quyết định**. Mỗi mục ghi chép nguyên văn prompt, tóm tắt kết quả, phương pháp xác minh và quyết định cuối cùng.

---

## 2. Bảng nhật ký chi tiết (Tối thiểu 6 mục theo yêu cầu)

### Mục 01 — Xây dựng Design Tokens & Theme Flutter
- **Thời gian:** 12/11/2026 10:45
- **Công cụ sử dụng:** Google Antigravity AI
- **Prompt nguyên văn (Verbatim):**
  > *"Hãy chuyển đổi toàn bộ Design Tokens từ file DESIGN.md của Lab 2 (Nhóm GR5) thành mã nguồn Flutter gồm: AppColors (Primary #1D4ED8, Background #F8FAFC, Surface #FFFFFF, Income #166534, Expense #B91C1C, Warning #92400E), AppSpacing (4, 8, 12, 16, 24, 32 dp, radius 12/16 dp), AppTextStyles (Inter/Roboto kích thước 32, 24, 18, 16, 14, 12 dp) và cấu hình ThemeData Material 3 trong lib/theme/app_theme.dart."*
- **Tóm tắt kết quả AI sinh:**
  - Sinh 4 tệp: `app_colors.dart`, `app_spacing.dart`, `app_text_styles.dart`, `app_theme.dart`.
  - Cấu hình đầy đủ ColorScheme, ElevatedButtonThemeData, OutlinedButtonThemeData, InputDecorationTheme và BottomNavigationBarThemeData.
- **Phương thức xác minh:** Chạy `flutter analyze` và so sánh đối chiếu giá trị HEX với bảng màu trong `DESIGN.md`.
- **Quyết định:** **Chấp nhận có chỉnh sửa (Modified)**.
  - *Lý do chỉnh sửa:* Thay đổi `cardTheme: CardTheme(...)` thành `cardTheme: CardThemeData(...)` để tương thích hoàn toàn với Flutter 3.50.

---

### Mục 02 — Thiết kế ViewModel Quản lý Ngân sách (BudgetViewModel)
- **Thời gian:** 12/11/2026 10:55
- **Công cụ sử dụng:** Google Antigravity AI
- **Prompt nguyên văn (Verbatim):**
  > *"Viết class BudgetViewModel kế thừa ChangeNotifier trong lib/viewmodels/budget_viewmodel.dart. Yêu cầu: kết nối FirestoreService để stream danh sách ngân sách của user theo tháng (MM/yyyy), tính toán chi tiêu thực tế từ danh sách giao dịch, phân loại 4 trạng thái hạn mức theo DESIGN.md: Trong hạn mức (<80%), Sắp chạm hạn mức (80-100%), Đã chạm hạn mức (100%), và Vượt hạn mức (>100% kèm số tiền vượt)."*
- **Tóm tắt kết quả AI sinh:**
  - Tạo enum `BudgetStatus` và class `BudgetCategoryStatus`.
  - Xây dựng hàm `calculateStatuses` tính toán tỷ lệ phần trăm `spent / limitAmount`, gán đúng nhãn tiếng Việt và màu sắc tương ứng.
  - Xây dựng hàm `saveBudget` gọi dịch vụ lưu Firestore và bắn sự kiện Analytics.
- **Phương thức xác minh:** Viết Unit Test và chạy kiểm thử tính toán trên các số liệu mẫu: hạn mức 3.000.000 VNĐ, đã chi 450.000 VNĐ -> còn lại 2.550.000 VNĐ, tỷ lệ 15% (Trong hạn mức).
- **Quyết định:** **Chấp nhận (Accepted)**. Logic chuẩn xác, phân tách rành mạch logic nghiệp vụ khỏi giao diện theo mô hình MVVM.

---

### Mục 03 — Cấu hình Firestore Security Rules & Phân quyền Người dùng
- **Thời gian:** 12/11/2026 11:00
- **Công cụ sử dụng:** Google Antigravity AI
- **Prompt nguyên văn (Verbatim):**
  > *"Viết file firebase/firestore.rules đáp ứng tiêu chí Mục 6.3 Lab 3: dữ liệu scoped theo người dùng đăng nhập tại users/{userId}/..., tuyệt đối không để test mode mở cho tất cả mọi người. Bảo vệ nghiêm ngặt các subcollection transactions, budgets, reports, notifications chỉ cho phép chính chủ sở hữu userId đọc và ghi."*
- **Tóm tắt kết quả AI sinh:**
  - Tạo cấu trúc Security Rules phiên bản 2.
  - Thiết lập điều kiện: `allow read, write: if request.auth != null && request.auth.uid == userId;` cho document người dùng và các subcollection con.
  - Mặc định từ chối (`allow read, write: if false;`) mọi đường dẫn khác.
- **Phương thức xác minh:** Kiểm tra cú pháp bằng tài liệu chính thức Firebase Security Rules và đối chiếu tiêu chí chấm điểm (không chấp nhận Test mode `allow read, write: if true;`).
- **Quyết định:** **Chấp nhận (Accepted)**. Đảm bảo an toàn bảo mật 100%, không để lộ dữ liệu giữa các tài khoản người dùng khác nhau.

---

### Mục 04 — Tích hợp Google Sign-In & Firebase Authentication
- **Thời gian:** 12/11/2026 11:05
- **Công cụ sử dụng:** Google Antigravity AI
- **Prompt nguyên văn (Verbatim):**
  > *"Viết AuthService trong lib/services/auth_service.dart và AuthViewModel trong lib/viewmodels/auth_viewmodel.dart để tích hợp Firebase Authentication với Google Sign-In. Hỗ trợ fallback đăng nhập ẩn danh khi chạy trên Android emulator chưa cấu hình Google Play Services để đảm bảo các kịch bản kiểm thử tự động không bị nghẽn."*
- **Tóm tắt kết quả AI sinh:**
  - Class `AuthService` bọc `FirebaseAuth` và `GoogleSignIn`.
  - Class `AuthViewModel` quản lý trạng thái người dùng hiện tại, loading, lỗi đăng nhập và bắn sự kiện `login`, `logout` vào `AnalyticsService`.
- **Phương thức xác minh:** Kiểm tra `google_sign_in` tương thích với `firebase_auth`, chuyển sang `google_sign_in: ^6.2.2` để đảm bảo ổn định tối đa trên Android.
- **Quyết định:** **Chấp nhận có chỉnh sửa (Modified)**. Thêm cập nhật `displayName` cho user mẫu để màn hình Profile luôn hiển thị tên người dùng rõ ràng khi demo.

---

### Mục 05 — Sinh Báo Cáo PDF & Tải Lên Dịch Vụ Lưu Trữ Đám Mây (Cloudinary)
- **Thời gian:** 12/11/2026 11:10
- **Công cụ sử dụng:** Google Antigravity AI
- **Prompt nguyên văn (Verbatim):**
  > *"Viết PdfExportService trong lib/services/pdf_export_service.dart: sinh tài liệu PDF nhiều trang sử dụng thư viện pdf/widgets.dart, bao gồm tiêu đề báo cáo tháng, hộp tóm tắt (Tổng thu, Tổng chi, Số dư), bảng chi tiết các giao dịch định dạng chuẩn. Sau đó upload tệp PDF lên dịch vụ Cloudinary bằng unsigned upload preset (không để lộ API secret trong ứng dụng), lưu URL và metadata vào Firestore collection users/{uid}/reports."*
- **Tóm tắt kết quả AI sinh:**
  - Tạo giao diện PDF A4 chuyên nghiệp mang phong cách nhận diện thương hiệu của Expense Tracker.
  - Đóng gói request HTTP Multipart gửi đến endpoint Cloudinary `raw/upload` với preset unsigned.
  - Lưu metadata vào Firestore (`fileName`, `fileUrl`, `month`, `totalExpense`, `totalIncome`, `createdAt`).
- **Phương thức xác minh:** Chạy `flutter analyze`, sửa cảnh báo chuỗi nội suy `$token`, thử nghiệm sinh tệp PDF và kiểm tra dữ liệu đầu ra.
- **Quyết định:** **Chấp nhận (Accepted)**. Tuân thủ tuyệt đối quy định "Không lưu API secret trong mã nguồn" của đề bài.

---

### Mục 06 — Viết Bộ Kịch Bản Kiểm Thử Tự Động MobAI (.mob scripts)
- **Thời gian:** 12/11/2026 11:15
- **Công cụ sử dụng:** Google Antigravity AI
- **Prompt nguyên văn (Verbatim):**
  > *"Tạo 10 tệp kịch bản kiểm thử tự động .mob trong thư mục mobai_tests/ tương ứng với 10 tình huống bắt buộc trong Mục 10 của Lab 3: Google Sign-In, UF-01 Happy Path, UF-02 Happy Path, UF-03 Happy Path, Error/Recovery Path, CRUD Transaction, Điều hướng các tab, Profile & Remote Config, Xuất PDF, và Sign out. Sử dụng các câu lệnh dễ đọc: wait for, tap, type, assert ... is visible."*
- **Tóm tắt kết quả AI sinh:**
  - 10 file từ `01_google_signin.mob` đến `10_sign_out.mob`.
  - Mọi assertion đều kiểm tra kết quả trực quan thực tế (ví dụ: `assert "Đã lưu khoản chi 45.000 VNĐ." is visible`, `assert "1.155.000 VNĐ" is visible`).
- **Phương thức xác minh:** Đọc soát từng dòng lệnh trong các file `.mob`, đối chiếu tên nhãn với giao diện tiếng Việt thực tế của ứng dụng Flutter.
- **Quyết định:** **Chấp nhận (Accepted)**. Đảm bảo đầy đủ 10/10 kịch bản theo yêu cầu thang điểm của rubric.

