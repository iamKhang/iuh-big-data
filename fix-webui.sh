#!/bin/bash

# Script để sửa lỗi build webui image (tương thích với ARM)

echo "===== Sửa lỗi build webui image (tương thích với ARM) ====="

# Kiểm tra kiến trúc CPU
ARCH=$(uname -m)
echo "Kiến trúc CPU: $ARCH"

# Dừng và xóa container registry nếu đang chạy
echo "Dừng và khởi động lại registry..."
docker rm -f registry 2>/dev/null || true
docker run -d -p 5000:5000 --restart=always --name registry registry:2

# Xóa tất cả các image webui cũ
echo "Xóa tất cả các image webui cũ..."
docker images | grep webui | awk '{print $3}' | xargs docker rmi -f 2>/dev/null || true
docker rmi 192.168.19.10:5000/dockercoins_webui:latest 2>/dev/null || true

# Xóa các container npm cache
echo "Xóa các container npm cache..."
docker ps -a | grep npm | awk '{print $1}' | xargs docker rm -f 2>/dev/null || true

# Xóa các volume không sử dụng
echo "Xóa các volume không sử dụng..."
docker volume prune -f

# Xóa cache npm
echo "Xóa cache npm..."
docker run --rm -v "$(pwd)/webui:/app" node:14-alpine sh -c "cd /app && npm cache clean --force"

# Tạo file package.json tạm thời
echo "Tạo file package.json tạm thời..."
cat > webui/package.json <<EOF
{
  "name": "webui",
  "version": "1.0.0",
  "description": "DockerCoins WebUI",
  "main": "webui.js",
  "dependencies": {
    "express": "4.17.1",
    "redis": "3.1.2"
  }
}
EOF

# Build lại image webui với các tùy chọn đặc biệt cho ARM
echo "Build lại image webui..."
if [[ "$ARCH" == "arm64" || "$ARCH" == "aarch64" ]]; then
  echo "Sử dụng các tùy chọn đặc biệt cho ARM..."
  docker build --platform linux/arm64 --no-cache -t 192.168.19.10:5000/dockercoins_webui:latest ./webui
else
  docker build --no-cache -t 192.168.19.10:5000/dockercoins_webui:latest ./webui
fi

# Push image lên registry
echo "Push image lên registry..."
docker push 192.168.19.10:5000/dockercoins_webui:latest

# Xóa file package.json tạm thời
rm -f webui/package.json

echo "===== Hoàn tất! ====="
echo "Nếu thành công, bạn có thể triển khai stack với: ./deploy-stack.sh"
echo "Hoặc cập nhật service webui với: docker service update --force dockercoins_webui"
