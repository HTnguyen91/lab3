# Nhật Ký Thay Đổi Thiết Kế (Design Change Log) — Expense Tracker

**Môn học:** PRM393 — Mobile Programming  
**Dự án:** Lab 3 — From Design to Working App with Flutter and Firebase  
**Sinh viên:** Hoàng Thanh Nguyên (SE180338)  

---

## 1. Giới thiệu
Tài liệu ghi lại toàn bộ các điều chỉnh và bổ sung giao diện so với bản thiết kế Lab 2 ban đầu nhằm đáp ứng yêu cầu hoạt động thực tế trên nền tảng di động và kết nối hệ thống Firebase.

---

## 2. Bảng ghi nhận thay đổi thiết kế

| Mã thay đổi | Màn hình ảnh hưởng | Thay đổi so với Lab 2 | Lý do thay đổi | Phê duyệt & Đánh giá |
|---|---|---|---|---|
| **DCL-01** | **S09 — Màn hình Đăng nhập (LoginScreen)** | Bổ sung mới hoàn toàn màn hình Đăng nhập với nút Google Sign-In, giới thiệu các tính năng chính và nhận diện thương hiệu. | Yêu cầu bắt buộc của Lab 3 (Mục 6.2). Người dùng phải xác thực trước khi truy cập dữ liệu cá nhân trên Firebase. | Hợp lý, bảo vệ an toàn dữ liệu người dùng. |
| **DCL-02** | **S10 — Màn hình Hồ sơ & Cài đặt (ProfileScreen)** | Bổ sung mới màn hình Hồ sơ cá nhân: Hiển thị avatar Google, tên, email, nút Đăng xuất, Notification Center (FCM), khu vực kiểm tra Remote Config, Crashlytics demo, và chức năng Xuất báo cáo PDF. | Yêu cầu tích hợp các dịch vụ Firebase của Lab 3 (Mục 6.2, 6.4, 6.5, 6.6, 6.7). | Đạt yêu cầu đồ án, tập trung các chức năng quản trị và kiểm thử. |
| **DCL-03** | **S01 — Trang chủ (HomeScreen)** | Thêm biểu tượng Avatar ở góc phải AppBar để mở S10 Profile; Thêm Banner thông điệp mẹo tài chính ở đầu màn hình từ Firebase Remote Config. | Tạo điểm truy cập tự nhiên vào màn hình Hồ sơ và phản ánh trực tiếp thay đổi từ Firebase Console theo Mục 6.6. | Cải thiện UX, không ảnh hưởng đến bố cục chính của S01. |
| **DCL-04** | **S02 — Thêm giao dịch (AddTransactionScreen)** | Thêm Segmented Switch cho phép chuyển đổi nhanh giữa "Khoản chi" và "Khoản thu". Mặc định mở sẵn "Khoản chi" như Lab 2. | Mở rộng tính năng để người dùng có thể ghi nhận tiền lương/thu nhập, giúp tính năng Số dư trên S05 có ý nghĩa thực tế. | Giữ nguyên luồng ghi khoản chi 15 giây của Persona Minh Anh. |
| **DCL-05** | **S03 — Lịch sử giao dịch (HistoryScreen)** | Bổ sung thanh tìm kiếm theo từ khóa và các chip lọc nhanh (Tất cả / Khoản chi / Khoản thu) ở đầu danh sách. | Khi danh sách giao dịch dài sau thời gian dài sử dụng, người dùng cần công cụ tra cứu nhanh. | Nâng cao trải nghiệm người dùng theo chuẩn Material 3. |
| **DCL-06** | **S04 — Chi tiết giao dịch (DetailScreen)** | Thêm tính năng Chỉnh sửa ghi chú và Hộp thoại xác nhận trước khi xóa (Confirm Delete Dialog). | Đáp ứng trọn vẹn yêu cầu CRUD hoàn chỉnh của thực thể chính theo Mục 6.3 của Lab 3. | Đảm bảo an toàn, tránh xóa nhầm giao dịch. |

---

## 3. Kết luận
Các thay đổi trên hoàn toàn tuân thủ Design System (màu sắc, kiểu chữ, khoảng cách, bo góc 12dp/16dp) đã định nghĩa trong `DESIGN.md` của Lab 2, đồng thời bổ sung đầy đủ các thành phần kỹ thuật cần thiết cho Lab 3.

