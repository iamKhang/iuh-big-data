#!/bin/bash

# Script để khởi động Docker Registry

# Đặt địa chỉ registry là IP của node manager
REGISTRY_IP=192.168.19.10

echo "===== Khởi động Docker Registry ====="

# Kiểm tra xem registry đã chạy chưa
if docker ps | grep -q registry; then
  echo "Registry đã đang chạy."
else
  # Dừng container registry nếu đang tồn tại nhưng không chạy
  docker rm -f registry 2>/dev/null || true
  
  # Khởi động registry mới
  echo "Khởi động registry mới..."
  docker run -d -p 5000:5000 --restart=always --name registry registry:2
fi

# Kiểm tra kết nối đến registry
echo "Kiểm tra kết nối đến registry..."
if curl -s http://localhost:5000/v2/ > /dev/null; then
  echo "✅ Kết nối đến registry thành công qua localhost."
else
  echo "❌ Không thể kết nối đến registry qua localhost."
fi

if curl -s http://$REGISTRY_IP:5000/v2/ > /dev/null; then
  echo "✅ Kết nối đến registry thành công qua $REGISTRY_IP."
else
  echo "❌ Không thể kết nối đến registry qua $REGISTRY_IP."
  echo "Có thể có vấn đề về cấu hình mạng hoặc tường lửa."
  echo "Hãy chạy script setup-registry.sh với quyền sudo để cấu hình Docker tin tưởng registry không bảo mật."
fi

echo "===== Hoàn tất! ====="
