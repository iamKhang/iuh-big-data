# Docker Swarm Stack with ELK, Prometheus-Grafana-InfluxDB, and Nginx Reverse Proxy

This repository contains a Docker Swarm stack configuration for running a comprehensive monitoring and logging solution alongside a sample application (DockerCoins). The stack includes ELK Stack (Elasticsearch, Logstash, Kibana), Prometheus-Grafana-InfluxDB for monitoring, and Nginx as a reverse proxy.

# Hệ thống Docker Swarm với ELK Stack, Prometheus-Grafana-InfluxDB và Nginx Reverse Proxy

Repository này chứa cấu hình Docker Swarm stack để triển khai một giải pháp giám sát và logging toàn diện cùng với ứng dụng mẫu (DockerCoins). Stack bao gồm ELK Stack (Elasticsearch, Logstash, Kibana), Prometheus-Grafana-InfluxDB để giám sát, và Nginx làm reverse proxy.

## System Architecture | Kiến trúc hệ thống

The system runs on a Docker Swarm cluster with the following components:

Hệ thống chạy trên cụm Docker Swarm với các thành phần sau:

- **DockerCoins Application**: A sample application with multiple microservices (rng, hasher, worker, webui, redis)
  **Ứng dụng DockerCoins**: Ứng dụng mẫu với nhiều microservice (rng, hasher, worker, webui, redis)

- **ELK Stack**: For centralized logging and log analysis
  **ELK Stack**: Dùng để tập trung và phân tích logs

- **Prometheus-Grafana-InfluxDB**: For metrics collection, storage, and visualization
  **Prometheus-Grafana-InfluxDB**: Dùng để thu thập, lưu trữ và hiển thị metrics

- **Nginx Reverse Proxy**: For unified access to all services
  **Nginx Reverse Proxy**: Cung cấp điểm truy cập thống nhất đến tất cả các dịch vụ

All services are connected through a custom overlay network named `hoangkhang-net`.
Tất cả các dịch vụ được kết nối thông qua mạng overlay tùy chỉnh có tên `hoangkhang-net`.

## Services Overview | Tổng quan các dịch vụ

### DockerCoins Application | Ứng dụng DockerCoins

| Service | Description | Replicas | Mô tả (Tiếng Việt) |
|---------|-------------|----------|---------------------|
| rng | Random number generator service | 3 | Dịch vụ tạo số ngẫu nhiên |
| hasher | Hashing service | 3 | Dịch vụ băm |
| worker | Worker service that connects rng and hasher | 5 | Dịch vụ worker kết nối rng và hasher |
| webui | Web UI for visualizing mining speed | 2 | Giao diện web hiển thị tốc độ đào coin |
| redis | Redis database for storing data | 2 | Cơ sở dữ liệu Redis để lưu trữ dữ liệu |

### ELK Stack | Stack ELK

| Service | Description | Replicas | Mô tả (Tiếng Việt) |
|---------|-------------|----------|---------------------|
| elasticsearch | Stores and indexes logs | 1 | Lưu trữ và đánh chỉ mục logs |
| logstash | Collects and processes logs from all services | 2 | Thu thập và xử lý logs từ tất cả các dịch vụ |
| kibana | Web UI for visualizing and analyzing logs | 1 | Giao diện web để hiển thị và phân tích logs |

### Monitoring Stack | Stack giám sát

| Service | Description | Replicas | Mô tả (Tiếng Việt) |
|---------|-------------|----------|---------------------|
| prometheus | Collects and stores metrics | 1 | Thu thập và lưu trữ metrics |
| grafana | Visualizes metrics with dashboards | 1 | Hiển thị metrics với các bảng điều khiển |
| influxdb | Time-series database for long-term metric storage | 1 | Cơ sở dữ liệu chuỗi thời gian để lưu trữ metrics dài hạn |
| node-exporter | Collects system metrics from each node | global | Thu thập metrics hệ thống từ mỗi node |
| cadvisor | Collects container metrics | global | Thu thập metrics từ các container |

### Reverse Proxy | Reverse Proxy

| Service | Description | Replicas | Mô tả (Tiếng Việt) |
|---------|-------------|----------|---------------------|
| nginx | Reverse proxy for accessing all services | 2 | Reverse proxy để truy cập tất cả các dịch vụ |

## Deployment Instructions | Hướng dẫn triển khai

### Prerequisites | Điều kiện tiên quyết

- Docker Swarm cluster with at least one manager node
  Cụm Docker Swarm với ít nhất một node quản lý (manager node)

- Docker installed on all nodes
  Docker đã được cài đặt trên tất cả các node

- Sufficient resources (CPU, memory) for running all services
  Đủ tài nguyên (CPU, bộ nhớ) để chạy tất cả các dịch vụ

### Setup and Deployment | Cài đặt và triển khai

1. **Cấp quyền thực thi cho các script**:
   ```bash
   # Cấp quyền thực thi cho script cấp quyền
   chmod +x setup-permissions.sh

   # Chạy script để cấp quyền cho tất cả các script khác
   ./setup-permissions.sh
   ```

2. **Xử lý vấn đề tương thích ARM** (cho máy Mac M1/M2):
   ```bash
   # Nếu bạn đang sử dụng máy Mac với chip ARM (M1/M2), hãy chạy script này
   sudo ./fix-arm-compatibility.sh
   ```

3. **Dọn dẹp Docker** (nếu cần):
   ```bash
   # Dọn dẹp hoàn toàn Docker (containers, services, images, networks, volumes)
   ./clean-docker.sh
   ```

3. **Cấu hình Docker Registry**:

   a. **Trên node manager**, cấu hình Docker để tin tưởng registry không bảo mật:
   ```bash
   # Cấu hình Docker (yêu cầu quyền sudo)
   sudo ./setup-registry.sh
   ```

   b. **Khởi động registry**:
   ```bash
   # Khởi động và kiểm tra registry
   ./start-registry.sh
   ```

   c. **Trên các worker node**, cấu hình Docker để tin tưởng registry không bảo mật:
   ```bash
   # Cấu hình Docker (yêu cầu quyền sudo)
   sudo ./setup-registry.sh
   ```

   > **Lưu ý**: Nếu địa chỉ IP của node manager không phải là `192.168.19.10`, hãy chỉnh sửa các file `setup-registry.sh`, `build-push-images.sh` và `start-registry.sh` để sử dụng địa chỉ IP thực tế của bạn.

4. **Tạo mạng overlay**:
   ```bash
   # Tạo mạng overlay cho Docker Swarm
   ./setup-network.sh
   ```

5. **Build và push images**:
   ```bash
   # Build và push các images lên registry
   ./build-push-images.sh
   ```

   > Nếu gặp lỗi với webui service, đặc biệt là trên máy Mac với chip ARM (M1/M2), bạn có thể sử dụng một trong các script sau:
   > ```bash
   > # Script sửa lỗi webui cho máy ARM (khởi động lại registry, xóa cache và build với các tùy chọn đặc biệt)
   > ./fix-webui.sh
   >
   > # Hoặc chỉ rebuild và redeploy webui service
   > ./rebuild-webui.sh
   > ```

6. **Triển khai stack**:
   ```bash
   # Triển khai toàn bộ stack
   ./deploy-stack.sh
   ```

7. **Kiểm tra triển khai**:
   ```bash
   # Kiểm tra trạng thái của tất cả các dịch vụ
   docker stack services dockercoins

   # Kiểm tra logs của webui service
   docker service logs dockercoins_webui
   ```

8. **Truy cập các dịch vụ** thông qua Nginx reverse proxy:
   - Trang chính: http://<manager-ip>
   - DockerCoins WebUI: http://<manager-ip>/webui/
   - Prometheus: http://<manager-ip>/prometheus/
   - Grafana: http://<manager-ip>/grafana/
   - Kibana: http://<manager-ip>/kibana/
   - Elasticsearch: http://<manager-ip>/elasticsearch/
   - InfluxDB: http://<manager-ip>/influxdb/

   > Thay thế `<manager-ip>` bằng địa chỉ IP của node manager (ví dụ: 192.168.19.10)

## Demo Commands | Các lệnh demo

### 1. ELK Stack (Elasticsearch, Logstash, Kibana) | Stack ELK

#### Check Logstash running with 2 replicas | Kiểm tra Logstash đang chạy với 2 bản sao
```bash
docker service ls | grep logstash
```

#### Check Logstash logs | Kiểm tra logs của Logstash
```bash
docker service logs dockercoins_logstash
```

#### Check Logstash configuration | Kiểm tra cấu hình Logstash
```bash
docker exec -it $(docker ps | grep logstash | head -n1 | awk '{print $1}') cat /usr/share/logstash/pipeline/logstash.conf
```

#### Check logs from services | Kiểm tra logs từ các dịch vụ
```bash
# View logs from rng service | Xem logs từ dịch vụ rng
docker service logs dockercoins_rng

# View logs from hasher service | Xem logs từ dịch vụ hasher
docker service logs dockercoins_hasher

# View logs from worker service | Xem logs từ dịch vụ worker
docker service logs dockercoins_worker

# View logs from webui service | Xem logs từ dịch vụ webui
docker service logs dockercoins_webui
```

#### Query data in Elasticsearch | Truy vấn dữ liệu trong Elasticsearch
```bash
# List indices in Elasticsearch | Liệt kê các chỉ mục trong Elasticsearch
curl -X GET "http://<manager-ip>/elasticsearch/_cat/indices?v"

# Query data from specific index (replace INDEX_NAME) | Truy vấn dữ liệu từ chỉ mục cụ thể
curl -X GET "http://<manager-ip>/elasticsearch/dockercoins-$(date +%Y.%m.%d)/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "match_all": {}
  },
  "size": 10
}'

# Search for logs containing the keyword "error" | Tìm kiếm logs chứa từ khóa "error"
curl -X GET "http://<manager-ip>/elasticsearch/dockercoins-$(date +%Y.%m.%d)/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "match": {
      "message": "error"
    }
  },
  "size": 10
}'
```

#### Interact with Kibana via CLI | Tương tác với Kibana qua CLI
```bash
# Check Kibana status | Kiểm tra trạng thái Kibana
curl -X GET "http://<manager-ip>/kibana/api/status" -H 'kbn-xsrf: true'

# Create index pattern in Kibana (needed before searching logs) | Tạo mẫu chỉ mục trong Kibana (cần thiết trước khi tìm kiếm logs)
curl -X POST "http://<manager-ip>/kibana/api/saved_objects/index-pattern/dockercoins" -H 'kbn-xsrf: true' -H 'Content-Type: application/json' -d'
{
  "attributes": {
    "title": "dockercoins-*",
    "timeFieldName": "@timestamp"
  }
}'
```

### 2. Prometheus-Grafana-InfluxDB | Hệ thống giám sát Prometheus-Grafana-InfluxDB

#### Check Prometheus status | Kiểm tra trạng thái Prometheus
```bash
# Check targets in Prometheus | Kiểm tra các mục tiêu trong Prometheus
curl -s "http://<manager-ip>/prometheus/api/v1/targets" | jq .

# Check available metrics | Kiểm tra các metrics có sẵn
curl -s "http://<manager-ip>/prometheus/api/v1/label/__name__/values" | jq .
```

#### Query metrics from Prometheus | Truy vấn metrics từ Prometheus
```bash
# CPU usage | Sử dụng CPU
curl -s "http://<manager-ip>/prometheus/api/v1/query?query=sum(rate(node_cpu_seconds_total{mode!='idle'}[1m])) by (instance)" | jq .

# Memory usage | Sử dụng bộ nhớ
curl -s "http://<manager-ip>/prometheus/api/v1/query?query=node_memory_MemTotal_bytes - node_memory_MemFree_bytes - node_memory_Buffers_bytes - node_memory_Cached_bytes" | jq .

# Disk usage | Sử dụng ổ đĩa
curl -s "http://<manager-ip>/prometheus/api/v1/query?query=100 - ((node_filesystem_avail_bytes * 100) / node_filesystem_size_bytes)" | jq .

# Open file descriptors | Số lượng file descriptors đang mở
curl -s "http://<manager-ip>/prometheus/api/v1/query?query=process_open_fds" | jq .

# Network I/O | Thông lượng mạng vào/ra
curl -s "http://<manager-ip>/prometheus/api/v1/query?query=rate(node_network_receive_bytes_total[1m])" | jq .
curl -s "http://<manager-ip>/prometheus/api/v1/query?query=rate(node_network_transmit_bytes_total[1m])" | jq .
```

#### Query data from InfluxDB | Truy vấn dữ liệu từ InfluxDB
```bash
# Check InfluxDB status | Kiểm tra trạng thái InfluxDB
curl -s "http://<manager-ip>/influxdb/health" | jq .

# Get token to query InfluxDB | Lấy token để truy vấn InfluxDB
INFLUX_TOKEN="mytoken"  # Token configured in docker-stack.yml | Token được cấu hình trong docker-stack.yml

# List buckets | Liệt kê các buckets
curl -s -H "Authorization: Token ${INFLUX_TOKEN}" "http://<manager-ip>/influxdb/api/v2/buckets" | jq .

# Query data from InfluxDB (using Flux query) | Truy vấn dữ liệu từ InfluxDB (sử dụng truy vấn Flux)
curl -s -H "Authorization: Token ${INFLUX_TOKEN}" -H "Content-Type: application/json" "http://<manager-ip>/influxdb/api/v2/query?org=dockercoins" -d '{
  "query": "from(bucket:\"metrics\") |> range(start: -1h) |> filter(fn: (r) => r._measurement == \"cpu\") |> yield()"
}'
```

#### Create Dashboard in Grafana via CLI | Tạo Dashboard trong Grafana qua CLI
```bash
# Get API key from Grafana (need to create in UI first) | Lấy API key từ Grafana (cần tạo trong giao diện trước)
GRAFANA_API_KEY="eyJrIjoiWW91ck5ld0FwaUtleSIsIm4iOiJteS1hcGkta2V5IiwiaWQiOjF9"

# Create datasource for Prometheus | Tạo nguồn dữ liệu cho Prometheus
curl -s -H "Authorization: Bearer ${GRAFANA_API_KEY}" -H "Content-Type: application/json" -X POST "http://<manager-ip>/grafana/api/datasources" -d '{
  "name": "Prometheus",
  "type": "prometheus",
  "url": "http://prometheus:9090",
  "access": "proxy",
  "basicAuth": false
}'

# Create simple dashboard | Tạo dashboard đơn giản
curl -s -H "Authorization: Bearer ${GRAFANA_API_KEY}" -H "Content-Type: application/json" -X POST "http://<manager-ip>/grafana/api/dashboards/db" -d '{
  "dashboard": {
    "id": null,
    "title": "Docker Swarm Monitoring",
    "panels": [
      {
        "title": "CPU Usage",
        "type": "graph",
        "gridPos": {"h": 8, "w": 12, "x": 0, "y": 0},
        "targets": [
          {
            "expr": "sum(rate(node_cpu_seconds_total{mode!=\"idle\"}[1m])) by (instance)",
            "refId": "A"
          }
        ]
      },
      {
        "title": "Memory Usage",
        "type": "graph",
        "gridPos": {"h": 8, "w": 12, "x": 12, "y": 0},
        "targets": [
          {
            "expr": "node_memory_MemTotal_bytes - node_memory_MemFree_bytes - node_memory_Buffers_bytes - node_memory_Cached_bytes",
            "refId": "A"
          }
        ]
      }
    ],
    "schemaVersion": 16,
    "version": 0
  },
  "overwrite": true
}'
```

### 3. Nginx Reverse Proxy | Nginx Reverse Proxy

#### Check Nginx configuration | Kiểm tra cấu hình Nginx
```bash
docker exec -it $(docker ps | grep nginx | head -n1 | awk '{print $1}') cat /etc/nginx/nginx.conf
```

#### Check Nginx status | Kiểm tra trạng thái Nginx
```bash
docker exec -it $(docker ps | grep nginx | head -n1 | awk '{print $1}') nginx -t
```

#### Check Nginx logs | Kiểm tra logs của Nginx
```bash
docker service logs dockercoins_nginx
```

#### Check URL routing | Kiểm tra định tuyến URL
```bash
# Check main page | Kiểm tra trang chính
curl -s "http://<manager-ip>/" | head -n 20

# Check routing to webui | Kiểm tra định tuyến đến webui
curl -s "http://<manager-ip>/webui/" | head -n 20

# Check routing to Prometheus | Kiểm tra định tuyến đến Prometheus
curl -s "http://<manager-ip>/prometheus/" | head -n 20

# Check routing to Grafana | Kiểm tra định tuyến đến Grafana
curl -s "http://<manager-ip>/grafana/" | head -n 20

# Check routing to Kibana | Kiểm tra định tuyến đến Kibana
curl -s "http://<manager-ip>/kibana/" | head -n 20

# Check routing to Elasticsearch | Kiểm tra định tuyến đến Elasticsearch
curl -s "http://<manager-ip>/elasticsearch/" | head -n 20
```

### General Useful Commands | Các lệnh hữu ích chung

#### Check Docker Swarm status | Kiểm tra trạng thái Docker Swarm
```bash
docker node ls
```

#### Check services running in the swarm | Kiểm tra các dịch vụ đang chạy trong swarm
```bash
docker stack services dockercoins
```

#### Check running containers | Kiểm tra các container đang chạy
```bash
docker stack ps dockercoins
```

#### Check networks in Docker Swarm | Kiểm tra các mạng trong Docker Swarm
```bash
docker network ls
```

#### Check details about hoangkhang-net network | Kiểm tra chi tiết về mạng hoangkhang-net
```bash
docker network inspect hoangkhang-net
```

#### Check resource usage of containers | Kiểm tra sử dụng tài nguyên của các container
```bash
docker stats
```

#### Check logs of the entire stack | Kiểm tra logs của toàn bộ stack
```bash
docker service logs dockercoins_$(docker service ls --format "{{.Name}}" | grep dockercoins | head -n1)
```

## Docker Registry in Swarm Mode

### Understanding Registry Configuration

When working with Docker Swarm, the registry configuration is crucial for proper deployment of custom images. Here's why:

1. **Registry Accessibility**:
   - In a multi-node swarm, all nodes need to pull images from the registry
   - Using `127.0.0.1:5000` only works on the node where the registry is running
   - Worker nodes cannot access `127.0.0.1:5000` as it refers to their own localhost

2. **Registry Address**:
   - The registry must be accessible via the manager node's IP address (e.g., `192.168.19.10:5000`)
   - All nodes must be configured to trust this registry if it's insecure (no SSL)

3. **Image Tagging**:
   - Images must be tagged with the correct registry address
   - Example: `192.168.19.10:5000/dockercoins_rng:latest` instead of `127.0.0.1:5000/dockercoins_rng:latest`

### Registry Setup Files

1. **setup-registry.sh**:
   - Configures Docker daemon to trust the insecure registry
   - Creates/updates `/etc/docker/daemon.json`
   - Restarts Docker service to apply changes
   - Must be run on all nodes with sudo privileges

2. **build-push-images.sh**:
   - Builds custom images from source directories
   - Tags images with the manager node's IP as registry
   - Pushes images to the registry
   - Only needs to be run on the manager node

### Testing Registry Access

To verify that your registry is properly configured and accessible:

```bash
# On the manager node
# List all repositories in the registry
curl -s http://localhost:5000/v2/_catalog

# List tags for a specific repository
curl -s http://localhost:5000/v2/dockercoins_rng/tags/list
```

```bash
# On worker nodes
# List all repositories in the registry (replace with your manager IP)
curl -s http://192.168.19.10:5000/v2/_catalog

# List tags for a specific repository
curl -s http://192.168.19.10:5000/v2/dockercoins_rng/tags/list
```

### Hướng dẫn cài đặt Docker Registry trong môi trường Swarm (Tiếng Việt)

#### Vấn đề với Docker Registry trong Swarm

Khi triển khai ứng dụng trên Docker Swarm với nhiều node, việc cấu hình registry là rất quan trọng. Dưới đây là những vấn đề thường gặp:

1. **Vấn đề về địa chỉ registry**:
   - Khi sử dụng địa chỉ `127.0.0.1:5000`, mỗi node sẽ tìm registry trên localhost của chính nó
   - Các worker node không thể truy cập registry qua địa chỉ `127.0.0.1:5000` vì registry chỉ chạy trên manager node
   - Cần sử dụng địa chỉ IP thực của manager node (ví dụ: `192.168.19.10:5000`)

2. **Cấu hình insecure registry**:
   - Registry không có SSL cần được cấu hình là "insecure registry" trên tất cả các node
   - Mỗi node cần cập nhật file `/etc/docker/daemon.json`

#### Các bước cài đặt

1. **Trên node manager**:

   a. Khởi động registry container:
   ```bash
   docker run -d -p 5000:5000 --restart=always --name registry registry:2
   ```

   b. Cấu hình Docker để tin tưởng registry không bảo mật:
   ```bash
   sudo ./setup-registry.sh
   ```

   c. Build và push images lên registry:
   ```bash
   ./build-push-images.sh
   ```

2. **Trên các worker node**:

   a. Cấu hình Docker để tin tưởng registry không bảo mật:
   ```bash
   sudo ./setup-registry.sh
   ```

   b. Kiểm tra kết nối tới registry:
   ```bash
   # Thay thế 192.168.19.10 bằng địa chỉ IP của manager node
   curl -s http://192.168.19.10:5000/v2/_catalog
   ```

3. **Triển khai stack từ manager node**:
   ```bash
   ./deploy-stack.sh
   ```

4. **Kiểm tra trạng thái các service**:
   ```bash
   docker stack services dockercoins
   ```

#### Xử lý sự cố

1. **Lỗi không thể truy cập registry**:
   - Kiểm tra registry đang chạy: `docker ps | grep registry`
   - Kiểm tra kết nối mạng giữa các node: `ping 192.168.19.10`
   - Kiểm tra cấu hình Docker: `cat /etc/docker/daemon.json`

2. **Lỗi không thể pull image**:
   - Kiểm tra image đã được push lên registry: `curl -s http://192.168.19.10:5000/v2/_catalog`
   - Kiểm tra tag của image: `curl -s http://192.168.19.10:5000/v2/dockercoins_rng/tags/list`
   - Kiểm tra địa chỉ registry trong file `docker-stack.yml`

## Component Details | Chi tiết các thành phần

### 1. ELK Stack | Stack ELK

#### Elasticsearch
- **Purpose | Mục đích**: Stores and indexes logs from all services | Lưu trữ và đánh chỉ mục logs từ tất cả các dịch vụ
- **Features | Tính năng**:
  - Full-text search capabilities | Khả năng tìm kiếm toàn văn bản
  - Real-time data and analytics | Phân tích và dữ liệu thời gian thực
  - Distributed and scalable architecture | Kiến trúc phân tán và có thể mở rộng
- **Access | Truy cập**: http://<manager-ip>/elasticsearch/

#### Logstash
- **Purpose | Mục đích**: Collects and processes logs from all services | Thu thập và xử lý logs từ tất cả các dịch vụ
- **Features | Tính năng**:
  - Collects logs from multiple sources | Thu thập logs từ nhiều nguồn
  - Filters and transforms logs | Lọc và chuyển đổi logs
  - Outputs processed logs to Elasticsearch | Đẩy logs đã xử lý đến Elasticsearch
- **Configuration | Cấu hình**: See `logstash.conf` | Xem file `logstash.conf`

#### Kibana
- **Purpose | Mục đích**: Visualizes and analyzes logs stored in Elasticsearch | Hiển thị và phân tích logs được lưu trữ trong Elasticsearch
- **Features | Tính năng**:
  - Interactive dashboards | Bảng điều khiển tương tác
  - Advanced data visualization | Hiển thị dữ liệu nâng cao
  - Log search and filtering | Tìm kiếm và lọc logs
- **Access | Truy cập**: http://<manager-ip>/kibana/

### 2. Monitoring Stack | Stack giám sát

#### Prometheus
- **Purpose | Mục đích**: Collects and stores metrics | Thu thập và lưu trữ metrics
- **Features | Tính năng**:
  - Time-series database | Cơ sở dữ liệu chuỗi thời gian
  - Multi-dimensional data model | Mô hình dữ liệu đa chiều
  - Powerful query language (PromQL) | Ngôn ngữ truy vấn mạnh mẽ (PromQL)
- **Access | Truy cập**: http://<manager-ip>/prometheus/
- **Configuration | Cấu hình**: See `prometheus.yml` | Xem file `prometheus.yml`

#### Grafana
- **Purpose | Mục đích**: Visualizes metrics with dashboards | Hiển thị metrics với các bảng điều khiển
- **Features | Tính năng**:
  - Interactive and customizable dashboards | Bảng điều khiển tương tác và tùy chỉnh được
  - Support for multiple data sources | Hỗ trợ nhiều nguồn dữ liệu
  - Alerting capabilities | Khả năng cảnh báo
- **Access | Truy cập**: http://<manager-ip>/grafana/
- **Default credentials | Thông tin đăng nhập mặc định**: admin/admin

#### InfluxDB
- **Purpose | Mục đích**: Time-series database for long-term metric storage | Cơ sở dữ liệu chuỗi thời gian để lưu trữ metrics dài hạn
- **Features | Tính năng**:
  - High-performance data storage | Lưu trữ dữ liệu hiệu suất cao
  - SQL-like query language (Flux) | Ngôn ngữ truy vấn giống SQL (Flux)
  - Built-in HTTP API | API HTTP tích hợp sẵn
- **Access | Truy cập**: http://<manager-ip>/influxdb/
- **Default credentials | Thông tin đăng nhập mặc định**: admin/adminpassword

#### Node Exporter
- **Purpose | Mục đích**: Collects system metrics from each node | Thu thập metrics hệ thống từ mỗi node
- **Features | Tính năng**:
  - CPU, memory, disk, and network metrics | Metrics về CPU, bộ nhớ, ổ đĩa và mạng
  - File system metrics | Metrics hệ thống tập tin
  - Hardware metrics (when available) | Metrics phần cứng (nếu có)

#### cAdvisor
- **Purpose | Mục đích**: Collects container metrics | Thu thập metrics từ các container
- **Features | Tính năng**:
  - Container resource usage | Sử dụng tài nguyên của container
  - Performance characteristics | Đặc điểm hiệu suất
  - Historical resource usage | Sử dụng tài nguyên theo lịch sử

### 3. Reverse Proxy | Reverse Proxy

#### Nginx
- **Purpose | Mục đích**: Provides unified access to all services | Cung cấp điểm truy cập thống nhất đến tất cả các dịch vụ
- **Features | Tính năng**:
  - URL routing | Định tuyến URL
  - Load balancing | Cân bằng tải
  - SSL termination (if configured) | Kết thúc SSL (nếu được cấu hình)
- **Configuration | Cấu hình**: See `nginx.conf` | Xem file `nginx.conf`

## Troubleshooting | Xử lý sự cố

### Common Issues | Các vấn đề thường gặp

1. **Vấn đề tương thích với chip ARM (M1/M2)**:
   - **Triệu chứng**: Gặp nhiều lỗi khác nhau khi build và chạy trên máy Mac với chip ARM
   - **Nguyên nhân**: Các image Docker và package có thể không hoàn toàn tương thích với kiến trúc ARM
   - **Giải pháp**:
     - Chạy script `sudo ./fix-arm-compatibility.sh` để cấu hình Docker cho ARM
     - Sử dụng script `./fix-webui.sh` để build webui image với các tùy chọn đặc biệt cho ARM
     - Thêm flag `--platform linux/arm64` khi build các image

2. **Lỗi `Error: Cannot find module 'node:events'` trong webui service**:
   - **Triệu chứng**: Service webui không khởi động được với lỗi `Error: Cannot find module 'node:events'`
   - **Nguyên nhân**: Phiên bản Node.js cũ (v4) không hỗ trợ cú pháp `node:` prefix để import các module core
   - **Giải pháp**:
     - Đã cập nhật Dockerfile của webui để sử dụng Node.js v14-alpine
     - Nếu vẫn gặp lỗi, hãy chạy script `./fix-webui.sh` để rebuild và redeploy webui service
     - Kiểm tra logs: `docker service logs dockercoins_webui`

2. **Lỗi `http: server gave HTTP response to HTTPS client` khi push image**:
   - **Triệu chứng**: Không thể push image lên registry với lỗi `http: server gave HTTP response to HTTPS client`
   - **Nguyên nhân**: Docker đang cố gắng sử dụng HTTPS để kết nối đến registry không bảo mật
   - **Giải pháp**:
     - Chạy script `sudo ./setup-registry.sh` trên tất cả các node để cấu hình Docker tin tưởng registry không bảo mật
     - Khởi động lại Docker: `sudo systemctl restart docker`
     - Kiểm tra cấu hình: `cat /etc/docker/daemon.json`

3. **Lỗi `npm error Tracker "idealTree" already exists` khi build webui**:
   - **Triệu chứng**: Không thể build image webui với lỗi `npm error Tracker "idealTree" already exists`
   - **Nguyên nhân**: Lỗi này thường xảy ra trên máy Mac với chip ARM (M1/M2) do vấn đề tương thích
   - **Giải pháp**:
     - Đã cập nhật Dockerfile để sử dụng cách tiếp cận khác: tạo package.json trước và cài đặt dependencies
     - Sử dụng script `./fix-webui.sh` để khởi động lại registry, xóa cache và build lại image webui với các tùy chọn đặc biệt cho ARM
     - Nếu vẫn gặp lỗi, hãy thử dọn dẹp Docker với `./clean-docker.sh` và thử lại

4. **Registry Access Issues | Vấn đề truy cập Registry**:
   - **Triệu chứng**: Các dịch vụ không khởi động được với lỗi như `image 127.0.0.1:5000/dockercoins_rng:latest could not be accessed on a registry`
   - **Giải pháp**:
     - Đảm bảo registry đang chạy trên node quản lý: `docker ps | grep registry`
     - Kiểm tra tất cả các node có thể truy cập registry: `curl -s http://<manager-ip>:5000/v2/_catalog`
     - Đảm bảo Docker được cấu hình để tin tưởng registry không bảo mật trên tất cả các node
     - Kiểm tra các image được gắn thẻ và đẩy lên đúng cách: `docker images | grep <manager-ip>:5000`

5. **Services not starting | Các dịch vụ không khởi động**:
   - Kiểm tra logs: `docker service logs <service_name>`
   - Kiểm tra tài nguyên có sẵn: `docker node ls`
   - Kiểm tra xem image có tồn tại trong registry không: `curl -s http://<manager-ip>:5000/v2/dockercoins_<service>/tags/list`

6. **Network connectivity issues | Vấn đề kết nối mạng**:
   - Kiểm tra mạng: `docker network inspect hoangkhang-net`
   - Kiểm tra khả năng phát hiện dịch vụ: `docker exec -it <container_id> ping <service_name>`
   - Kiểm tra kết nối giữa các node: `ping <other-node-ip>`

7. **Elasticsearch not storing logs | Elasticsearch không lưu trữ logs**:
   - Kiểm tra cấu hình Logstash
   - Kiểm tra trạng thái Elasticsearch: `curl -X GET "http://<manager-ip>/elasticsearch/_cluster/health?pretty"`

8. **Prometheus not collecting metrics | Prometheus không thu thập metrics**:
   - Kiểm tra các mục tiêu: `curl -s "http://<manager-ip>/prometheus/api/v1/targets" | jq .`
   - Kiểm tra cấu hình thu thập trong `prometheus.yml`

## License | Giấy phép

This project is licensed under the MIT License - see the LICENSE file for details.
Dự án này được cấp phép theo Giấy phép MIT - xem file LICENSE để biết chi tiết.

## Acknowledgments | Lời cảm ơn

- Docker and Docker Swarm for container orchestration | Docker và Docker Swarm cho việc điều phối container
- Elastic for the ELK Stack | Elastic cho ELK Stack
- Prometheus, Grafana, and InfluxDB teams for monitoring tools | Các đội Prometheus, Grafana và InfluxDB cho các công cụ giám sát
- Nginx for the reverse proxy | Nginx cho reverse proxy
