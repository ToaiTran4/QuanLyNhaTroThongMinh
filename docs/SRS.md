# TÀI LIỆU ĐẶC TẢ YÊU CẦU PHẦN MỀM
### (Software Requirements Specification - SRS)
## Hệ thống Quản lý Nhà trọ Thông minh - Nền tảng SaaS đa chủ trọ
**Phiên bản 2.0 - Chuyển đổi từ BRD v1.5**
Ngày: 02/07/2026
Tham chiếu chuẩn: cấu trúc theo thông lệ IEEE 830, tùy biến cho quy mô dự án MVP.

---

## Mục lục

1. [Giới thiệu](#1-giới-thiệu)
2. [Mô tả tổng quan hệ thống](#2-mô-tả-tổng-quan-hệ-thống)
3. [Yêu cầu chức năng (Functional Requirements)](#3-yêu-cầu-chức-năng-functional-requirements)
   - 3.1 [Quản lý phòng](#31-quản-lý-phòng-nguồn-br-01-br-02)
   - 3.2 [Quản lý khách thuê và tài khoản Người thuê](#32-quản-lý-khách-thuê-và-tài-khoản-người-thuê-nguồn-br-03-br-04b-br-04c-br-04d)
   - 3.3 [Quản lý hợp đồng thuê](#33-quản-lý-hợp-đồng-thuê-nguồn-br-05-br-07-br-07b-br-07c-br-07d-mục-531-532)
   - 3.4 [Ghi nhận chỉ số và đơn giá điện, nước](#34-ghi-nhận-chỉ-số-và-đơn-giá-điện-nước-nguồn-br-08-br-08b-br-08c-br-08d-br-09-br-10)
   - 3.5 [Quản lý hóa đơn](#35-quản-lý-hóa-đơn-nguồn-br-11-br-11a-br-11b-br-12-br-12b-br-12c)
   - 3.6 [Thanh toán và công nợ](#36-thanh-toán-và-công-nợ-nguồn-br-13-br-14)
   - 3.7 [Yêu cầu sửa chữa](#37-yêu-cầu-sửa-chữa-nguồn-br-15-br-16)
   - 3.8 [Báo cáo tổng quan](#38-báo-cáo-tổng-quan-nguồn-br-17)
   - 3.9 [Tài khoản, vai trò và đa chủ trọ](#39-tài-khoản-vai-trò-và-đa-chủ-trọ-nguồn-br-18-br-19-br-20-br-21)
   - 3.10 [Cổng thông tin Người thuê](#310-cổng-thông-tin-người-thuê-nguồn-mục-510)
   - 3.11 [Trao đổi thông tin (Chat)](#311-trao-đổi-thông-tin-chat-nguồn-mục-511)
   - 3.12 [Thông báo](#312-thông-báo-nguồn-mục-512)
4. [Yêu cầu phi chức năng (Non-Functional Requirements)](#4-yêu-cầu-phi-chức-năng-non-functional-requirements)
5. [Các điểm cần xác nhận lại với BRD/PO](#5-các-điểm-cần-xác-nhận-lại-với-brdpo)
6. [Ma trận truy vết (Traceability Matrix)](#6-ma-trận-truy-vết-traceability-matrix)
7. [Tóm tắt](#7-tóm-tắt)

---

## 1. Giới thiệu

### 1.1. Mục đích
Tài liệu này đặc tả các yêu cầu phần mềm (Software Requirements) của Hệ thống Quản lý Nhà trọ Thông minh, chuyển đổi từ BRD phiên bản 1.5. So với SRS v1.0 (chuyển đổi từ BRD v1.3), BRD v1.5 đã chốt phần lớn các điểm còn mơ hồ trước đây (giá trị mặc định, phạm vi cấu hình, cơ chế xác minh, luồng ngoại lệ), nên SRS v2.0 này bám sát BRD làm nguồn duy nhất, hạn chế tối đa việc tự suy đoán.

### 1.2. Phạm vi
SRS bao trùm toàn bộ phạm vi nghiệp vụ MVP theo BRD v1.5, bao gồm: 3 vai trò (Quản trị hệ thống, Chủ trọ, Người thuê); quản lý phòng/khách thuê/hợp đồng/hóa đơn/thanh toán/sửa chữa/báo cáo; quy trình ghi nhận chỉ số điện nước qua ảnh chụp + OCR; quy trình hóa đơn nháp và Adjustment; Cổng thông tin Người thuê; kênh trao đổi thông tin và thông báo. Các mục "Ngoài phạm vi nghiệp vụ" tại Mục 8 của BRD v1.5 tiếp tục không thuộc phạm vi SRS này (bao gồm tích hợp IoT thật, định hướng gói VIP tương lai).

### 1.3. Tài liệu tham chiếu
- BRD "Hệ thống Quản lý Nhà trọ Thông minh - Nền tảng SaaS đa chủ trọ", phiên bản 1.5.
- SRS phiên bản 1.0 (chuyển đổi từ BRD v1.3) - dùng để đối chiếu các điểm đã được làm rõ.

### 1.4. Thuật ngữ và từ viết tắt
Kế thừa toàn bộ bảng thuật ngữ tại Mục 10 của BRD v1.5 (bao gồm OCR, Chỉ số cần xác minh, Adjustment). Bổ sung riêng cho SRS:

| Từ viết tắt | Giải thích |
|---|---|
| FR | Functional Requirement - Yêu cầu chức năng |
| NFR | Non-Functional Requirement - Yêu cầu phi chức năng |
| BR | Business Rule - mã quy tắc nghiệp vụ trong BRD |
| Tenant (kỹ thuật) | Đơn vị dữ liệu cách ly của một chủ trọ trên nền tảng dùng chung (multi-tenancy) - không nhầm với vai trò "Người thuê" trong nghiệp vụ. |

### 1.5. Quy ước đánh mã
Mỗi yêu cầu chức năng được đánh mã **FR-0xx**, tăng dần không phân biệt module, kèm dòng "Nguồn" tham chiếu mã BR hoặc mục BRD tương ứng để truy vết hai chiều.

---

## 2. Mô tả tổng quan hệ thống

### 2.1. Bối cảnh sản phẩm
Ứng dụng web dùng được trên trình duyệt máy tính và điện thoại, mô hình SaaS đa chủ trọ (multi-tenant), giai đoạn đầu số lượng chủ trọ ít, tăng trưởng dần. Kiến trúc dự kiến serverless (không nêu công nghệ cụ thể trong SRS). Hệ thống có xử lý ảnh (chụp đồng hồ điện/nước theo BR-08b, ảnh minh chứng sửa chữa theo BR-15) và tác vụ OCR - các tác vụ này được xử lý bất đồng bộ, không yêu cầu phản hồi tức thời (xem NFR-01).

### 2.2. Vai trò người dùng (actors)

| Actor | Mô tả ngắn gọn | Nguồn BRD |
|---|---|---|
| Quản trị hệ thống (Admin) | Vận hành nền tảng, chỉ khóa/mở tài khoản chủ trọ, không truy cập dữ liệu nghiệp vụ chi tiết. | Mục 3, BR-20 |
| Chủ trọ (Owner) | Toàn quyền quản lý dữ liệu nghiệp vụ trong phạm vi của mình, bao gồm cấu hình tham số và xác minh chỉ số khi cần. | Mục 3, BR-18 |
| Người thuê (Tenant-user) | Người đại diện đứng tên hợp đồng, có tài khoản tra cứu/thao tác trong phạm vi hợp đồng của mình, bao gồm gửi chỉ số điện nước hàng tháng. | Mục 3, BR-19, BR-04b |
| Hệ thống (System) | Actor tự động: tạo hóa đơn, chạy OCR, đánh dấu quá hạn/nợ dồn kỳ, chuyển trạng thái hợp đồng, gửi thông báo/nhắc nhở. | Xuyên suốt |

### 2.3. Giả định và ràng buộc kế thừa từ BRD
Toàn bộ giả định tại Mục 7 và ràng buộc ngoài phạm vi tại Mục 8 của BRD v1.5 được kế thừa nguyên trạng, đặc biệt: MoMo là tích hợp giả lập ở MVP; OCR là công cụ hỗ trợ, không đảm bảo chính xác tuyệt đối (có lớp xác minh con người bù lại); không có tính năng nối lịch sử thuê xuyên hợp đồng; không hỗ trợ đổi người đại diện hợp đồng đang hoạt động; không hỗ trợ thanh toán một phần hóa đơn.

---

## 3. Yêu cầu chức năng (Functional Requirements)

### 3.1. Quản lý phòng (Nguồn: BR-01, BR-02)

**FR-001 — Tạo và xem thông tin phòng**
- *Nguồn:* BR-01
- *Actor:* Chủ trọ
- *Pre-condition:* Chủ trọ đã đăng nhập.
- *Main flow:* (1) Nhập tên phòng, diện tích, giá thuê cơ bản, mô tả. (2) Hệ thống tự sinh mã phòng duy nhất. (3) Trạng thái mặc định "Trống".
- *Exception flow:* Thiếu tên phòng → báo lỗi bắt buộc.
- *Post-condition:* Phòng xuất hiện trong danh sách, chưa gắn hợp đồng.

**FR-002 — Tự động cập nhật trạng thái phòng theo vòng đời hợp đồng**
- *Nguồn:* BR-01, liên kết Mục 5.3.2
- *Actor:* Hệ thống
- *Pre-condition:* Phòng đã gắn hợp đồng.
- *Main flow:* Hợp đồng "Đang hoạt động" hoặc "Chờ chấm dứt" (bất kể luồng thông thường hay vi phạm) → phòng "Đang cho thuê"; hợp đồng "Đã chấm dứt/Hết hạn" → phòng "Trống".
- *Exception flow:* Không áp dụng.
- *Post-condition:* Trạng thái phòng luôn phản ánh đúng tình trạng hợp đồng hiện tại.

**FR-003 — Chỉnh sửa/xóa thông tin phòng**
- *Nguồn:* BR-02
- *Actor:* Chủ trọ
- *Pre-condition:* Phòng tồn tại.
- *Main flow:* Chỉnh sửa diện tích/giá/mô tả hoặc yêu cầu xóa.
- *Exception flow:* Phòng đang có hợp đồng hiệu lực (Đang hoạt động/Chờ chấm dứt) → từ chối.
- *Post-condition:* Thông tin cập nhật, hoặc phòng chuyển trạng thái lưu trữ (FR-055) nếu xóa.

### 3.2. Quản lý khách thuê và tài khoản Người thuê (Nguồn: BR-03, BR-04b, BR-04c, BR-04d)

**FR-004 — Tạo hồ sơ khách thuê (người đại diện)**
- *Nguồn:* BR-03
- *Actor:* Chủ trọ
- *Pre-condition:* Đang tạo hợp đồng mới.
- *Main flow:* Nhập họ tên, số CCCD, số điện thoại, **địa chỉ email** (đủ 4 trường bắt buộc).
- *Exception flow:* Thiếu một trong bốn trường (đặc biệt email, vì là kênh kích hoạt bắt buộc duy nhất - FR-007) → từ chối lưu, báo lỗi cụ thể.
- *Post-condition:* Hồ sơ sẵn sàng gắn vào hợp đồng.

**FR-005 — Khai báo người đại diện và người ở cùng khi tạo hợp đồng**
- *Nguồn:* BR-04b
- *Actor:* Chủ trọ
- *Pre-condition:* Hợp đồng ở trạng thái khởi tạo (Bản nháp).
- *Main flow:* (1) Chỉ định đúng một người đại diện. (2) Thêm 0-n người ở cùng, chỉ lưu thông tin cơ bản, không cấp tài khoản.
- *Exception flow:* Không chỉ định người đại diện → không cho khởi tạo hợp đồng.
- *Post-condition:* Hợp đồng có đúng một người đại diện, danh sách người ở cùng có thể rỗng.

**FR-006 — Cập nhật danh sách người ở cùng, chặn đổi người đại diện**
- *Nguồn:* BR-04c
- *Actor:* Chủ trọ
- *Pre-condition:* Hợp đồng "Đang hoạt động".
- *Main flow:* (1) Thêm/xóa người ở cùng. (2) Hệ thống ghi lịch sử thời điểm bắt đầu/kết thúc cư trú.
- *Exception flow:* Yêu cầu đổi người đại diện của hợp đồng đang hoạt động → hệ thống từ chối tuyệt đối, hướng dẫn phải chấm dứt hợp đồng và tạo hợp đồng mới (đúng theo quy định rõ ràng của BR-04c).
- *Post-condition:* Danh sách người ở cùng và lịch sử cư trú cập nhật; điều khoản hợp đồng đã ký không đổi.

**FR-007 — Hệ thống tự động khởi tạo tài khoản Người thuê và gửi link kích hoạt qua email**
- *Nguồn:* BR-04d
- *Actor:* Hệ thống
- *Pre-condition:* Hợp đồng mới tạo thành công, có email người đại diện (bắt buộc theo BR-03).
- *Main flow:* (1) Hệ thống tạo tài khoản Người thuê gắn 1-1 với hợp đồng. (2) Gửi đường dẫn kích hoạt qua email - **kênh kích hoạt bắt buộc duy nhất ở Phiên bản 1**, không có kênh SMS thay thế. (3) Kênh in-app chỉ khả dụng sau khi tài khoản đã kích hoạt lần đầu.
- *Exception flow:* Không áp dụng (email đã là trường bắt buộc từ FR-004, không còn tình huống thiếu email).
- *Post-condition:* Tài khoản ở trạng thái "Chưa kích hoạt".

**FR-008 — Người thuê kích hoạt tài khoản qua email**
- *Nguồn:* BR-04d
- *Actor:* Người thuê
- *Pre-condition:* Đường dẫn kích hoạt hợp lệ, chưa hết hạn/chưa sử dụng.
- *Main flow:* (1) Mở đường dẫn từ email. (2) Thiết lập thông tin xác thực lần đầu (cơ chế cụ thể do đội kỹ thuật quyết định ở SDD, ngoài phạm vi BRD/SRS). (3) Tài khoản chuyển "Đã kích hoạt".
- *Exception flow:* Đường dẫn hết hạn/đã dùng → từ chối, hướng dẫn yêu cầu gửi lại.
- *Post-condition:* Người thuê đăng nhập được vào Cổng thông tin (Mục 3.10).

### 3.3. Quản lý hợp đồng thuê (Nguồn: BR-05, BR-07, BR-07b, BR-07c, BR-07d, Mục 5.3.1, 5.3.2)

**FR-009 — Tạo hợp đồng mới**
- *Nguồn:* BR-05
- *Actor:* Chủ trọ
- *Pre-condition:* Phòng "Trống"; hồ sơ người đại diện đã có (FR-004).
- *Main flow:* (1) Nhập ngày bắt đầu, tiền cọc, tiền thuê (bắt buộc); ngày kết thúc (tùy chọn). (2) Chọn phương án tính tiền tháng đầu nếu vào giữa tháng (FR-039). (3) Hệ thống lưu hợp đồng.
- *Exception flow:* Thiếu trường bắt buộc → từ chối. Có cấu hình thời gian thuê tối thiểu (FR-020) và khoảng thời gian dự kiến ngắn hơn → từ chối.
- *Post-condition:* Hợp đồng được tạo; nếu bỏ trống ngày kết thúc, hợp đồng vô thời hạn.

**FR-010 — Khóa chỉnh sửa điều khoản chính sau khi hợp đồng có hiệu lực**
- *Nguồn:* BR-05
- *Actor:* Hệ thống
- *Pre-condition:* Hợp đồng "Đang hoạt động" trở đi.
- *Main flow:* Chặn mọi yêu cầu sửa người đại diện, thời hạn, tiền thuê, tiền cọc.
- *Exception flow:* Không áp dụng - ràng buộc luôn bật, chỉ trừ danh sách người ở cùng (FR-006).
- *Post-condition:* Điều khoản chính bất biến suốt vòng đời hợp đồng.

**FR-011 — Cập nhật ngày kết thúc thực tế khi hợp đồng thanh lý**
- *Nguồn:* BR-05
- *Actor:* Hệ thống
- *Pre-condition:* Hợp đồng chuyển "Đã chấm dứt/Hết hạn" (FR-016 hoặc FR-022).
- *Main flow:* Ghi nhận ngày kết thúc thực tế.
- *Exception flow:* Không áp dụng.
- *Post-condition:* Hợp đồng có ngày kết thúc xác định.

**FR-012 — Cấu hình số ngày báo trước tối thiểu cho chấm dứt thông thường (Y)**
- *Nguồn:* BR-07b
- *Actor:* Chủ trọ
- *Pre-condition:* Đã đăng nhập.
- *Main flow:* (1) Nhập Y. (2) Hệ thống kiểm tra Y ≥ 30. (3) Lưu.
- *Exception flow:* Y < 30 → từ chối lưu, báo mức sàn bắt buộc.
- *Post-condition:* Giá trị mặc định khi chưa cấu hình: 30 ngày.

**FR-013 — Gửi yêu cầu chấm dứt hợp đồng thông thường**
- *Nguồn:* BR-07b
- *Actor:* Chủ trọ hoặc Người thuê
- *Pre-condition:* Hợp đồng "Đang hoạt động".
- *Main flow:* (1) Chọn ngày mong muốn chấm dứt. (2) Hệ thống kiểm tra khoảng cách đến hôm nay ≥ Y ngày. (3) Hợp lệ → hợp đồng chuyển "Chờ chấm dứt", gửi thông báo bên còn lại (FR-062/063).
- *Exception flow:* Khoảng cách < Y ngày → từ chối.
- *Post-condition:* Hợp đồng "Chờ chấm dứt", chờ phản hồi (FR-014/FR-016).

**FR-014 — Xác nhận "Đã tiếp nhận" yêu cầu chấm dứt**
- *Nguồn:* Mục 5.3.2
- *Actor:* Bên nhận thông báo
- *Pre-condition:* Hợp đồng "Chờ chấm dứt", chưa "Đã chấp nhận".
- *Main flow:* Bên nhận xác nhận đã tiếp nhận.
- *Exception flow:* Không áp dụng.
- *Post-condition:* Hợp đồng vẫn "Chờ chấm dứt"; bên gửi vẫn có quyền rút lại (FR-015).

**FR-015 — Rút lại yêu cầu chấm dứt (khi ở trạng thái "Đã tiếp nhận")**
- *Nguồn:* Mục 5.3.2
- *Actor:* Bên đã gửi yêu cầu (FR-013)
- *Pre-condition:* Hợp đồng "Chờ chấm dứt", chưa "Đã chấp nhận".
- *Main flow:* (1) Rút lại yêu cầu. (2) Hợp đồng về "Đang hoạt động". (3) Thông báo bên còn lại.
- *Exception flow:* Đã ở "Đã chấp nhận" → từ chối (xem FR-016).
- *Post-condition:* Hợp đồng hoạt động bình thường.

**FR-016 — Xác nhận "Đã chấp nhận" yêu cầu chấm dứt (không thể đảo ngược)**
- *Nguồn:* Mục 5.3.2
- *Actor:* Bên nhận thông báo
- *Pre-condition:* Hợp đồng "Chờ chấm dứt".
- *Main flow:* (1) Xác nhận đồng ý. (2) Hệ thống khóa khả năng rút lại/hủy từ cả hai bên. (3) Lên lịch tự động chuyển "Đã chấm dứt" đúng ngày đã thông báo. (4) Đến ngày đó, kích hoạt FR-011, FR-002, FR-018. Nếu hai bên sau đó muốn tiếp tục thuê, phải tạo hợp đồng mới sau khi hợp đồng hiện tại đã chấm dứt - hệ thống không có chức năng khôi phục.
- *Exception flow:* Không áp dụng - điểm không thể đảo ngược theo đúng BRD.
- *Post-condition:* Hợp đồng chắc chắn chấm dứt vào ngày định.

**FR-017 — Nhắc nhở định kỳ khi yêu cầu chấm dứt chưa được phản hồi**
- *Nguồn:* Mục 5.3.2
- *Actor:* Hệ thống
- *Pre-condition:* Hợp đồng "Chờ chấm dứt" (luồng thông thường), bên nhận chưa có hành động "Đã tiếp nhận"/"Đã chấp nhận".
- *Main flow:* Hệ thống không áp thời hạn bắt buộc phản hồi, nhưng tự động gửi lại thông báo nhắc nhở định kỳ (mặc định gợi ý mỗi 2-3 ngày) cho đến khi có hành động hoặc đến ngày dự kiến chấm dứt.
- *Exception flow:* Bên nhận đã phản hồi (FR-014/FR-016) → dừng nhắc nhở tương ứng với bước đã hoàn tất.
- *Post-condition:* Yêu cầu không bị "treo" âm thầm quá lâu mà không ai để ý.

**FR-018 — Cấu hình phương án xử lý tiền cọc khi chấm dứt đúng quy định**
- *Nguồn:* BR-07
- *Actor:* Chủ trọ
- *Pre-condition:* Đang cấu hình hợp đồng/chủ trọ.
- *Main flow:* Chọn (1) Cấn trừ vào tiền thuê tháng cuối, hoặc (2) Hoàn cọc trực tiếp (chủ trọ tự thực hiện, hệ thống chỉ ghi nhận).
- *Exception flow:* Không áp dụng.
- *Post-condition:* Phương án áp dụng khi hợp đồng chấm dứt đúng quy định (FR-019).

**FR-019 — Tính toán và xử lý tiền cọc khi hợp đồng chấm dứt đúng quy định, kể cả khi nợ vượt cọc**
- *Nguồn:* BR-07, Mục 5.3.1
- *Actor:* Hệ thống
- *Pre-condition:* Hợp đồng chuyển "Đã chấm dứt" qua luồng thông thường (FR-016).
- *Main flow:* (1) Tính chi phí phát sinh hợp lệ. (2) Trừ vào tiền cọc theo phương án đã cấu hình (FR-018). (3) Nếu còn dư, đánh dấu chờ hoàn cho người thuê.
- *Exception flow:* Nếu chi phí/công nợ vượt quá số cọc → hệ thống ghi nhận phần vượt là công nợ còn lại của người thuê để chủ trọ theo dõi; **không có cơ chế cưỡng chế/thu hồi tự động** (đúng theo BR-07 v1.5).
- *Post-condition:* Số tiền cọc được xử lý và ghi nhận đầy đủ trong lịch sử hợp đồng.

**FR-020 — Cấu hình thời gian thuê tối thiểu**
- *Nguồn:* BR-07c
- *Actor:* Chủ trọ
- *Pre-condition:* Đang cấu hình phòng hoặc hợp đồng.
- *Main flow:* Nhập số ngày/tháng thuê tối thiểu (tùy chọn).
- *Exception flow:* Giá trị ≤ 0 → từ chối lưu.
- *Post-condition:* Áp dụng kiểm tra tại FR-009.

**FR-021 — Cấu hình ngưỡng vi phạm và số ngày báo trước (X2) cho chấm dứt do vi phạm**
- *Nguồn:* BR-07d
- *Actor:* Chủ trọ
- *Pre-condition:* Đã đăng nhập.
- *Main flow:* (1) Cấu hình số kỳ nợ tối thiểu kích hoạt vi phạm (mặc định 1 kỳ). (2) Cấu hình X2 (mặc định **5 ngày**, gợi ý điều chỉnh trong khoảng 3-7 ngày).
- *Exception flow:* Không áp dụng mức sàn 30 ngày của FR-012 cho X2 (khác biệt có chủ đích).
- *Post-condition:* Nếu chủ trọ không tự cấu hình, hệ thống áp dụng đúng giá trị mặc định 5 ngày / ngưỡng 1 kỳ.

**FR-022 — Khởi tạo chấm dứt hợp đồng do vi phạm nghĩa vụ thanh toán**
- *Nguồn:* BR-07d
- *Actor:* Chủ trọ
- *Pre-condition:* Hợp đồng "Đang hoạt động"; số kỳ hóa đơn "quá hạn" (FR-047) đạt ngưỡng đã cấu hình (FR-021).
- *Main flow:* (1) Chủ trọ chủ động khởi tạo. (2) Hệ thống chuyển hợp đồng sang trạng thái chờ chấm dứt (luồng vi phạm), ngày chấm dứt dự kiến = hôm nay + X2 ngày. (3) Gửi thông báo người thuê. (4) Đến ngày đó, tự động chuyển "Đã chấm dứt", kích hoạt FR-011, FR-002, FR-023.
- *Exception flow:* Chưa đạt ngưỡng kỳ nợ → không cho khởi tạo, báo lý do.
- *Post-condition:* Hợp đồng chắc chắn chấm dứt đúng hạn X2 ngày; luồng này không có bước rút lại (khác FR-015), đúng theo bản chất "xử lý vi phạm" đã nêu rõ trong BRD v1.5.

**FR-023 — Cấn trừ nợ vào tiền cọc và hoàn phần dư khi chấm dứt do vi phạm**
- *Nguồn:* Mục 5.3.1
- *Actor:* Hệ thống
- *Pre-condition:* Hợp đồng chấm dứt qua luồng vi phạm (FR-022).
- *Main flow:* (1) Tính tổng nợ + chi phí phát sinh hợp lệ. (2) Trừ vào tiền cọc. (3) Phần dư (nếu có) đánh dấu bắt buộc hoàn lại người thuê.
- *Exception flow:* Nợ vượt quá cọc → áp dụng đúng nguyên tắc ghi nhận công nợ còn lại như FR-019 (không cưỡng chế thu hồi).
- *Post-condition:* Tiền cọc cấn trừ đúng, phần dư (nếu có) đánh dấu chờ hoàn.

**FR-024 — Đánh dấu "nợ dồn kỳ" mà không chặn tạo hóa đơn kỳ mới**
- *Nguồn:* Mục 5.3.1
- *Actor:* Hệ thống
- *Pre-condition:* Hợp đồng "Đang hoạt động", chuyển sang chu kỳ thanh toán mới trong khi nghĩa vụ tài chính chu kỳ trước chưa xử lý xong.
- *Main flow:* (1) Hệ thống vẫn tạo hóa đơn kỳ mới bình thường theo lịch (FR-035), **không chặn**. (2) Đồng thời gắn cờ cảnh báo "nợ dồn kỳ" lên hồ sơ hợp đồng. (3) Hiển thị nổi bật cờ này trên báo cáo công nợ (FR-050).
- *Exception flow:* Không áp dụng - đây là hành vi mặc định theo đúng quyết định đã chốt ở BRD v1.5 (khác với bản BRD v1.3 còn để ngỏ).
- *Post-condition:* Chủ trọ được cảnh báo rõ ràng, tự quyết định có áp dụng FR-021/FR-022 hay không.

### 3.4. Ghi nhận chỉ số và đơn giá điện, nước (Nguồn: BR-08, BR-08b, BR-08c, BR-08d, BR-09, BR-10)

**FR-025 — Cấu hình bậc thang giá điện/nước**
- *Nguồn:* BR-08
- *Actor:* Chủ trọ
- *Pre-condition:* Đã đăng nhập.
- *Main flow:* Thêm/sửa/xóa số bậc, ngưỡng, đơn giá cho điện và nước riêng biệt; hệ thống lưu kèm thời điểm hiệu lực.
- *Exception flow:* Ngưỡng không tăng dần, hoặc đơn giá âm → từ chối lưu.
- *Post-condition:* Cấu hình mới có hiệu lực từ thời điểm lưu, không hồi tố (xem FR-033).

**FR-026 — Hệ thống nhắc người thuê chụp ảnh chỉ số đầu kỳ**
- *Nguồn:* BR-08b
- *Actor:* Hệ thống
- *Pre-condition:* Đến mốc thời gian liên kết với ngày tạo hóa đơn đã cấu hình (FR-039).
- *Main flow:* Gửi thông báo nhắc người thuê chụp ảnh đồng hồ điện và đồng hồ nước, tải lên hệ thống (FR-062/063).
- *Exception flow:* Không áp dụng.
- *Post-condition:* Người thuê có lời nhắc rõ ràng đầu mỗi kỳ.

**FR-027 — Người thuê tải ảnh, hệ thống chạy OCR tự động điền chỉ số**
- *Nguồn:* BR-08b
- *Actor:* Người thuê, Hệ thống
- *Pre-condition:* Có nhắc nhở (FR-026) hoặc người thuê chủ động vào chức năng gửi chỉ số.
- *Main flow:* (1) Người thuê chụp/tải ảnh đồng hồ điện và nước. (2) Hệ thống chạy OCR (xử lý bất đồng bộ, xem NFR-01) và điền sẵn chỉ số nhận diện được vào ô nhập liệu tương ứng.
- *Exception flow:* OCR không nhận diện được số nào → ô nhập liệu để trống, chuyển sang FR-028 với trạng thái "cần xác minh" ngay từ đầu.
- *Post-condition:* Người thuê nhìn thấy ảnh cùng chỉ số đã điền sẵn (nếu có).

**FR-028 — Người thuê xác nhận hoặc chỉnh sửa chỉ số OCR**
- *Nguồn:* BR-08b, BR-08c
- *Actor:* Người thuê
- *Pre-condition:* Đã có kết quả từ FR-027 (kể cả trường hợp trống do OCR thất bại).
- *Main flow:* (1) Xác nhận đúng chỉ số OCR đã điền → hệ thống dùng ngay, không cần xác minh thêm (bỏ qua FR-030). (2) Hoặc chỉnh sửa lại chỉ số → hệ thống đánh dấu "cần xác minh" (FR-029).
- *Exception flow:* Chỉ số nhập/sửa nhỏ hơn chỉ số kỳ trước → áp dụng kiểm tra FR-034 trước khi cho xác nhận.
- *Post-condition:* Chỉ số ở trạng thái "Đã xác nhận, dùng ngay" hoặc "Cần xác minh".

**FR-029 — Hệ thống đánh dấu chỉ số "cần xác minh"**
- *Nguồn:* BR-08c
- *Actor:* Hệ thống
- *Pre-condition:* Người thuê chỉnh sửa chỉ số OCR (FR-028), hoặc OCR không nhận diện được (FR-027).
- *Main flow:* Gắn cờ "cần xác minh" lên bản ghi chỉ số của kỳ đó, kèm ảnh gốc và kết quả OCR (nếu có) để chủ trọ đối chiếu.
- *Exception flow:* Không áp dụng.
- *Post-condition:* Bản ghi chờ xử lý theo chế độ đã cấu hình ở FR-030.

**FR-030 — Cấu hình chế độ xử lý chỉ số cần xác minh**
- *Nguồn:* BR-08c
- *Actor:* Chủ trọ
- *Pre-condition:* Đã đăng nhập.
- *Main flow:* Chọn một trong hai chế độ áp dụng cho toàn bộ chủ trọ: (1) **Bỏ qua xác minh** - hệ thống tự động tạo/phát hành hóa đơn với chỉ số người thuê đã nhập, không chờ duyệt. (2) **Yêu cầu xác minh** - hệ thống chờ chủ trọ xác nhận/chỉnh sửa trước khi phát hành; kèm cấu hình thời gian chờ tối đa (ví dụ 30 phút/1 giờ/1 ngày).
- *Exception flow:* Không cấu hình thời gian chờ ở chế độ (2) → cần giá trị mặc định (xem Mục 5, điểm cần xác nhận).
- *Post-condition:* Cấu hình áp dụng cho mọi chỉ số "cần xác minh" phát sinh sau đó.

**FR-031 — Chủ trọ xác minh chỉ số (chế độ "Yêu cầu xác minh") trong thời gian chờ**
- *Nguồn:* BR-08c
- *Actor:* Chủ trọ, Hệ thống
- *Pre-condition:* Chế độ (2) đang bật (FR-030); có bản ghi "cần xác minh" (FR-029).
- *Main flow:* (1) Hệ thống gửi thông báo cho chủ trọ kèm ảnh, kết quả OCR, chỉ số người thuê đã nhập. (2) Chủ trọ xác nhận hoặc chỉnh sửa lại chỉ số đúng trong thời gian chờ đã cấu hình. (3) Hệ thống dùng chỉ số chủ trọ đã xác nhận để tính hóa đơn (FR-035).
- *Exception flow:* Hết thời gian chờ mà chủ trọ chưa phản hồi → hệ thống tự động phát hành hóa đơn với chỉ số người thuê đã gửi ban đầu (tránh treo vô thời hạn).
- *Post-condition:* Hóa đơn được phát hành với chỉ số cuối cùng (do chủ trọ xác nhận hoặc tự động sau timeout).

**FR-032 — Kế thừa chỉ số liên tục theo phòng qua các đời khách thuê**
- *Nguồn:* BR-08d
- *Actor:* Hệ thống
- *Pre-condition:* Hợp đồng mới bắt đầu tại một phòng đã từng có chỉ số ghi nhận trước đó (dù khách thuê trước là ai).
- *Main flow:* Chỉ số cuối kỳ của khách thuê trước tự động trở thành chỉ số khởi điểm cho khách thuê mới tại phòng đó; khách mới không cần thao tác gì thêm.
- *Exception flow:* Không áp dụng.
- *Post-condition:* Chỉ số gắn liền với phòng (không phải với hợp đồng/người thuê), liên tục qua thời gian.

**FR-033 — Xử lý chỉ số khởi điểm cho phòng hoàn toàn mới**
- *Nguồn:* BR-08d
- *Actor:* Chủ trọ, Hệ thống
- *Pre-condition:* Phòng chưa từng có bất kỳ chỉ số nào trong hệ thống.
- *Main flow:* (1) Nếu chủ trọ đã nhập chỉ số khởi điểm khi tạo phòng → dùng giá trị đó làm mốc. (2) Nếu chưa nhập, lần gửi chỉ số đầu tiên của khách thuê mới (FR-027/028) chỉ được ghi nhận làm **mốc khởi điểm**, chưa tính tiêu thụ - hóa đơn kỳ đó **không tính tiền điện/nước**.
- *Exception flow:* Không áp dụng.
- *Post-condition:* Tiêu thụ thực tế bắt đầu tính từ kỳ ghi nhận chỉ số kế tiếp, dựa trên chênh lệch so với mốc khởi điểm.

**FR-034 — Lưu lịch sử đơn giá và áp dụng đúng đơn giá theo thời điểm phát sinh**
- *Nguồn:* BR-09
- *Actor:* Hệ thống
- *Pre-condition:* Đã có ít nhất một lần thay đổi đơn giá (FR-025).
- *Main flow:* (1) Mỗi lần đơn giá đổi, lưu bản ghi lịch sử kèm thời điểm hiệu lực. (2) Khi tính hóa đơn (FR-035), dùng đúng đơn giá có hiệu lực tại kỳ phát sinh.
- *Exception flow:* Không áp dụng.
- *Post-condition:* Hóa đơn các tháng trước không bị tính lại theo đơn giá mới.

**FR-035 — Kiểm tra tính hợp lệ của chỉ số mới (áp dụng cả khi người thuê gửi và khi chủ trọ xác minh)**
- *Nguồn:* BR-10
- *Actor:* Người thuê hoặc Chủ trọ
- *Pre-condition:* Đã có chỉ số kỳ trước của phòng (từ FR-032/033).
- *Main flow:* So sánh chỉ số mới với chỉ số kỳ trước.
- *Exception flow:* Chỉ số mới < chỉ số kỳ trước → hệ thống cảnh báo, yêu cầu xác nhận lại trước khi lưu (áp dụng đồng nhất cho cả bước FR-028 và FR-031).
- *Post-condition:* Chỉ số hợp lệ được lưu, sẵn sàng tính hóa đơn.

### 3.5. Quản lý hóa đơn (Nguồn: BR-11, BR-11a, BR-11b, BR-12, BR-12b, BR-12c)

**FR-036 — Tự động tạo hóa đơn hàng tháng với chỉ số đã xác nhận/xác minh**
- *Nguồn:* BR-11
- *Actor:* Hệ thống
- *Pre-condition:* Hợp đồng "Đang hoạt động"; đến ngày tạo hóa đơn (FR-039); chỉ số điện/nước của kỳ đã sẵn sàng (đã xác nhận theo FR-028, hoặc đã xác minh xong theo FR-031 nếu chế độ xác minh đang bật).
- *Main flow:* (1) Tính tiền thuê + tiền điện + tiền nước (theo FR-032/033/034) + phụ phí khác. (2) Tạo hóa đơn gắn đúng một hợp đồng, trạng thái "Chưa thanh toán". (3) Gửi thông báo hóa đơn mới (FR-062/063).
- *Exception flow:* Chưa có chỉ số kỳ này tại đúng ngày tạo hóa đơn → chuyển sang luồng FR-037 (hóa đơn nháp), không tạo hóa đơn chính thức.
- *Post-condition:* Hóa đơn chính thức sẵn sàng cho thanh toán (Mục 3.6).

**FR-037 — Tạo hóa đơn nháp khi thiếu chỉ số tại ngày tạo hóa đơn**
- *Nguồn:* BR-11a
- *Actor:* Hệ thống
- *Pre-condition:* Đến ngày tạo hóa đơn (FR-039) nhưng chưa có chỉ số điện/nước của kỳ đó.
- *Main flow:* (1) Hệ thống tạo hóa đơn ở trạng thái **"Nháp - chờ bổ sung chỉ số"**, chỉ gồm tiền thuê phòng và phụ phí cố định (nếu có), phần điện/nước để trống. (2) **Không gửi thông báo chính thức** cho người thuê ở bước này.
- *Exception flow:* Không áp dụng.
- *Post-condition:* Hóa đơn nháp tồn tại, không tính là "hóa đơn chính thức" cho mục đích đánh dấu quá hạn (FR-047 loại trừ hóa đơn nháp).

**FR-038 — Phát hành hóa đơn chính thức khi bổ sung chỉ số còn thiếu**
- *Nguồn:* BR-11a
- *Actor:* Hệ thống
- *Pre-condition:* Có hóa đơn "Nháp" (FR-037); người thuê vừa bổ sung chỉ số (FR-027/028), đã xác minh xong nếu cần (FR-031).
- *Main flow:* (1) Hệ thống tính lại đầy đủ hóa đơn (thêm phần điện/nước). (2) Chuyển hóa đơn từ "Nháp" sang "Chưa thanh toán" (chính thức). (3) Lúc này mới gửi thông báo hóa đơn mới cho người thuê.
- *Exception flow:* Không áp dụng.
- *Post-condition:* Hóa đơn chính thức, thời điểm bắt đầu tính quá hạn (FR-047) tính từ thời điểm phát hành chính thức này, không tính từ ngày tạo bản nháp.

**FR-039 — Tính tiền thuê tháng đầu khi nhận phòng giữa tháng**
- *Nguồn:* BR-11b
- *Actor:* Hệ thống (theo phương án chọn ở FR-009)
- *Pre-condition:* Ngày bắt đầu hợp đồng không trùng đầu tháng.
- *Main flow:* Phương án (1): đơn giá ngày = tiền thuê tháng / số ngày của tháng; tiền thuê tháng đầu = đơn giá ngày × số ngày sử dụng. Phương án (2): miễn phần còn lại của tháng, thu từ kỳ kế tiếp.
- *Exception flow:* Không áp dụng.
- *Post-condition:* Hóa đơn tháng đầu phản ánh đúng phương án đã chọn riêng cho hợp đồng đó (không phải cấu hình chung toàn chủ trọ).

**FR-040 — Cấu hình ngày tạo hóa đơn trong tháng (đồng thời là mốc nhắc gửi chỉ số)**
- *Nguồn:* BR-12
- *Actor:* Chủ trọ
- *Pre-condition:* Đã đăng nhập.
- *Main flow:* Chọn ngày trong tháng để kích hoạt FR-026 (nhắc gửi chỉ số) và FR-036/037 (tạo hóa đơn).
- *Exception flow:* Không chọn → áp dụng giá trị mặc định (cần xác nhận giá trị cụ thể - xem Mục 5).
- *Post-condition:* Lịch tạo hóa đơn và nhắc chỉ số hàng tháng được thiết lập.

**FR-041 — Hủy hóa đơn chưa thanh toán và tạo hóa đơn thay thế**
- *Nguồn:* BR-12b
- *Actor:* Chủ trọ
- *Pre-condition:* Hóa đơn "Chưa thanh toán" hoặc "Quá hạn" (chưa thanh toán).
- *Main flow:* (1) Hủy hóa đơn có sai sót. (2) Cập nhật lại dữ liệu đầu vào. (3) Hệ thống tạo hóa đơn mới thay thế, giữ liên kết tham chiếu (không xóa vật lý, theo BR-21).
- *Exception flow:* Hóa đơn đã "Đã thanh toán" → từ chối, chuyển hướng sang luồng Adjustment (FR-043).
- *Post-condition:* Hóa đơn cũ ở trạng thái "Đã hủy" (lưu trữ), hóa đơn mới thay thế active.

**FR-042 — Adjustment: cập nhật trực tiếp hóa đơn chưa thanh toán**
- *Nguồn:* BR-12c
- *Actor:* Chủ trọ
- *Pre-condition:* Phát hiện sai sót (qua phản hồi ở kênh chat, FR-059) trên hóa đơn đã phát hành nhưng **chưa thanh toán**.
- *Main flow:* (1) Chủ trọ xác nhận lại chỉ số/số tiền đúng. (2) Hệ thống cập nhật trực tiếp lại hóa đơn đó theo số liệu đúng.
- *Exception flow:* Nếu hóa đơn liên quan hóa ra đã được thanh toán trong lúc xử lý → chuyển sang luồng FR-043.
- *Post-condition:* Hóa đơn phản ánh đúng số liệu, không cần tạo khoản riêng.

**FR-043 — Adjustment: tạo khoản điều chỉnh riêng cho hóa đơn đã thanh toán**
- *Nguồn:* BR-12c
- *Actor:* Chủ trọ, Hệ thống
- *Pre-condition:* Phát hiện sai sót trên hóa đơn **đã thanh toán**.
- *Main flow:* (1) Chủ trọ xác nhận số liệu đúng. (2) Hệ thống tính phần chênh lệch. (3) Hệ thống **không sửa hóa đơn cũ** (giữ nguyên lịch sử giao dịch đã hoàn tất), mà tạo một khoản Điều chỉnh (Adjustment) riêng. (4) Khoản Điều chỉnh được cộng/trừ vào hóa đơn của kỳ kế tiếp (FR-036).
- *Exception flow:* Không áp dụng.
- *Post-condition:* Hóa đơn đã thanh toán không đổi; khoản chênh lệch được phản ánh minh bạch ở kỳ sau, có thể truy vết (xem NFR-04).

### 3.6. Thanh toán và công nợ (Nguồn: BR-13, BR-14)

**FR-044 — Cấu hình chế độ xác nhận thanh toán (áp dụng cho toàn bộ hợp đồng của chủ trọ)**
- *Nguồn:* BR-13
- *Actor:* Chủ trọ
- *Pre-condition:* Đã đăng nhập.
- *Main flow:* Chọn (1) Tự động qua MoMo (giả lập ở MVP), hoặc (2) Xác nhận thủ công - áp dụng thống nhất cho **toàn bộ hợp đồng thuộc chủ trọ đó**, không tách riêng theo từng hợp đồng.
- *Exception flow:* Không áp dụng.
- *Post-condition:* Chế độ áp dụng đồng bộ cho mọi hóa đơn phát sinh sau đó.

**FR-045 — Thanh toán qua cổng MoMo (giả lập)**
- *Nguồn:* BR-13
- *Actor:* Người thuê
- *Pre-condition:* Hóa đơn "Chưa thanh toán"; chế độ tự động đang bật.
- *Main flow:* (1) Chọn thanh toán qua MoMo. (2) Hệ thống mô phỏng xác nhận giao dịch thành công. (3) Tự động đánh dấu "Đã thanh toán", ghi nhận phí giao dịch (chủ trọ chịu).
- *Exception flow:* Mô phỏng thất bại → hóa đơn giữ "Chưa thanh toán", thông báo thử lại.
- *Post-condition:* Không hỗ trợ thanh toán một phần số tiền hóa đơn.

**FR-046 — Xác nhận thanh toán thủ công**
- *Nguồn:* BR-13
- *Actor:* Chủ trọ
- *Pre-condition:* Hóa đơn "Chưa thanh toán"/"Quá hạn"; chế độ thủ công đang áp dụng.
- *Main flow:* Xác nhận đã nhận đủ tiền, đánh dấu "Đã thanh toán".
- *Exception flow:* Không áp dụng.
- *Post-condition:* Hóa đơn "Đã thanh toán", các thay đổi tiếp theo (nếu có) qua luồng Adjustment (FR-043).

**FR-047 — Đánh dấu hóa đơn quá hạn (loại trừ hóa đơn nháp)**
- *Nguồn:* BR-14
- *Actor:* Hệ thống
- *Pre-condition:* Hóa đơn **chính thức** (không phải "Nháp" - FR-037) "Chưa thanh toán" quá X ngày kể từ ngày **phát hành chính thức**.
- *Main flow:* (1) Rà soát hàng ngày. (2) Đánh dấu "Quá hạn". (3) Cập nhật báo cáo công nợ (FR-050).
- *Exception flow:* Hóa đơn đang ở trạng thái "Nháp" → không tính vào thời hạn quá hạn cho đến khi được phát hành chính thức (FR-038).
- *Post-condition:* Chủ trọ được cảnh báo; không phát sinh phí phạt/lãi tự động.

### 3.7. Yêu cầu sửa chữa (Nguồn: BR-15, BR-16)

**FR-048 — Gửi yêu cầu sửa chữa (mô tả + tối đa 1 ảnh)**
- *Nguồn:* BR-15
- *Actor:* Người thuê
- *Pre-condition:* Đã đăng nhập, hợp đồng "Đang hoạt động".
- *Main flow:* (1) Nhập mô tả sự cố, đính kèm tối đa 1 ảnh. (2) Hệ thống tạo yêu cầu trạng thái "Mới". (3) Nếu cần trao đổi thêm ảnh/thông tin/hẹn lịch, thực hiện qua kênh chat gắn với yêu cầu (FR-059), không giới hạn số ảnh trong kênh chat.
- *Exception flow:* Đính kèm quá 1 ảnh ở bước tạo yêu cầu → hệ thống từ chối ảnh vượt mức, hướng dẫn dùng kênh chat cho ảnh bổ sung.
- *Post-condition:* Chủ trọ nhận yêu cầu mới (FR-062/063). Không có chức năng đánh dấu ngày rảnh (đúng theo BR-15 v1.5).

**FR-049 — Cập nhật và theo dõi trạng thái yêu cầu sửa chữa (trạng thái kết thúc không mở lại)**
- *Nguồn:* BR-16
- *Actor:* Chủ trọ (cập nhật), Người thuê (theo dõi)
- *Pre-condition:* Yêu cầu sửa chữa tồn tại.
- *Main flow:* Chuyển trạng thái Mới → Đang xử lý → Hoàn thành, hoặc Đã hủy tại bất kỳ bước nào trước Hoàn thành.
- *Exception flow:* Yêu cầu chuyển trạng thái từ "Hoàn thành" hoặc "Đã hủy" (hai trạng thái kết thúc) sang trạng thái khác → hệ thống từ chối tuyệt đối; người thuê phải tạo yêu cầu sửa chữa mới nếu cần xử lý tiếp (đúng theo quy định rõ ràng của BR-16 v1.5).
- *Post-condition:* Cả hai bên nắm được tiến độ hiện tại.

### 3.8. Báo cáo tổng quan (Nguồn: BR-17)

**FR-050 — Xem báo cáo tổng hợp trong phạm vi chủ trọ, nổi bật nợ dồn kỳ và quá hạn**
- *Nguồn:* BR-17
- *Actor:* Chủ trọ
- *Pre-condition:* Đã đăng nhập.
- *Main flow:* Hệ thống tổng hợp số phòng theo trạng thái, doanh thu theo kỳ, công nợ; hiển thị nổi bật các hợp đồng đang bị đánh dấu "nợ dồn kỳ" (FR-024) và hóa đơn "quá hạn" (FR-047).
- *Exception flow:* Không áp dụng.
- *Post-condition:* Dữ liệu chỉ thuộc phạm vi chủ trọ đăng nhập (xem NFR-02).

### 3.9. Tài khoản, vai trò và đa chủ trọ (Nguồn: BR-18, BR-19, BR-20, BR-21)

**FR-051 — Kiểm soát phạm vi truy cập dữ liệu theo chủ trọ và theo hợp đồng**
- *Nguồn:* BR-18, BR-19
- *Actor:* Hệ thống
- *Pre-condition:* Người dùng đã đăng nhập.
- *Main flow:* Mọi truy vấn được lọc theo định danh chủ trọ (Chủ trọ) hoặc theo hợp đồng cụ thể (Người thuê) trước khi trả kết quả.
- *Exception flow:* Truy cập trực tiếp tài nguyên ngoài phạm vi → từ chối, trả lỗi không có quyền.
- *Post-condition:* Không rò rỉ dữ liệu chéo giữa các chủ trọ hoặc giữa các hợp đồng khác nhau (xem NFR-02).

**FR-052 — Khóa/mở tài khoản chủ trọ**
- *Nguồn:* BR-20
- *Actor:* Quản trị hệ thống
- *Pre-condition:* Tài khoản chủ trọ tồn tại.
- *Main flow:* Khóa hoặc mở lại khả năng đăng nhập của riêng tài khoản chủ trọ đó.
- *Exception flow:* Không áp dụng.
- *Post-condition:* Dữ liệu nghiệp vụ không bị ảnh hưởng.

**FR-053 — Duy trì quyền tra cứu của Người thuê khi chủ trọ liên kết bị khóa**
- *Nguồn:* BR-20
- *Actor:* Người thuê
- *Pre-condition:* Tài khoản chủ trọ liên kết đang bị khóa (FR-052).
- *Main flow:* Người thuê vẫn xem được hợp đồng, hóa đơn, lịch sử thanh toán của mình.
- *Exception flow:* Không áp dụng.
- *Post-condition:* Quyền tra cứu không phụ thuộc trạng thái tài khoản chủ trọ.

**FR-054 — Quản trị hệ thống chỉ xem số liệu thống kê tổng hợp**
- *Nguồn:* BR-20
- *Actor:* Quản trị hệ thống
- *Pre-condition:* Đã đăng nhập vai trò Quản trị hệ thống.
- *Main flow:* Xem số lượng chủ trọ, số phòng, trạng thái tài khoản ở mức tổng hợp.
- *Exception flow:* Cố truy vấn chi tiết dữ liệu nghiệp vụ của một chủ trọ cụ thể → từ chối.
- *Post-condition:* Không nhìn thấy dữ liệu nghiệp vụ chi tiết của bất kỳ chủ trọ nào.

**FR-055 — Lưu trữ dữ liệu, không xóa vĩnh viễn (soft delete nghiệp vụ)**
- *Nguồn:* BR-21
- *Actor:* Hệ thống
- *Pre-condition:* Chủ trọ thực hiện thao tác "xóa" trên phòng, khách thuê, hợp đồng, hóa đơn.
- *Main flow:* Chuyển bản ghi sang trạng thái "đã lưu trữ/đã hủy" thay vì xóa vật lý.
- *Exception flow:* Không áp dụng - bắt buộc cho mọi thao tác xóa các đối tượng nêu trên.
- *Post-condition:* Toàn vẹn lịch sử dữ liệu được bảo toàn phục vụ tra cứu/đối soát/tranh chấp.

### 3.10. Cổng thông tin Người thuê (Nguồn: Mục 5.10)

**FR-056 — Xem hợp đồng của mình**
- *Nguồn:* Mục 5.10 (mục 1), liên kết BR-19
- *Actor:* Người thuê
- *Pre-condition:* Đã đăng nhập (FR-008).
- *Main flow:* Xem chi tiết hợp đồng gắn với tài khoản của mình.
- *Exception flow:* Không áp dụng (đã kiểm soát ở FR-051).
- *Post-condition:* Người thuê nắm rõ tình trạng hợp đồng hiện tại.

**FR-057 — Xem hóa đơn và lịch sử thanh toán của mình**
- *Nguồn:* Mục 5.10 (mục 2), liên kết BR-19
- *Actor:* Người thuê
- *Pre-condition:* Đã đăng nhập.
- *Main flow:* Xem danh sách hóa đơn (kèm trạng thái) và lịch sử thanh toán liên quan hợp đồng của mình.
- *Exception flow:* Không áp dụng.
- *Post-condition:* Người thuê tự tra cứu công nợ mà không cần liên hệ chủ trọ.

**FR-058 — Gửi chỉ số điện/nước qua Cổng thông tin**
- *Nguồn:* Mục 5.10 (mục 3), liên kết BR-08b
- *Actor:* Người thuê
- *Pre-condition:* Hợp đồng "Đang hoạt động".
- *Main flow:* Truy cập chức năng gửi chỉ số, thực hiện theo luồng FR-026 → FR-027 → FR-028.
- *Exception flow:* Xem exception của FR-027/028/035.
- *Post-condition:* Chỉ số được ghi nhận, chờ tính hóa đơn hoặc xác minh.

**FR-059 — Giới hạn tài khoản gắn hợp đồng đã chấm dứt chỉ còn chế độ xem hợp đồng/hóa đơn**
- *Nguồn:* Mục 5.10, Mục 3
- *Actor:* Hệ thống
- *Pre-condition:* Hợp đồng gắn với tài khoản đã chuyển "Đã chấm dứt/Hết hạn".
- *Main flow:* Hệ thống chỉ giữ khả dụng hai chức năng: xem hợp đồng (FR-056) và xem hóa đơn/lịch sử thanh toán (FR-057), ở chế độ chỉ đọc.
- *Exception flow:* Tài khoản cố gắng thực hiện thao tác khác (gửi yêu cầu sửa chữa mới, chat mới, gửi chỉ số điện nước mới...) → hệ thống từ chối.
- *Post-condition:* Tài khoản của hợp đồng cũ chỉ phục vụ tra cứu lịch sử, không có thao tác nghiệp vụ mới.

### 3.11. Trao đổi thông tin (Chat) (Nguồn: Mục 5.11)

**FR-060 — Gửi/nhận tin nhắn trao đổi giữa Chủ trọ và Người thuê**
- *Nguồn:* Mục 5.11
- *Actor:* Chủ trọ, Người thuê
- *Pre-condition:* Cả hai đã đăng nhập, có hợp đồng liên kết còn hoạt động (xem giới hạn FR-059 với hợp đồng đã chấm dứt).
- *Main flow:* Hai bên trao đổi tin nhắn (văn bản, có thể kèm ảnh) phục vụ hỏi đáp, phản hồi hóa đơn (liên kết FR-042/043), trao đổi thêm về sửa chữa (liên kết FR-048), hẹn lịch, nhắc thanh toán không chính thức.
- *Exception flow:* Không áp dụng - kênh này không tự động thay đổi trạng thái bất kỳ nghiệp vụ nào (đúng giới hạn của Mục 5.11 BRD).
- *Post-condition:* Lịch sử trao đổi được lưu lại giữa hai bên.

**FR-061 — Tin nhắn hệ thống tự động gắn với sự kiện nghiệp vụ**
- *Nguồn:* Mục 5.11
- *Actor:* Hệ thống
- *Pre-condition:* Có sự kiện nghiệp vụ phát sinh (hóa đơn mới, yêu cầu chấm dứt hợp đồng, nhắc gửi chỉ số điện nước...).
- *Main flow:* Hệ thống tự động chèn tin nhắn thông tin vào kênh trao đổi giữa hai bên liên quan.
- *Exception flow:* Không áp dụng.
- *Post-condition:* Hai bên nắm được tiến độ mà không cần chủ động hỏi.

### 3.12. Thông báo (Nguồn: Mục 5.12)

**FR-062 — Gửi thông báo trong ứng dụng (in-app)**
- *Nguồn:* Mục 5.12
- *Actor:* Hệ thống
- *Pre-condition:* Có sự kiện cần thông báo (hóa đơn mới, nhắc gửi chỉ số, chỉ số cần xác minh, cập nhật yêu cầu sửa chữa, yêu cầu chấm dứt hợp đồng, hóa đơn quá hạn, nợ dồn kỳ...).
- *Main flow:* Tạo thông báo hiển thị trong ứng dụng khi người dùng đăng nhập lần kế tiếp hoặc theo thời gian thực nếu đang trực tuyến.
- *Exception flow:* Không áp dụng.
- *Post-condition:* Người dùng thấy thông báo chưa đọc trong ứng dụng.

**FR-063 — Gửi thông báo qua email (bao gồm kênh bắt buộc cho kích hoạt tài khoản)**
- *Nguồn:* Mục 5.12, liên kết BR-04d
- *Actor:* Hệ thống
- *Pre-condition:* Có sự kiện cần thông báo; người dùng có email (bắt buộc theo BR-03, không còn trường hợp thiếu email).
- *Main flow:* Gửi email tóm tắt sự kiện kèm đường dẫn vào ứng dụng. Riêng luồng kích hoạt tài khoản lần đầu (FR-007), email là kênh **bắt buộc duy nhất**, không có kênh SMS thay thế.
- *Exception flow:* Không áp dụng (khác với SRS v1.0, vì email nay là trường bắt buộc).
- *Post-condition:* Người dùng nhận thông báo ngoài ứng dụng.

---

## 4. Yêu cầu phi chức năng (Non-Functional Requirements)

| Mã | Hạng mục | Mô tả |
|---|---|---|
| NFR-01 | Hiệu năng | API đọc dữ liệu thông thường (danh sách phòng, hóa đơn, báo cáo) phản hồi trong 1-2 giây ở điều kiện tải thấp giai đoạn MVP. Riêng tác vụ OCR (FR-027) và các tác vụ nặng khác (tạo hóa đơn hàng loạt cuối kỳ - FR-036/037, tính báo cáo tổng hợp) được xử lý **bất đồng bộ**: người dùng tải ảnh lên và nhận phản hồi ngay rằng ảnh đã nhận, kết quả OCR điền vào form có thể xuất hiện sau vài giây đến vài chục giây mà không chặn thao tác khác của người dùng. |
| NFR-02 | Bảo mật - Cách ly dữ liệu đa chủ trọ (multi-tenancy) | **Yêu cầu phi chức năng quan trọng nhất của hệ thống.** Mọi dữ liệu nghiệp vụ (phòng, khách thuê, hợp đồng, hóa đơn, thanh toán, chỉ số điện nước, ảnh chụp đồng hồ, yêu cầu sửa chữa, tin nhắn) phải gắn với đúng một chủ trọ và được lọc theo định danh chủ trọ ở mọi lớp truy xuất dữ liệu (BR-18). Tài khoản Người thuê chỉ được cấp quyền giới hạn trong đúng phạm vi hợp đồng gắn với tài khoản (BR-19), và bị thu hẹp thêm về chỉ đọc khi hợp đồng đã chấm dứt (FR-059). Phải kiểm chứng bằng kiểm thử cố ý truy cập chéo (một chủ trọ/người thuê cố truy cập tài nguyên ngoài phạm vi qua thao tác trực tiếp) và bị từ chối ở mọi trường hợp. Quyền của Quản trị hệ thống giới hạn ở mức chỉ đọc số liệu tổng hợp (BR-20), không có đường truy cập nào cho phép xem dữ liệu nghiệp vụ chi tiết của một chủ trọ cụ thể. |
| NFR-03 | Khả năng mở rộng (Scalability) | Chịu tải tăng dần theo số lượng chủ trọ mà không cần thiết kế lại kiến trúc cốt lõi ở giai đoạn đầu. Khối lượng ảnh chụp/OCR tăng theo số phòng active không được làm chậm các tác vụ đồng bộ (đọc dữ liệu, thanh toán) của chủ trọ khác - tác vụ OCR cần cách ly về tải xử lý (queue riêng) khỏi luồng tương tác chính. |
| NFR-04 | Độ tin cậy dữ liệu và khả năng truy vết (Data Integrity & Audit Trail) | Không xóa vật lý dữ liệu nghiệp vụ quan trọng (BR-21) - mọi thao tác xóa/hủy phải lưu vết (ai, khi nào, dữ liệu trước khi đổi). Các thao tác tài chính quan trọng phải có nhật ký đầy đủ, đặc biệt: xử lý cọc (FR-019/FR-023), khoản Adjustment (FR-042/FR-043 - phải truy vết được hóa đơn gốc, số liệu sai, số liệu đúng, và hóa đơn kỳ sau đã áp dụng điều chỉnh), xác nhận thanh toán (FR-045/FR-046), và lịch sử chỉnh sửa chỉ số (ai sửa - người thuê hay chủ trọ, từ giá trị OCR nào sang giá trị nào). |
| NFR-05 | Khả năng cấu hình theo từng chủ trọ (Multi-tenant Configuration) | Toàn bộ tham số "Có thể cấu hình" (bậc thang điện/nước, số ngày báo trước hai loại chấm dứt, ngày tạo hóa đơn, ngưỡng quá hạn, chế độ/thời gian chờ xác minh chỉ số, chế độ xác nhận thanh toán, thời gian thuê tối thiểu, phương án tính tiền giữa tháng theo hợp đồng) phải lưu và áp dụng riêng theo từng chủ trọ (hoặc theo hợp đồng đối với tham số cấp hợp đồng), không dùng chung giá trị toàn hệ thống. Giá trị mặc định (Y=30, X2=5, ngưỡng vi phạm=1 kỳ) phải áp dụng tự động khi chủ trọ chưa tự cấu hình. |
| NFR-06 | Độ tin cậy/chấp nhận được của OCR | OCR (FR-027) là công cụ **hỗ trợ giảm thao tác nhập tay**, không yêu cầu độ chính xác tuyệt đối, vì đã có lớp xác minh con người bù lại ngay sau đó (người thuê xác nhận/sửa - FR-028; chủ trọ xác minh nếu cần - FR-031). Hệ thống cần đo lường và có thể theo dõi tỷ lệ chỉnh sửa thủ công trên tổng số lần OCR chạy (tỷ lệ "cần xác minh") để đánh giá chất lượng OCR theo thời gian, nhưng không đặt ngưỡng SLA cứng về độ chính xác OCR cho MVP. |
| NFR-07 | Độ sẵn sàng (Availability) | Hệ thống là công cụ vận hành hàng ngày; cần tránh gián đoạn kéo dài quanh các mốc quan trọng theo chu kỳ: ngày tạo hóa đơn đã cấu hình (FR-040), và các mốc timeout tự động (FR-031 xác minh chỉ số, FR-022/FR-016 chuyển trạng thái hợp đồng đúng ngày). |
| NFR-08 | Khả năng sử dụng (Usability) | Giao diện tiếng Việt, phù hợp người dùng phổ thông. Màn hình chụp ảnh chỉ số cần hướng dẫn rõ ràng (góc chụp, ánh sáng) để tăng tỷ lệ OCR đọc đúng. Màn hình cấu hình tham số cần hiển thị rõ giá trị mặc định gợi ý (Y=30 ngày, X2=5 ngày, ngưỡng vi phạm=1 kỳ...). |
| NFR-09 | Đa nền tảng qua trình duyệt | Giao diện web hiển thị và thao tác tốt trên trình duyệt điện thoại, đặc biệt màn hình chụp ảnh chỉ số điện nước (FR-027) và ảnh yêu cầu sửa chữa (FR-048) - ưu tiên hỗ trợ truy cập camera trực tiếp từ trình duyệt di động. |

---

## 5. Các điểm cần xác nhận lại với BRD/PO

So với SRS v1.0 (12 điểm cần xác nhận), danh sách lần này **ngắn hơn đáng kể** vì BRD v1.5 đã chốt phần lớn giá trị mặc định và luồng ngoại lệ còn để ngỏ trước đây (đổi người đại diện, kênh kích hoạt, nợ vượt cọc, chỉ số kế thừa, trạng thái kết thúc của yêu cầu sửa chữa, cơ chế nợ dồn kỳ...). Các điểm còn lại chỉ là những chi tiết nhỏ, chủ yếu về giá trị mặc định cụ thể chưa được nêu, không phải mâu thuẫn logic nghiệp vụ.

| # | Điểm cần xác nhận | Liên quan | Vì sao chưa đủ rõ |
|---|---|---|---|
| 1 | Giá trị mặc định cụ thể của "thời gian chờ xác minh tối đa" ở chế độ "Yêu cầu xác minh" (BR-08c) | FR-030, FR-031 | BRD chỉ nêu ví dụ minh họa (30 phút/1 giờ/1 ngày) chứ chưa chốt một giá trị mặc định áp dụng khi chủ trọ chưa tự cấu hình. |
| 2 | Giá trị mặc định cụ thể của "ngày tạo hóa đơn trong tháng" khi chủ trọ chưa tự cấu hình (BR-12) | FR-040 | BRD chỉ nêu ví dụ minh họa (ngày 1 hoặc ngày 5), chưa chốt giá trị mặc định duy nhất. |
| 3 | Trường hợp hóa đơn ở trạng thái "Nháp - chờ bổ sung chỉ số" (BR-11a) kéo dài nhiều kỳ liên tiếp mà người thuê không bao giờ gửi chỉ số | FR-037 | BRD mô tả luồng bổ sung chỉ số nhưng chưa nêu cơ chế xử lý nếu người thuê không hợp tác kéo dài (có cần chủ trọ tự can thiệp nhập tay thay, hay có ngưỡng số kỳ nháp liên tiếp để cảnh báo đặc biệt) - vì hóa đơn nháp không tính vào "quá hạn" nên hiện chưa có cơ chế cảnh báo tương ứng cho trường hợp này. |
| 4 | Khoản Adjustment (BR-12c) được dồn vào đúng "hóa đơn kỳ kế tiếp" - trường hợp hợp đồng chấm dứt trước khi có kỳ kế tiếp | FR-043 | BRD không đề cập cách xử lý khoản Adjustment còn treo nếu hợp đồng kết thúc trước khi kỳ hóa đơn tiếp theo được tạo ra. |

---

## 6. Ma trận truy vết (Traceability Matrix)

| BR-xx | FR tương ứng | Ghi chú |
|---|---|---|
| BR-01 | FR-001, FR-002 | Tạo/xem phòng + tự động cập nhật trạng thái theo hợp đồng. |
| BR-02 | FR-003 | Bao gồm ràng buộc chặn sửa/xóa khi có hợp đồng hiệu lực. |
| BR-03 | FR-004 | Bổ sung email là trường bắt buộc (thay đổi so với v1.3). |
| BR-04b | FR-005 | Người đại diện + người ở cùng. |
| BR-04c | FR-006 | Cập nhật người ở cùng + chặn tuyệt đối đổi người đại diện. |
| BR-04d | FR-007, FR-008 | Khởi tạo tài khoản (hệ thống) + kích hoạt qua email bắt buộc (người thuê). |
| BR-05 | FR-009, FR-010, FR-011 | Tạo hợp đồng; khóa điều khoản chính; cập nhật ngày kết thúc thực tế. |
| BR-07 | FR-018, FR-019 | Cấu hình phương án cọc + xử lý cọc khi chấm dứt đúng quy định, bao gồm trường hợp nợ vượt cọc. |
| BR-07b | FR-012, FR-013, FR-014, FR-015, FR-016, FR-017 | Toàn bộ quy trình chấm dứt thông thường + cơ chế nhắc nhở định kỳ (mới ở v1.5). |
| BR-07c | FR-020 | Cấu hình thời gian thuê tối thiểu. |
| BR-07d | FR-021, FR-022, FR-023 | Cấu hình ngưỡng/X2 (mặc định 5 ngày); khởi tạo chấm dứt do vi phạm; cấn trừ và hoàn cọc dư. |
| BR-08 | FR-025 | Cấu hình bậc thang. |
| BR-08b | FR-026, FR-027, FR-028 | Nhắc chụp ảnh; OCR tự động điền; người thuê xác nhận/chỉnh sửa. |
| BR-08c | FR-029, FR-030, FR-031 | Đánh dấu cần xác minh; cấu hình chế độ; luồng xác minh có timeout. |
| BR-08d | FR-032, FR-033 | Kế thừa chỉ số theo phòng; xử lý phòng hoàn toàn mới. |
| BR-09 | FR-034 | Lưu lịch sử đơn giá, áp dụng đúng thời điểm. |
| BR-10 | FR-035 | Kiểm tra chỉ số hợp lệ, áp dụng cả khi gửi và khi xác minh. |
| BR-11 | FR-036 | Tự động tạo hóa đơn hàng tháng. |
| BR-11a | FR-037, FR-038 | Hóa đơn nháp khi thiếu chỉ số + phát hành chính thức khi bổ sung. |
| BR-11b | FR-039 | Tính tiền thuê tháng đầu khi vào giữa tháng, theo từng hợp đồng. |
| BR-12 | FR-040 | Cấu hình ngày tạo hóa đơn, đồng thời là mốc nhắc gửi chỉ số. |
| BR-12b | FR-041 | Hủy/thay thế hóa đơn chưa thanh toán. |
| BR-12c | FR-042, FR-043 | Adjustment: 2 nhánh (chưa thanh toán / đã thanh toán). |
| BR-13 | FR-044, FR-045, FR-046 | Cấu hình chế độ (theo chủ trọ) + 2 luồng xác nhận thanh toán. |
| BR-14 | FR-047 | Đánh dấu hóa đơn quá hạn, loại trừ hóa đơn nháp. |
| BR-15 | FR-048 | Gửi yêu cầu sửa chữa, tối đa 1 ảnh, không có tính năng ngày rảnh. |
| BR-16 | FR-049 | Trạng thái xử lý, hai trạng thái kết thúc không mở lại. |
| BR-17 | FR-050 | Báo cáo tổng hợp, nổi bật nợ dồn kỳ và quá hạn. |
| BR-18 | FR-051 | Cách ly dữ liệu theo chủ trọ (kết hợp NFR-02). |
| BR-19 | FR-051, FR-056, FR-057, FR-059 | Phạm vi truy cập của người thuê + các chức năng Cổng thông tin liên quan. |
| BR-20 | FR-052, FR-053, FR-054 | Khóa/mở tài khoản; duy trì quyền tra cứu người thuê; giới hạn quyền xem Admin. |
| BR-21 | FR-055 | Không xóa vật lý (kết hợp NFR-04). |

**Ghi chú bổ sung:** FR-058 (gửi chỉ số qua Cổng thông tin), FR-060, FR-061 (Chat), FR-062, FR-063 (Thông báo) có nguồn từ Mục 5.10-5.12 của BRD (không gắn mã BR-xx cụ thể) nhưng vẫn được đưa vào SRS đầy đủ để phủ hết yêu cầu nghiệp vụ.

---

## 7. Tóm tắt

- **Tổng số FR đã tạo:** 63 (FR-001 đến FR-063) - tăng so với 49 FR của SRS v1.0, chủ yếu do bổ sung toàn bộ luồng OCR/xác minh chỉ số (FR-026 đến FR-035), luồng hóa đơn nháp (FR-037, FR-038) và luồng Adjustment (FR-042, FR-043).
- **Tổng số NFR đã liệt kê:** 9 (NFR-01 đến NFR-09), trong đó NFR-02 (cách ly dữ liệu đa chủ trọ) vẫn là quan trọng nhất; bổ sung mới NFR-06 (độ tin cậy chấp nhận được của OCR) so với SRS v1.0.
- **Số BR trong BRD v1.5 được truy vết:** 32/32 (100%), bao gồm toàn bộ mã mới (BR-08b, BR-08c, BR-08d, BR-11a, BR-12c) - không có BR nào bị bỏ sót trong Ma trận truy vết ở Mục 6.
- **Số điểm cần xác nhận lại với BRD/PO:** 4 điểm (Mục 5) - **giảm mạnh so với 12 điểm ở SRS v1.0**, đúng như kỳ vọng vì BRD v1.5 đã chốt hầu hết các quyết định nghiệp vụ còn để ngỏ trước đây (đổi người đại diện, kênh kích hoạt tài khoản, nợ vượt cọc, cơ chế nợ dồn kỳ, kế thừa chỉ số, trạng thái kết thúc yêu cầu sửa chữa, phạm vi cấu hình BR-13...). 4 điểm còn lại chỉ là giá trị mặc định cụ thể chưa nêu (thời gian chờ xác minh, ngày tạo hóa đơn mặc định) và 2 trường hợp biên hiếm gặp (hóa đơn nháp treo nhiều kỳ, Adjustment khi hợp đồng kết thúc trước kỳ kế tiếp) - không phải mâu thuẫn logic nghiệp vụ như các điểm ở bản trước.