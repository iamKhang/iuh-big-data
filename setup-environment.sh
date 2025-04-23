#!/bin/bash

# Hiển thị thông báo
echo "===== THIẾT LẬP MÔI TRƯỜNG CHO DỰ ÁN BIG DATA ====="
echo "Script này sẽ làm sạch Docker và thiết lập môi trường cần thiết"

# Dừng và xóa tất cả các container đang chạy
echo "Đang dừng và xóa tất cả các container..."
docker stop $(docker ps -aq) 2>/dev/null || true
docker rm $(docker ps -aq) 2>/dev/null || true

# Xóa tất cả các service trong Docker Swarm
echo "Đang xóa tất cả các service trong Docker Swarm..."
docker service rm $(docker service ls -q) 2>/dev/null || true

# Xóa tất cả các network không sử dụng
echo "Đang xóa tất cả các network không sử dụng..."
docker network prune -f

# Xóa tất cả các volume không sử dụng
echo "Đang xóa tất cả các volume không sử dụng..."
docker volume prune -f

# Xóa tất cả các image không sử dụng
echo "Đang xóa tất cả các image không sử dụng..."
docker image prune -a -f

# Tạo mạng hoangkhang-net
echo "Đang tạo mạng hoangkhang-net..."
docker network create --driver overlay --attachable hoangkhang-net || true

# Khởi động registry local
echo "Đang khởi động registry local..."
docker run -d -p 5000:5000 --restart=always --name registry registry:2 || true

# Hiển thị thông báo hoàn thành
echo "===== THIẾT LẬP MÔI TRƯỜNG HOÀN TẤT ====="
echo "Mạng hoangkhang-net đã được tạo"
echo "Registry local đã được khởi động tại 127.0.0.1:5000"
echo "Bạn có thể tiếp tục với việc triển khai ứng dụng"
