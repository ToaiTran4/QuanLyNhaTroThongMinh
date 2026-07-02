# QuanLyNhaTroThongMinh

Hệ thống quản lý nhà trọ thông minh - Nền tảng SaaS đa chủ trọ

## Tổng quan

QuanLyNhaTroThongMinh là một hệ thống quản lý nhà trọ hiện đại, hỗ trợ nhiều chủ trọ cùng sử dụng, với các tính năng chính:

- Quản lý phòng trọ
- Quản lý khách thuê và hợp đồng
- Ghi nhận chỉ số điện/nước qua ảnh chụp + OCR
- Tạo và quản lý hóa đơn
- Quản lý thanh toán và công nợ
- Yêu cầu sửa chữa
- Chat giữa chủ trọ và khách thuê
- Thông báo tự động

## Kiến trúc hệ thống

Hệ thống được xây dựng theo kiến trúc microservices trên AWS:

- **Backend**: Node.js Lambda functions (AWS SAM)
- **Frontend**: React + Vite
- **Database**: PostgreSQL (RDS) với Row Level Security
- **Authentication**: AWS Cognito
- **Storage**: S3 (ảnh chụp chỉ số, sửa chữa)
- **OCR**: Amazon Textract
- **Messaging**: EventBridge (sự kiện hệ thống)

## Cấu trúc thư mục

```
QuanLyNhaTroThongMinh/
├── backend/
│   ├── auth-service/          # Xác thực và quản lý tài khoản
│   ├── room-service/          # Quản lý phòng trọ
│   ├── contract-service/      # Quản lý hợp đồng
│   ├── config-service/        # Cấu hình chủ trọ
│   ├── utility-service/       # Chỉ số điện/nước + OCR
│   ├── invoice-service/       # Hóa đơn và báo cáo
│   ├── repair-service/        # Yêu cầu sửa chữa
│   ├── chat-service/          # Chat và tin nhắn
│   ├── notification-service/  # Thông báo
│   ├── layers/
│   │   └── common/            # Layer chung: DB, middleware, validation
│   └── template.yaml          # AWS SAM template
├── frontend/                  # React frontend
│   ├── src/
│   │   ├── components/
│   │   ├── pages/
│   │   ├── stores/            # Zustand state management
│   │   ├── utils/
│   │   └── types/
│   ├── public/
│   └── tests/
├── infra/
│   └── db-migrations/         # Database migration scripts
├── docs/                      # Tài liệu BRD, SRS, SDD
└── .github/
    └── workflows/             # CI/CD pipelines
```

## Cài đặt môi trường phát triển

### Yêu cầu tiên quyết

- Node.js 18+
- npm 9+
- AWS CLI
- AWS SAM CLI
- PostgreSQL 14+

### Cài đặt Backend

1. Di chuyển vào thư mục backend:
   ```bash
   cd backend
   ```

2. Cài đặt dependencies cho common layer:
   ```bash
   cd layers/common
   npm install
   cd ../../
   ```

3. Cài đặt dependencies cho từng service:
   ```bash
   for dir in *-service; do
     cd "$dir"
     npm install
     cd ..
   done
   ```

4. Tạo file `.env` trong từng service (tham khảo `.env.example`)

5. Chạy migrations để tạo database schema:
   ```bash
   cd ../infra/db-migrations
   psql -h localhost -U postgres -d quanlynhathro -f V1__init_schema.sql
   ```

### Cài đặt Frontend

1. Di chuyển vào thư mục frontend:
   ```bash
   cd frontend
   ```

2. Cài đặt dependencies:
   ```bash
   npm install
   ```

3. Tạo file `.env` (tham khảo `.env.example`)

## Chạy local

### Chạy Backend Local (SAM)

```bash
cd backend
sam build
sam local start-api --env-vars env.json
```

### Chạy Frontend Local

```bash
cd frontend
npm run dev
```

Frontend sẽ chạy tại `http://localhost:5173`

## Triển khai lên AWS

### Triển khai lên Staging

Khi bạn push code lên nhánh `develop`, GitHub Actions sẽ tự động triển khai lên môi trường staging.

Hoặc bạn có thể triển khai thủ công:

```bash
cd backend
sam build
sam deploy --stack-name quanlynhathro-staging --capabilities CAPABILITY_IAM --parameter-overrides Stage=staging ...
```

### Triển khai lên Production

Khi bạn tạo một release tag, GitHub Actions sẽ tự động triển khai lên môi trường production.

## Tài liệu thêm

- [BRD - Business Requirements Document](docs/BRD.md)
- [SRS - Software Requirements Specification](docs/SRS.md)
- [SDD - System Design Document](docs/SDD.md)
- [Database Migrations](infra/db-migrations/README.md)
