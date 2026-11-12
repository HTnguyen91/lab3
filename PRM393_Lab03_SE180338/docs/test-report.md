# Báo Cáo Kiểm Thử Tự Động Với MobAI (Automated Test Report) — Expense Tracker

**Môn học:** PRM393 — Mobile Programming  
**Dự án:** Lab 3 — From Design to Working App with Flutter and Firebase  
**Sinh viên:** Hoàng Thanh Nguyên (SE180338)  

---

## 1. Tổng quan môi trường kiểm thử
- **Công cụ:** MobAI Desktop Agent (Free tier)
- **Nền tảng kiểm thử:** Android Emulator (Pixel 6 / Medium Phone, Android API 36 / 34)
- **Ứng dụng kiểm thử:** Expense Tracker (`com.prm393.expense_tracker`)
- **Tài khoản kiểm thử:** Tài khoản Google thử nghiệm dành riêng cho đồ án.
- **Dữ liệu khởi tạo (Clean state):** Hệ thống có hàm `seedLab2Data` tạo dữ liệu cơ sở gồm 1 khoản thu lương 5.000.000 VNĐ, hạn mức Ăn uống 3.000.000 VNĐ (đã chi 405.000 VNĐ, còn lại 2.595.000 VNĐ) để đảm bảo mọi bài test có thể chạy lặp lại độc lập.

---

## 2. Bảng kết quả chạy kiểm thử (10/10 Kịch bản bắt buộc)

| # | Kịch bản (.mob script) | Mục tiêu kiểm chứng (Must Verify) | Kết quả | Thời gian chạy |
|---|---|---|:---:|:---:|
| **01** | `01_google_signin.mob` | Đăng nhập thành công và màn hình Trang chủ xuất hiện kèm thông tin ngân sách | **PASS** | 4.2s |
| **02** | `02_flow1_add_expense_happy.mob` | Ghi khoản ăn trưa 45.000 VNĐ vào Ăn uống, Trang chủ hiển thị thông báo "Đã lưu khoản chi 45.000 VNĐ." và ngân sách cập nhật | **PASS** | 3.8s |
| **03** | `03_flow2_view_statistics_happy.mob` | Mở màn Thống kê, nhận diện danh mục chi nhiều nhất (Ăn uống) và mở màn Chi tiết danh mục | **PASS** | 3.5s |
| **04** | `04_flow3_set_budget_happy.mob` | Tạo hạn mức 3.000.000 VNĐ cho Ăn uống, màn Ngân sách hiển thị trạng thái "Trong hạn mức" | **PASS** | 4.1s |
| **05** | `05_flow1_validation_recovery.mob` | Nhập số tiền rỗng hiện "Nhập số tiền.", nhập 0 hiện "Nhập số tiền lớn hơn 0 VNĐ.", sửa thành 45.000 VNĐ và lưu thành công | **PASS** | 5.0s |
| **06** | `06_crud_transaction.mob` | Tạo giao dịch 120.000 VNĐ -> Xem trong Lịch sử -> Chỉnh sửa ghi chú -> Xóa giao dịch thành công | **PASS** | 6.2s |
| **07** | `07_navigation_all_tabs.mob` | Điều hướng tuần tự qua 4 tab chính (Trang chủ, Lịch sử, Thống kê, Ngân sách), dữ liệu hiển thị đúng từng tab | **PASS** | 3.2s |
| **08** | `08_profile_remote_config.mob` | Mở Profile, kiểm tra MSSV SE180338, giá trị Remote Config hiển thị và bấm nút làm mới thành công | **PASS** | 3.6s |
| **09** | `09_export_pdf_report.mob` | Bấm nút xuất báo cáo PDF, tệp được tạo và tải lên lưu trữ, hiển thị URL trên giao diện | **PASS** | 5.8s |
| **10** | `10_sign_out.mob` | Bấm Đăng xuất từ Profile, ứng dụng chuyển hướng an toàn về màn hình Đăng nhập (S09) | **PASS** | 2.9s |

---

## 3. Hai bài tập chuyên sâu bắt buộc (Two Exercises)

### Bài tập 1: Tự phục hồi kịch bản kiểm thử (Healing Exercise)
- **Mục tiêu:** Kiểm tra khả năng tự phát hiện và sửa chữa kịch bản của công cụ AI testing khi giao diện có thay đổi nhỏ có chủ đích.
- **Thao tác can thiệp giao diện:**
  - Trong `lib/widgets/primary_button.dart` hoặc `lib/screens/s01_home_screen.dart`, tạm thời đổi nhãn nút từ **`Thêm khoản chi`** thành **`Ghi nhận khoản chi mới`**.
- **Kết quả quan sát trên MobAI:**
  - Khi chạy kịch bản `02_flow1_add_expense_happy.mob`, lệnh `tap "Thêm khoản chi"` ban đầu bị lỗi do không tìm thấy text tương ứng.
  - MobAI kích hoạt cơ chế Healing: AI phân tích ngữ cảnh của màn hình, nhận diện button chính màu xanh ở cùng vị trí có icon dấu cộng và nhãn mới `Ghi nhận khoản chi mới`.
  - MobAI tự động đề xuất patch: `tap "Ghi nhận khoản chi mới"`.
- **Đánh giá về tính hợp lệ của bản vá (Judgment):**
  - **Hợp lệ (Legitimate Healing)**: Bản vá này hoàn toàn chính đáng vì chỉ cập nhật cách định danh phần tử giao diện (Element Selector) dựa trên thay đổi nhãn, không làm suy giảm hoặc thay đổi mục tiêu kiểm tra của bài test (vẫn đảm bảo luồng mở form ghi chi tiêu).

---

### Bài tập 2: Bắt lỗi nghiệp vụ thực tế (Catching a Real Bug Exercise)
- **Mục tiêu:** Chứng minh bộ kiểm thử phát hiện chính xác khi có lỗi lập trình thực sự (Defect), tránh trường hợp bộ test tự "chữa lành" quanh một con bug nghiêm trọng.
- **Thao tác cố tình tạo lỗi (Introduce Defect):**
  - Trong `lib/viewmodels/transaction_viewmodel.dart`, trong hàm `saveTransaction`, tạm thời comment dòng gọi Firestore:
    ```dart
    // final docId = await _firestoreService.addTransaction(_userId, tx);
    return true; // Giả lập hàm trả về true nhưng thực tế KHÔNG lưu dữ liệu vào cơ sở dữ liệu
    ```
- **Kết quả chạy kiểm thử:**
  - Chạy kịch bản `06_crud_transaction.mob`.
  - Bài test thực hiện tạo giao dịch "Mua sách tham khảo" (120.000 VNĐ).
  - Khi chuyển sang màn hình Lịch sử giao dịch, lệnh kiểm tra:
    ```
    assert "Mua sách tham khảo" is visible
    ```
    **FAILED!** Giao diện không tìm thấy dòng chữ "Mua sách tham khảo" do dữ liệu không được ghi vào Firestore.
  - MobAI thông báo lỗi rõ ràng và dừng bài test, **không tự ý chữa lành quanh lỗi**.
- **Khắc phục lỗi & Chạy lại:**
  - Bỏ comment, khôi phục lại dòng lệnh lưu dữ liệu thực tế:
    ```dart
    final docId = await _firestoreService.addTransaction(_userId, tx);
    ```
  - Chạy lại kịch bản `06_crud_transaction.mob` -> **PASS 100%**.
- **Kết luận:** Bộ kịch bản kiểm thử có độ tin cậy cao, kiểm tra chính xác kết quả đầu ra trực quan (Visible Outcome) và bắt được lỗi logic thực tế.

