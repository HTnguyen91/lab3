# Báo Cáo Kiểm Tra Độ Chuẩn Xác Thiết Kế (Design Fidelity Check) — Expense Tracker

**Môn học:** PRM393 — Mobile Programming  
**Dự án:** Lab 3 — From Design to Working App with Flutter and Firebase  
**Sinh viên:** Hoàng Thanh Nguyên (SE180338)  

---

## 1. Giới thiệu
Tài liệu đối chiếu độ trung thực giữa bản thiết kế Lab 2 và ứng dụng Flutter thực tế trên môi trường Android (kích thước chuẩn 360 × 800 dp đến 390 × 844 dp). Báo cáo đánh giá minh bạch trên 5 tiêu chí: So sánh màn hình, Token màu/chữ, Reusable component, Xử lý trạng thái và Khả năng tiếp cận (Accessibility).

---

## 2. So sánh màn hình thực tế (Screen Comparison)

| Mã màn | Tên màn hình | Mức độ khớp (%) | Điểm khác biệt so với Lab 2 | Nguyên nhân & Biện pháp xử lý |
|---|---|---|---|---|
| **S01** | **Trang chủ** | 98% | Thêm banner mẹo tài chính nhỏ ở đầu màn hình và avatar trên AppBar. | Tích hợp tính năng Firebase Remote Config và điểm truy cập Profile theo yêu cầu Lab 3. Bố cục tổng quan và nút "Thêm khoản chi" giữ nguyên 100%. |
| **S02** | **Thêm giao dịch** | 96% | Bổ sung nút chuyển đổi tab "Khoản chi" / "Khoản thu". | Hỗ trợ thêm cả thu nhập thực tế. Trường hợp lỗi số tiền và thiếu danh mục hiển thị chính xác câu chữ theo `DESIGN.md`. |
| **S03** | **Lịch sử giao dịch** | 95% | Thêm thanh tìm kiếm và bộ lọc chip ở trên cùng. | Giúp người dùng dễ tra cứu khi có nhiều giao dịch. Danh sách nhóm theo ngày và số tiền căn phải đúng chuẩn. |
| **S04** | **Chi tiết giao dịch** | 97% | Thêm nút "Chỉnh sửa ghi chú" và nút "Xóa giao dịch". | Đáp ứng yêu cầu CRUD đầy đủ cho thực thể chính theo Mục 6.3. |
| **S05** | **Thống kê** | 98% | Biểu đồ thanh ngang kèm số tiền và tỷ lệ phần trăm bằng chữ. | Khớp hoàn toàn với mô tả của Persona Ngọc Linh (P02). Trạng thái tháng trống hiển thị đúng thông điệp. |
| **S06** | **Chi tiêu theo danh mục** | 99% | Giữ đúng danh mục và tháng đã chọn, hiển thị danh sách các khoản chi. | Khớp hoàn toàn đặc tả con của S05. |
| **S07** | **Ngân sách** | 98% | Thẻ ngân sách có thanh tiến độ 4 trạng thái: Xanh (<80%), Vàng cam (80-100%), Đỏ (>100%). | Thể hiện chính xác yêu cầu trực quan của Persona Quốc Huy (P03). |
| **S08** | **Tạo ngân sách** | 99% | Đầy đủ trường chọn tháng, danh mục, nhập hạn mức, nút chính "Lưu ngân sách" và nút phụ "Hủy". | Khớp 100% với kịch bản UF-03. |
| **S09** | **Đăng nhập** | N/A (Mới) | Màn hình đăng nhập Google Sign-In kèm logo và giới thiệu ngắn. | Màn hình mới được bổ sung theo Mục 6.2 của Lab 3. |
| **S10** | **Hồ sơ cá nhân** | N/A (Mới) | Hồ sơ, Notification Center, điều khiển Remote Config, Crashlytics, Xuất PDF. | Màn hình mới được bổ sung theo Mục 6 của Lab 3. |

---

## 3. Kiểm tra Design Tokens (Token Check)

Toàn bộ thuộc tính giao diện được tập trung tại thư mục `lib/theme/`:
- **Màu sắc (`AppColors`):** 
  - Không tồn tại mã màu hard-coded rải rác ngoài file theme.
  - Primary: `#1D4ED8`, Background: `#F8FAFC`, Surface: `#FFFFFF`, Income: `#166534`, Expense: `#B91C1C`, Warning: `#92400E`.
- **Kiểu chữ (`AppTextStyles`):**
  - Số tiền nổi bật: Size 32, Weight 700.
  - Tiêu đề màn hình: Size 24, Weight 700.
  - Tiêu đề nhóm: Size 18, Weight 600.
  - Nội dung: Size 16, Weight 400.
  - Nút bấm & Nhãn: Size 14, Weight 600.
  - Chú thích: Size 12, Weight 500.
- **Khoảng cách & Bo góc (`AppSpacing`):**
  - Thang đo chuẩn: `4, 8, 12, 16, 24, 32 dp`.
  - Lề ngang: `16.0 dp`. Bo góc card: `16.0 dp`. Bo góc button/input: `12.0 dp`.

---

## 4. Kiểm tra Thành phần tái sử dụng (Component Check)

Mọi thành phần UI được mô đun hóa thành các widget độc lập trong `lib/widgets/`:
1. `PrimaryButton`: Nút chính đồng nhất chiều cao 52 dp, hiệu ứng xoay tròn và nhãn "Đang lưu…" khi xử lý bất đồng bộ.
2. `SecondaryButton`: Nút viền phụ, thao tác "Hủy" hoặc "Chỉnh sửa".
3. `OverviewCard`: Thẻ tổng hợp ngân sách tháng còn lại / tổng chi hôm nay.
4. `TransactionRow`: Dòng hiển thị giao dịch có icon bo góc, danh mục, ghi chú và số tiền màu phân biệt thu/chi.
5. `CategoryBar`: Thanh ngang đo lường tỷ trọng danh mục kèm nhãn số tiền.
6. `BudgetCard`: Thẻ tiến độ ngân sách 4 mức cảnh báo trực quan.
7. `EmptyStateWidget`: Trạng thái rỗng chuẩn hóa cho các màn hình.
8. `InputField`: Ô nhập dữ liệu có nhãn cố định và vùng hiển thị lỗi chuẩn.

---

## 5. Kiểm tra Trạng thái (State Check)
- **Loading State:** Các thao tác tải dữ liệu từ Firestore có `CircularProgressIndicator`. Khi bấm lưu, nút hiển thị vòng xoay và khóa tương tác chống bấm đúp.
- **Empty State:** Khi tháng chưa có giao dịch hoặc chưa tạo hạn mức ngân sách, hệ thống hiển thị thông báo hướng dẫn cụ thể kèm nút tạo dữ liệu mẫu nhanh.
- **Error State:** Khi người dùng nhập số tiền trống hoặc bằng 0, thông báo lỗi xuất hiện ngay dưới ô nhập liệu và giữ nguyên dữ liệu các trường khác.

---

## 6. Kiểm tra Khả năng tiếp cận (Accessibility Check)
- **Tương phản màu sắc:** Tỷ lệ tương phản chữ trên nền đạt tối thiểu `4.8:1` (Text Primary `#0F172A` trên Background `#F8FAFC`), vượt ngưỡng chuẩn WCAG AA (4.5:1).
- **Vùng chạm tối thiểu (Touch Target):** Mọi nút bấm, ô nhập liệu và thẻ danh sách đều có chiều cao `>= 48 dp` (chiều cao nút thực tế là `52 dp`).
- **Khả năng co giãn màn hình:** Ứng dụng đã được kiểm thử bố cục mượt mà trên cả chiều rộng hẹp `360 dp` (Android tiêu chuẩn) và `412 dp` (màn hình lớn), nội dung tự động xuống dòng và cuộn trơn tru, không xảy ra hiện tượng tràn màn hình (Overconstrained / Overflow).

