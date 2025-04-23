#!/bin/bash

# Script để cập nhật cấu hình DNS trong Docker Swarm

echo "===== Cập nhật cấu hình DNS trong Docker Swarm ====="

# Kiểm tra xem có phải là node manager không
if ! docker node ls &>/dev/null; then
  echo "Script này phải được chạy trên node manager của Docker Swarm."
  exit 1
fi

# Tạo hoặc cập nhật file daemon.json
echo "Cập nhật cấu hình DNS trong /etc/docker/daemon.json..."

if [ -f /etc/docker/daemon.json ]; then
  # Sao lưu file cấu hình hiện tại
  sudo cp /etc/docker/daemon.json /etc/docker/daemon.json.bak
  
  # Thêm cấu hình DNS vào file hiện tại
  TMP_FILE=$(mktemp)
  if command -v jq > /dev/null; then
    # Sử dụng jq nếu có
    sudo jq '.dns = ["8.8.8.8", "8.8.4.4"] | ."dns-search" = ["hoangkhang-net"] | ."dns-opts" = ["ndots:1", "timeout:2", "attempts:3"]' /etc/docker/daemon.json > "$TMP_FILE"
    sudo cat "$TMP_FILE" > /etc/docker/daemon.json
  else
    # Nếu không có jq, tạo file mới
    echo '{
  "dns": ["8.8.8.8", "8.8.4.4"],
  "dns-search": ["hoangkhang-net"],
  "dns-opts": ["ndots:1", "timeout:2", "attempts:3"],
  "insecure-registries": ["192.168.19.10:5000"]
}' | sudo tee /etc/docker/daemon.json > /dev/null
  fi
  rm -f "$TMP_FILE"
else
  # Tạo file mới
  sudo mkdir -p /etc/docker
  echo '{
  "dns": ["8.8.8.8", "8.8.4.4"],
  "dns-search": ["hoangkhang-net"],
  "dns-opts": ["ndots:1", "timeout:2", "attempts:3"],
  "insecure-registries": ["192.168.19.10:5000"]
}' | sudo tee /etc/docker/daemon.json > /dev/null
fi

# Khởi động lại Docker
echo "Khởi động lại Docker..."
sudo systemctl restart docker

# Đợi Docker khởi động lại
echo "Đợi Docker khởi động lại..."
sleep 5

# Kiểm tra trạng thái Docker
echo "Kiểm tra trạng thái Docker..."
sudo systemctl status docker --no-pager

echo "===== Hoàn tất! ====="
echo "Bạn cần chạy script này trên tất cả các node trong swarm."
echo "Sau đó, triển khai lại stack với lệnh: ./deploy-stack.sh"
