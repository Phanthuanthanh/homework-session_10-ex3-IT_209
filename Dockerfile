# ==========================================
# STAGE 1: Builder
# ==========================================
FROM node:18-alpine AS builder

WORKDIR /app

# 1. Tận dụng Docker Build Cache: Copy dependency manifest trước
COPY package*.json ./

# 2. Cài đặt dependencies
RUN npm install

# 3. Copy toàn bộ source code vào để chuẩn bị
COPY . .

# 4. (Tùy chọn) Loại bỏ các thư viện dev thừa nếu có
RUN npm prune --production

# ==========================================
# STAGE 2: Runtime (Siêu nhẹ)
# ==========================================
FROM node:18-alpine

WORKDIR /app

# Thiết lập biến môi trường production
ENV NODE_ENV=production

# Chỉ trích xuất tệp cần thiết từ stage builder
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/server.js ./

# Mở cổng 3000
EXPOSE 3000

# Chạy ứng dụng
CMD ["node", "server.js"]
