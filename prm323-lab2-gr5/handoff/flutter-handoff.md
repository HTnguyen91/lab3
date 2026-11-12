# handoff/flutter-handoff.md — Expense Tracker (Quản Lý Thu Chi)

**Môn học:** PRM393 — Mobile Programming  
**Nhóm:** GR5  
**Phiên bản:** 1.0 · Tháng 11/2026  
**Nền tảng:** Flutter (Android · Màn hình chuẩn 390 × 844 dp, responsive 360–412 dp)  
**Kiến trúc:** MVVM (Model - View - ViewModel) với `provider`  
**Bộ nhận diện:** Material 3 · Light Theme · Primary `#1D4ED8` · Font Roboto / Inter  

---

## 1. Tổng Quan và Cấu Trúc Dự Án Flutter

Ứng dụng phục vụ 3 chân dung người dùng chính:
- **P01 (Nguyễn Minh Anh):** Ghi nhanh khoản chi trong 15 giây, kiểm tra ngân sách tháng còn lại.
- **P02 (Trần Ngọc Linh):** Xem thống kê chi tiêu theo danh mục, nhận diện khoản chi lớn nhất.
- **P03 (Lê Quốc Huy):** Thiết lập hạn mức ngân sách cho từng danh mục, theo dõi cảnh báo khi vượt 80% / 100%.

### Cấu trúc mã nguồn Flutter (`lib/`)
```
lib/
├── main.dart                      # Khởi tạo App, Firebase, Provider MultiProvider
├── firebase_options.dart          # Cấu hình Firebase generated
├── theme/
│   ├── app_colors.dart            # Toàn bộ design token mã màu (Primary, Income, Expense, v.v.)
│   ├── app_text_styles.dart       # Định nghĩa TextStyle chuẩn kích thước và độ đậm
│   ├── app_theme.dart             # ThemeData Material 3 tích hợp đầy đủ tokens
│   └── app_spacing.dart           # Khoảng cách 4, 8, 12, 16, 24, 32 dp & Radius
├── models/
│   ├── transaction_model.dart     # Giao dịch thu/chi (to/from Firestore)
│   ├── budget_model.dart          # Hạn mức ngân sách danh mục
│   ├── category_model.dart        # Danh mục thu/chi kèm icon và màu
│   ├── notification_item.dart     # Thông báo FCM lưu trữ nội bộ
│   └── report_model.dart          # Metadata báo cáo PDF đã xuất
├── services/
│   ├── auth_service.dart          # Firebase Auth + Google Sign-In
│   ├── firestore_service.dart     # Thao tác CRUD Cloud Firestore scoped users/{uid}/...
│   ├── fcm_service.dart           # Firebase Cloud Messaging & Notification handler
│   ├── remote_config_service.dart # Firebase Remote Config fetch & fallback
│   ├── crashlytics_service.dart   # Crashlytics log exception & test crash
│   ├── analytics_service.dart     # Firebase Analytics logging các custom events
│   └── pdf_export_service.dart    # Sinh PDF báo cáo & upload Cloudinary / Storage
├── viewmodels/
│   ├── auth_viewmodel.dart        # Trạng thái đăng nhập, profile, signout
│   ├── transaction_viewmodel.dart # Lịch sử, thêm/sửa/xóa, lọc giao dịch, tính tổng hôm nay
│   ├── budget_viewmodel.dart      # Ngân sách tháng, tính tỷ lệ %, cảnh báo hạn mức
│   ├── statistics_viewmodel.dart  # Tổng hợp thu chi theo tháng, chi tiêu theo danh mục
│   └── settings_viewmodel.dart    # Quản lý Remote Config, thông báo, xuất file PDF
├── screens/
│   ├── s01_home_screen.dart       # Trang chủ: Ngân sách còn lại, chi tiêu hôm nay, quick action
│   ├── s02_add_transaction_screen.dart # Thêm giao dịch: Form nhập tiền, danh mục, ngày, note
│   ├── s03_history_screen.dart    # Lịch sử giao dịch theo ngày
│   ├── s04_detail_screen.dart     # Chi tiết giao dịch + sửa/xóa
│   ├── s05_statistics_screen.dart # Thống kê tổng hợp & biểu đồ cột ngang danh mục
│   ├── s06_category_detail_screen.dart # Chi tiết chi tiêu theo danh mục đã chọn
│   ├── s07_budget_screen.dart     # Danh sách ngân sách các danh mục trong tháng
│   ├── s08_create_budget_screen.dart # Form tạo/chỉnh sửa hạn mức ngân sách
│   ├── s09_login_screen.dart      # Màn hình đăng nhập Google
│   └── s10_profile_screen.dart    # Hồ sơ, Notification Center, Remote Config & Crashlytics Demo
├── widgets/
│   ├── primary_button.dart        # Nút chính chuẩn 48dp, Primary color, loading state
│   ├── secondary_button.dart      # Nút phụ Hủy / Quay lại
│   ├── overview_card.dart         # Thẻ ngân sách tháng còn lại / tổng chi
│   ├── transaction_row.dart       # Hàng giao dịch danh sách (icon, tên, ngày, tiền +/-)
│   ├── category_bar.dart          # Thanh ngang biểu đồ chi tiêu danh mục
│   ├── budget_card.dart           # Thẻ ngân sách với thanh progress bar 4 mức trạng thái
│   └── empty_state.dart           # Trạng thái trống minh họa đẹp mắt
└── utils/
    ├── formatters.dart            # Format tiền tệ VNĐ (45.000 VNĐ) và ngày dd/MM/yyyy
    └── constants.dart             # Danh mục mặc định, key cấu hình
```

---

## 2. Design Tokens sang Flutter Theme

### Bảng Token Màu Sắc (`AppColors`)
| Token Name | Giá Trị HEX | Color trong Flutter | Ứng Dụng |
|---|---|---|---|
| Primary | `#1D4ED8` | `Color(0xFF1D4ED8)` | Nút bấm chính, tab đang chọn, viền focus |
| On Primary / Surface | `#FFFFFF` | `Color(0xFFFFFFFF)` | Nền thẻ (Card), ô nhập liệu, chữ trên nút chính |
| Primary Tint | `#EFF6FF` | `Color(0xFFEFF6FF)` | Nền mục đang chọn, thẻ ngân sách nổi bật |
| Background | `#F8FAFC` | `Color(0xFFF8FAFC)` | Nền toàn bộ ứng dụng |
| Text Primary | `#0F172A` | `Color(0xFF0F172A)` | Tiêu đề màn hình, số tiền, text quan trọng |
| Text Secondary | `#475569` | `Color(0xFF475569)` | Nhãn phụ, ghi chú, ngày giao dịch, placeholder |
| Divider / Border | `#E2E8F0` | `Color(0xFFE2E8F0)` | Đường phân cách thẻ, viền ô nhập mặc định |
| Success / Income | `#166534` | `Color(0xFF166534)` | Khoản thu (+), xác nhận thành công |
| Warning | `#92400E` | `Color(0xFF92400E)` | Ngân sách sắp chạm hạn mức (80% - 100%) |
| Error / Expense | `#B91C1C` | `Color(0xFFB91C1C)` | Khoản chi (-), thông báo lỗi, vượt hạn mức (>100%) |

### Thang Khoảng Cách & Bo Góc (`AppSpacing`)
- Spacing: `4.0`, `8.0`, `12.0`, `16.0`, `24.0`, `32.0` dp
- Lề chuẩn màn hình: `16.0` dp
- Bo góc thẻ: `16.0` dp (`BorderRadius.circular(16)`)
- Bo góc nút bấm & ô nhập liệu: `12.0` dp (`BorderRadius.circular(12)`)
- Chiều cao nút bấm và ô nhập tối thiểu: `48.0` dp - `52.0` dp (Vùng chạm tối thiểu >= 48x48 dp)

### Kiểu Chữ (`AppTextStyles`)
- **Số tiền nổi bật:** Size 32, Height 1.25 (40dp), FontWeight 700 (Bold)
- **Tiêu đề màn hình:** Size 24, Height 1.33 (32dp), FontWeight 700 (Bold)
- **Tiêu đề nhóm:** Size 18, Height 1.33 (24dp), FontWeight 600 (SemiBold)
- **Nội dung thường:** Size 16, Height 1.5 (24dp), FontWeight 400 (Regular)
- **Nút bấm & Nhãn ô nhập:** Size 14, Height 1.43 (20dp), FontWeight 600 (SemiBold)
- **Chú thích:** Size 12, Height 1.33 (16dp), FontWeight 500 (Medium)

---

## 3. Quy Tắc Giao Diện & Tương Tác Các Màn Hình

1. **S01 — Trang chủ:**
   - Thẻ nổi bật đầu màn hình: "Ngân sách tháng còn lại" (mặc định tháng hiện tại).
   - "Tổng chi hôm nay" kèm nút chính to rõ: "Thêm khoản chi" (dẫn trực tiếp sang S02).
   - Danh sách "Giao dịch gần đây" (5 mục mới nhất) và "Xem tất cả" mở S03.
   - BottomNavigationBar: 4 tab cố định: Trang chủ (0), Lịch sử (1), Thống kê (2), Ngân sách (3). Header có avatar mở Profile (S10).

2. **S02 — Thêm giao dịch:**
   - Segmented Button / Tab chọn: "Khoản chi" (mặc định) hoặc "Khoản thu".
   - Ô số tiền: Bàn phím số `keyboardType: TextInputType.number`, hậu tố "VNĐ".
   - Dropdown hoặc danh sách chọn Danh mục trực quan (Ăn uống, Đi lại, Mua sắm, Hóa đơn, Tiền lương, v.v.).
   - Bộ chọn ngày `DatePicker`, mặc định ngày hiện tại.
   - Ô nhập ghi chú tùy chọn.
   - Nút chính: "Lưu giao dịch". Khi bấm, chuyển thành "Đang lưu…" và vô hiệu hóa chống click đúp. Khi thành công quay về S01 và hiển thị SnackBar thông báo.

3. **S03 — Lịch sử giao dịch & S04 — Chi tiết giao dịch:**
   - Danh sách nhóm theo ngày (ví dụ: Hôm nay - 12/11/2026, Hôm qua - 11/11/2026).
   - Tiền chi có dấu "−" màu đỏ, tiền thu có dấu "+" màu xanh. Căn phải rõ ràng.
   - Chạm vào dòng giao dịch để mở S04 xem chi tiết; S04 cung cấp nút Sửa và nút Xóa (có hộp thoại xác nhận).

4. **S05 — Thống kê & S06 — Chi tiêu theo danh mục:**
   - Bộ lọc chọn Tháng (`MM/yyyy`).
   - Thẻ tổng hợp: Tổng thu, Tổng chi, Số dư thực tế.
   - Danh sách thanh ngang (Horizontal Bar Chart) biểu thị tỷ trọng chi tiêu của các danh mục, sắp xếp từ cao xuống thấp.
   - Nhấn vào từng danh mục sẽ điều hướng sang S06, hiển thị toàn bộ giao dịch của danh mục đó trong tháng.
   - Nếu tháng chưa có dữ liệu: Hiển thị Empty State "Chưa có khoản chi trong tháng này. Chọn tháng khác để xem thống kê."

5. **S07 — Ngân sách & S08 — Tạo ngân sách:**
   - S07 liệt kê các thẻ ngân sách theo danh mục: Hiển thị Hạn mức, Đã chi, Còn lại và thanh tiến độ màu sắc (Xanh dưới 80%, Cam 80%-100%, Đỏ trên 100%).
   - Nút "Tạo ngân sách" mở S08.
   - S08 cho phép chọn tháng, danh mục và nhập hạn mức. Nút chính "Lưu ngân sách", nút phụ "Hủy".

6. **S09 — Đăng nhập & S10 — Hồ sơ cá nhân (Mở rộng cho Lab 3):**
   - S09: Giao diện đăng nhập Google Sign-In chuẩn Google branding.
   - S10: Hiển thị Avatar Google, Tên, Email, nút Đăng xuất. Tích hợp Notification Center, Remote Config test panel, Crashlytics test buttons, và Export PDF Report.

