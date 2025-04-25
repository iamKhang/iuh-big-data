# DockerCoins Images

Đây là bộ các image Docker cho ứng dụng DockerCoins, một ứng dụng demo đơn giản để minh họa việc sử dụng Docker và microservices.

## Các image có sẵn

- `iamhoangkhang/rng:latest`: Service tạo số ngẫu nhiên
- `iamhoangkhang/hasher:latest`: Service tạo hash
- `iamhoangkhang/webui:latest`: Giao diện web
- `iamhoangkhang/worker:latest`: Worker xử lý công việc

## Cách sử dụng

### Sử dụng Docker Compose

```yaml
version: "3"

services:
  rng:
    image: iamhoangkhang/rng:latest
    ports:
    - "8001:80"
    networks:
      - mynet

  hasher:
    image: iamhoangkhang/hasher:latest
    ports:
    - "8002:80"
    networks:
      - mynet

  webui:
    image: iamhoangkhang/webui:latest
    ports:
    - "8000:80"
    volumes:
    - "./webui/files/:/files/"
    networks:
      - mynet

  redis:
    image: redis
    networks:
      - mynet

  worker:
    image: iamhoangkhang/worker:latest
    networks:
      - mynet

networks:
  mynet:
    driver: bridge
```

Lưu nội dung trên vào file `docker-compose.yml` và chạy lệnh:

```bash
docker-compose up -d
```

### Truy cập các dịch vụ

- WebUI: http://localhost:8000
- RNG API: http://localhost:8001
- Hasher API: http://localhost:8002

## Thông tin chi tiết

- **RNG**: Dịch vụ tạo số ngẫu nhiên, được viết bằng Python với Flask
- **Hasher**: Dịch vụ tạo hash, được viết bằng Python với Flask
- **WebUI**: Giao diện web, được viết bằng Node.js
- **Worker**: Xử lý công việc, được viết bằng Python

## Nguồn

Các image này được tạo từ mã nguồn tại: [https://github.com/iamhoangkhang/dockercoins](https://github.com/iamhoangkhang/dockercoins)
