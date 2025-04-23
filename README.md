# Dự án Big Data - DockerCoins với ELK Stack, Prometheus-Grafana-InfluxDB và Nginx

Dự án này triển khai ứng dụng DockerCoins trên Docker Swarm với các công cụ giám sát và phân tích dữ liệu.

## Mục lục

- [Giới thiệu](#giới-thiệu)
- [Yêu cầu hệ thống](#yêu-cầu-hệ-thống)
- [Cấu trúc dự án](#cấu-trúc-dự-án)
- [Hướng dẫn triển khai](#hướng-dẫn-triển-khai)
  - [Cách 1: Triển khai tự động](#cách-1-triển-khai-tự-động)
  - [Cách 2: Triển khai thủ công](#cách-2-triển-khai-thủ-công)
- [ELK Stack](#elk-stack)
- [Prometheus-Grafana-InfluxDB](#prometheus-grafana-influxdb)
- [Nginx Reverse Proxy](#nginx-reverse-proxy)
- [Xử lý sự cố](#xử-lý-sự-cố)

## Giới thiệu

Dự án này triển khai ứng dụng DockerCoins (bao gồm các dịch vụ rng, hasher, worker, webui và redis) trên Docker Swarm, kèm theo các công cụ giám sát và phân tích dữ liệu:

1. **ELK Stack**: Thu thập, xử lý và hiển thị logs từ các dịch vụ
2. **Prometheus-Grafana-InfluxDB**: Thu thập, lưu trữ và hiển thị metrics từ các node và dịch vụ
3. **Nginx Reverse Proxy**: Cung cấp điểm truy cập duy nhất đến các dịch vụ

## Yêu cầu hệ thống

- Docker Engine phiên bản 19.03 trở lên
- Docker Swarm đã được thiết lập với ít nhất 2 node (1 manager và 1 worker)
- Các node có địa chỉ IP cố định (192.168.19.10 cho manager và 192.168.19.11 cho worker)
- Ít nhất 4GB RAM và 10GB dung lượng ổ đĩa trống trên mỗi node

### Lưu ý cho môi trường ARM (Apple Silicon)

Dự án đã được điều chỉnh để hoạt động trên kiến trúc ARM (như Macbook M2):

- Một số dịch vụ như cAdvisor đã bị tắt vì không tương thích với ARM
- Các dịch vụ ELK Stack và Prometheus đã được điều chỉnh để sử dụng ít bộ nhớ hơn
- Các dịch vụ được cấu hình để chạy trên node manager thay vì phân tán trên cả cụm

## Cấu trúc dự án

```
.
├── docker-stack.yml          # File cấu hình Docker Swarm
├── setup-environment.sh      # Script thiết lập môi trường
├── run-all.sh                # Script triển khai toàn bộ ứng dụng
├── hasher/                   # Dịch vụ hasher
├── rng/                      # Dịch vụ rng
├── webui/                    # Dịch vụ webui
├── worker/                   # Dịch vụ worker
├── elk/                      # Cấu hình ELK Stack
│   └── config/
│       ├── elasticsearch.yml
│       ├── kibana.yml
│       ├── logstash.conf
│       └── filebeat.yml
├── monitoring/               # Cấu hình Prometheus-Grafana-InfluxDB
│   └── config/
│       ├── prometheus.yml
│       ├── grafana.ini
│       └── influxdb.conf
└── nginx/                    # Cấu hình Nginx
    └── config/
        └── nginx.conf
```

## Hướng dẫn triển khai

### Cách 1: Triển khai tự động

Sử dụng script `run-all.sh` để triển khai toàn bộ ứng dụng:

```bash
chmod +x setup-environment.sh run-all.sh
./run-all.sh
```

Script này sẽ:
1. Thiết lập môi trường (nếu chưa được thiết lập)
2. Build và push các image vào registry local
3. Triển khai stack trên Docker Swarm

### Cách 2: Triển khai thủ công

#### Bước 1: Thiết lập môi trường

```bash
chmod +x setup-environment.sh
./setup-environment.sh
```

Script này sẽ:
1. Dừng và xóa tất cả các container đang chạy
2. Xóa tất cả các service trong Docker Swarm
3. Xóa tất cả các network, volume và image không sử dụng
4. Tạo mạng `hoangkhang-net`
5. Khởi động registry local

#### Bước 2: Build và push các image

```bash
# Build và push image rng
docker build -t 127.0.0.1:5000/rng ./rng
docker push 127.0.0.1:5000/rng

# Build và push image hasher
docker build -t 127.0.0.1:5000/hasher ./hasher
docker push 127.0.0.1:5000/hasher

# Build và push image webui
docker build -t 127.0.0.1:5000/webui ./webui
docker push 127.0.0.1:5000/webui

# Build và push image worker
docker build -t 127.0.0.1:5000/worker ./worker
docker push 127.0.0.1:5000/worker
```

#### Bước 3: Triển khai stack

```bash
docker stack deploy -c docker-stack.yml dockercoins
```

#### Bước 4: Kiểm tra trạng thái các dịch vụ

```bash
docker service ls
```

#### Bước 5: Truy cập các dịch vụ

Sau khi triển khai, bạn có thể truy cập các dịch vụ qua địa chỉ IP của node manager (192.168.19.10) hoặc localhost (127.0.0.1) nếu bạn đang ở trên máy manager:

## ELK Stack

### Logstash

Logstash được cấu hình để thu thập logs từ 4 dịch vụ: rng, hasher, worker và webui. Logstash chạy với 2 replicas để đảm bảo tính sẵn sàng cao.

#### Cấu hình Logstash

Logstash được cấu hình để:
1. Thu thập logs từ Filebeat
2. Lọc và xử lý logs theo từng dịch vụ
3. Gửi logs đã xử lý đến Elasticsearch

### Elasticsearch

Elasticsearch lưu trữ logs từ Logstash và cung cấp khả năng tìm kiếm nhanh chóng.

#### Truy vấn dữ liệu trong Elasticsearch

Bạn có thể truy vấn dữ liệu trong Elasticsearch thông qua API:

```bash
curl -X GET "http://192.168.19.10/elasticsearch/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "match_all": {}
  }
}
'
```

### Kibana

Kibana cung cấp giao diện người dùng để tìm kiếm, trực quan hóa và phân tích dữ liệu logs.

#### Thao tác với Kibana

1. Truy cập Kibana tại http://192.168.19.10/kibana
2. Tạo index pattern: Management > Stack Management > Index Patterns > Create index pattern
3. Nhập `dockercoins-*` và chọn `@timestamp` làm trường thời gian
4. Khám phá dữ liệu: Analytics > Discover
5. Tạo dashboard: Analytics > Dashboard > Create new dashboard

## Prometheus-Grafana-InfluxDB

### Prometheus

Prometheus thu thập metrics từ các node và dịch vụ trong cụm Docker Swarm.

#### Metrics được thu thập

- CPU, RAM (active or inactive memory), disk usage trên tất cả các node
- Tất cả các process và state của chúng
- Số lượng file đang mở, sockets và trạng thái của chúng
- Các hoạt động của I/O (disk, network), trên thao tác hoặc dung lượng (volume)
- Phần cứng vật lý (nếu có thể): fan speed, cpu temperature

#### Truy cập Prometheus

Truy cập Prometheus tại http://192.168.19.10/prometheus

### InfluxDB

InfluxDB lưu trữ dữ liệu metrics từ Prometheus để phân tích dài hạn.

#### Truy vấn dữ liệu trong InfluxDB

Bạn có thể truy vấn dữ liệu trong InfluxDB thông qua API:

```bash
curl -G 'http://192.168.19.10/influxdb/query?db=prometheus' --data-urlencode 'q=SELECT * FROM "cpu_usage_system" LIMIT 10'
```

### Grafana

Grafana cung cấp giao diện người dùng để trực quan hóa và phân tích dữ liệu metrics.

#### Thao tác với Grafana

1. Truy cập Grafana tại http://192.168.19.10/grafana (username: admin, password: admin)
2. Thêm data source:
   - Configuration > Data Sources > Add data source
   - Chọn Prometheus
   - URL: http://prometheus:9090
   - Lưu và kiểm tra kết nối
3. Thêm data source InfluxDB:
   - Configuration > Data Sources > Add data source
   - Chọn InfluxDB
   - URL: http://influxdb:8086
   - Database: prometheus
   - Lưu và kiểm tra kết nối
4. Tạo dashboard:
   - Create > Dashboard
   - Add new panel
   - Chọn metrics và tùy chỉnh hiển thị

## Nginx Reverse Proxy

### Giới thiệu về Reverse Proxy

Reverse proxy là một loại proxy server hoạt động ở phía server, nhận các request từ client và chuyển tiếp chúng đến các server phía sau. Reverse proxy giúp cân bằng tải, bảo mật và tối ưu hóa hiệu suất.

### Giới thiệu về Nginx

Nginx là một web server mạnh mẽ, có thể được sử dụng làm reverse proxy, load balancer, mail proxy và HTTP cache.

### Cấu hình URL routing trong Nginx

Nginx được cấu hình để định tuyến các request đến các dịch vụ tương ứng:

- http://192.168.19.10/ -> DockerCoins WebUI
- http://192.168.19.10/kibana/ -> Kibana
- http://192.168.19.10/grafana/ -> Grafana
- http://192.168.19.10/prometheus/ -> Prometheus
- http://192.168.19.10/elasticsearch/ -> Elasticsearch
- http://192.168.19.10/influxdb/ -> InfluxDB

## Xử lý sự cố

### Kiểm tra logs của các dịch vụ

```bash
docker service logs dockercoins_rng
docker service logs dockercoins_hasher
docker service logs dockercoins_worker
docker service logs dockercoins_webui
docker service logs dockercoins_elasticsearch
docker service logs dockercoins_logstash
docker service logs dockercoins_kibana
docker service logs dockercoins_prometheus
docker service logs dockercoins_grafana
docker service logs dockercoins_influxdb
docker service logs dockercoins_nginx
```

### Kiểm tra trạng thái của các dịch vụ

```bash
docker service ls
```

### Khởi động lại một dịch vụ

```bash
docker service update --force dockercoins_<service_name>
```

### Xóa và triển khai lại stack

```bash
docker stack rm dockercoins
docker stack deploy -c docker-stack.yml dockercoins
```

### Xử lý vấn đề với kiến trúc ARM (Apple Silicon)

Nếu bạn gặp vấn đề "unsupported platform" hoặc các lỗi tương tự, hãy thử các giải pháp sau:

1. **Đảm bảo sử dụng các image tương thích với ARM**:
   ```bash
   # Kiểm tra kiến trúc của image
   docker inspect --format '{{.Architecture}}' <image_name>
   ```

2. **Giảm bộ nhớ cấp cho các dịch vụ**:
   ```bash
   # Chỉnh sửa giới hạn bộ nhớ trong docker-stack.yml
   # Ví dụ: giảm từ 1G xuống 512M
   ```

3. **Tắt các dịch vụ không cần thiết**:
   ```bash
   # Bỏ comment các dịch vụ không tương thích trong docker-stack.yml
   ```

4. **Sử dụng các phiên bản mới hơn của các image**:
   ```bash
   # Cập nhật phiên bản image trong docker-stack.yml
   ```
