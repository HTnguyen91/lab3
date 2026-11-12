# Báo Cáo Đánh Giá Mã Nguồn Với AI (AI-Assisted Code Review) — Expense Tracker

**Môn học:** PRM393 — Mobile Programming  
**Dự án:** Lab 3 — From Design to Working App with Flutter and Firebase  
**Sinh viên:** Hoàng Thanh Nguyên (SE180338)  
**Nhánh kiểm tra (Feature branch):** `feature/firebase-mvvm-implementation`  
**Pull Request:** PR #1 vào nhánh `main`  

---

## 1. Giới thiệu
Tài liệu ghi lại kết quả rà soát mã nguồn tự động bằng công cụ AI Code Review (GitHub Copilot / CodeRabbit AI) trên Pull Request. Báo cáo ghi nhận tối thiểu 3 phát hiện chất lượng, bao gồm vấn đề an ninh bảo mật, giải pháp xử lý và mã nguồn trước/sau khi sửa.

---

## 2. Danh sách phát hiện từ công cụ Code Review

### Phát hiện 01 (Bảo mật & Quy tắc An ninh Firestore)
- **Công cụ phát hiện:** Code Review AI
- **Tệp & Dòng:** [`firebase/firestore.rules`](../firebase/firestore.rules) (Dòng 12-25)
- **Mô tả vấn đề:** 
  > *"Trong các subcollection như `transactions`, `budgets`, nếu chỉ kiểm tra `request.auth.uid == userId` mà không kiểm tra thêm kiểu dữ liệu của payload ghi (ví dụ: `request.resource.data.amount is number && request.resource.data.amount > 0`), người dùng có thể gửi dữ liệu bị lỗi kiểu dữ liệu hoặc số âm trực tiếp qua SDK bypass UI validation."*
- **Đánh giá mức độ nghiêm trọng (Severity):** **Cao (High - Security & Data Integrity)**
- **Quyết định:** **Chấp nhận (Accepted)**.
- **Lý do:** Ràng buộc chặt chẽ dữ liệu ngay tại tầng cơ sở dữ liệu Firestore Rules giúp ngăn chặn việc inject dữ liệu sai lệch từ các client ngoài luồng.
- **Mã nguồn trước và sau khi khắc phục:**
  - *Trước (Before):*
    ```javascript
    match /transactions/{transactionId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    ```
  - *Sau (After):*
    ```javascript
    match /transactions/{transactionId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      allow create, update: if request.auth != null && request.auth.uid == userId
                            && request.resource.data.amount is number
                            && request.resource.data.amount > 0;
    }
    ```

---

### Phát hiện 02 (Bảo mật & Xử lý Ngoại lệ Tải Tệp)
- **Công cụ phát hiện:** Code Review AI
- **Tệp & Dòng:** [`lib/services/pdf_export_service.dart`](../lib/services/pdf_export_service.dart) (Dòng 195-215)
- **Mô tả vấn đề:** 
  > *"Khi tải tệp PDF lên dịch vụ lưu trữ đám mây Cloudinary qua HTTP Multipart, ứng dụng đang sử dụng `http.MultipartRequest` trực tiếp mà không thiết lập thời gian chờ (`timeout`). Trong trường hợp mạng di động yếu hoặc mất kết nối đột ngột, tác vụ có thể bị treo vô hạn dẫn đến trạng thái 'Đang tạo và tải lên...' không bao giờ kết thúc trên UI."*
- **Đánh giá mức độ nghiêm trọng (Severity):** **Trung bình (Medium - Robustness & UX)**
- **Quyết định:** **Chấp nhận (Accepted)**.
- **Lý do:** Cần bọc cơ chế `.timeout(const Duration(seconds: 20))` kèm theo khối `try/catch` có xử lý fallback URL để giao diện người dùng luôn nhận được phản hồi rõ ràng.
- **Mã nguồn trước và sau khi khắc phục:**
  - *Trước (Before):*
    ```dart
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    ```
  - *Sau (After):*
    ```dart
    final streamedResponse = await request.send().timeout(const Duration(seconds: 20));
    final response = await http.Response.fromStream(streamedResponse).timeout(const Duration(seconds: 20));
    ```

---

### Phát hiện 03 (Hiệu năng & Memory Leak trong ViewModel)
- **Công cụ phát hiện:** Code Review AI
- **Tệp & Dòng:** [`lib/viewmodels/transaction_viewmodel.dart`](../lib/viewmodels/transaction_viewmodel.dart) (Dòng 30-45)
- **Mô tả vấn đề:** 
  > *"Class `TransactionViewModel` lắng nghe luồng Firestore `_firestoreService.streamTransactions(_userId).listen(...)`. Khi người dùng đăng xuất và đổi tài khoản khác, nếu subscription cũ không được hủy trước khi khởi tạo subscription mới, có thể gây rò rỉ bộ nhớ (Memory Leak) hoặc callback chồng chéo dữ liệu của hai tài khoản khác nhau."*
- **Đánh giá mức độ nghiêm trọng (Severity):** **Trung bình (Medium - Robustness)**
- **Quyết định:** **Chấp nhận (Accepted)**.
- **Lý do:** Gọi lệnh `_subscription?.cancel()` ngay tại hàm `_initStream()` trước khi đăng ký luồng mới và đảm bảo hủy trong hàm `dispose()`.
- **Mã nguồn trước và sau khi khắc phục:**
  - *Trước (Before):*
    ```dart
    void _initStream() {
      _subscription = _firestoreService.streamTransactions(_userId).listen(...);
    }
    ```
  - *Sau (After):*
    ```dart
    void _initStream() {
      _subscription?.cancel(); // Đảm bảo hủy luồng trước khi gán mới
      _subscription = _firestoreService.streamTransactions(_userId).listen(...);
    }
    ```

---

## 3. Tổng kết
Cả 3 phát hiện liên quan trực tiếp đến an ninh dữ liệu Firestore, tính bền vững khi tương tác mạng và quản lý vòng đời bộ nhớ đều đã được rà soát, đồng ý và khắc phục triệt để trong mã nguồn của ứng dụng.

