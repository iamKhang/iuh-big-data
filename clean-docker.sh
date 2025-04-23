#!/bin/bash

# Script để dọn dẹp hoàn toàn Docker (containers, images, services, networks, volumes)
# Chú ý: Script này sẽ xóa TẤT CẢ dữ liệu Docker, hãy sử dụng cẩn thận!

echo "===== DOCKER CLEANUP SCRIPT ====="
echo "Script này sẽ dọn dẹp hoàn toàn Docker trên hệ thống."
echo "Tất cả containers, services, networks, images và volumes sẽ bị xóa."
echo "Dữ liệu sẽ bị mất vĩnh viễn!"
echo ""
echo "Nhấn ENTER để tiếp tục hoặc Ctrl+C để hủy..."
read

# Dừng và xóa tất cả Docker Swarm stacks
echo "===== Dừng và xóa tất cả Docker Swarm stacks ====="
for stack in $(docker stack ls --format "{{.Name}}"); do
  echo "Xóa stack: $stack"
  docker stack rm "$stack"
done

# Đợi một chút để các services được dừng hoàn toàn
echo "Đợi các services dừng hoàn toàn..."
sleep 10

# Dừng và xóa tất cả containers đang chạy
echo "===== Dừng và xóa tất cả containers ====="
docker container stop $(docker container ls -aq) 2>/dev/null || true
docker container rm $(docker container ls -aq) 2>/dev/null || true

# Xóa tất cả networks (trừ các networks mặc định)
echo "===== Xóa tất cả networks ====="
for network in $(docker network ls --format "{{.Name}}" | grep -v "bridge\|host\|none"); do
  echo "Xóa network: $network"
  docker network rm "$network" 2>/dev/null || true
done

# Xóa tất cả volumes
echo "===== Xóa tất cả volumes ====="
docker volume rm $(docker volume ls -q) 2>/dev/null || true

# Xóa tất cả images
echo "===== Xóa tất cả images ====="
docker image rm $(docker image ls -aq) --force 2>/dev/null || true

# Xóa các resources không sử dụng
echo "===== Dọn dẹp các resources không sử dụng ====="
docker system prune -af --volumes

# Kiểm tra trạng thái sau khi dọn dẹp
echo "===== Trạng thái sau khi dọn dẹp ====="
echo "Containers:"
docker container ls -a
echo ""
echo "Images:"
docker image ls
echo ""
echo "Networks:"
docker network ls
echo ""
echo "Volumes:"
docker volume ls
echo ""
echo "Docker Swarm stacks:"
docker stack ls
echo ""

echo "===== Dọn dẹp hoàn tất! ====="
