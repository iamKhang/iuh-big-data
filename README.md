# Docker Swarm Stack with ELK, Prometheus-Grafana-InfluxDB, and Nginx Reverse Proxy

This repository contains a Docker Swarm stack configuration for running a comprehensive monitoring and logging solution alongside a sample application (DockerCoins). The stack includes ELK Stack (Elasticsearch, Logstash, Kibana), Prometheus-Grafana-InfluxDB for monitoring, and Nginx as a reverse proxy.

## System Architecture

The system runs on a Docker Swarm cluster with the following components:

- **DockerCoins Application**: A sample application with multiple microservices (rng, hasher, worker, webui, redis)
- **ELK Stack**: For centralized logging and log analysis
- **Prometheus-Grafana-InfluxDB**: For metrics collection, storage, and visualization
- **Nginx Reverse Proxy**: For unified access to all services

All services are connected through a custom overlay network named `hoangkhang-net`.

## Services Overview

### DockerCoins Application

| Service | Description | Replicas |
|---------|-------------|----------|
| rng | Random number generator service | 3 |
| hasher | Hashing service | 3 |
| worker | Worker service that connects rng and hasher | 5 |
| webui | Web UI for visualizing mining speed | 2 |
| redis | Redis database for storing data | 2 |

### ELK Stack

| Service | Description | Replicas |
|---------|-------------|----------|
| elasticsearch | Stores and indexes logs | 1 |
| logstash | Collects and processes logs from all services | 2 |
| kibana | Web UI for visualizing and analyzing logs | 1 |

### Monitoring Stack

| Service | Description | Replicas |
|---------|-------------|----------|
| prometheus | Collects and stores metrics | 1 |
| grafana | Visualizes metrics with dashboards | 1 |
| influxdb | Time-series database for long-term metric storage | 1 |
| node-exporter | Collects system metrics from each node | global |
| cadvisor | Collects container metrics | global |

### Reverse Proxy

| Service | Description | Replicas |
|---------|-------------|----------|
| nginx | Reverse proxy for accessing all services | 2 |

## Deployment Instructions

### Prerequisites

- Docker Swarm cluster with at least one manager node
- Docker installed on all nodes
- Sufficient resources (CPU, memory) for running all services

### Setup and Deployment

1. Clone this repository:
   ```bash
   git clone <repository-url>
   cd <repository-directory>
   ```

2. Make the deployment scripts executable:
   ```bash
   chmod +x setup-network.sh deploy-stack.sh
   ```

3. Deploy the stack:
   ```bash
   ./deploy-stack.sh
   ```

4. Access the services through the Nginx reverse proxy:
   - Main dashboard: http://localhost
   - DockerCoins WebUI: http://localhost/webui/
   - Prometheus: http://localhost/prometheus/
   - Grafana: http://localhost/grafana/
   - Kibana: http://localhost/kibana/
   - Elasticsearch: http://localhost/elasticsearch/
   - InfluxDB: http://localhost/influxdb/

## Demo Commands

### 1. ELK Stack (Elasticsearch, Logstash, Kibana)

#### Check Logstash running with 2 replicas
```bash
docker service ls | grep logstash
```

#### Check Logstash logs
```bash
docker service logs dockercoins_logstash
```

#### Check Logstash configuration
```bash
docker exec -it $(docker ps | grep logstash | head -n1 | awk '{print $1}') cat /usr/share/logstash/pipeline/logstash.conf
```

#### Check logs from services
```bash
# View logs from rng service
docker service logs dockercoins_rng

# View logs from hasher service
docker service logs dockercoins_hasher

# View logs from worker service
docker service logs dockercoins_worker

# View logs from webui service
docker service logs dockercoins_webui
```

#### Query data in Elasticsearch
```bash
# List indices in Elasticsearch
curl -X GET "http://localhost/elasticsearch/_cat/indices?v"

# Query data from specific index (replace INDEX_NAME)
curl -X GET "http://localhost/elasticsearch/dockercoins-$(date +%Y.%m.%d)/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "match_all": {}
  },
  "size": 10
}'

# Search for logs containing the keyword "error"
curl -X GET "http://localhost/elasticsearch/dockercoins-$(date +%Y.%m.%d)/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "match": {
      "message": "error"
    }
  },
  "size": 10
}'
```

#### Interact with Kibana via CLI
```bash
# Check Kibana status
curl -X GET "http://localhost/kibana/api/status" -H 'kbn-xsrf: true'

# Create index pattern in Kibana (needed before searching logs)
curl -X POST "http://localhost/kibana/api/saved_objects/index-pattern/dockercoins" -H 'kbn-xsrf: true' -H 'Content-Type: application/json' -d'
{
  "attributes": {
    "title": "dockercoins-*",
    "timeFieldName": "@timestamp"
  }
}'
```

### 2. Prometheus-Grafana-InfluxDB

#### Check Prometheus status
```bash
# Check targets in Prometheus
curl -s "http://localhost/prometheus/api/v1/targets" | jq .

# Check available metrics
curl -s "http://localhost/prometheus/api/v1/label/__name__/values" | jq .
```

#### Query metrics from Prometheus
```bash
# CPU usage
curl -s "http://localhost/prometheus/api/v1/query?query=sum(rate(node_cpu_seconds_total{mode!='idle'}[1m])) by (instance)" | jq .

# Memory usage
curl -s "http://localhost/prometheus/api/v1/query?query=node_memory_MemTotal_bytes - node_memory_MemFree_bytes - node_memory_Buffers_bytes - node_memory_Cached_bytes" | jq .

# Disk usage
curl -s "http://localhost/prometheus/api/v1/query?query=100 - ((node_filesystem_avail_bytes * 100) / node_filesystem_size_bytes)" | jq .

# Open file descriptors
curl -s "http://localhost/prometheus/api/v1/query?query=process_open_fds" | jq .

# Network I/O
curl -s "http://localhost/prometheus/api/v1/query?query=rate(node_network_receive_bytes_total[1m])" | jq .
curl -s "http://localhost/prometheus/api/v1/query?query=rate(node_network_transmit_bytes_total[1m])" | jq .
```

#### Query data from InfluxDB
```bash
# Check InfluxDB status
curl -s "http://localhost/influxdb/health" | jq .

# Get token to query InfluxDB
INFLUX_TOKEN="mytoken"  # Token configured in docker-stack.yml

# List buckets
curl -s -H "Authorization: Token ${INFLUX_TOKEN}" "http://localhost/influxdb/api/v2/buckets" | jq .

# Query data from InfluxDB (using Flux query)
curl -s -H "Authorization: Token ${INFLUX_TOKEN}" -H "Content-Type: application/json" "http://localhost/influxdb/api/v2/query?org=dockercoins" -d '{
  "query": "from(bucket:\"metrics\") |> range(start: -1h) |> filter(fn: (r) => r._measurement == \"cpu\") |> yield()"
}'
```

#### Create Dashboard in Grafana via CLI
```bash
# Get API key from Grafana (need to create in UI first)
GRAFANA_API_KEY="eyJrIjoiWW91ck5ld0FwaUtleSIsIm4iOiJteS1hcGkta2V5IiwiaWQiOjF9"

# Create datasource for Prometheus
curl -s -H "Authorization: Bearer ${GRAFANA_API_KEY}" -H "Content-Type: application/json" -X POST "http://localhost/grafana/api/datasources" -d '{
  "name": "Prometheus",
  "type": "prometheus",
  "url": "http://prometheus:9090",
  "access": "proxy",
  "basicAuth": false
}'

# Create simple dashboard
curl -s -H "Authorization: Bearer ${GRAFANA_API_KEY}" -H "Content-Type: application/json" -X POST "http://localhost/grafana/api/dashboards/db" -d '{
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

### 3. Nginx Reverse Proxy

#### Check Nginx configuration
```bash
docker exec -it $(docker ps | grep nginx | head -n1 | awk '{print $1}') cat /etc/nginx/nginx.conf
```

#### Check Nginx status
```bash
docker exec -it $(docker ps | grep nginx | head -n1 | awk '{print $1}') nginx -t
```

#### Check Nginx logs
```bash
docker service logs dockercoins_nginx
```

#### Check URL routing
```bash
# Check main page
curl -s "http://localhost/" | head -n 20

# Check routing to webui
curl -s "http://localhost/webui/" | head -n 20

# Check routing to Prometheus
curl -s "http://localhost/prometheus/" | head -n 20

# Check routing to Grafana
curl -s "http://localhost/grafana/" | head -n 20

# Check routing to Kibana
curl -s "http://localhost/kibana/" | head -n 20

# Check routing to Elasticsearch
curl -s "http://localhost/elasticsearch/" | head -n 20
```

### General Useful Commands

#### Check Docker Swarm status
```bash
docker node ls
```

#### Check services running in the swarm
```bash
docker stack services dockercoins
```

#### Check running containers
```bash
docker stack ps dockercoins
```

#### Check networks in Docker Swarm
```bash
docker network ls
```

#### Check details about hoangkhang-net network
```bash
docker network inspect hoangkhang-net
```

#### Check resource usage of containers
```bash
docker stats
```

#### Check logs of the entire stack
```bash
docker service logs dockercoins_$(docker service ls --format "{{.Name}}" | grep dockercoins | head -n1)
```

## Component Details

### 1. ELK Stack

#### Elasticsearch
- **Purpose**: Stores and indexes logs from all services
- **Features**:
  - Full-text search capabilities
  - Real-time data and analytics
  - Distributed and scalable architecture
- **Access**: http://localhost/elasticsearch/

#### Logstash
- **Purpose**: Collects and processes logs from all services
- **Features**:
  - Collects logs from multiple sources
  - Filters and transforms logs
  - Outputs processed logs to Elasticsearch
- **Configuration**: See `logstash.conf`

#### Kibana
- **Purpose**: Visualizes and analyzes logs stored in Elasticsearch
- **Features**:
  - Interactive dashboards
  - Advanced data visualization
  - Log search and filtering
- **Access**: http://localhost/kibana/

### 2. Monitoring Stack

#### Prometheus
- **Purpose**: Collects and stores metrics
- **Features**:
  - Time-series database
  - Multi-dimensional data model
  - Powerful query language (PromQL)
- **Access**: http://localhost/prometheus/
- **Configuration**: See `prometheus.yml`

#### Grafana
- **Purpose**: Visualizes metrics with dashboards
- **Features**:
  - Interactive and customizable dashboards
  - Support for multiple data sources
  - Alerting capabilities
- **Access**: http://localhost/grafana/
- **Default credentials**: admin/admin

#### InfluxDB
- **Purpose**: Time-series database for long-term metric storage
- **Features**:
  - High-performance data storage
  - SQL-like query language (Flux)
  - Built-in HTTP API
- **Access**: http://localhost/influxdb/
- **Default credentials**: admin/adminpassword

#### Node Exporter
- **Purpose**: Collects system metrics from each node
- **Features**:
  - CPU, memory, disk, and network metrics
  - File system metrics
  - Hardware metrics (when available)

#### cAdvisor
- **Purpose**: Collects container metrics
- **Features**:
  - Container resource usage
  - Performance characteristics
  - Historical resource usage

### 3. Reverse Proxy

#### Nginx
- **Purpose**: Provides unified access to all services
- **Features**:
  - URL routing
  - Load balancing
  - SSL termination (if configured)
- **Configuration**: See `nginx.conf`

## Troubleshooting

### Common Issues

1. **Services not starting**:
   - Check logs: `docker service logs <service_name>`
   - Verify resource availability: `docker node ls`

2. **Network connectivity issues**:
   - Check network: `docker network inspect hoangkhang-net`
   - Verify service discovery: `docker exec -it <container_id> ping <service_name>`

3. **Elasticsearch not storing logs**:
   - Check Logstash configuration
   - Verify Elasticsearch status: `curl -X GET "http://localhost/elasticsearch/_cluster/health?pretty"`

4. **Prometheus not collecting metrics**:
   - Check targets: `curl -s "http://localhost/prometheus/api/v1/targets" | jq .`
   - Verify scrape configuration in `prometheus.yml`

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Docker and Docker Swarm for container orchestration
- Elastic for the ELK Stack
- Prometheus, Grafana, and InfluxDB teams for monitoring tools
- Nginx for the reverse proxy
