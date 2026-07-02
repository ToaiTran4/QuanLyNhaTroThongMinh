# TÀI LIỆU YÊU CẦU NGHIỆP VỤ
### (Business Requirements Document - BRD)
## Hệ thống Quản lý Nhà trọ Thông minh - Nền tảng SaaS đa chủ trọ
**Phiên bản 1.5 - MVP**
Ngày: 02/07/2026

---

## 1. Thông tin chung

| Hạng mục | Nội dung |
|---|---|
| Tên dự án | Hệ thống Quản lý Nhà trọ Thông minh - Nền tảng SaaS đa chủ trọ |
| Loại tài liệu | Tài liệu Yêu cầu Nghiệp vụ (Business Requirements Document) |
| Phiên bản | 1.5 - Giai đoạn MVP |
| Ngày soạn | 02/07/2026 |
| Người soạn | Bộ phận phân tích nghiệp vụ |
| Tài liệu liên quan | BRD phiên bản 1.4; SRS phiên bản 1.0 (chuyển đổi từ BRD v1.3) |
| Tóm tắt thay đổi so với v1.4 | Bổ sung toàn bộ nghiệp vụ ghi chỉ số điện/nước qua chụp ảnh + OCR (BR-08b, BR-08c), nguyên tắc chỉ số gắn liền với phòng và liên tục qua các đời khách thuê (BR-08d); bổ sung luồng ngoại lệ điều chỉnh hóa đơn sau phát hành/thanh toán - Adjustment (BR-12c); đơn giản hóa BR-15 (yêu cầu sửa chữa): giới hạn tối đa 1 ảnh, bỏ tính năng đánh dấu ngày rảnh, chỉ còn mô tả + hình ảnh + kênh chat; bổ sung ghi chú ngoài phạm vi về tích hợp IoT đo tự động (định hướng gói VIP tương lai); chính thức hóa 12 quyết định MVP từng nêu ở SRS v1.0 (Mục 5) thành quy tắc nghiệp vụ chính thức trong BRD, để BRD là nguồn duy nhất cần tham chiếu khi viết lại SRS. |

---

## 2. Mục đích của tài liệu

Tài liệu này mô tả các yêu cầu nghiệp vụ (business requirements) của hệ thống dưới góc nhìn của người vận hành nhà trọ thực tế, không đi vào chi tiết kỹ thuật (công nghệ, cơ sở dữ liệu, giao diện lập trình...). Mục tiêu là để chủ trọ và các bên liên quan về nghiệp vụ có thể đọc, hiểu và xác nhận rằng hệ thống sẽ hỗ trợ đúng và đủ những gì họ cần trước khi đội kỹ thuật bắt đầu thiết kế và xây dựng.

Sau khi tài liệu này được xác nhận, đội phân tích sẽ chuyển các yêu cầu nghiệp vụ (mã BR-xx) thành đặc tả kỹ thuật chi tiết (SRS) để đội phát triển thực hiện.

---

## 3. Đối tượng sử dụng hệ thống

| Vai trò | Mô tả công việc thực tế |
|---|---|
| Quản trị hệ thống | Bộ phận vận hành nền tảng SaaS (không thuộc về một chủ trọ cụ thể nào). Có quyền khóa/mở tài khoản của chủ trọ khi cần (ví dụ vi phạm điều khoản sử dụng, nợ phí nền tảng...). Chỉ xem được các số liệu tổng hợp mang tính thống kê (số lượng chủ trọ, số phòng, trạng thái tài khoản...), không được xem chi tiết dữ liệu nghiệp vụ (phòng, hợp đồng, hóa đơn cụ thể) của bất kỳ chủ trọ nào. |
| Chủ trọ | Người sở hữu/quản lý nhà trọ, đăng ký sử dụng hệ thống riêng cho mình. Toàn quyền quản lý phòng, khách thuê, hợp đồng, hóa đơn, công nợ, sửa chữa và xem báo cáo trong phạm vi nhà trọ của mình. |
| Người thuê | Khách đang thuê phòng của một chủ trọ. Được tự tra cứu thông tin phòng, hợp đồng, hóa đơn của mình, thanh toán, gửi yêu cầu sửa chữa, gửi yêu cầu chấm dứt hợp đồng, gửi chỉ số điện/nước hàng tháng và trao đổi thông tin với chủ trọ qua hệ thống. |

> **Lưu ý:** Mỗi hợp đồng thuê tương ứng với một tài khoản Người thuê duy nhất. Hệ thống không hỗ trợ gia hạn hợp đồng: nếu một người thuê tiếp tục thuê (dù cùng phòng hay phòng khác) bằng một hợp đồng mới, hệ thống sẽ tạo một tài khoản Người thuê mới gắn với hợp đồng mới đó, không hỗ trợ đổi người đại diện trên một hợp đồng đang hoạt động. Tài khoản của hợp đồng cũ chỉ giữ quyền xem (chỉ đọc) hợp đồng, hóa đơn và lịch sử thanh toán của chính hợp đồng đó, không được thực hiện bất kỳ thao tác nào khác (gửi yêu cầu sửa chữa mới, chat mới, gửi chỉ số điện nước...). Đây là nguyên tắc duy nhất chi phối việc tách tài khoản theo hợp đồng; hệ thống không có tính năng nối hoặc tổng hợp lịch sử thuê của cùng một khách qua nhiều hợp đồng khác nhau ở Phiên bản 1.

---

## 4. Quy trình nghiệp vụ hiện tại (trước khi có hệ thống)

Hiện nay chủ trọ đang vận hành hoàn toàn thủ công, cụ thể:

- Ghi chép thông tin phòng, khách thuê, hợp đồng trên Excel hoặc sổ tay.
- Mỗi tháng tự đi ghi chỉ số điện/nước từng phòng, tự tính tiền bằng tay, dễ nhầm khi có nhiều mức giá khác nhau.
- Nhắc khách đóng tiền qua điện thoại hoặc Zalo, dễ quên hoặc bỏ sót.
- Khi khách báo hỏng hóc, chủ trọ ghi nhớ hoặc ghi giấy, không có cách theo dõi tiến độ xử lý rõ ràng.
- Không có báo cáo tổng hợp doanh thu, công nợ theo thời gian thực - phải tự cộng sổ khi cần biết.

Hệ thống mới sẽ số hóa toàn bộ quy trình trên, đồng thời cho phép nhiều chủ trọ khác nhau cùng sử dụng chung nền tảng, mỗi chủ trọ chỉ thấy và quản lý dữ liệu của riêng mình.

---

## 5. Yêu cầu nghiệp vụ chi tiết

Mỗi yêu cầu nghiệp vụ được đánh mã (BR-xx) để tiện tham chiếu ở các tài liệu kỹ thuật sau này. Cột "Loại" cho biết quy tắc đó là cố định trong hệ thống, hay là tham số chủ trọ có thể tự thiết lập theo ý mình (không lập trình cứng trong hệ thống).

### 5.1. Quản lý phòng

| Mã | Tên quy tắc | Mô tả | Loại |
|---|---|---|---|
| BR-01 | Trạng thái phòng | Mỗi phòng thuộc về đúng một chủ trọ, có một trong các trạng thái: Trống / Đang cho thuê / Đang sửa chữa. Mỗi phòng có mã phòng do hệ thống tự sinh để đảm bảo không trùng lặp, và tên phòng do chủ trọ tự đặt để dễ nhận diện. | Cố định |
| BR-02 | Chỉnh sửa thông tin phòng | Chủ trọ có thể thêm, sửa, xóa thông tin phòng (diện tích, giá thuê cơ bản, mô tả...) bất kỳ lúc nào, trừ khi phòng đang có hợp đồng hiệu lực. | Cố định |

> **Lưu ý:** Trong phạm vi hệ thống, mỗi chủ trọ chỉ quản lý một địa điểm nhà trọ duy nhất. Vì vậy hệ thống không có khái niệm "Nhà trọ/Tòa nhà" để nhóm phòng theo nhiều địa chỉ khác nhau - mọi phòng thuộc trực tiếp về chủ trọ, và các báo cáo được tổng hợp trên toàn bộ số phòng của chủ trọ đó. Việc hỗ trợ một chủ trọ quản lý nhiều địa điểm sẽ được xem xét ở các phiên bản mở rộng sau.

### 5.2. Quản lý khách thuê

| Mã | Tên quy tắc | Mô tả | Loại |
|---|---|---|---|
| BR-03 | Thông tin bắt buộc | Hồ sơ khách thuê bắt buộc có họ tên, số CCCD, số điện thoại **và địa chỉ email** để phục vụ xác minh, liên hệ và khởi tạo tài khoản Người thuê (xem BR-04d). | Cố định |
| BR-04b | Người ở cùng (đồng cư trú) | Một hợp đồng có thể có nhiều người cùng ở, nhưng chỉ một người đại diện đứng tên hợp đồng và được cấp tài khoản Người thuê để dùng hệ thống. Những người ở cùng còn lại chỉ được lưu thông tin cơ bản để phục vụ quản lý cư trú nội bộ của chủ trọ, không được cấp tài khoản đăng nhập và không có quyền truy cập hệ thống. | Cố định |
| BR-04c | Cập nhật danh sách người ở cùng | Danh sách người ở cùng được phép cập nhật trong thời gian hợp đồng còn hiệu lực để phản ánh đúng tình trạng cư trú thực tế. Hệ thống lưu lại lịch sử thời điểm bắt đầu/kết thúc cư trú của từng người. Việc này không làm thay đổi nội dung hợp đồng đã ký (người đại diện, thời hạn, tiền thuê, tiền cọc). Hệ thống không hỗ trợ đổi người đại diện của một hợp đồng đang hoạt động - muốn đổi người đại diện, phải chấm dứt hợp đồng hiện tại và tạo hợp đồng mới. | Cố định |
| BR-04d | Khởi tạo tài khoản Người thuê | Người thuê không tự đăng ký tài khoản. Tài khoản Người thuê chỉ được tạo khi có hợp đồng gắn với người đó: khi chủ trọ tạo hợp đồng mới, hệ thống tự động tạo tài khoản Người thuê tương ứng và gửi đường dẫn kích hoạt qua email của người đại diện (bắt buộc phải có theo BR-03) và đồng thời qua kênh trong ứng dụng một khi tài khoản đã kích hoạt lần đầu. Do người thuê chưa đăng nhập được trước khi kích hoạt, **email là kênh kích hoạt bắt buộc duy nhất ở Phiên bản 1**; hệ thống không hỗ trợ kích hoạt qua SMS. Người thuê kích hoạt tài khoản bằng đường dẫn nhận qua email. Cơ chế xác thực cụ thể (mật khẩu, liên kết đăng nhập một lần...) do đội kỹ thuật quyết định ở giai đoạn thiết kế, không thuộc phạm vi BRD. | Cố định |

### 5.3. Quản lý hợp đồng thuê

| Mã | Tên quy tắc | Mô tả | Loại |
|---|---|---|---|
| BR-05 | Thông tin hợp đồng | Hợp đồng bắt buộc có ngày bắt đầu, số tiền cọc, tiền thuê hàng tháng. Ngày kết thúc là tùy chọn: nếu chủ trọ nhập, hợp đồng có thời hạn xác định; nếu để trống, hợp đồng được xem là vô thời hạn cho đến khi được chấm dứt hoặc thanh lý (khi đó hệ thống mới cập nhật ngày kết thúc thực tế). Sau khi hợp đồng có hiệu lực, các điều khoản chính (người đại diện, thời hạn thuê, tiền thuê, tiền cọc...) không được phép chỉnh sửa; chỉ danh sách người ở cùng (BR-04c) được phép cập nhật. | Có thể cấu hình |
| BR-07 | Xử lý tiền cọc khi chấm dứt hợp đồng đúng quy định | Khi hợp đồng được chấm dứt đúng quy trình (đã báo trước đủ số ngày theo BR-07b), khách thuê đủ điều kiện được hoàn tiền cọc sau khi trừ các khoản chi phí phát sinh (nếu có, do chủ trọ tự ghi nhận). Chủ trọ tự chọn một trong hai phương án áp dụng: (1) Cấn trừ tiền cọc vào tiền thuê tháng cuối, hoặc (2) Hoàn tiền cọc trực tiếp cho khách (tiền mặt hoặc chuyển khoản, do chủ trọ tự thực hiện, hệ thống chỉ ghi nhận việc hoàn). Nếu chi phí phát sinh và công nợ vượt quá số tiền cọc hiện có, phần vượt được hệ thống ghi nhận là công nợ còn lại của khách thuê để chủ trọ theo dõi; Phiên bản 1 không có cơ chế cưỡng chế hay tự động thu hồi phần công nợ này. | Có thể cấu hình |
| BR-07b | Chấm dứt hợp đồng thông thường (đúng quy trình) | Cả chủ trọ và người thuê đều có quyền đơn phương chấm dứt hợp đồng thông thường (kể cả khi hợp đồng chưa hết hạn hoặc là hợp đồng vô thời hạn), với điều kiện báo trước tối thiểu Y ngày. Giá trị Y do từng chủ trọ tự thiết lập, nhưng không được thấp hơn mức sàn tối thiểu theo quy định pháp luật hiện hành (mặc định 30 ngày); nếu chủ trọ nhập giá trị nhỏ hơn mức sàn, hệ thống cảnh báo và từ chối lưu. Quy trình chấm dứt áp dụng thống nhất cho cả hai bên (xem quy trình xử lý yêu cầu chấm dứt ở mục 5.3.2). | Có thể cấu hình (có sàn tối thiểu) |
| BR-07c | Thời gian thuê tối thiểu | Chủ trọ có thể (không bắt buộc) thiết lập số ngày/tháng thuê tối thiểu cho từng phòng hoặc từng hợp đồng. Nếu có thiết lập, hệ thống không cho tạo hợp đồng ngắn hơn mức này. Nếu không thiết lập, không giới hạn thời gian thuê tối thiểu. | Có thể cấu hình |
| BR-07d | Chấm dứt hợp đồng do vi phạm nghĩa vụ thanh toán | Khi khách thuê nợ tiền thuê từ một chu kỳ thanh toán trở lên (mặc định ngưỡng kích hoạt là 1 chu kỳ, chủ trọ có thể tự điều chỉnh) và hóa đơn đã bị đánh dấu quá hạn (theo BR-14) mà vẫn chưa thanh toán, chủ trọ có quyền chủ động khởi tạo chấm dứt hợp đồng do vi phạm. Trường hợp này KHÔNG áp dụng mức sàn báo trước tối thiểu 30 ngày của BR-07b, vì bản chất là chấm dứt do vi phạm chứ không phải chấm dứt tự nguyện. Thời gian báo trước trong trường hợp này là X2 ngày, mặc định là **5 ngày** khi chủ trọ chưa tự cấu hình, do chủ trọ tự điều chỉnh trong khoảng gợi ý 3-7 ngày. Sau thời điểm báo trước, hợp đồng chấm dứt và khách thuê phải bàn giao phòng. | Có thể cấu hình (không áp dụng sàn 30 ngày, mặc định 5 ngày) |

#### 5.3.1. Nguyên tắc xử lý nghĩa vụ tài chính theo chu kỳ thuê

Tiền cọc đóng vai trò là khoản bảo đảm nghĩa vụ tài chính, tương đương một hoặc nhiều chu kỳ thuê (do chủ trọ thiết lập số tháng cọc khi tạo hợp đồng). Nguyên tắc áp dụng:

- Toàn bộ nghĩa vụ tài chính của chu kỳ hiện tại (tiền thuê, điện, nước, phụ phí) phải được thanh toán hoặc được xử lý cấn trừ trước khi hợp đồng được xem là đã hoàn tất nghĩa vụ của chu kỳ đó.
- Khi khách thuê nợ sang chu kỳ thanh toán mới mà chưa xử lý xong nghĩa vụ tài chính của chu kỳ trước, hệ thống **không chặn việc tạo hóa đơn của chu kỳ mới** (hóa đơn hàng tháng vẫn được tạo tự động bình thường theo BR-11) - hệ thống chỉ đánh dấu cờ cảnh báo "nợ dồn kỳ" trên hồ sơ hợp đồng, hiển thị nổi bật trên báo cáo công nợ (BR-17) để chủ trọ chủ động xử lý.
- Việc khách thuê chậm thanh toán trong phạm vi một chu kỳ (chưa quá hạn theo BR-14) chỉ bị đánh dấu "quá hạn" để cảnh báo, không bị phạt tiền, không tự động xử lý cọc - chủ trọ chủ động liên hệ khách qua kênh trao đổi thông tin hoặc gặp trực tiếp.
- Chỉ khi khách thuê nợ sang chu kỳ mới mà vẫn chưa xử lý xong nghĩa vụ tài chính của chu kỳ trước, chủ trọ mới có thể áp dụng BR-07d (chấm dứt do vi phạm) hoặc quyết định cấn trừ nghĩa vụ đó vào tiền cọc.
- Khi chấm dứt hợp đồng do vi phạm nghĩa vụ thanh toán (BR-07d), tiền cọc được dùng để cấn trừ các khoản nợ và chi phí phát sinh hợp lệ trước. Phần tiền cọc còn dư sau khi cấn trừ **bắt buộc phải được hoàn lại** cho khách thuê, vì bản chất tiền cọc là khoản bảo đảm chứ không phải khoản phạt. Nếu nợ vượt quá tiền cọc, áp dụng nguyên tắc ghi nhận công nợ còn lại như mô tả ở BR-07.

#### 5.3.2. Quy trình xử lý yêu cầu chấm dứt hợp đồng (áp dụng cho cả chủ trọ và người thuê)

Vòng đời hợp đồng gồm các trạng thái: **Bản nháp → Đang hoạt động → (Chờ chấm dứt, nếu có yêu cầu chấm dứt trước hạn) → Đã chấm dứt / Hết hạn.**

Khi một bên (chủ trọ hoặc người thuê) gửi yêu cầu chấm dứt hợp đồng theo đúng thời gian báo trước quy định, hợp đồng chuyển sang trạng thái **Chờ chấm dứt** và hệ thống gửi thông báo cho bên còn lại. Bên nhận thông báo có hai hành động xử lý:

- **Đã tiếp nhận:** xác nhận đã nhận được yêu cầu chấm dứt. Ở trạng thái này, bên gửi yêu cầu vẫn có thể rút lại yêu cầu và hợp đồng quay về trạng thái Đang hoạt động.
- **Đã chấp nhận:** xác nhận đồng ý với yêu cầu chấm dứt và bắt đầu thực hiện các công việc liên quan (ví dụ chuẩn bị bàn giao phòng, tìm khách thuê mới...). Kể từ thời điểm này, yêu cầu chấm dứt không được phép hủy hoặc rút lại trong hệ thống. Hợp đồng sẽ được thanh lý và chuyển sang trạng thái Đã chấm dứt vào đúng ngày kết thúc đã thông báo. Nếu sau đó cả hai bên thực tế muốn tiếp tục mối quan hệ thuê, cách xử lý là tạo một hợp đồng mới sau khi hợp đồng hiện tại đã chấm dứt - hệ thống không hỗ trợ khôi phục lại hợp đồng đã ở trạng thái này.

Hệ thống **không áp dụng thời hạn bắt buộc** cho việc bên nhận phải phản hồi "Đã tiếp nhận"/"Đã chấp nhận". Để tránh yêu cầu bị "treo" quá lâu, hệ thống tự động gửi lại thông báo nhắc nhở định kỳ (gợi ý mỗi 2-3 ngày) cho bên nhận nếu chưa có phản hồi, cho đến khi có hành động hoặc đến ngày dự kiến chấm dứt.

Quy tắc này nhằm đảm bảo bên còn lại vẫn có cơ hội thay đổi quyết định khi mới chỉ tiếp nhận thông tin, đồng thời bảo vệ quyền lợi của bên đã chấp nhận yêu cầu và bắt đầu triển khai công việc tiếp theo. Trong suốt thời gian hợp đồng ở trạng thái Chờ chấm dứt, phòng vẫn giữ trạng thái "Đang cho thuê" cho đến khi hợp đồng thực sự chuyển sang "Đã chấm dứt/Hết hạn", lúc đó phòng mới chuyển về trạng thái "Trống".

> **Lưu ý:** Quy trình "Đã tiếp nhận / Đã chấp nhận" ở trên áp dụng cho luồng chấm dứt thông thường (BR-07b). Chấm dứt do vi phạm nghĩa vụ thanh toán (BR-07d) là một luồng riêng, đơn giản hơn (chủ trọ khởi tạo, báo trước ngắn hạn, không có bước rút lại), do bản chất là xử lý vi phạm chứ không phải thỏa thuận song phương.

### 5.4. Ghi nhận chỉ số và đơn giá điện, nước

Đây là nghiệp vụ trung tâm để hệ thống tự động tính hóa đơn mà chủ trọ không cần nhập tay. Do Phiên bản 1 **chưa tích hợp thiết bị đo từ xa (IoT)**, việc ghi nhận chỉ số điện/nước hàng tháng dựa trên ảnh chụp đồng hồ do người thuê cung cấp, kết hợp nhận diện ký tự quang học (OCR) để giảm thao tác nhập tay.

| Mã | Tên quy tắc | Mô tả | Loại |
|---|---|---|---|
| BR-08 | Đơn giá theo bậc thang | Tiền điện/nước được tính theo bậc thang (nhiều mức tiêu thụ, mỗi mức một đơn giá riêng). Số lượng bậc, ngưỡng từng bậc và đơn giá mỗi bậc do từng chủ trọ tự thiết lập, không cố định trong hệ thống. | Có thể cấu hình |
| BR-08b | Gửi chỉ số qua ảnh chụp kèm OCR | Đầu mỗi kỳ (theo lịch tạo hóa đơn, BR-12), hệ thống gửi thông báo nhắc người thuê chụp ảnh đồng hồ điện và đồng hồ nước, tải lên hệ thống. Hệ thống chạy OCR trên ảnh để tự động nhận diện và điền sẵn chỉ số vào ô nhập liệu. Người thuê xem ảnh cùng chỉ số OCR đã điền, xác nhận đúng hoặc chỉnh sửa lại nếu OCR đọc sai. | Cố định |
| BR-08c | Xác minh chỉ số nhập tay/OCR sai | Nếu người thuê xác nhận chỉ số OCR mà không chỉnh sửa, hệ thống dùng ngay chỉ số đó để tính hóa đơn, không cần xác minh thêm. Nếu người thuê chỉnh sửa lại chỉ số (do OCR đọc sai) hoặc OCR không nhận diện được, hệ thống đánh dấu là "cần xác minh". Chủ trọ tự cấu hình cách xử lý trường hợp cần xác minh, theo một trong hai chế độ: (1) **Bỏ qua xác minh** - hệ thống vẫn tự động tạo và phát hành hóa đơn bình thường với chỉ số người thuê đã nhập, không chờ chủ trọ duyệt; (2) **Yêu cầu xác minh** - hệ thống gửi thông báo cho chủ trọ kèm ảnh đồng hồ, kết quả OCR (nếu có) và chỉ số người thuê đã nhập, để chủ trọ xác nhận hoặc chỉnh sửa trước khi hóa đơn được phát hành. Ở chế độ (2), chủ trọ tự cấu hình thời gian chờ xác minh tối đa (ví dụ 30 phút, 1 giờ, 1 ngày...); nếu hết thời gian chờ mà chủ trọ chưa phản hồi, hệ thống tự động phát hành hóa đơn với chỉ số người thuê đã gửi, tránh hóa đơn bị treo vô thời hạn. | Có thể cấu hình |
| BR-08d | Chỉ số gắn liền với phòng, liên tục qua các đời khách thuê | Chỉ số điện/nước gắn với **phòng** (đồng hồ vật lý cố định tại phòng), không gắn với hợp đồng hay người thuê cụ thể, và được duy trì liên tục qua các đời khách thuê khác nhau. Khi một hợp đồng mới bắt đầu tại một phòng đã từng có khách thuê trước đó, chỉ số cuối kỳ của khách thuê trước tự động trở thành chỉ số khởi điểm cho khách thuê mới - khách thuê mới không cần lo lắng về lịch sử tiêu thụ trước đó. Nếu phòng hoàn toàn chưa từng có khách thuê (chưa có chỉ số nào trong hệ thống), chủ trọ nhập chỉ số khởi điểm khi tạo phòng, hoặc nếu chưa nhập, lần chụp ảnh gửi chỉ số đầu tiên của khách thuê mới chỉ được ghi nhận làm **mốc khởi điểm**, chưa tính tiêu thụ (không tính tiền điện/nước cho tháng đó); tiêu thụ thực tế bắt đầu được tính từ kỳ ghi nhận chỉ số kế tiếp trở đi, dựa trên chênh lệch so với mốc khởi điểm này. | Cố định |
| BR-09 | Lưu lịch sử đơn giá | Khi chủ trọ thay đổi đơn giá điện/nước, hệ thống lưu lại lịch sử để hóa đơn của các tháng trước không bị tính lại theo đơn giá mới. | Cố định |
| BR-10 | Kiểm tra chỉ số hợp lệ | Chỉ số điện/nước mới nhập (dù từ OCR hay nhập tay) phải lớn hơn hoặc bằng chỉ số kỳ trước; nếu nhỏ hơn, hệ thống cảnh báo để xác nhận lại trước khi lưu, áp dụng cả cho người thuê lúc gửi và cho chủ trọ lúc xác minh (BR-08c). | Cố định |

> **Ví dụ minh họa** cách tính bậc thang (chỉ để làm rõ ý, không phải giá trị cố định của hệ thống): Điện - 50 kWh đầu tiên tính 3.500đ/kWh, từ kWh thứ 51 trở đi tính 3.700đ/kWh. Nước - 4 khối đầu tiên tính 18.000đ/khối, từ khối thứ 5 trở đi tính 20.000đ/khối. Mỗi chủ trọ có thể tự đặt số bậc, ngưỡng và đơn giá khác với ví dụ này.

> **Định hướng tương lai (ngoài phạm vi Phiên bản 1):** Khi tích hợp thiết bị đo từ xa (IoT), toàn bộ quy trình chụp ảnh/OCR/xác minh ở trên sẽ không còn cần thiết - chỉ số được ghi nhận tự động và liên tục. Lợi ích dự kiến: người thuê không cần thao tác chụp ảnh hàng tháng; chủ trọ giám sát được mức tiêu thụ theo thời gian thực; cả hai bên có thể phát hiện bất thường (rò rỉ nước, tiêu thụ điện đột biến) sớm hơn. Tính năng này dự kiến thuộc gói dịch vụ nâng cao (VIP) ở các phiên bản sau, không thuộc phạm vi MVP - chỉ ghi chú định hướng tại đây.

### 5.5. Quản lý hóa đơn

| Mã | Tên quy tắc | Mô tả | Loại |
|---|---|---|---|
| BR-11 | Tự động tạo hóa đơn | Hệ thống tự động tạo hóa đơn hàng tháng cho từng phòng đang có hợp đồng hiệu lực, gồm tiền thuê phòng + tiền điện + tiền nước (tính theo chỉ số ghi nhận ở Mục 5.4) + phụ phí khác (nếu chủ trọ có thiết lập). Mỗi hóa đơn bắt buộc phải gắn với đúng một hợp đồng. Việc tạo hóa đơn hoàn toàn tự động, không cần chủ trọ tính tay, miễn là chỉ số điện/nước của kỳ đó đã được ghi nhận (BR-08b) và xác minh xong nếu chế độ xác minh đang bật (BR-08c). | Cố định |
| BR-11a | Hóa đơn nháp khi thiếu chỉ số | Nếu đến ngày tạo hóa đơn tự động (BR-12) mà người thuê chưa gửi chỉ số điện/nước của kỳ đó, hệ thống vẫn tạo hóa đơn nhưng ở trạng thái **"Nháp - chờ bổ sung chỉ số"** (phần điện/nước để trống, chỉ có tiền thuê phòng và phụ phí cố định nếu có). Hóa đơn nháp **không được gửi thông báo chính thức** cho người thuê. Khi người thuê bổ sung chỉ số (và xác minh xong nếu cần), hệ thống tính lại đầy đủ và phát hành hóa đơn chính thức, lúc đó mới gửi thông báo. | Cố định |
| BR-11b | Tính tiền thuê khi nhận phòng giữa tháng | Khi khách nhận phòng vào giữa tháng, tiền thuê tháng đầu được tính theo một trong hai phương án áp dụng cho hợp đồng đó: (1) Tính theo số ngày thực tế sử dụng - đơn giá ngày = tiền thuê tháng chia cho số ngày của tháng đó (28-31 ngày), tiền thuê tháng đầu = đơn giá ngày nhân số ngày sử dụng; hoặc (2) Miễn phần thời gian còn lại của tháng, bắt đầu thu tiền từ kỳ thu đầu tiên theo chính sách của chủ trọ. Phương án áp dụng được chọn khi tạo từng hợp đồng, không phải cấu hình chung cho toàn bộ chủ trọ, vì phụ thuộc vào thỏa thuận cụ thể với từng khách thuê. | Có thể cấu hình (theo từng hợp đồng) |
| BR-12 | Ngày tạo hóa đơn | Ngày trong tháng mà hệ thống tự động tạo hóa đơn do từng chủ trọ tự chọn (ví dụ ngày 1 hoặc ngày 5 hàng tháng); đồng thời là mốc hệ thống gửi thông báo nhắc người thuê gửi chỉ số điện/nước của kỳ mới (BR-08b). | Có thể cấu hình |
| BR-12b | Hủy hóa đơn chưa thanh toán | Chủ trọ chỉ được hủy hóa đơn khi hóa đơn đó **chưa được thanh toán**; sau khi cập nhật lại dữ liệu đầu vào, hệ thống tạo một hóa đơn mới thay thế. Hóa đơn đã thanh toán không được phép hủy theo cách này - áp dụng quy trình Điều chỉnh (Adjustment) ở BR-12c. | Cố định |
| BR-12c | Điều chỉnh hóa đơn sau khi phát hành hoặc đã thanh toán (Adjustment) | Đây là quy trình xử lý ngoại lệ, không phải bước bắt buộc trong luồng thông thường, chỉ phát sinh khi chủ trọ hoặc người thuê phát hiện sai sót (ví dụ chỉ số đã ghi nhận sai) sau khi hóa đơn đã phát hành hoặc đã thanh toán. Actor phản hồi qua kênh trao đổi thông tin (Mục 5.11), chủ trọ xác nhận lại chỉ số/số tiền đúng, hệ thống tính phần chênh lệch và xử lý theo 2 trường hợp: (1) Nếu hóa đơn liên quan **chưa thanh toán** → hệ thống cập nhật trực tiếp lại hóa đơn đó theo số liệu đúng; (2) Nếu hóa đơn liên quan **đã thanh toán** → hệ thống không sửa hóa đơn cũ (giữ nguyên để không phá vỡ lịch sử giao dịch đã hoàn tất), mà tạo một khoản Điều chỉnh (Adjustment) riêng, được cộng/trừ vào hóa đơn của kỳ kế tiếp. | Cố định |

### 5.6. Thanh toán và công nợ

| Mã | Tên quy tắc | Mô tả | Loại |
|---|---|---|---|
| BR-13 | Xác nhận thanh toán | Hệ thống hỗ trợ hai chế độ xác nhận thanh toán, chủ trọ tự chọn áp dụng **cho toàn bộ hợp đồng thuộc chủ trọ đó** (không tách riêng theo từng hợp đồng): (1) Tự động xác nhận qua cổng thanh toán trực tuyến (MoMo), hoặc (2) Xác nhận thủ công - chủ trọ tự xác nhận trên hệ thống khi đã nhận được tiền (tiền mặt hoặc chuyển khoản). Phí giao dịch phát sinh khi thanh toán qua cổng MoMo do chủ trọ chi trả. Hệ thống chưa hỗ trợ thanh toán một phần cho một hóa đơn (phải thanh toán đủ số tiền của hóa đơn). Ở giai đoạn MVP, việc tích hợp MoMo là giả lập (xem giả định ở Mục 7), phục vụ mục đích hoàn thiện luồng nghiệp vụ và giao diện; kết nối cổng thanh toán thật (bao gồm quyết định về tài khoản merchant) sẽ thực hiện ở giai đoạn sau. | Có thể cấu hình (theo chủ trọ) |
| BR-14 | Đánh dấu hóa đơn quá hạn | Hóa đơn chưa thanh toán quá X ngày kể từ ngày phát hành chính thức (không tính hóa đơn ở trạng thái Nháp theo BR-11a) sẽ được đánh dấu "quá hạn" để cảnh báo chủ trọ (thể hiện qua báo cáo/biểu đồ công nợ). Giá trị X do từng chủ trọ tự thiết lập. Việc đánh dấu quá hạn không tự động áp dụng phí phạt hay lãi trễ hạn; chủ trọ tự liên hệ khách qua kênh trao đổi thông tin hoặc trực tiếp để xử lý. | Có thể cấu hình |

### 5.7. Yêu cầu sửa chữa

| Mã | Tên quy tắc | Mô tả | Loại |
|---|---|---|---|
| BR-15 | Gửi yêu cầu sửa chữa | Người thuê gửi yêu cầu sửa chữa, gồm mô tả sự cố bằng văn bản kèm **tối đa 1 hình ảnh** minh chứng tình trạng hư hỏng. Trao đổi thêm chi tiết (nếu cần nhiều ảnh hoặc thông tin bổ sung) thực hiện qua kênh trao đổi thông tin (Mục 5.11) gắn với yêu cầu đó, không giới hạn số lượng trong kênh chat. Phiên bản 1 không có tính năng người thuê chọn/đánh dấu ngày rảnh để hẹn lịch sửa chữa - việc hẹn lịch do hai bên tự thỏa thuận qua kênh chat. | Cố định |
| BR-16 | Trạng thái xử lý | Mỗi yêu cầu sửa chữa có một trong các trạng thái: Mới - Đang xử lý - Hoàn thành - Đã hủy, để cả hai bên theo dõi tiến độ. Trạng thái "Đã hủy" và "Hoàn thành" là trạng thái kết thúc, không thể mở lại; nếu cần xử lý tiếp, người thuê tạo yêu cầu sửa chữa mới. | Cố định |

### 5.8. Báo cáo tổng quan

| Mã | Tên quy tắc | Mô tả | Loại |
|---|---|---|---|
| BR-17 | Phạm vi dữ liệu báo cáo | Báo cáo (số phòng, doanh thu, công nợ...) chỉ hiển thị dữ liệu trong phạm vi của chủ trọ đang đăng nhập, không hiển thị dữ liệu của chủ trọ khác. Do mỗi chủ trọ chỉ quản lý một địa điểm, báo cáo được tổng hợp trên toàn bộ số phòng của chủ trọ mà không cần phân tách theo địa điểm. Báo cáo công nợ hiển thị nổi bật các hợp đồng đang bị đánh dấu "nợ dồn kỳ" (Mục 5.3.1) và hóa đơn quá hạn (BR-14). | Cố định |

### 5.9. Tài khoản, vai trò và mô hình nhiều chủ trọ

| Mã | Tên quy tắc | Mô tả | Loại |
|---|---|---|---|
| BR-18 | Mỗi chủ trọ là một đơn vị độc lập | Mỗi chủ trọ đăng ký một tài khoản riêng trên nền tảng và được xem như một đơn vị vận hành độc lập. Toàn bộ dữ liệu (phòng, khách thuê, hợp đồng, hóa đơn...) chỉ hiển thị trong phạm vi của đúng chủ trọ đó. | Cố định |
| BR-19 | Phạm vi truy cập của người thuê | Người thuê chỉ xem được thông tin (phòng, hợp đồng, hóa đơn) thuộc đúng chủ trọ mà mình đang thuê phòng, không xem được dữ liệu ở chủ trọ khác dù dùng chung nền tảng. | Cố định |
| BR-20 | Quyền hạn của Quản trị hệ thống | Quản trị hệ thống chỉ có quyền khóa hoặc mở lại tài khoản của chủ trọ; không được xem, sửa hoặc xóa dữ liệu nghiệp vụ (phòng, hợp đồng, hóa đơn cụ thể) của chủ trọ. Khi tài khoản chủ trọ bị khóa: chỉ tài khoản đăng nhập của chủ trọ đó bị vô hiệu hóa; toàn bộ hợp đồng, hóa đơn và lịch sử thanh toán vẫn được lưu trữ nguyên vẹn; tài khoản Người thuê thuộc các hợp đồng đó vẫn được truy cập bình thường ở chế độ tra cứu (xem hợp đồng, hóa đơn, lịch sử thanh toán của mình), vì dữ liệu hợp đồng là căn cứ giao dịch của cả hai bên và không phụ thuộc vào việc chủ trọ có đăng nhập được hay không. | Cố định |
| BR-21 | Lưu trữ dữ liệu, không xóa vĩnh viễn | Hệ thống phải lưu lại lịch sử toàn bộ dữ liệu nghiệp vụ quan trọng (phòng, khách thuê, hợp đồng, hóa đơn), không cho phép xóa vĩnh viễn khỏi hệ thống, nhằm phục vụ tra cứu, đối soát hoặc giải quyết tranh chấp khi cần. | Cố định |

### 5.10. Cổng thông tin dành cho Người thuê

Người thuê truy cập hệ thống qua một cổng thông tin riêng (Portal) với các chức năng sau:

1. Xem hợp đồng của mình.
2. Xem hóa đơn của mình.
3. Gửi chỉ số điện/nước hàng tháng qua ảnh chụp (theo BR-08b).
4. Thanh toán hóa đơn (theo BR-13).
5. Tạo yêu cầu sửa chữa (theo BR-15, BR-16).
6. Gửi yêu cầu chấm dứt hợp đồng (theo Mục 5.3.2).
7. Trao đổi thông tin (chat) với chủ trọ.

Nếu tài khoản gắn với hợp đồng đã chấm dứt, chỉ mục 1, 2 ở trên còn khả dụng, ở chế độ chỉ xem (xem Mục 3).

### 5.11. Trao đổi thông tin (Chat)

Hệ thống cung cấp kênh trao đổi thông tin trực tiếp giữa chủ trọ và người thuê, dùng để hỏi đáp, bổ sung thông tin, trao đổi thêm về các vấn đề phát sinh (ví dụ phản hồi về hóa đơn theo BR-12c, trao đổi thêm ảnh/thông tin về sửa chữa theo BR-15, hẹn lịch sửa chữa, nhắc nhở thanh toán không chính thức...). Kênh này chỉ mang tính trao đổi thông tin, **không dùng để xử lý hoặc xác nhận chính thức các nghiệp vụ** - mọi yêu cầu chính thức (sửa chữa, chấm dứt hợp đồng, thanh toán, điều chỉnh hóa đơn...) vẫn phải thực hiện qua đúng chức năng tương ứng trong hệ thống; kênh chat chỉ hỗ trợ trao đổi, không tự động thay đổi trạng thái của bất kỳ nghiệp vụ nào.

Ngoài tin nhắn trao đổi giữa hai người dùng, hệ thống còn gửi các tin nhắn tự động (ví dụ thông báo hóa đơn mới, thông báo yêu cầu chấm dứt hợp đồng, nhắc gửi chỉ số điện nước) để hai bên nắm được tiến độ xử lý mà không cần chủ động hỏi.

### 5.12. Thông báo

Hệ thống gửi thông báo cho người dùng khi có sự kiện cần lưu ý (hóa đơn mới, nhắc gửi chỉ số điện/nước, chỉ số cần xác minh, yêu cầu sửa chữa cập nhật trạng thái, yêu cầu chấm dứt hợp đồng, hóa đơn quá hạn...). Ở giai đoạn MVP, thông báo được gửi qua hai kênh: trong ứng dụng (in-app) và email. Kênh tin nhắn SMS/thông báo đẩy chưa nằm trong phạm vi MVP, ngoại trừ email vẫn là kênh bắt buộc riêng cho việc kích hoạt tài khoản lần đầu (BR-04d).

---

## 6. Bảng tổng hợp toàn bộ quy tắc nghiệp vụ

| Mã | Tên quy tắc | Loại |
|---|---|---|
| BR-01 | Trạng thái phòng | Cố định |
| BR-02 | Chỉnh sửa thông tin phòng | Cố định |
| BR-03 | Thông tin bắt buộc của khách thuê (bao gồm email) | Cố định |
| BR-04b | Người ở cùng (đồng cư trú) | Cố định |
| BR-04c | Cập nhật danh sách người ở cùng | Cố định |
| BR-04d | Khởi tạo tài khoản Người thuê (kích hoạt qua email bắt buộc) | Cố định |
| BR-05 | Thông tin hợp đồng | Có thể cấu hình |
| BR-07 | Xử lý tiền cọc khi chấm dứt hợp đồng đúng quy định | Có thể cấu hình |
| BR-07b | Chấm dứt hợp đồng thông thường (đúng quy trình) | Có thể cấu hình (có sàn tối thiểu) |
| BR-07c | Thời gian thuê tối thiểu | Có thể cấu hình |
| BR-07d | Chấm dứt hợp đồng do vi phạm nghĩa vụ thanh toán | Có thể cấu hình (mặc định 5 ngày, ngưỡng 1 kỳ) |
| BR-08 | Đơn giá điện/nước theo bậc thang | Có thể cấu hình |
| BR-08b | Gửi chỉ số qua ảnh chụp kèm OCR | Cố định |
| BR-08c | Xác minh chỉ số nhập tay/OCR sai | Có thể cấu hình |
| BR-08d | Chỉ số gắn liền với phòng, liên tục qua các đời khách thuê | Cố định |
| BR-09 | Lưu lịch sử đơn giá | Cố định |
| BR-10 | Kiểm tra chỉ số hợp lệ | Cố định |
| BR-11 | Tự động tạo hóa đơn hàng tháng | Cố định |
| BR-11a | Hóa đơn nháp khi thiếu chỉ số | Cố định |
| BR-11b | Tính tiền thuê khi nhận phòng giữa tháng | Có thể cấu hình (theo từng hợp đồng) |
| BR-12 | Ngày tạo hóa đơn trong tháng | Có thể cấu hình |
| BR-12b | Hủy hóa đơn chưa thanh toán | Cố định |
| BR-12c | Điều chỉnh hóa đơn sau phát hành/thanh toán (Adjustment) | Cố định |
| BR-13 | Xác nhận thanh toán (tự động qua cổng hoặc thủ công) | Có thể cấu hình (theo chủ trọ) |
| BR-14 | Đánh dấu hóa đơn quá hạn | Có thể cấu hình |
| BR-15 | Gửi yêu cầu sửa chữa (mô tả + tối đa 1 ảnh) | Cố định |
| BR-16 | Trạng thái xử lý yêu cầu sửa chữa | Cố định |
| BR-17 | Phạm vi dữ liệu báo cáo | Cố định |
| BR-18 | Mỗi chủ trọ là một đơn vị độc lập | Cố định |
| BR-19 | Phạm vi truy cập của người thuê | Cố định |
| BR-20 | Quyền hạn của Quản trị hệ thống | Cố định |
| BR-21 | Lưu trữ dữ liệu, không xóa vĩnh viễn | Cố định |

> **So với phiên bản 1.4:** bổ sung BR-08b, BR-08c, BR-08d (quy trình ghi chỉ số qua ảnh/OCR và tính liên tục theo phòng); bổ sung BR-11a (hóa đơn nháp khi thiếu chỉ số); bổ sung BR-12c (Adjustment); sửa BR-15 (bỏ giới hạn N ảnh và tính năng ngày rảnh, còn tối đa 1 ảnh); sửa BR-03 (bổ sung email bắt buộc); sửa BR-04d (làm rõ kích hoạt chỉ qua email); sửa BR-07d (chốt mặc định 5 ngày); sửa BR-13 (làm rõ phạm vi cấu hình theo chủ trọ).

---

## 7. Giả định nghiệp vụ

- Tiền cọc đóng vai trò khoản bảo đảm nghĩa vụ tài chính; phần cọc còn dư sau khi cấn trừ nghĩa vụ hợp lệ luôn phải được hoàn lại cho người thuê trong mọi trường hợp chấm dứt hợp đồng.
- Tỷ lệ hoàn trả cọc, số ngày báo trước, phương án xử lý cọc (cấn trừ hoặc hoàn trực tiếp) là các tham số có thể chỉnh theo từng chủ trọ, không cố định trong hệ thống, ngoại trừ mức sàn báo trước tối thiểu theo luật (mặc định 30 ngày) áp dụng cho chấm dứt hợp đồng thông thường.
- Đơn giá điện, nước theo bậc thang chỉ là ví dụ minh họa cách tính (xem Mục 5.4); giá trị thực tế do từng chủ trọ tự thiết lập và có thể khác nhau hoàn toàn giữa các chủ trọ.
- Hệ thống không có tính năng nối/tổng hợp lịch sử thuê của cùng một khách qua nhiều hợp đồng khác nhau ở Phiên bản 1. Mỗi hợp đồng và tài khoản Người thuê tương ứng là độc lập hoàn toàn với các hợp đồng trước đó của cùng một người, kể cả khi thuê lại tại cùng một chủ trọ.
- Thanh toán trực tuyến qua cổng MoMo nằm trong phạm vi MVP ở mức giả lập (mock): hệ thống mô phỏng đầy đủ luồng nghiệp vụ và giao diện thanh toán, nhưng chưa kết nối với cổng thanh toán MoMo thật. Việc kết nối cổng thanh toán thật, bao gồm cơ chế tài khoản merchant và phân bổ tiền về từng chủ trọ, sẽ được xác định ở giai đoạn sau khi có nhu cầu triển khai thật. Việc thu phí sử dụng nền tảng từ chủ trọ (nếu có) thực hiện thủ công ở Phiên bản 1, chưa tự động.
- Hệ thống không triển khai tính năng nhắc hết hạn hợp đồng: do phần lớn hợp đồng có thể vô thời hạn và việc chấm dứt luôn phải qua quy trình báo trước chính thức (BR-07b/BR-07d), tính năng cảnh báo hết hạn theo ngày cố định không còn cần thiết ở giai đoạn MVP.
- Việc ghi nhận chỉ số điện/nước qua OCR (BR-08b) là công cụ hỗ trợ giảm thao tác nhập tay, không đảm bảo độ chính xác tuyệt đối; cơ chế xác minh (BR-08c) là lớp kiểm soát chất lượng dữ liệu do chủ trọ tự quyết định mức độ chặt chẽ phù hợp với nhu cầu vận hành của mình.
- Ngôn ngữ giao diện: Tiếng Việt. Đơn vị tiền tệ: VNĐ.
- Các tham số liên quan đến hợp đồng (số ngày báo trước chấm dứt, thời gian thuê tối thiểu...) đều do từng chủ trọ tự thiết lập, ngoại trừ số ngày báo trước chấm dứt hợp đồng thông thường có mức sàn tối thiểu bắt buộc theo pháp luật hiện hành (mặc định 30 ngày) mà chủ trọ không thể đặt thấp hơn; mức sàn này không áp dụng cho trường hợp chấm dứt do vi phạm nghĩa vụ thanh toán (BR-07d).

---

## 8. Ngoài phạm vi nghiệp vụ (Phiên bản 1)

- Tích hợp đồng hồ điện, nước tự động đo từ xa (IoT) - chỉ số vẫn do người thuê chụp ảnh gửi ở Phiên bản 1 (xem định hướng tương lai ở Mục 5.4, dự kiến thuộc gói dịch vụ VIP).
- Thu phí thuê bao tự động từ chủ trọ sử dụng nền tảng.
- Ứng dụng di động riêng cho iOS/Android - Phiên bản 1 dùng giao diện web, xem được trên điện thoại qua trình duyệt.
- Thông báo qua SMS hoặc thông báo đẩy (push notification) - Phiên bản 1 chỉ có in-app và email.
- Hỗ trợ một chủ trọ quản lý nhiều địa điểm nhà trọ khác nhau trên cùng một tài khoản.
- Thanh toán một phần cho một hóa đơn (thanh toán từng phần, trả góp).
- Kết nối thật với cổng thanh toán MoMo (Phiên bản 1 chỉ giả lập luồng thanh toán, xem Mục 7).
- Tính năng khai báo tạm trú cho người ở cùng (chỉ lưu thông tin cơ bản phục vụ quản lý nội bộ, không xuất báo cáo/khai báo với cơ quan chức năng).
- Tính năng tra cứu/nối lịch sử thuê của cùng một khách qua nhiều hợp đồng.
- Tính năng người thuê đánh dấu ngày rảnh để hẹn lịch sửa chữa (thay bằng thỏa thuận qua chat, xem BR-15).
- Đổi người đại diện trên một hợp đồng đang hoạt động (phải chấm dứt và tạo hợp đồng mới, xem BR-04c).

---

## 9. Tiêu chí nghiệm thu nghiệp vụ

- Chủ trọ tự thiết lập được bậc thang giá điện/nước của riêng mình mà không cần nhờ lập trình viên can thiệp.
- Chủ trọ tự thiết lập được số ngày báo trước và tỷ lệ hoàn cọc cho chấm dứt hợp đồng thông thường, cũng như số ngày báo trước cho chấm dứt do vi phạm thanh toán (mặc định 5 ngày nếu không tự cấu hình).
- Cả chủ trọ và người thuê đều có thể chấm dứt hợp đồng thông thường trước hạn nếu đã báo trước đủ số ngày quy định; hệ thống từ chối nếu chủ trọ cố tình đặt số ngày báo trước thấp hơn mức sàn luật định.
- Chủ trọ có thể chấm dứt hợp đồng do khách thuê vi phạm nghĩa vụ thanh toán theo đúng quy trình riêng (BR-07d), độc lập với quy trình chấm dứt thông thường.
- Hai chủ trọ khác nhau cùng dùng hệ thống nhưng không ai nhìn thấy dữ liệu của người còn lại, kể cả khi thử truy cập trực tiếp.
- Quản trị hệ thống khóa được tài khoản chủ trọ khi cần, nhưng không xem được dữ liệu nghiệp vụ chi tiết của chủ trọ đó; người thuê liên quan vẫn tra cứu được hợp đồng/hóa đơn của mình dù chủ trọ bị khóa.
- Người thuê tự tra cứu được hóa đơn, hợp đồng, thanh toán, gửi chỉ số điện nước qua ảnh chụp, gửi yêu cầu sửa chữa và gửi yêu cầu chấm dứt hợp đồng qua Cổng thông tin mà không cần liên hệ chủ trọ qua điện thoại/Zalo.
- Người thuê chụp ảnh đồng hồ điện/nước, hệ thống tự nhận diện chỉ số qua OCR và điền sẵn; người thuê xác nhận hoặc chỉnh sửa; nếu cần xác minh, chủ trọ được thông báo và có thời gian chờ cấu hình được trước khi hệ thống tự động phát hành hóa đơn.
- Khi khách nhận phòng tại một phòng đã từng có người thuê trước, chỉ số điện nước kế thừa liên tục từ khách cũ, không bị reset về 0 hay yêu cầu chủ trọ nhập lại thủ công.
- Hóa đơn hàng tháng được tạo tự động, đúng công thức bậc thang mà chủ trọ đã thiết lập, có tính đến trường hợp nhận phòng giữa tháng theo phương án đã chọn cho từng hợp đồng và trường hợp thiếu chỉ số (hóa đơn nháp), không cần chủ trọ tính tay.
- Khi phát hiện sai sót sau khi hóa đơn đã phát hành hoặc đã thanh toán, hệ thống xử lý đúng theo luồng Adjustment (cập nhật trực tiếp nếu chưa thanh toán, hoặc tạo khoản điều chỉnh cho kỳ sau nếu đã thanh toán), không làm sai lệch lịch sử giao dịch đã hoàn tất.
- Thanh toán qua cổng MoMo (giả lập ở Phiên bản 1) được xác nhận tự động; thanh toán tiền mặt/chuyển khoản vẫn được xác nhận thủ công khi chủ trọ chọn chế độ này.

---

## 10. Thuật ngữ

| Thuật ngữ | Giải thích |
|---|---|
| Chủ trọ | Người/đơn vị sở hữu và vận hành nhà trọ, là khách hàng chính sử dụng hệ thống. |
| Người thuê | Khách đang thuê phòng của một chủ trọ, sử dụng Cổng thông tin để tra cứu và thao tác trong phạm vi hợp đồng của mình. |
| Quản trị hệ thống | Bộ phận vận hành nền tảng, chỉ có quyền khóa/mở tài khoản chủ trọ, không can thiệp vào dữ liệu nghiệp vụ của chủ trọ. |
| Đơn vị chủ trọ | Không gian dữ liệu riêng của một chủ trọ trên nền tảng dùng chung; dữ liệu giữa các đơn vị chủ trọ khác nhau hoàn toàn tách biệt, không ai xem được của ai. |
| Chờ chấm dứt | Trạng thái tạm thời của hợp đồng trong khoảng thời gian từ khi có yêu cầu chấm dứt cho đến khi hợp đồng thực sự kết thúc. |
| Chấm dứt thông thường | Việc kết thúc hợp đồng trước hạn theo thỏa thuận, có báo trước đủ số ngày quy định (tối thiểu 30 ngày theo luật). |
| Chấm dứt do vi phạm | Việc chủ trọ chấm dứt hợp đồng do khách thuê không thanh toán nghĩa vụ tài chính đúng hạn, theo quy trình báo trước ngắn hạn riêng. |
| Bậc thang giá | Cách tính tiền điện/nước theo nhiều mức tiêu thụ, mỗi mức áp dụng một đơn giá khác nhau (dùng càng nhiều, đơn giá phần vượt càng cao). |
| OCR | Nhận diện ký tự quang học (Optical Character Recognition) - công nghệ đọc số từ ảnh chụp đồng hồ điện/nước để tự động điền chỉ số. |
| Chỉ số cần xác minh | Chỉ số điện/nước do người thuê tự chỉnh sửa (không dùng nguyên kết quả OCR) hoặc trường hợp OCR không đọc được, cần chủ trọ xác nhận lại tùy theo chế độ đã cấu hình. |
| Adjustment (Điều chỉnh) | Khoản chênh lệch phát sinh khi phát hiện sai sót sau khi hóa đơn đã phát hành hoặc thanh toán, được xử lý ở kỳ hóa đơn kế tiếp thay vì sửa lại hóa đơn cũ. |
| Công nợ | Số tiền người thuê còn nợ chủ trọ do chưa thanh toán hóa đơn. |
| Cổng thông tin Người thuê | Khu vực chức năng dành riêng cho người thuê để xem hợp đồng, hóa đơn, thanh toán, gửi chỉ số điện nước, gửi yêu cầu sửa chữa/chấm dứt hợp đồng và trao đổi thông tin với chủ trọ. |
| Tham số có thể cấu hình | Giá trị mà chủ trọ (hoặc trong một số trường hợp, từng hợp đồng cụ thể) tự thiết lập trên giao diện hệ thống, không bị cố định sẵn trong hệ thống. |

---

## 11. Xác nhận (Sign-off)

Các bên liên quan xác nhận đã đọc, hiểu và đồng ý với các yêu cầu nghiệp vụ nêu trong tài liệu này trước khi chuyển sang giai đoạn thiết kế kỹ thuật chi tiết.

| Vai trò | Họ tên | Chữ ký | Ngày |
|---|---|---|---|
| Chủ trọ / Khách hàng | | | |
| Đại diện đội phân tích | | | |