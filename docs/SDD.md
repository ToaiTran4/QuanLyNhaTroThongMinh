# TÀI LIỆU THIẾT KẾ HỆ THỐNG
### (System Design Document - SDD)
## Hệ thống Quản lý Nhà trọ Thông minh - Nền tảng SaaS đa chủ trọ
**Phiên bản 1.0**
Ngày: 02/07/2026
Nguồn: BRD v1.5, SRS v2.0 (63 FR, 9 NFR) + 4 giá trị mặc định bổ sung đã chốt trước khi thiết kế.

---

## 0. Giá trị mặc định áp dụng trong thiết kế (chưa có trong SRS v2.0)

| # | Nội dung | Áp dụng tại |
|---|---|---|
| 1 | Thời gian chờ xác minh chỉ số (BR-08c) mặc định = **1 giờ** | `tenant_settings.verification_timeout_minutes` default 60 |
| 2 | Ngày tạo hóa đơn (BR-12) mặc định = **ngày 1 hàng tháng** | `tenant_settings.invoice_day_of_month` default 1 |
| 3 | Hóa đơn nháp (BR-11a) quá **2 kỳ liên tiếp** chưa bổ sung chỉ số → cảnh báo riêng + cho phép chủ trọ tự nhập chỉ số thay | Job định kỳ `stale-draft-invoice-scan`, mục HLD 4 và API `invoice-service` |
| 4 | Hợp đồng chấm dứt khi còn Adjustment (BR-12c) chưa dồn vào hóa đơn nào → gộp vào bước xử lý cọc (FR-019/FR-023) | Luồng (c) mục HLD 3, bảng `invoice_adjustments.status = included_in_deposit_settlement` |

---

## HLD — High-Level Design

### 1. Sơ đồ kiến trúc tổng thể

```
                              ┌───────────────────────────────┐
                              │   CloudFront + S3 (React SPA)   │   (ngoài phạm vi SDD backend)
                              └────────────────┬────────────────┘
                                                │ HTTPS + JWT (Cognito)
                                                ▼
                              ┌───────────────────────────────┐
                              │  Amazon API Gateway (REST)      │
                              │  Cognito Authorizer → JWT claims │
                              │  (role, owner_id/contract_id)    │
                              └───┬────┬────┬────┬────┬────┬────┘
             ┌───────────────────┘    │    │    │    │    └───────────────────┐
             ▼                        ▼    ▼    ▼    ▼                        ▼
     ┌──────────────┐   ┌──────────┐ ... (7 service khác, xem Mục 2) ...  ┌──────────────┐
     │ auth-service │   │room-svc  │                                     │notification- │
     │  (Lambda)    │   │(Lambda)  │                                     │  service     │
     └──────┬───────┘   └────┬─────┘                                     └──────┬───────┘
            │                │                                                  │
            └────────────────┴─────────────────┬────────────────────────────────┘
                                                 ▼
                                     ┌───────────────────────┐
                                     │      RDS Proxy          │  (connection pooling,
                                     └────────────┬────────────┘   IAM auth, giảm cold-start
                                                  ▼                 connection storm)
                                     ┌───────────────────────┐
                                     │ RDS PostgreSQL Multi-AZ │
                                     │  (Row-Level Security)   │
                                     └───────────────────────┘

── Nhánh BẤT ĐỒNG BỘ: chụp ảnh chỉ số → OCR ────────────────────────────────────────

Người thuê ──POST /readings──▶ API GW ──▶ utility-service "upload-reading"
                                                │  (trả ngay 202 + reading_id, KHÔNG chờ OCR)
                                                ▼
                                     ┌───────────────────────┐
                                     │ S3 bucket "readings-img"│
                                     └────────────┬────────────┘
                                                  │ S3 Event: ObjectCreated
                                                  ▼
                                     ┌───────────────────────┐
                                     │  SQS "ocr-queue" (+DLQ)  │  ← cách ly tải OCR khỏi
                                     └────────────┬────────────┘     luồng đồng bộ (NFR-01/03)
                                                  ▼
                                     ┌───────────────────────┐
                                     │ Lambda "ocr-processor"  │──▶ Amazon Textract
                                     │ (reserved concurrency   │    (AnalyzeDocument -
                                     │  riêng, tách khỏi pool  │     FORMS/QUERIES hoặc
                                     │  Lambda đồng bộ)         │     DetectDocumentText)
                                     └────────────┬────────────┘
                                                  ▼ UPDATE utility_readings qua RDS Proxy
                                     ┌───────────────────────┐
                                     │ status: ocr_done         │
                                     └────────────┬────────────┘
                                                  ▼
                              Client GET /readings/{id} (polling, xem đánh đổi Mục 3.a)

── Tác vụ định kỳ (EventBridge Scheduler) ──────────────────────────────────────────
EventBridge rule ──▶ Lambda (trong service tương ứng) ──▶ RDS Proxy ──▶ RDS
                 └─▶ (một số job phát sự kiện nội bộ EventBridge Bus để
                      notification-service gửi SES/in-app)
```

**Lựa chọn OCR: Amazon Textract (AnalyzeDocument), không dùng Rekognition.**
Lý do: chỉ số đồng hồ điện/nước là **chuỗi ký tự số in trên bảng cơ khí**, đây đúng là bài toán OCR có cấu trúc (document text/number extraction) mà Textract được tối ưu (kể cả ảnh chụp nghiêng, độ phân giải thấp qua điện thoại). Rekognition thiên về nhận diện đối tượng/khuôn mặt/nhãn cảnh, không có mô hình chuyên biệt đọc số đồng hồ tốt bằng Textract; dùng Rekognition sẽ cần tự huấn luyện custom label, tốn chi phí không hợp lý cho MVP.

### 2. Danh sách Lambda service (9 service)

| # | Service | Chịu trách nhiệm (FR) | Lý do ranh giới |
|---|---|---|---|
| 1 | **auth-service** | FR-007, FR-008, FR-052, FR-053, FR-054 | Vòng đời tài khoản & xác thực là mối quan tâm xuyên suốt (cross-cutting), không phụ thuộc domain nghiệp vụ cụ thể; tách riêng để tập trung logic Cognito, JWT claim (role, owner_id, contract_id). |
| 2 | **room-service** | FR-001, FR-002, FR-003 | Entity đơn giản, ranh giới rõ theo "phòng"; FR-002 (đồng bộ trạng thái theo hợp đồng) vẫn đặt ở đây nhưng được **gọi nội bộ** từ contract-service khi hợp đồng đổi trạng thái. |
| 3 | **contract-service** | FR-004, FR-005, FR-006, FR-009→FR-011, FR-013→FR-017, FR-019, FR-022, FR-023, FR-024, FR-056 | Hồ sơ người đại diện (tenant_profile) chỉ tồn tại gắn 1-1 với hợp đồng nên gộp chung để tránh distributed transaction giữa 2 service khi tạo hợp đồng mới. Toàn bộ vòng đời hợp đồng (chấm dứt, cọc, nợ dồn kỳ) là một domain nghiệp vụ phức tạp, cần transaction nội bộ chặt (đặc biệt bước "Đã chấp nhận" không thể đảo ngược). |
| 4 | **config-service** | FR-012, FR-018, FR-020, FR-021, FR-030, FR-040, FR-044 | Toàn bộ tham số scalar cấp chủ trọ (Y, X2, ngưỡng vi phạm, phương án cọc, thời gian thuê tối thiểu, chế độ xác minh, ngày tạo hóa đơn, chế độ thanh toán) gom một nơi để NFR-05 (cấu hình theo từng chủ trọ) có một nguồn sự thật duy nhất; các service khác đọc qua lời gọi nội bộ (Lambda invoke trực tiếp, không qua API Gateway, để giảm độ trễ). |
| 5 | **utility-service** | FR-025→FR-029, FR-031→FR-035, FR-058 | Domain phức tạp nhất, có đặc thù xử lý bất đồng bộ (OCR) khác hẳn phần còn lại → cô lập để không ảnh hưởng NFR-01/03 của các service khác (xem Mục 4). |
| 6 | **invoice-service** | FR-036→FR-039, FR-041→FR-047, FR-050, FR-057 | Trung tâm tính toán tài chính; gộp cả báo cáo (FR-050) vì báo cáo chủ yếu tổng hợp dữ liệu hóa đơn/công nợ, tránh join xuyên service. |
| 7 | **repair-service** | FR-048, FR-049 | Domain độc lập, không phụ thuộc luồng tài chính. |
| 8 | **chat-service** | FR-059 (phần chat), FR-060, FR-061 | Tách riêng vì có thể cần mở rộng real-time (WebSocket API Gateway) độc lập với REST API các service khác trong tương lai. |
| 9 | **notification-service** | FR-062, FR-063, FR-017 (nhắc nhở), FR-026 (nhắc chụp ảnh) | Điểm tổng hợp gửi in-app/email; các service khác **không tự gửi email/SES**, mà publish sự kiện (EventBridge custom bus hoặc lời gọi nội bộ) cho notification-service xử lý, tránh trùng lặp logic gửi thông báo ở 8 service còn lại. |

> FR-051 (kiểm soát phạm vi truy cập) và FR-055 (soft delete) là ràng buộc áp dụng **xuyên suốt mọi service**, không phải một service riêng — xem Mục 4 (NFR-02) và DB Design Mục 4.

### 3. Luồng xử lý chi tiết — 3 use case phức tạp nhất

#### (a) Chụp ảnh → OCR → xác nhận/xác minh → phát hành hóa đơn (FR-026→FR-038)

1. **EventBridge rule `reading-reminder`** (chạy hàng ngày, xem Mục 4) → notification-service gửi nhắc người thuê chụp ảnh (FR-026), kích hoạt trước ngày tạo hóa đơn (config-service cung cấp `invoice_day_of_month`).
2. Người thuê gọi `POST /readings` (utility-service) kèm ảnh (multipart hoặc presigned S3 URL 2 bước). utility-service tạo bản ghi `utility_readings(status=pending_ocr)`, lưu ảnh vào S3 bucket riêng, **trả về ngay `202 Accepted` kèm `reading_id`** — không chờ OCR (đáp ứng NFR-01).
3. S3 event `ObjectCreated` → SQS `ocr-queue` → Lambda `ocr-processor` gọi Textract, ghi kết quả `ocr_raw_value` vào bản ghi, chuyển `status=ocr_done`.
4. Client poll `GET /readings/{id}` cho tới khi thấy `ocr_done` (xem đánh đổi bên dưới).
5. Người thuê `PATCH /readings/{id}/confirm`:
   - Giữ nguyên giá trị OCR → `status=confirmed` ngay (FR-028 nhánh 1), utility-service phát sự kiện nội bộ `reading.confirmed`.
   - Sửa lại giá trị → `status=needs_verification` (FR-029), kèm ảnh gốc + `ocr_raw_value` + giá trị người thuê nhập để đối chiếu.
6. Trước khi chấp nhận giá trị (dù confirmed hay needs_verification), utility-service luôn gọi kiểm tra FR-035 (giá trị mới ≥ kỳ trước, lấy từ bản ghi `utility_readings` gần nhất cùng `room_id`).
7. Nếu `needs_verification`: utility-service gọi config-service lấy `verification_mode`:
   - **skip** → tự chuyển `status=confirmed` ngay, không chờ chủ trọ.
   - **require** → notification-service báo chủ trọ kèm đầy đủ dữ liệu đối chiếu; chủ trọ `PATCH /readings/{id}/verify` trong `verification_timeout_minutes` (mặc định 60 - giá trị mặc định #1). EventBridge rule `verification-timeout-checker` (rate 15 phút) quét các bản ghi `needs_verification` quá hạn → tự `status=auto_verified_timeout`, dùng giá trị người thuê đã gửi (FR-031 exception flow).
8. Khi `status ∈ {confirmed, verified, auto_verified_timeout}` → utility-service phát sự kiện `reading.ready-for-billing`.
9. **EventBridge rule `monthly-invoice-generation`** (chạy hàng ngày, kiểm tra owner nào có `invoice_day_of_month == hôm nay`) → invoice-service, với từng hợp đồng active của owner đó:
   - Có đủ chỉ số điện + nước sẵn sàng cho kỳ này → tạo hóa đơn chính thức `status=unpaid` (FR-036), notification-service gửi thông báo.
   - Thiếu chỉ số → tạo hóa đơn **Nháp** `status=draft` (FR-037), chỉ gồm tiền thuê + phụ phí cố định, **không gửi thông báo**.
10. Khi chỉ số còn thiếu được bổ sung sau đó (bước 5-8 xảy ra muộn), utility-service phát sự kiện `reading.ready-for-billing` → invoice-service lắng nghe, tìm hóa đơn `draft` tương ứng `(contract_id, period_month)`, tính lại đầy đủ, chuyển `status=unpaid` (FR-038), **lúc này mới gửi thông báo**.
11. **Giá trị mặc định #3**: EventBridge rule `stale-draft-invoice-scan` (hàng ngày) quét hóa đơn `draft` đã tồn tại quá 2 kỳ liên tiếp (so `period_month` hiện tại với hóa đơn draft cũ nhất chưa xử lý của cùng hợp đồng) → gửi cảnh báo riêng (khác cảnh báo quá hạn FR-047) cho chủ trọ qua notification-service, đồng thời `invoice-service` mở endpoint cho phép chủ trọ tự `PATCH /readings/owner-input` nhập chỉ số thay người thuê để phá vỡ tình trạng treo.

**Đánh đổi polling vs WebSocket/AppSync:** MVP dùng **polling đơn giản** (`GET /readings/{id}` mỗi vài giây từ client) vì: (1) thời gian OCR hoàn tất chỉ vài giây đến vài chục giây (NFR-01), UX chấp nhận được; (2) không cần thêm hạ tầng AppSync/WebSocket API Gateway, giảm chi phí vận hành và độ phức tạp cho quy mô MVP ít chủ trọ. Đánh đổi: tốn một số lượt gọi API dư thừa so với push thật. Khuyến nghị chuyển sang AppSync Subscriptions nếu về sau UX yêu cầu cập nhật tức thời hoặc số lượng người dùng đồng thời tăng cao.

#### (b) Luồng Adjustment — 2 nhánh (FR-042, FR-043) + trường hợp hợp đồng kết thúc sớm (giá trị mặc định #4)

1. Actor (chủ trọ hoặc người thuê) phát hiện sai sót, trao đổi qua `chat-service` (kênh chat không tự đổi trạng thái nghiệp vụ — đúng Mục 5.11 BRD).
2. Chủ trọ xác nhận số liệu đúng, gọi `PATCH /invoices/{id}/adjust` (invoice-service) kèm giá trị mới.
3. invoice-service kiểm tra `invoices.status`:
   - **`unpaid`** → cập nhật trực tiếp `invoice_line_items` + `total_amount` của hóa đơn đó (FR-042); ghi `audit_logs` (giá trị cũ → mới).
   - **`paid`** → **không sửa hóa đơn cũ**; tạo bản ghi `invoice_adjustments(status=pending, delta_amount, original_invoice_id, contract_id)` (FR-043).
4. Khi invoice-service tạo hóa đơn chính thức kỳ kế tiếp cho hợp đồng đó (bước 9 ở luồng a), nó **luôn truy vấn** `invoice_adjustments WHERE contract_id=? AND status=pending` trước khi chốt `total_amount`, cộng/trừ khoản chênh lệch làm một `invoice_line_item(item_type=adjustment)`, sau đó set `status=applied, applied_invoice_id=<hóa đơn kỳ mới>`.
5. **Trường hợp đặc biệt (giá trị mặc định #4):** khi `contract-service` xử lý một hợp đồng chuyển `status=terminated` (luồng c, bước cuối), nó gọi API nội bộ `invoice-service: GET /internal/contracts/{id}/pending-adjustments`. Nếu có `invoice_adjustments(status=pending)` cho hợp đồng này:
   - invoice-service không chờ kỳ hóa đơn tiếp theo (vì không còn kỳ nào nữa).
   - Toàn bộ `delta_amount` được cộng dồn vào bước tính `deposit_transactions` (FR-019/FR-023) làm một khoản điều chỉnh trong `adjustments_included`.
   - Đánh dấu `invoice_adjustments.status = included_in_deposit_settlement`, `applied_invoice_id = null` (không gắn hóa đơn nào, mà gắn `deposit_transactions.id` để truy vết — xem DB Design).

#### (c) Luồng chấm dứt hợp đồng (Mục 5.3.2 / FR-013→FR-017)

1. Bên khởi tạo gọi `contract-service: POST /contracts/{id}/termination-requests` (thông thường, FR-013) hoặc hệ thống tự khởi tạo khi vi phạm đạt ngưỡng (FR-022, do EventBridge rule `overdue-scan` phát hiện qua invoice-service rồi gọi nội bộ contract-service).
2. contract-service gọi config-service lấy `min_notice_days_normal` (Y, mặc định 30) hoặc dùng `min_notice_days_violation` (X2, mặc định 5) cho nhánh vi phạm; kiểm tra khoảng cách ngày hợp lệ.
3. Hợp lệ → tạo `termination_requests(status=requested)`, `contracts.status=pending_termination`; gọi nội bộ `room-service` để **không** đổi trạng thái phòng (phòng vẫn "Đang cho thuê" theo đúng BRD); notification-service báo bên còn lại.
4. **Nhánh thông thường** có 2 bước phản hồi:
   - `PATCH /termination-requests/{id}/acknowledge` → `status=acknowledged` (FR-014); bên gửi vẫn có thể `DELETE /termination-requests/{id}` để rút lại → `contracts.status=active` (FR-015).
   - `PATCH /termination-requests/{id}/accept` → `status=accepted`, **khóa vĩnh viễn** khả năng rút/hủy ở tầng service (FR-016).
   - EventBridge rule `termination-reminder` (rate 1 ngày, ngưỡng gợi ý 2-3 ngày) gửi nhắc nếu bên nhận chưa phản hồi (FR-017), dừng khi có `acknowledged_at`/`accepted_at`.
5. **Nhánh vi phạm** (FR-022): không có bước acknowledge/rút lại — tạo thẳng `termination_requests(status=accepted, notice_type=violation)`.
6. EventBridge rule `contract-status-transition` (rate 1 ngày) quét `termination_requests(status=accepted)` có `requested_end_date <= hôm nay`:
   - `contracts.status = terminated`, `actual_end_date` set (FR-011).
   - Gọi nội bộ `room-service`: phòng → "Trống" (FR-002).
   - Gọi nội bộ xử lý cọc: FR-019 (nhánh thường) hoặc FR-023 (nhánh vi phạm), bao gồm bước gộp Adjustment còn treo (Mục 3.b bước 5).
   - `termination_requests.status = completed`.

### 4. Chiến lược EventBridge Scheduler cho tác vụ định kỳ

| Rule | Tần suất | Service xử lý | Việc thực hiện |
|---|---|---|---|
| `monthly-invoice-generation` | `cron(0 1 * * ? *)` — hàng ngày 01:00, tự lọc owner có `invoice_day_of_month == hôm nay` | invoice-service | FR-036/FR-037 |
| `reading-reminder` | `cron(0 0 * * ? *)` hàng ngày, gửi trước N ngày so với `invoice_day_of_month` | notification-service (đọc utility-service) | FR-026 |
| `overdue-scan` | `rate(1 day)` | invoice-service | FR-047, cập nhật cờ cho FR-050 |
| `stale-draft-invoice-scan` | `rate(1 day)` | invoice-service | Giá trị mặc định #3 |
| `verification-timeout-checker` | `rate(15 minutes)` | utility-service | FR-031 (timeout mặc định 60 phút cần độ phân giải mịn hơn 1 ngày) |
| `contract-status-transition` | `rate(1 day)` | contract-service | FR-016 (finalize), FR-022 (finalize vi phạm) |
| `termination-reminder` | `rate(1 day)` | notification-service (đọc contract-service) | FR-017 |
| `debt-carry-flag-scan` | `rate(1 day)` (đồng bộ cùng lúc invoice generation) | contract-service | FR-024 |

### 5. NFR-02 — Cách ly dữ liệu đa chủ trọ: 2 lớp phòng thủ

**Lớp 1 — Middleware Lambda (application layer):** mọi Lambda business logic dùng một middleware chung (Lambda Layer) trích `owner_id` (và `contract_id` nếu là actor Người thuê) **duy nhất từ JWT claims** do Cognito Authorizer xác thực (`event.requestContext.authorizer.claims`). Toàn bộ query builder **bắt buộc** nhận `owner_id` từ context này; mọi `owner_id`/`contract_id` xuất hiện trong request body/query string của client bị **bỏ qua hoàn toàn**, không được tin dùng để lọc dữ liệu.

**Lớp 2 — PostgreSQL Row-Level Security (RLS):** mọi bảng nghiệp vụ có cột `owner_id` bật RLS với policy dạng:
```sql
CREATE POLICY tenant_isolation ON rooms
  USING (owner_id = current_setting('app.current_owner_id')::uuid);
```
Mỗi Lambda, ngay sau khi lấy connection từ RDS Proxy, chạy `SET LOCAL app.current_owner_id = '<owner_id từ JWT>'` trong cùng transaction trước khi thực thi câu lệnh nghiệp vụ. RDS Proxy hỗ trợ connection pinning khi có `SET` session-level nên cần dùng `SET LOCAL` (phạm vi transaction) để tránh pin connection không cần thiết và giữ hiệu quả pooling.

Lý do 2 lớp: Lớp 1 chặn phần lớn lỗi ở tầng ứng dụng (nhanh, rõ ràng khi review code); Lớp 2 là **lưới an toàn cuối cùng** — nếu một Lambda có bug quên điều kiện `WHERE owner_id = ...`, RLS vẫn chặn được truy cập chéo ở tầng database, đúng tinh thần NFR-02 "yêu cầu quan trọng nhất của hệ thống". Actor Quản trị hệ thống dùng một DB role riêng **không có** policy bypass cho dữ liệu nghiệp vụ chi tiết (chỉ có quyền SELECT trên các view thống kê tổng hợp - FR-054).

### 6. NFR-01/NFR-03 áp dụng riêng cho luồng OCR

- **Tách hàng đợi:** ảnh upload không gọi Textract đồng bộ trong request API; toàn bộ xử lý OCR đi qua SQS `ocr-queue` (S3 event trigger), decouple hoàn toàn khỏi API Gateway/Lambda đồng bộ.
- **Cách ly concurrency:** Lambda `ocr-processor` được cấu hình **reserved concurrency** riêng (tách khỏi pool concurrency chung của các Lambda đồng bộ khác) — nếu một chủ trọ có lượng ảnh tải lên tăng đột biến (đầu tháng, nhiều phòng cùng gửi ảnh), nó chỉ làm chậm chính hàng đợi OCR (SQS tự động buffer + Lambda scale trong giới hạn reserved), **không** làm cạn concurrency pool ảnh hưởng tới API đọc/ghi (đăng nhập, xem hóa đơn, thanh toán...) của các chủ trọ khác.
- **Chống fail lan:** SQS có Dead Letter Queue (DLQ) cho các lần gọi Textract lỗi (throttle, ảnh không đọc được) — không block message tiếp theo trong queue, không rơi vào retry vô hạn.
- **Kết quả tức thời cho người dùng:** API `POST /readings` luôn trả `202 Accepted` ngay khi ảnh được nhận và lưu S3 thành công, đúng NFR-01 (tác vụ nặng không chặn thao tác khác).

---

## DB Design

### 1. ERD dạng text (rút gọn quan hệ chính)

```
owners (1) ───< rooms (1) ───< contracts >─── (1) tenant_profiles
   │                              │  \
   │                              │   \──< co_residents
   │                              │   \──(1) renter_accounts
   │                              │   \──< termination_requests
   │                              │   \──< deposit_transactions
   │                              │
   │                              └──< invoices ──< invoice_line_items
   │                                     │  \──< payments
   │                                     │  \──(0..1) invoice_adjustments (original_invoice_id)
   │                                     │  \──(0..1) invoice_adjustments (applied_invoice_id)
   │
   ├──< utility_rates
   ├──< utility_readings >── rooms (room_id BẮT BUỘC) ; contracts (submitted_by_contract_id, tham chiếu mềm)
   ├──< repair_requests ──< repair_request_images
   ├──< chat_messages
   ├──< notifications
   ├──< audit_logs
   └──(1) tenant_settings

admins (độc lập, không owner_id — vai trò Quản trị hệ thống)
```

### 2. Chi tiết bảng

> Quy ước chung: `id UUID PK default gen_random_uuid()`, `created_at timestamptz default now()`, `updated_at timestamptz` (trigger tự cập nhật) áp dụng cho hầu hết bảng — không lặp lại ở từng bảng để tiết kiệm không gian, chỉ liệt kê cột đặc thù + ràng buộc quan trọng.

**owners** (không có owner_id — đây là gốc)
| Cột | Kiểu | Ràng buộc |
|---|---|---|
| business_name | varchar(255) | NOT NULL |
| email | varchar(255) | UNIQUE, NOT NULL |
| phone | varchar(20) | NOT NULL |
| cognito_sub | varchar(64) | UNIQUE, NOT NULL |
| status | enum(active, locked) | NOT NULL default 'active' |

**admins** (không có owner_id)
| Cột | Kiểu | Ràng buộc |
|---|---|---|
| email | varchar(255) | UNIQUE, NOT NULL |
| cognito_sub | varchar(64) | UNIQUE, NOT NULL |

**rooms** — owner_id NOT NULL
| Cột | Kiểu | Ràng buộc |
|---|---|---|
| owner_id | uuid | FK owners, NOT NULL, **INDEX** |
| name | varchar(100) | NOT NULL |
| room_code | varchar(20) | UNIQUE per owner, hệ thống tự sinh |
| area_m2 | numeric(6,2) | NULL |
| base_rent | numeric(14,2) | NOT NULL |
| description | text | NULL |
| status | enum(trong, dang_cho_thue, dang_sua_chua) | NOT NULL default 'trong', **INDEX** |
| initial_electric_reading | numeric(10,2) | NULL — mốc khởi điểm nhập tay (FR-033) |
| initial_water_reading | numeric(10,2) | NULL |
| deleted_at | timestamptz | NULL (FR-055) |

**tenant_profiles** — owner_id NOT NULL
| Cột | Kiểu | Ràng buộc |
|---|---|---|
| owner_id | uuid | FK owners, NOT NULL, **INDEX** |
| full_name | varchar(255) | NOT NULL |
| national_id | varchar(20) | NOT NULL, UNIQUE(owner_id, national_id) |
| phone | varchar(20) | NOT NULL |
| email | varchar(255) | NOT NULL (bắt buộc theo BR-03) |
| deleted_at | timestamptz | NULL |

**co_residents** — owner_id NOT NULL
| Cột | Kiểu | Ràng buộc |
|---|---|---|
| owner_id | uuid | FK owners, NOT NULL, **INDEX** |
| contract_id | uuid | FK contracts, NOT NULL, **INDEX** |
| full_name | varchar(255) | NOT NULL |
| national_id | varchar(20) | NULL |
| move_in_date | date | NOT NULL |
| move_out_date | date | NULL |

**contracts** — owner_id NOT NULL
| Cột | Kiểu | Ràng buộc |
|---|---|---|
| owner_id | uuid | FK owners, NOT NULL, **INDEX** |
| room_id | uuid | FK rooms, NOT NULL, **INDEX** |
| tenant_profile_id | uuid | FK tenant_profiles, NOT NULL |
| start_date | date | NOT NULL |
| end_date | date | NULL (vô thời hạn nếu trống) |
| deposit_amount | numeric(14,2) | NOT NULL |
| deposit_months | int | NOT NULL default 1 |
| monthly_rent | numeric(14,2) | NOT NULL |
| first_month_billing_option | enum(pro_rata, free_remainder) | NOT NULL |
| min_lease_days | int | NULL (FR-020, theo hợp đồng) |
| status | enum(draft, active, pending_termination, expired, terminated) | NOT NULL default 'draft', **INDEX** |
| termination_type | enum(normal, violation) | NULL |
| debt_carry_flag | boolean | NOT NULL default false (FR-024) |
| actual_end_date | date | NULL |
| CHECK | | `end_date IS NULL OR end_date > start_date` |

**termination_requests** — owner_id NOT NULL
| Cột | Kiểu | Ràng buộc |
|---|---|---|
| owner_id | uuid | FK owners, NOT NULL, **INDEX** |
| contract_id | uuid | FK contracts, NOT NULL, **INDEX** |
| requested_by | enum(owner, tenant, system) | NOT NULL |
| requested_end_date | date | NOT NULL |
| notice_type | enum(normal, violation) | NOT NULL |
| status | enum(requested, acknowledged, accepted, withdrawn, completed) | NOT NULL default 'requested', **INDEX** |
| acknowledged_at | timestamptz | NULL |
| accepted_at | timestamptz | NULL |
| last_reminder_at | timestamptz | NULL (FR-017) |

**renter_accounts** — owner_id NOT NULL
| Cột | Kiểu | Ràng buộc |
|---|---|---|
| owner_id | uuid | FK owners, NOT NULL, **INDEX** |
| contract_id | uuid | FK contracts, UNIQUE, NOT NULL (1-1) |
| tenant_profile_id | uuid | FK tenant_profiles, NOT NULL |
| cognito_sub | varchar(64) | UNIQUE, NULL (đến khi kích hoạt) |
| activation_token_hash | varchar(255) | NULL |
| activation_token_expires_at | timestamptz | NULL |
| activation_status | enum(pending, activated) | NOT NULL default 'pending' |
| access_mode | enum(full, readonly) | NOT NULL default 'full' — chuyển `readonly` khi hợp đồng terminated (FR-059) |

**tenant_settings** — owner_id UNIQUE (1-1 với owner)
| Cột | Kiểu | Ràng buộc | Mặc định |
|---|---|---|---|
| owner_id | uuid | FK owners, UNIQUE, NOT NULL | |
| min_notice_days_normal | int | CHECK >= 30 | 30 |
| min_notice_days_violation | int | CHECK BETWEEN 3 AND 7 | 5 |
| violation_threshold_cycles | int | CHECK >= 1 | 1 |
| invoice_day_of_month | int | CHECK BETWEEN 1 AND 28 | **1** (giá trị mặc định #2) |
| verification_mode | enum(skip, require) | | require |
| verification_timeout_minutes | int | CHECK > 0 | **60** (giá trị mặc định #1) |
| payment_mode | enum(momo, manual) | | manual |
| overdue_threshold_days | int | CHECK > 0 | 5 |
| deposit_handling_option | enum(offset_last_rent, direct_refund) | | offset_last_rent |

**utility_rates** — owner_id NOT NULL
| Cột | Kiểu | Ràng buộc |
|---|---|---|
| owner_id | uuid | FK owners, NOT NULL, **INDEX** |
| utility_type | enum(electric, water) | NOT NULL |
| tier_order | int | NOT NULL |
| threshold_from | numeric(10,2) | NOT NULL |
| threshold_to | numeric(10,2) | NULL (bậc cuối không giới hạn) |
| unit_price | numeric(14,2) | NOT NULL, CHECK >= 0 |
| effective_from | timestamptz | NOT NULL, **INDEX** |
| effective_to | timestamptz | NULL (FR-034 — lịch sử hiệu lực) |

**utility_readings** — owner_id NOT NULL — thiết kế riêng cho BR-08d, xem giải thích Mục 3
| Cột | Kiểu | Ràng buộc |
|---|---|---|
| owner_id | uuid | FK owners, NOT NULL, **INDEX** |
| room_id | uuid | FK rooms, NOT NULL, **INDEX** (gắn phòng, KHÔNG gắn contract_id) |
| submitted_by_contract_id | uuid | FK contracts, NULL — hợp đồng active tại thời điểm gửi, phục vụ tính hóa đơn |
| period_month | date | NOT NULL (ngày 1 của kỳ), **INDEX** |
| utility_type | enum(electric, water) | NOT NULL |
| image_s3_key | varchar(512) | NULL (trống nếu chủ trọ tự nhập thay - giá trị mặc định #3) |
| ocr_raw_value | numeric(10,2) | NULL — giá trị OCR gốc, giữ lại kể cả sau khi người dùng sửa |
| submitted_value | numeric(10,2) | NULL — giá trị cuối dùng để tính hóa đơn |
| previous_value | numeric(10,2) | NOT NULL — chỉ số kỳ trước cùng room_id (denormalize để audit) |
| is_baseline | boolean | NOT NULL default false (FR-033 — mốc khởi điểm, không tính tiêu thụ) |
| status | enum(pending_ocr, ocr_done, confirmed, needs_verification, verified, auto_verified_timeout) | NOT NULL, **INDEX** |
| verified_by | enum(tenant, owner, system) | NULL |
| deleted_at | timestamptz | NULL |
| UNIQUE | | `(room_id, period_month, utility_type)` |

**invoices** — owner_id NOT NULL
| Cột | Kiểu | Ràng buộc |
|---|---|---|
| owner_id | uuid | FK owners, NOT NULL, **INDEX** |
| contract_id | uuid | FK contracts, NOT NULL, **INDEX** |
| period_month | date | NOT NULL |
| status | enum(draft, unpaid, paid, overdue, cancelled) | NOT NULL, **INDEX** |
| rent_amount | numeric(14,2) | NOT NULL default 0 |
| electric_amount | numeric(14,2) | NULL |
| water_amount | numeric(14,2) | NULL |
| other_fee_amount | numeric(14,2) | NOT NULL default 0 |
| total_amount | numeric(14,2) | NOT NULL default 0 |
| issued_at | timestamptz | NULL — thời điểm phát hành chính thức (mốc tính quá hạn FR-047) |
| due_date | date | NULL |
| paid_at | timestamptz | NULL, **INDEX** (dùng cho overdue-scan) |
| replaced_by_invoice_id | uuid | FK invoices (self), NULL (FR-041) |
| UNIQUE | | `(contract_id, period_month)` |

**invoice_line_items**
| Cột | Kiểu | Ràng buộc |
|---|---|---|
| invoice_id | uuid | FK invoices, NOT NULL, **INDEX** |
| item_type | enum(rent, electric, water, other_fee, adjustment) | NOT NULL |
| description | varchar(255) | NULL |
| amount | numeric(14,2) | NOT NULL |

**payments** — owner_id NOT NULL
| Cột | Kiểu | Ràng buộc |
|---|---|---|
| owner_id | uuid | FK owners, NOT NULL, **INDEX** |
| invoice_id | uuid | FK invoices, NOT NULL, **INDEX** |
| method | enum(momo, cash, bank_transfer) | NOT NULL |
| amount | numeric(14,2) | NOT NULL |
| momo_transaction_id | varchar(100) | NULL (giả lập MVP) |
| confirmed_by | enum(system, owner) | NOT NULL |
| confirmed_at | timestamptz | NOT NULL |

**deposit_transactions** — owner_id NOT NULL
| Cột | Kiểu | Ràng buộc |
|---|---|---|
| owner_id | uuid | FK owners, NOT NULL, **INDEX** |
| contract_id | uuid | FK contracts, NOT NULL, UNIQUE, **INDEX** |
| deposit_amount | numeric(14,2) | NOT NULL |
| deductions_total | numeric(14,2) | NOT NULL default 0 |
| adjustments_included | numeric(14,2) | NOT NULL default 0 — khoản Adjustment gộp lúc thanh lý (giá trị mặc định #4) |
| remaining_debt | numeric(14,2) | NOT NULL default 0 (khi nợ vượt cọc) |
| refund_method | enum(offset_last_rent, direct_refund) | NULL |
| refund_status | enum(pending, refunded) | NULL |
| settled_at | timestamptz | NOT NULL |

**invoice_adjustments** — owner_id NOT NULL
| Cột | Kiểu | Ràng buộc |
|---|---|---|
| owner_id | uuid | FK owners, NOT NULL, **INDEX** |
| original_invoice_id | uuid | FK invoices, NOT NULL |
| applied_invoice_id | uuid | FK invoices, NULL |
| contract_id | uuid | FK contracts, NOT NULL, **INDEX** |
| delta_amount | numeric(14,2) | NOT NULL — có thể âm (trừ) hoặc dương (cộng) |
| reason | text | NOT NULL |
| status | enum(pending, applied, included_in_deposit_settlement) | NOT NULL default 'pending', **INDEX** |
| applied_at | timestamptz | NULL |

**repair_requests** — owner_id NOT NULL
| Cột | Kiểu | Ràng buộc |
|---|---|---|
| owner_id | uuid | FK owners, NOT NULL, **INDEX** |
| contract_id | uuid | FK contracts, NOT NULL, **INDEX** |
| description | text | NOT NULL |
| status | enum(moi, dang_xu_ly, hoan_thanh, da_huy) | NOT NULL default 'moi', **INDEX** |

**repair_request_images**
| Cột | Kiểu | Ràng buộc |
|---|---|---|
| repair_request_id | uuid | FK repair_requests, NOT NULL |
| s3_key | varchar(512) | NOT NULL |
| is_primary | boolean | NOT NULL default true — tối đa 1 ảnh chính (BR-15); ảnh bổ sung qua `chat_messages.image_s3_key` |

**chat_messages** — owner_id NOT NULL
| Cột | Kiểu | Ràng buộc |
|---|---|---|
| owner_id | uuid | FK owners, NOT NULL, **INDEX** |
| contract_id | uuid | FK contracts, NOT NULL, **INDEX** |
| sender_type | enum(owner, tenant, system) | NOT NULL |
| message | text | NULL |
| image_s3_key | varchar(512) | NULL |
| related_entity_type | varchar(50) | NULL (vd 'invoice', 'repair_request') |
| related_entity_id | uuid | NULL |

**notifications** — owner_id NOT NULL
| Cột | Kiểu | Ràng buộc |
|---|---|---|
| owner_id | uuid | FK owners, NOT NULL, **INDEX** |
| recipient_type | enum(owner, tenant, admin) | NOT NULL |
| recipient_id | uuid | NOT NULL, **INDEX** |
| channel | enum(in_app, email) | NOT NULL |
| event_type | varchar(50) | NOT NULL |
| payload | jsonb | NOT NULL |
| read_at | timestamptz | NULL |
| sent_at | timestamptz | NULL |

**audit_logs** — owner_id NULL cho phép (hành động Admin)
| Cột | Kiểu | Ràng buộc |
|---|---|---|
| owner_id | uuid | FK owners, NULL, **INDEX** |
| actor_type | enum(owner, tenant, admin, system) | NOT NULL |
| actor_id | uuid | NOT NULL |
| action | varchar(100) | NOT NULL |
| entity_type | varchar(50) | NOT NULL, **INDEX** |
| entity_id | uuid | NOT NULL, **INDEX** |
| old_value | jsonb | NULL |
| new_value | jsonb | NULL |

### 3. Xử lý riêng cho `utility_readings` (BR-08d)

Chỉ số **bắt buộc gắn `room_id`** (không gắn `contract_id`) để đảm bảo tính liên tục qua các đời khách thuê (BR-08d): khi tra `previous_value`, hệ thống luôn `SELECT ... WHERE room_id = ? ORDER BY period_month DESC LIMIT 1`, không quan tâm chỉ số đó thuộc hợp đồng nào. Tuy nhiên, để biết **kỳ đó thuộc hợp đồng nào đang active** phục vụ tính hóa đơn (invoice-service cần join `invoices.contract_id`), bảng có thêm cột **`submitted_by_contract_id`** (nullable, ghi nhận tại thời điểm submit bằng cách tra `contracts WHERE room_id=? AND status='active'`). Cột này chỉ mang tính tham chiếu/audit — logic nghiệp vụ chính (kế thừa chỉ số) không bao giờ dựa vào nó.

### 4. Soft delete (FR-055) — nhất quán 2 kiểu

- **Entity có thể "gỡ" khỏi danh sách hoạt động nhưng không có state machine phức tạp** (`rooms`, `tenant_profiles`, `utility_readings`): dùng cột `deleted_at timestamptz NULL`; mọi query mặc định thêm `WHERE deleted_at IS NULL` (thực hiện qua RLS policy kết hợp hoặc query builder chung).
- **Entity có sẵn state machine nghiệp vụ** (`contracts`, `invoices`, `repair_requests`, `termination_requests`): tận dụng cột `status` hiện có (`terminated`, `cancelled`, `da_huy`...) làm trạng thái lưu trữ, không thêm `deleted_at` để tránh 2 nguồn sự thật về "đã xóa hay chưa".

### 5. Audit log (NFR-04) — truy vết bắt buộc

Bảng `audit_logs` dùng chung (generic) cho mọi hành động cần truy vết, ghi tại tầng application ngay sau mỗi lệnh UPDATE quan trọng:

| Nghiệp vụ cần truy vết | `entity_type` | Ghi chú `old_value` → `new_value` |
|---|---|---|
| Sửa chỉ số (người thuê hay chủ trọ) | `utility_reading` | `{ocr_raw_value, submitted_value cũ}` → `{submitted_value mới, verified_by}` |
| Lịch sử Adjustment | `invoice_adjustment` | Toàn bộ vòng đời `pending → applied/included_in_deposit_settlement` |
| Lịch sử xử lý cọc | `deposit_transaction` | `{deposit_amount, deductions_total, adjustments_included, remaining_debt}` |
| Xác nhận thanh toán | `payment` | `{status invoice cũ}` → `{status mới, confirmed_by}` |

---

## API List

> Quy ước lỗi chung: `400` = dữ liệu không hợp lệ, `401` = chưa xác thực, `403` = không có quyền/ngoài phạm vi owner_id-contract_id (NFR-02), `404` = không tìm thấy, `409` = xung đột trạng thái. Cột "Role" ghi rõ actor bắt buộc. API tiền tố `/internal/*` chỉ gọi được nội bộ giữa các Lambda (không lộ qua API Gateway public route, dùng resource policy/VPC-only hoặc Lambda invoke trực tiếp).

### auth-service

| # | Method & Path | Mô tả | Request | Response 2xx | Lỗi | Role | Nguồn |
|---|---|---|---|---|---|---|---|
| 1 | POST /auth/login | Đăng nhập, phân biệt role qua Cognito | `{email, password}` | `{access_token, refresh_token, role}` | 401 sai thông tin | Chủ trọ/Người thuê/Admin | Hạ tầng |
| 2 | POST /auth/refresh-token | Làm mới token | `{refresh_token}` | `{access_token}` | 401 token hết hạn | Tất cả | Hạ tầng |
| 3 | POST /auth/activate | Kích hoạt tài khoản Người thuê lần đầu | `{activation_token, password}` | `{status: activated}` | 400 token hết hạn/đã dùng | Người thuê | FR-008 |
| 4 | POST /auth/activate/resend | Gửi lại link kích hoạt | `{renter_account_id}` | `{status: sent}` | 404 | Chủ trọ | FR-008 |
| 5 | PATCH /admin/owners/{ownerId}/lock | Khóa tài khoản chủ trọ | — | `{status: locked}` | 404 | Admin | FR-052 |
| 6 | PATCH /admin/owners/{ownerId}/unlock | Mở lại tài khoản | — | `{status: active}` | 404 | Admin | FR-052 |
| 7 | GET /admin/stats | Số liệu tổng hợp (số chủ trọ, số phòng, trạng thái tài khoản) | — | `{ownerCount, roomCount, lockedCount,...}` | — | Admin | FR-054 |

### room-service

| # | Method & Path | Mô tả | Request | Response 2xx | Lỗi | Role | Nguồn |
|---|---|---|---|---|---|---|---|
| 1 | POST /rooms | Tạo phòng | `{name, area_m2, base_rent, description, initial_electric_reading?, initial_water_reading?}` | `201 {room}` | 400 thiếu tên | Chủ trọ | FR-001 |
| 2 | GET /rooms | Danh sách phòng | query `status?` | `200 [room]` | — | Chủ trọ | FR-001 |
| 3 | GET /rooms/{roomId} | Chi tiết phòng | — | `200 {room}` | 404 | Chủ trọ | FR-001 |
| 4 | PATCH /rooms/{roomId} | Sửa thông tin phòng | `{area_m2?, base_rent?, description?}` | `200 {room}` | 409 phòng đang có hợp đồng hiệu lực | Chủ trọ | FR-003 |
| 5 | DELETE /rooms/{roomId} | "Xóa" (soft delete) phòng | — | `200 {deleted_at}` | 409 đang có hợp đồng hiệu lực | Chủ trọ | FR-003, FR-055 |
| 6 | PATCH /internal/rooms/{roomId}/status | (nội bộ) đồng bộ trạng thái phòng theo hợp đồng | `{status}` | `200` | — | System | FR-002 |

### contract-service

| # | Method & Path | Mô tả | Request | Response 2xx | Lỗi | Role | Nguồn |
|---|---|---|---|---|---|---|---|
| 1 | POST /tenant-profiles | Tạo hồ sơ người đại diện | `{full_name, national_id, phone, email}` | `201 {tenant_profile}` | 400 thiếu email/CCCD trùng | Chủ trọ | FR-004 |
| 2 | POST /contracts | Tạo hợp đồng mới (kèm người đại diện + người ở cùng) | `{room_id, tenant_profile_id, start_date, end_date?, deposit_amount, monthly_rent, first_month_billing_option, co_residents?[]}` | `201 {contract}` — kích hoạt FR-007 | 400 thiếu trường; 409 phòng không "Trống"; 409 ngắn hơn `min_lease_days` | Chủ trọ | FR-005, FR-009 |
| 3 | GET /contracts/{id} | Xem hợp đồng | — | `200 {contract}` | 403 ngoài phạm vi; 404 | Chủ trọ/Người thuê | FR-056 |
| 4 | GET /contracts | Danh sách hợp đồng | query `status?` | `200 [contract]` | — | Chủ trọ | — |
| 5 | POST /contracts/{id}/co-residents | Thêm người ở cùng | `{full_name, national_id?, move_in_date}` | `201` | 409 hợp đồng không active | Chủ trọ | FR-006 |
| 6 | PATCH /co-residents/{coResidentId}/move-out | Ghi nhận kết thúc cư trú | `{move_out_date}` | `200` | 404 | Chủ trọ | FR-006 |
| 7 | POST /contracts/{id}/termination-requests | Gửi yêu cầu chấm dứt thông thường | `{requested_end_date}` | `201 {termination_request}` | 409 chưa đủ Y ngày báo trước; 409 hợp đồng không active | Chủ trọ/Người thuê | FR-013 |
| 8 | POST /internal/contracts/{id}/violation-termination | (nội bộ) khởi tạo chấm dứt do vi phạm | `{}` | `201` | 409 chưa đạt ngưỡng kỳ nợ | System (do invoice-service gọi) | FR-022 |
| 9 | PATCH /termination-requests/{trId}/acknowledge | Xác nhận "Đã tiếp nhận" | — | `200` | 409 sai trạng thái | Bên nhận | FR-014 |
| 10 | DELETE /termination-requests/{trId} | Rút lại yêu cầu | — | `200` | 409 đã "Đã chấp nhận" | Bên gửi | FR-015 |
| 11 | PATCH /termination-requests/{trId}/accept | Xác nhận "Đã chấp nhận" (không thể đảo ngược) | — | `200` | 409 sai trạng thái | Bên nhận | FR-016 |
| 12 | POST /internal/contracts/{id}/finalize-termination | (nội bộ, EventBridge) hoàn tất chấm dứt đúng ngày | `{}` | `200` | — | System | FR-011, FR-016, FR-022 |
| 13 | GET /contracts/{id}/deposit-settlement | Xem kết quả xử lý cọc | — | `200 {deposit_transaction}` | 404 chưa thanh lý | Chủ trọ/Người thuê | FR-019, FR-023 |
| 14 | PATCH /contracts/{id}/deposit-option | Cấu hình phương án xử lý cọc | `{deposit_handling_option}` | `200` | — | Chủ trọ | FR-018 |

### config-service

| # | Method & Path | Mô tả | Request | Response 2xx | Lỗi | Role | Nguồn |
|---|---|---|---|---|---|---|---|
| 1 | GET /config | Xem toàn bộ tham số cấu hình của chủ trọ | — | `200 {tenant_settings}` | — | Chủ trọ | FR-012,018,020,021,030,040,044 |
| 2 | PUT /config | Cập nhật tham số | `{min_notice_days_normal?, min_notice_days_violation?, violation_threshold_cycles?, invoice_day_of_month?, verification_mode?, verification_timeout_minutes?, payment_mode?, overdue_threshold_days?}` | `200 {tenant_settings}` | 400 `min_notice_days_normal < 30`; 400 `min_notice_days_violation` ngoài 3-7 | Chủ trọ | FR-012,020,021,030,040,044 |
| 3 | GET /internal/config/{ownerId} | (nội bộ) service khác đọc cấu hình | — | `200 {tenant_settings}` | — | System | — |

### utility-service

| # | Method & Path | Mô tả | Request | Response 2xx | Lỗi | Role | Nguồn |
|---|---|---|---|---|---|---|---|
| 1 | PUT /utility-rates | Cấu hình bậc thang điện/nước (tạo bản ghi mới, đóng hiệu lực bản cũ) | `{utility_type, tiers: [{from, to, unit_price}]}` | `201 {utility_rates[]}` | 400 ngưỡng không tăng dần/đơn giá âm | Chủ trọ | FR-025 |
| 2 | GET /utility-rates | Xem bậc thang hiện hành + lịch sử | query `utility_type?, at_date?` | `200 [utility_rates]` | — | Chủ trọ | FR-025, FR-034 |
| 3 | **POST /readings** | **Bất đồng bộ** — tải ảnh chỉ số, trả ngay `reading_id`, KHÔNG trả kết quả OCR ngay | multipart: `{room_id, utility_type, image}` | `202 {reading_id, status: pending_ocr}` | 400 thiếu ảnh; 409 đã có bản ghi kỳ này | Người thuê | FR-027, FR-058 |
| 4 | GET /readings/{id} | **API riêng để poll kết quả OCR** | — | `200 {status, ocr_raw_value, image_url}` | 404 | Người thuê/Chủ trọ | FR-027 |
| 5 | PATCH /readings/{id}/confirm | Người thuê xác nhận/chỉnh sửa chỉ số | `{submitted_value}` | `200 {status}` | 400 giá trị < kỳ trước (FR-035) | Người thuê | FR-028, FR-035 |
| 6 | GET /readings?status=needs_verification | Danh sách chỉ số chờ xác minh | — | `200 [reading]` | — | Chủ trọ | FR-029 |
| 7 | PATCH /readings/{id}/verify | Chủ trọ xác nhận/sửa chỉ số cần xác minh | `{submitted_value}` | `200 {status: verified}` | 400 giá trị < kỳ trước; 409 hết hạn (đã auto timeout) | Chủ trọ | FR-031 |
| 8 | POST /readings/owner-input | Chủ trọ tự nhập chỉ số thay người thuê (hóa đơn nháp treo quá 2 kỳ) | `{room_id, utility_type, period_month, value}` | `201 {status: verified}` | 400 giá trị < kỳ trước | Chủ trọ | Giá trị mặc định #3 |
| 9 | POST /internal/readings/verification-timeout-check | (nội bộ, EventBridge) tự động phát hành khi hết giờ chờ | `{}` | `200 {processedCount}` | — | System | FR-031 |

### invoice-service

| # | Method & Path | Mô tả | Request | Response 2xx | Lỗi | Role | Nguồn |
|---|---|---|---|---|---|---|---|
| 1 | GET /invoices | Danh sách hóa đơn | query `status?, period_month?` | `200 [invoice]` | — | Chủ trọ/Người thuê | FR-057 |
| 2 | GET /invoices/{id} | Chi tiết hóa đơn | — | `200 {invoice, line_items}` | 403/404 | Chủ trọ/Người thuê | FR-057 |
| 3 | POST /invoices/{id}/cancel | Hủy hóa đơn chưa thanh toán | `{reason}` | `200 {status: cancelled, replacement_invoice}` | 409 đã thanh toán | Chủ trọ | FR-041 |
| 4 | PATCH /invoices/{id}/adjust | Điều chỉnh hóa đơn (Adjustment) | `{corrected_line_items}` | `200 {invoice}` hoặc `201 {invoice_adjustment}` tùy trạng thái | 404 | Chủ trọ | FR-042, FR-043 |
| 5 | POST /invoices/{id}/pay/momo | Thanh toán qua MoMo (giả lập) | `{}` | `200 {status: paid}` | 409 không phải chế độ MoMo; 402 mô phỏng thất bại | Người thuê | FR-045 |
| 6 | POST /invoices/{id}/pay/manual-confirm | Xác nhận thanh toán thủ công | `{method, amount}` | `200 {status: paid}` | 400 số tiền không khớp (không hỗ trợ trả một phần) | Chủ trọ | FR-046 |
| 7 | GET /reports/overview | Báo cáo tổng hợp (số phòng, doanh thu, công nợ) | query `from?, to?` | `200 {summary}` | — | Chủ trọ | FR-050 |
| 8 | GET /reports/debts | Báo cáo công nợ, nổi bật nợ dồn kỳ + quá hạn | — | `200 {debtList}` | — | Chủ trọ | FR-050, FR-024, FR-047 |
| 9 | POST /internal/invoices/generate-monthly | (nội bộ, EventBridge) tạo hóa đơn/nháp hàng loạt | `{owner_id}` | `200 {createdCount}` | — | System | FR-036, FR-037 |
| 10 | POST /internal/invoices/finalize-draft | (nội bộ) chuyển nháp → chính thức khi đủ chỉ số | `{invoice_id}` | `200 {invoice}` | — | System | FR-038 |
| 11 | POST /internal/invoices/overdue-scan | (nội bộ, EventBridge) đánh dấu quá hạn | `{}` | `200 {flaggedCount}` | — | System | FR-047 |
| 12 | POST /internal/invoices/stale-draft-scan | (nội bộ, EventBridge) cảnh báo nháp treo >2 kỳ | `{}` | `200 {warnedCount}` | — | System | Giá trị mặc định #3 |
| 13 | GET /internal/contracts/{id}/pending-adjustments | (nội bộ) contract-service lấy Adjustment còn treo khi thanh lý | — | `200 [invoice_adjustment]` | — | System | Giá trị mặc định #4 |
| 14 | POST /internal/deposit-settlement | (nội bộ) tính xử lý cọc, gộp Adjustment còn treo | `{contract_id, termination_type}` | `201 {deposit_transaction}` | — | System | FR-019, FR-023 |

### repair-service

| # | Method & Path | Mô tả | Request | Response 2xx | Lỗi | Role | Nguồn |
|---|---|---|---|---|---|---|---|
| 1 | POST /repair-requests | Gửi yêu cầu sửa chữa (mô tả + tối đa 1 ảnh) | multipart: `{description, image?}` | `201 {repair_request}` | 400 quá 1 ảnh | Người thuê | FR-048 |
| 2 | GET /repair-requests | Danh sách yêu cầu | query `status?` | `200 [repair_request]` | — | Chủ trọ/Người thuê | FR-049 |
| 3 | GET /repair-requests/{id} | Chi tiết | — | `200 {repair_request}` | 404 | Chủ trọ/Người thuê | FR-049 |
| 4 | PATCH /repair-requests/{id}/status | Cập nhật trạng thái xử lý | `{status}` | `200 {status}` | 409 chuyển từ trạng thái kết thúc | Chủ trọ | FR-049 |

### chat-service

| # | Method & Path | Mô tả | Request | Response 2xx | Lỗi | Role | Nguồn |
|---|---|---|---|---|---|---|---|
| 1 | GET /chats/{contractId}/messages | Lịch sử tin nhắn | query `cursor?` | `200 [message]` | 403 hợp đồng không thuộc phạm vi | Chủ trọ/Người thuê | FR-060 |
| 2 | POST /chats/{contractId}/messages | Gửi tin nhắn | `{message?, image?}` | `201 {message}` | 403 tài khoản readonly (hợp đồng đã chấm dứt, FR-059) | Chủ trọ/Người thuê | FR-060 |
| 3 | POST /internal/chats/{contractId}/system-message | (nội bộ) chèn tin nhắn hệ thống tự động | `{event_type, payload}` | `201` | — | System | FR-061 |

### notification-service

| # | Method & Path | Mô tả | Request | Response 2xx | Lỗi | Role | Nguồn |
|---|---|---|---|---|---|---|---|
| 1 | GET /notifications | Danh sách thông báo in-app | query `unread_only?` | `200 [notification]` | — | Chủ trọ/Người thuê/Admin | FR-062 |
| 2 | PATCH /notifications/{id}/read | Đánh dấu đã đọc | — | `200` | 404 | Chủ trọ/Người thuê | FR-062 |
| 3 | POST /internal/notifications/send | (nội bộ) các service khác gọi để gửi in-app + email | `{owner_id, recipient_type, recipient_id, event_type, payload, channels}` | `200` | — | System | FR-062, FR-063 |
| 4 | POST /internal/notifications/reading-reminders | (nội bộ, EventBridge) nhắc chụp ảnh chỉ số | `{}` | `200 {sentCount}` | — | System | FR-026 |
| 5 | POST /internal/notifications/termination-reminders | (nội bộ, EventBridge) nhắc phản hồi yêu cầu chấm dứt | `{}` | `200 {sentCount}` | — | System | FR-017 |

---

## Tóm tắt

- **Số Lambda service:** 9 (auth-service, room-service, contract-service, config-service, utility-service, invoice-service, repair-service, chat-service, notification-service).
- **Số bảng DB:** 21 (owners, admins, rooms, tenant_profiles, co_residents, contracts, termination_requests, renter_accounts, tenant_settings, utility_rates, utility_readings, invoices, invoice_line_items, payments, deposit_transactions, invoice_adjustments, repair_requests, repair_request_images, chat_messages, notifications, audit_logs).
- **Tổng số API:** 65 endpoint (bao gồm cả API `/internal/*` chỉ gọi nội bộ giữa các Lambda) trải trên 9 service.

**Điểm trong SRS v2.0 chưa đủ để thiết kế dứt khoát (ngoài 4 điểm đã được bổ sung giá trị mặc định trước khi thiết kế):**

1. **Ngưỡng "confidence score" chấp nhận được của Textract** để tự động điền `ocr_raw_value` vs. để trống ô nhập liệu — SRS/NFR-06 chỉ nêu "không đặt ngưỡng SLA cứng", nhưng ở tầng kỹ thuật cần một ngưỡng confidence cụ thể (ví dụ >80%) để quyết định có điền tự động hay bắt buộc để trống ngay từ đầu; đề xuất coi đây là tham số cấu hình runtime (không phải BR), điều chỉnh được sau khi có dữ liệu thực tế.
2. **Chính sách lifecycle cụ thể cho ảnh S3** (BRD chỉ "gợi ý, không bắt buộc" không lưu vĩnh viễn ảnh gốc sau khi đã xác minh) — SDD này chưa chốt số ngày giữ ảnh; đề xuất mặc định 90 ngày sau khi `status` chuyển `verified`/`confirmed`, cần Product Owner xác nhận trước khi áp vào S3 Lifecycle Policy.
3. **Định dạng và nội dung chi tiết của thông báo cảnh báo "hóa đơn nháp treo quá 2 kỳ"** (giá trị mặc định #3 mới bổ sung) — chưa có đặc tả UI/nội dung email cụ thể, cần làm rõ ở giai đoạn thiết kế UI/UX hoặc một SRS bổ sung nhỏ.
4. **Cơ chế "khoảng thời gian dự kiến ngắn hơn `min_lease_days`" ở FR-009** khi hợp đồng không có `end_date` (vô thời hạn) — SRS không nói rõ cách kiểm tra thời gian thuê tối thiểu áp dụng thế nào cho hợp đồng vô thời hạn; SDD tạm coi ràng buộc này chỉ áp dụng khi hợp đồng có `end_date` xác định, cần xác nhận lại với BRD/PO.