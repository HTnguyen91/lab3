# Phân Tích Khoảng Trống Handoff (Handoff Gaps) — Expense Tracker

**Môn học:** PRM393 — Mobile Programming  
**Dự án:** Lab 3 — From Design to Working App with Flutter and Firebase  
**Sinh viên:** Hoàng Thanh Nguyên (SE180338)  
**Nhóm Lab 2:** GR5  

---

## 1. Giới thiệu
Tài liệu này ghi nhận trung thực các điểm chưa rõ ràng, thiếu sót hoặc mâu thuẫn được phát hiện khi chuyển giao đặc tả kỹ thuật từ Lab 2 (`DESIGN.md`, `user-flow.md`, prototype) sang mã nguồn Flutter thực tế trong Lab 3, kèm theo giải pháp xử lý cụ thể.

---

## 2. Danh sách khoảng trống & Cách xử lý

| # | Hạng mục | Vấn đề trong Lab 2 Handoff | Ảnh hưởng khi code Flutter | Giải pháp xử lý trong Lab 3 |
|---|---|---|---|---|
| **GAP-01** | **Xử lý số tiền âm / dương** | Handoff chỉ ghi hiển thị `45.000 VNĐ`, chưa quy định rõ lưu trữ `amount` trong Database là số âm hay số dương kèm cờ phân biệt. | Nếu lưu số âm, khi cộng dồn tổng chi dễ bị sai sót hoặc khó tính toán toán học. | Quy định `amount` luôn là số thực dương (`double > 0`), lưu kèm trường `type: 'expense' \| 'income'`. Tầng format (`Formatters.formatTransactionAmount`) tự động thêm tiền tố `−` hoặc `+` tương ứng. |
| **GAP-02** | **Bộ chọn danh mục (Category Picker)** | Lab 2 prototype chỉ có hình ảnh dropdown nhưng không định nghĩa cách lấy icon và màu của từng danh mục trong Flutter. | Thiếu mapping giữa tên danh mục và icon Material. | Tạo `CategoryModel` với `iconCodePoint` và `colorValue`. Cung cấp danh sách 8 danh mục mặc định (`AppConstants.defaultCategories`) kèm màu sắc chuẩn theo token. |
| **GAP-03** | **Định dạng tháng & lưu trữ Ngân sách** | Handoff ghi lọc theo tháng nhưng chưa chuẩn hóa chuỗi khóa (Key) của tháng (ví dụ: `11/2026` hay `2026-11` hay timestamp). | Trùng lặp hoặc không query được hạn mức ngân sách theo tháng. | Chuẩn hóa toàn bộ tháng thành định dạng `MM/yyyy` (chuẩn hiển thị tiếng Việt). Document ngân sách lưu trường `month: 'MM/yyyy'` kết hợp query Firestore kép `where('month').where('categoryId')`. |
| **GAP-04** | **Phân chia trạng thái Ngân sách tại mốc 100%** | Brief ghi: dưới 80% (Bình thường), 80-100% (Sắp chạm hạn mức), trên 100% (Vượt). Chưa nói rõ mốc đúng 100% hiển thị màu gì. | Gây phân vân trong logic điều kiện `if/else` của Widget thanh tiến độ. | Bổ sung trạng thái riêng `BudgetStatus.reached` (Đã chạm hạn mức) khi `ratio == 1.0` dùng màu cảnh báo đỏ/error, thanh dừng ở 100%. |
| **GAP-05** | **Xử lý khi ứng dụng chưa có dữ liệu (Empty State)** | Lab 2 chỉ phác thảo màn hình khi có dữ liệu, chưa thiết kế giao diện khi người dùng mới đăng nhập chưa có giao dịch nào. | Màn hình Trang chủ và Thống kê bị trống trải hoặc lỗi chia cho 0 (`NaN`). | Xây dựng reusable widget `EmptyStateWidget` có thông điệp hướng dẫn, đồng thời thêm nút "Tạo dữ liệu mẫu Lab 2" (`seedLab2Data`) để kiểm thử ngay lập tức. |
| **GAP-06** | **Xác thực người dùng & Bảo mật dữ liệu** | Lab 2 chỉ thiết kế giao diện cục bộ, chưa có luồng đăng nhập hay mô hình phân quyền dữ liệu. | Dữ liệu giao dịch của mọi người dùng có thể bị lẫn lộn nếu không thiết kế từ đầu. | Tích hợp Firebase Authentication với Google Sign-In (màn S09) và phân vùng Cloud Firestore theo `users/{uid}/transactions` và `users/{uid}/budgets` với Firestore Security Rules nghiêm ngặt. |

---

## 3. Đánh giá chất lượng Handoff Lab 2
- **Điểm mạnh:** Token màu sắc và cỡ chữ được xác định rất rõ ràng (`#1D4ED8`, `#F8FAFC`, `#B91C1C`, `#166534`), giúp cấu hình `ThemeData` nhanh chóng và chuẩn xác.
- **Điểm cần cải thiện:** Cần mô tả chi tiết hơn về cấu trúc dữ liệu Model, kiểu dữ liệu trường và các trạng thái ngoại lệ (Empty State, Error State) ngay trong giai đoạn thiết kế UI/UX.

