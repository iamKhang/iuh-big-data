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

# Kiểm tra và xóa mạng hoangkhang-net nếu đã tồn tại
echo "Kiểm tra mạng hoangkhang-net..."
if docker network ls | grep -q hoangkhang-net; then
    echo "Mạng hoangkhang-net đã tồn tại. Đang xóa..."
    docker network rm hoangkhang-net 2>/dev/null || true
    sleep 2
fi

# Tạo mạng hoangkhang-net
echo "Đang tạo mạng hoangkhang-net..."
docker network create --driver overlay --attachable hoangkhang-net

# Kiểm tra và dừng registry nếu đang chạy
echo "Kiểm tra và dừng registry nếu đang chạy..."
docker stop registry 2>/dev/null || true
docker rm registry 2>/dev/null || true

# Kiểm tra xem image registry:2 đã có sẵn chưa
echo "Kiểm tra image registry:2..."
if ! docker images | grep -q "registry.*2"; then
    echo "Image registry:2 chưa có sẵn. Bạn có thể gặp vấn đề với giới hạn kéo image."
    echo "Thử sử dụng registry đã có sẵn hoặc bỏ qua bước này..."

    # Kiểm tra xem registry đã chạy chưa
    if docker ps | grep -q registry; then
        echo "Registry đã đang chạy. Tiếp tục..."
    else
        echo "Cảnh báo: Không thể khởi động registry. Tiếp tục mà không có registry..."
    fi
else
    # Khởi động registry local với địa chỉ IP cố định
    echo "Đang khởi động registry local tại 192.168.19.10:5000..."
    docker run -d -p 5000:5000 --restart=always --name registry registry:2

    # Đảm bảo registry đã khởi động
    echo "Kiểm tra registry đã khởi động..."
    sleep 2
    if ! docker ps | grep -q registry; then
        echo "Cảnh báo: Registry không thể khởi động. Tiếp tục mà không có registry..."
    else
        echo "Registry đã khởi động thành công."
    fi
fi

# Hiển thị thông báo hoàn thành
echo "===== THIẾT LẬP MÔI TRƯỜNG HOÀN TẤT ====="
echo "Mạng hoangkhang-net đã được tạo"

# Kiểm tra lại xem registry có đang chạy không
if docker ps | grep -q registry; then
    echo "Registry local đã được khởi động tại 192.168.19.10:5000"
else
    echo "Lưu ý: Registry không được khởi động. Bạn cần sử dụng các image đã có sẵn."
fi

echo "Bạn có thể tiếp tục với việc triển khai ứng dụng"
