#!/bin/bash

# Script này cấu hình Docker trên tất cả các node để tin tưởng registry không bảo mật

# Đặt địa chỉ registry là IP của node manager
REGISTRY_IP=192.168.19.10

echo "Cấu hình Docker để tin tưởng registry không bảo mật tại $REGISTRY_IP:5000"

# Tạo hoặc cập nhật cấu hình daemon của Docker
if [ -f /etc/docker/daemon.json ]; then
  # Nếu file đã tồn tại, hãy thêm cấu hình mới vào file hiện tại
  echo "Cập nhật file daemon.json hiện tại..."
  # Sử dụng jq để thêm cấu hình mới nếu có sẵn
  if command -v jq > /dev/null; then
    TMP_FILE=$(mktemp)
    jq --arg ip "$REGISTRY_IP:5000" '."insecure-registries" = (."insecure-registries" // []) + [$ip] | ."insecure-registries" = (."insecure-registries" | unique)' /etc/docker/daemon.json > "$TMP_FILE"
    cat "$TMP_FILE" > /etc/docker/daemon.json
    rm "$TMP_FILE"
  else
    # Nếu không có jq, tạo file mới
    cat > /etc/docker/daemon.json <<EOF
{
  "insecure-registries": ["$REGISTRY_IP:5000"]
}
EOF
  fi
else
  # Nếu file chưa tồn tại, tạo file mới
  echo "Tạo file daemon.json mới..."
  mkdir -p /etc/docker
  cat > /etc/docker/daemon.json <<EOF
{
  "insecure-registries": ["$REGISTRY_IP:5000"]
}
EOF
fi

echo "Khởi động lại dịch vụ Docker..."
systemctl restart docker

echo "Docker đã được cấu hình để tin tưởng registry không bảo mật tại $REGISTRY_IP:5000"
echo "Lưu ý: Script này phải được chạy trên tất cả các node trong swarm với quyền sudo"
