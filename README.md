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

Kibana cung cấp giao diện người dùng để tìm kiếm, trực quan hóa và phân tích dữ liệu logs. Kibana đã được cấu hình để tắt xác thực và bỏ qua màn hình chào mừng, giúp bạn truy cập trực tiếp vào giao diện chính mà không cần nhập token hay mật khẩu.

#### Kết nối với Elasticsearch

Kibana được cấu hình để kết nối tự động với Elasticsearch thông qua các biến môi trường và file cấu hình. Các cài đặt sau đã được thực hiện để đảm bảo kết nối suôn sẻ:

- `elasticsearch.hosts` được cấu hình để trỏ đến dịch vụ Elasticsearch
- `xpack.security.enabled` được đặt thành `false` để tắt xác thực
- Các tính năng telemetry và reporting đã bị tắt để tăng hiệu suất

#### Thao tác với Kibana

1. Truy cập Kibana tại http://192.168.19.10/kibana
2. Tạo index pattern: Management > Stack Management > Index Patterns > Create index pattern
3. Nhập `dockercoins-*` và chọn `@timestamp` làm trường thời gian
4. Khám phá dữ liệu: Analytics > Discover
5. Tạo dashboard: Analytics > Dashboard > Create new dashboard

#### Tìm kiếm và phân tích logs

Kibana cung cấp nhiều công cụ mạnh mẽ để tìm kiếm và phân tích logs:

1. **Tìm kiếm cơ bản**: Sử dụng Discover để tìm kiếm logs theo từ khóa
   ```
   service: worker AND log_level: ERROR
   ```

2. **Tìm kiếm nâng cao**: Sử dụng Kibana Query Language (KQL)
   ```
   service: "worker" and log_message: *"error"* and @timestamp > now-1h
   ```

3. **Tạo biểu đồ**: Sử dụng Visualize để tạo các biểu đồ từ dữ liệu logs
   - Biểu đồ cột: Số lượng logs theo dịch vụ
   - Biểu đồ đường: Số lượng logs theo thời gian
   - Biểu đồ tròn: Phân bố logs theo mức độ nghiêm trọng

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

#### Pipeline thu thập và lưu trữ metrics

Prometheus sử dụng một pipeline hoàn chỉnh để thu thập và lưu trữ metrics:

1. **Thu thập metrics**: Prometheus sử dụng các exporter (node-exporter) để thu thập metrics từ các node và dịch vụ
2. **Lưu trữ metrics**: Metrics được lưu trữ trong cơ sở dữ liệu TSDB (Time Series Database) của Prometheus
3. **Truy vấn metrics**: Sử dụng ngôn ngữ truy vấn PromQL để truy vấn và phân tích metrics
4. **Hiển thị metrics**: Hiển thị metrics trên giao diện web của Prometheus hoặc Grafana

#### Truy vấn metrics với CLI

Bạn có thể sử dụng API của Prometheus để truy vấn metrics từ command line:

```bash
# Truy vấn CPU usage
curl -G "http://192.168.19.10/prometheus/api/v1/query" --data-urlencode "query=sum(rate(node_cpu_seconds_total{mode!='idle'}[1m])) by (instance)"

# Truy vấn memory usage
curl -G "http://192.168.19.10/prometheus/api/v1/query" --data-urlencode "query=node_memory_MemTotal_bytes - node_memory_MemFree_bytes - node_memory_Buffers_bytes - node_memory_Cached_bytes"

# Truy vấn disk usage
curl -G "http://192.168.19.10/prometheus/api/v1/query" --data-urlencode "query=node_filesystem_size_bytes{mountpoint='/'} - node_filesystem_free_bytes{mountpoint='/'}"
```

### InfluxDB

InfluxDB là một cơ sở dữ liệu time series được tối ưu hóa cho việc lưu trữ và truy vấn dữ liệu metrics với khối lượng lớn. Trong dự án này, InfluxDB được sử dụng để lưu trữ dữ liệu metrics từ Prometheus để phân tích dài hạn.

#### Đồng bộ hóa dữ liệu từ Prometheus với InfluxDB

Prometheus được cấu hình để gửi dữ liệu đến InfluxDB thông qua cấu hình `remote_write` và `remote_read` trong file `prometheus.yml`:

```yaml
remote_write:
  - url: "http://influxdb:8086/api/v1/prom/write?db=prometheus"

remote_read:
  - url: "http://influxdb:8086/api/v1/prom/read?db=prometheus"
```

#### Truy vấn dữ liệu trong InfluxDB

Bạn có thể truy vấn dữ liệu trong InfluxDB thông qua API:

```bash
# Truy vấn cơ bản
curl -G 'http://192.168.19.10/influxdb/query?db=prometheus' --data-urlencode 'q=SELECT * FROM "cpu_usage_system" LIMIT 10'

# Truy vấn CPU usage trung bình trong 5 phút gần nhất
curl -G 'http://192.168.19.10/influxdb/query?db=prometheus' --data-urlencode 'q=SELECT mean("value") FROM "cpu_usage_system" WHERE time > now() - 5m GROUP BY time(30s)'

# Truy vấn memory usage
curl -G 'http://192.168.19.10/influxdb/query?db=prometheus' --data-urlencode 'q=SELECT last("value") FROM "memory_usage_bytes" GROUP BY "instance"'
```

### Grafana

Grafana là một nền tảng trực quan hóa dữ liệu mạnh mẽ, cho phép bạn tạo các dashboard để giám sát và phân tích hiệu suất của hệ thống. Grafana có thể kết nối với nhiều nguồn dữ liệu khác nhau, bao gồm Prometheus và InfluxDB.

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

#### Tạo Dashboard trong Grafana

Grafana cho phép bạn tạo các dashboard tùy chỉnh để giám sát hiệu suất của Docker Swarm:

1. **Tạo dashboard mới**:
   - Click vào "+" > Dashboard
   - Click "Add new panel"

2. **Cấu hình panel**:
   - Chọn data source (Prometheus hoặc InfluxDB)
   - Viết truy vấn PromQL (với Prometheus) hoặc InfluxQL (với InfluxDB)
   - Ví dụ truy vấn PromQL cho CPU usage:
     ```
     sum(rate(node_cpu_seconds_total{mode!="idle"}[1m])) by (instance)
     ```
   - Chọn loại biểu đồ (Graph, Gauge, Bar chart, etc.)
   - Cấu hình các tùy chọn hiển thị (màu sắc, đơn vị, ngưỡng cảnh báo)

3. **Tạo các panel giám sát quan trọng**:
   - **CPU Usage**: Giám sát tỉ lệ sử dụng CPU trên các node
   - **Memory Usage**: Giám sát lượng RAM đã sử dụng và còn trống
   - **Disk Usage**: Giám sát dung lượng ổ đĩa đã sử dụng
   - **Network Traffic**: Giám sát lượng dữ liệu truyền qua mạng
   - **Container Metrics**: Giám sát hiệu suất của các container

4. **Tạo các cảnh báo**:
   - Click vào biểu tượng chuông trên panel
   - Cấu hình ngưỡng cảnh báo (ví dụ: CPU > 80%)
   - Cấu hình kênh thông báo (email, Slack, etc.)

5. **Lưu và chia sẻ dashboard**:
   - Click "Save" để lưu dashboard
   - Đặt tên và mô tả cho dashboard
   - Có thể xuất dashboard dưới dạng JSON để chia sẻ hoặc sao lưu

## Nginx Reverse Proxy

### Giới thiệu về Reverse Proxy

Reverse proxy là một loại proxy server hoạt động ở phía server, nhận các request từ client và chuyển tiếp chúng đến các server phía sau. Reverse proxy mang lại nhiều lợi ích:

- **Cân bằng tải**: Phân phối request đến nhiều server để tối ưu hóa hiệu suất
- **Bảo mật**: Ẩn các chi tiết về các server phía sau và cung cấp lớp bảo vệ thêm
- **SSL Termination**: Xử lý mã hóa/giải mã SSL/TLS, giảm tải cho các server phía sau
- **Nén**: Nén dữ liệu trước khi gửi đến client, giảm băng thông
- **Caching**: Lưu trữ nội dung tĩnh để giảm tải cho các server phía sau

### Giới thiệu về Nginx

Nginx là một web server mạnh mẽ, có thể được sử dụng làm reverse proxy, load balancer, mail proxy và HTTP cache. Nginx nổi tiếng với hiệu suất cao, ổn định, tính năng phù hợp và tính bảo mật.

Các đặc điểm chính của Nginx:

- **Kiến trúc hướng sự kiện**: Xử lý nhiều kết nối đồng thời với tài nguyên thấp
- **Tính mở rộng**: Hỗ trợ nhiều module và có thể tùy chỉnh
- **Hiệu suất cao**: Xử lý hàng nghìn kết nối đồng thời
- **Tính ổn định**: Được sử dụng rộng rãi trong các hệ thống sản xuất

### Cấu hình URL routing trong Nginx

Nginx được cấu hình để định tuyến các request đến các dịch vụ tương ứng:

- http://192.168.19.10/ -> DockerCoins WebUI
- http://192.168.19.10/kibana/ -> Kibana
- http://192.168.19.10/grafana/ -> Grafana
- http://192.168.19.10/prometheus/ -> Prometheus
- http://192.168.19.10/elasticsearch/ -> Elasticsearch
- http://192.168.19.10/influxdb/ -> InfluxDB

### Thao tác với Nginx trong Docker Swarm

Nginx trong Docker Swarm được triển khai như một dịch vụ với các đặc điểm sau:

1. **Triển khai trên manager node**: Đảm bảo tính ổn định và khả năng truy cập
   ```yaml
   deploy:
     placement:
       constraints:
         - node.role == manager
   ```

2. **Cấu hình proxy_pass**: Chuyển tiếp request đến các dịch vụ trong Swarm
   ```nginx
   location /kibana/ {
       proxy_pass http://kibana:5601/;
       proxy_set_header Host $host;
       proxy_set_header X-Real-IP $remote_addr;
   }
   ```

3. **Truy cập các dịch vụ thông qua Nginx**:
   - Truy cập DockerCoins WebUI: `http://192.168.19.10/`
   - Truy cập Kibana: `http://192.168.19.10/kibana/`
   - Truy cập Grafana: `http://192.168.19.10/grafana/`

4. **Kiểm tra logs của Nginx**:
   ```bash
   docker service logs dockercoins_nginx
   ```

5. **Cập nhật cấu hình Nginx**:
   - Chỉnh sửa file `nginx/config/nginx.conf`
   - Cập nhật dịch vụ Nginx:
     ```bash
     docker service update --force dockercoins_nginx
     ```

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

1. **Đảm bảo sử dụng địa chỉ IP cố định cho registry**:
   ```bash
   # Sử dụng địa chỉ IP cố định của manager node (192.168.19.10) thay vì 127.0.0.1
   # Đã được cập nhật trong các file cấu hình
   ```

2. **Giảm bộ nhớ cấp cho các dịch vụ**:
   ```bash
   # Đã giảm bộ nhớ cho Elasticsearch từ 512M xuống 384M
   # Đã giảm bộ nhớ cho Logstash từ 384M xuống 256M
   # Đã giảm JVM heap cho Elasticsearch và Logstash
   ```

3. **Đảm bảo các dịch vụ chỉ chạy trên manager node**:
   ```bash
   # Đã thêm ràng buộc placement cho các dịch vụ quan trọng
   placement:
     constraints:
       - node.role == manager
   ```

4. **Kiểm tra logs của dịch vụ đang gặp vấn đề**:
   ```bash
   # Kiểm tra logs của Logstash
   docker service logs dockercoins_logstash

   # Kiểm tra logs của Elasticsearch
   docker service logs dockercoins_elasticsearch

   # Kiểm tra logs của InfluxDB
   docker service logs dockercoins_influxdb
   ```

5. **Khởi động lại dịch vụ cụ thể**:
   ```bash
   # Khởi động lại Logstash
   docker service update --force dockercoins_logstash

   # Khởi động lại Elasticsearch
   docker service update --force dockercoins_elasticsearch
   ```
