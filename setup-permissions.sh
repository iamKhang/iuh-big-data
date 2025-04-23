#!/bin/bash

# Script để cấu hình quyền thực thi cho tất cả các script

echo "Cấu hình quyền thực thi cho các script..."

# Danh sách các script cần cấp quyền thực thi
SCRIPTS=(
  "build-push-images.sh"
  "clean-docker.sh"
  "deploy-stack.sh"
  "rebuild-webui.sh"
  "setup-network.sh"
  "setup-registry.sh"
  "start-registry.sh"
  "setup-permissions.sh"
  "fix-webui.sh"
)

# Cấp quyền thực thi cho từng script
for script in "${SCRIPTS[@]}"; do
  if [ -f "$script" ]; then
    chmod +x "$script"
    echo "✅ Đã cấp quyền thực thi cho $script"
  else
    echo "❌ Không tìm thấy script $script"
  fi
done

echo "Hoàn tất cấu hình quyền thực thi!"
