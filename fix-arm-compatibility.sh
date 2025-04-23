#!/bin/bash

# Script để xử lý vấn đề tương thích ARM trong Docker Swarm

echo "===== Xử lý vấn đề tương thích ARM trong Docker Swarm ====="

# Kiểm tra kiến trúc CPU
ARCH=$(uname -m)
echo "Kiến trúc CPU: $ARCH"

# Kiểm tra xem có phải là ARM không
if [[ "$ARCH" == "arm64" || "$ARCH" == "aarch64" ]]; then
  echo "Phát hiện kiến trúc ARM. Áp dụng các cấu hình đặc biệt..."
  
  # Cập nhật cấu hình Docker để hỗ trợ tốt hơn cho ARM
  echo "Cập nhật cấu hình Docker..."
  
  # Tạo hoặc cập nhật file daemon.json
  if [ -f /etc/docker/daemon.json ]; then
    # Sao lưu file cấu hình hiện tại
    sudo cp /etc/docker/daemon.json /etc/docker/daemon.json.bak
    
    # Thêm cấu hình mới vào file hiện tại
    TMP_FILE=$(mktemp)
    if command -v jq > /dev/null; then
      # Sử dụng jq nếu có
      sudo jq '.experimental = true | ."insecure-registries" = (."insecure-registries" // []) + ["192.168.19.10:5000"] | ."insecure-registries" = (."insecure-registries" | unique)' /etc/docker/daemon.json > "$TMP_FILE"
      sudo cat "$TMP_FILE" > /etc/docker/daemon.json
    else
      # Nếu không có jq, tạo file mới
      echo '{
  "experimental": true,
  "insecure-registries": ["192.168.19.10:5000"]
}' | sudo tee /etc/docker/daemon.json > /dev/null
    fi
    rm -f "$TMP_FILE"
  else
    # Tạo file mới
    sudo mkdir -p /etc/docker
    echo '{
  "experimental": true,
  "insecure-registries": ["192.168.19.10:5000"]
}' | sudo tee /etc/docker/daemon.json > /dev/null
  fi
  
  # Khởi động lại Docker
  echo "Khởi động lại Docker..."
  sudo systemctl restart docker
  
  # Kiểm tra cấu hình
  echo "Cấu hình Docker hiện tại:"
  cat /etc/docker/daemon.json
  
  # Kiểm tra buildx
  if ! docker buildx ls | grep -q "default"; then
    echo "Cài đặt và cấu hình Docker Buildx..."
    docker buildx create --name mybuilder --use
  fi
  
  echo "Đã áp dụng các cấu hình đặc biệt cho ARM."
else
  echo "Không phải kiến trúc ARM. Không cần áp dụng cấu hình đặc biệt."
fi

echo "===== Hoàn tất! ====="
