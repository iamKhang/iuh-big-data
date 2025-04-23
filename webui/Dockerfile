FROM node:16-alpine

# Cài đặt các dependencies trong một lệnh để tránh lỗi npm
RUN npm install express@4.18.2 redis@3 --no-fund --no-audit

# Copy các file cần thiết
COPY files/ /files/
COPY webui.js /

# Expose port và chạy ứng dụng
EXPOSE 80
CMD ["node", "webui.js"]
