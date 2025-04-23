FROM node:16-alpine

# Tạo thư mục làm việc và copy package.json
WORKDIR /app

# Tạo package.json đơn giản
RUN echo '{"dependencies":{"express":"^4.18.2","redis":"^3.1.2"}}' > package.json

# Cài đặt dependencies
RUN npm install --production

# Copy các file cần thiết
COPY files/ /app/files/
COPY webui.js /app/

# Expose port và chạy ứng dụng
EXPOSE 80
CMD ["node", "webui.js"]
