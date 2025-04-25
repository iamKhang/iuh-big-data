# Sử dụng node:14-alpine cho tính tương thích tốt hơn với ARM
FROM node:14-alpine

# Tạo thư mục làm việc
WORKDIR /app

# Cài đặt express và redis trực tiếp từ npm
RUN npm init -y && \
    npm cache clean --force && \
    npm install express@4.17.1 redis@3.1.2 --no-package-lock --no-save

# Copy các file cần thiết
COPY files/ /app/files/
COPY webui.js /app/

# Expose port và chạy ứng dụng
EXPOSE 80
CMD ["node", "webui.js"]
