# Kế Hoạch Theo Dõi Firebase Analytics (Analytics Plan) — Expense Tracker

**Môn học:** PRM393 — Mobile Programming  
**Dự án:** Lab 3 — From Design to Working App with Flutter and Firebase  
**Sinh viên:** Hoàng Thanh Nguyên (SE180338)  

---

## 1. Giới thiệu
Tài liệu định nghĩa kế hoạch đo lường và theo dõi hành vi người dùng bằng Firebase Analytics. Toàn bộ tên sự kiện tuân thủ quy tắc: chữ thường, số, dấu gạch dưới, không dấu và tối đa 40 ký tự.

---

## 2. Bảng kế hoạch sự kiện chi tiết

| Tên sự kiện (Event Name) | Thời điểm kích hoạt (Trigger) | Tham số (Parameters) | Luồng Lab 2 liên quan |
|---|---|---|---|
| **`login`** | Đăng nhập thành công với tài khoản Google | `method` (`google_sign_in` / `popup`) | Mục 6.2 (Authentication) |
| **`logout`** | Người dùng bấm Đăng xuất từ màn hình Hồ sơ | *Không có* | Mục 6.2 (Authentication) |
| **`screen_view`** | Mở một màn hình mới trong ứng dụng | `screen_name` (`s01_home`, `s02_add`, `s03_history`, `s04_detail`, `s05_stats`, `s06_category_detail`, `s07_budget`, `s08_create_budget`, `s09_login`, `s10_profile`) | Toàn bộ luồng điều hướng |
| **`view_transaction`** | Chạm mở màn hình xem chi tiết một giao dịch (S04) | `item_id` (Mã document Firestore)<br>`item_name` (Danh mục - Số tiền) | UF-01 (Kiểm tra giao dịch) |
| **`create_transaction`** | Lưu thành công một giao dịch thu/chi mới | `item_id`<br>`amount`<br>`category` | UF-01 (Ghi khoản chi) |
| **`update_transaction`** | Cập nhật thành công thông tin / ghi chú giao dịch | `item_id` | Mục 6.3 (CRUD Data) |
| **`delete_transaction`** | Xóa thành công một giao dịch khỏi Firestore | `item_id` | Mục 6.3 (CRUD Data) |
| **`create_budget`** | Thiết lập hoặc cập nhật hạn mức ngân sách danh mục | `category`<br>`limit_amount` | UF-03 (Đặt hạn mức ngân sách) |
| **`view_statistics_category`** | Người dùng bấm vào một danh mục trong biểu đồ thống kê để xem chi tiết | `category_name`<br>`month` | UF-02 (Xem chi tiêu danh mục) |
| **`add_expense_flow_complete`** | Hoàn thành trọn vẹn luồng UF-01: thêm khoản chi và cập nhật ngân sách | `category`<br>`amount` | UF-01 (Custom Key Event) |
| **`set_budget_flow_complete`** | Hoàn thành trọn vẹn luồng UF-03: tạo hạn mức cho danh mục thành công | `category`<br>`limit_amount` | UF-03 (Custom Key Event) |
| **`export_pdf`** | Hoàn thành việc tạo tệp PDF và tải lên Cloudinary / Storage | `item_count` (Số lượng giao dịch trong báo cáo) | Mục 6.4 (Report export) |

---

## 3. Triển khai trong mã nguồn & Kiểm chứng (DebugView)
- **Tầng mã nguồn:** Toàn bộ logic được đóng gói tại [`lib/services/analytics_service.dart`](../lib/services/analytics_service.dart) và được gọi gián tiếp thông qua các ViewModel. Không có mã Analytics trực tiếp trong UI Widgets.
- **Kích hoạt DebugView trên Android Emulator:**
  ```bash
  adb shell setprop debug.firebase.analytics.app com.prm393.expense_tracker
  ```
- **Tắt DebugView sau khi kiểm thử:**
  ```bash
  adb shell setprop debug.firebase.analytics.app .none.
  ```
- **Minh chứng:** Các sự kiện xuất hiện theo thời gian thực trên giao diện Firebase Console → Analytics → DebugView, kèm đầy đủ các trường tham số (`item_id`, `amount`, `category`, `screen_name`).

