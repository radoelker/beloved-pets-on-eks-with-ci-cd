<!-- © 2024 | Ironhack -->

---

# Multi-Stack Voting Application

**Welcome to your DevOps practice project!** This repository hosts a multi-stack voting application composed of five services, each implemented in different languages and technology stacks. The goal is to help you gain hands-on experience with containerization, orchestration, service communication, and running a distributed set of services—both individually and as part of a unified system.

This application demonstrates modern distributed architecture patterns, giving you practical experience in connecting services, managing containers, and working with infrastructure automation.

## Table of Contents
- [Application Overview](#application-overview)
- [Prerequisites](#prerequisites)
- [Architecture](#architecture)
- [Quick Start](#quick-start)
- [Running Components Locally](#running-components-locally)
- [Docker & Docker Compose](#docker--docker-compose)
- [Troubleshooting](#troubleshooting)
- [Platform-Specific Notes](#platform-specific-notes)
- [Development Workflow](#development-workflow)
- [Next Steps](#next-steps)

---

## Application Overview

The voting application includes five interconnected services:

| Service | Technology | Port | Purpose |
|---------|-----------|------|---------|
| **Vote** | Python Flask | 5000 / 8080 | Web interface for voting |
| **Redis** | In-memory Queue | 6379 | Temporary vote storage & queue |
| **Worker** | .NET 8.0 | N/A | Consumes votes from Redis, writes to Postgres |
| **Postgres** | Relational Database | 5432 | Persistent vote storage |
| **Result** | Node.js/Express | 4000 / 8081 | Real-time results display |

### Why This Architecture?

This setup introduces you to:

- **Multiple Languages & Runtimes**: Python, Node.js, .NET in a single project
- **Microservices Patterns**: Service discovery, inter-service communication, asynchronous processing
- **Containerization**: Docker best practices for each language/framework
- **Orchestration**: Docker Compose for local development; Kubernetes-ready architecture
- **Data Persistence**: Both temporary (Redis) and permanent (Postgres) storage
- **Real-time Updates**: WebSocket communication between frontend and backend

This is **intentionally diverse** to simulate real-world complexity and help you build troubleshooting and integration skills.

---

## Prerequisites

### For Local Development (No Docker)

- **Python 3.10+** (for vote service)
- **Node.js 18+** (for result service)
- **.NET 8.0 SDK** (for worker service)
- **Redis** (latest, or install via package manager)
- **PostgreSQL** 15+ (for database)

### For Docker/Docker Compose

- **Docker** 20.10+
- **Docker Compose** 2.0+
- **4GB+ RAM** available for containers
- For **Apple Silicon (M1/M2)**: May need `docker buildx` for multi-platform builds

---

## Architecture

### Data Flow

```
User (Browser)
    ↓
    └─→ [Vote Service (Port 8080)] ─→ [Redis Queue]
                                            ↓
                                    [Worker Service]
                                            ↓
                                    [Postgres Database]
                                            ↓
    ┌─────────────────────────────────────┘
    ↓
[Result Service (Port 8081)] ←→ [Postgres] (read votes)
    ↓
User (Browser) sees real-time results
```

### Service Dependencies

```
vote ──→ redis ──→ worker ──→ postgres
                                   ↑
                                result
```

---

## Quick Start

### Using Docker Compose (Recommended for Local Development)

1. **Clone or navigate to the repository:**
   ```bash
   cd beloved-pets-voting-app
   ```

2. **Start all services:**
   ```bash
   docker compose up
   ```

   Docker Compose will:
   - Build the vote, worker, and result images
   - Pull official Redis and Postgres images
   - Create a shared network for service communication
   - Initialize the Postgres database
   - Run health checks

3. **Access the applications:**
   - **Vote Interface**: [http://localhost:8080](http://localhost:8080)
   - **Results Interface**: [http://localhost:8081](http://localhost:8081)

4. **View logs:**
   ```bash
   docker compose logs -f          # All services
   docker compose logs -f vote     # Specific service
   ```

5. **Stop all services:**
   ```bash
   docker compose down
   ```

   To remove volumes (database data):
   ```bash
   docker compose down -v
   ```

---

## Running Components Locally

### 1. Running the Vote Service (Python)

Prerequisites: Python 3.10+

```bash
cd vote
pip install -r requirements.txt
python app.py
```

Access at [http://localhost:5000](http://localhost:5000)

**Expected Output:**
```
 * Running on http://127.0.0.1:5000
 * WARNING: This is a development server...
```

### 2. Running Redis

Prerequisites: Redis installed

```bash
redis-server
```

Verify with: `redis-cli ping` (should return `PONG`)

**Accessible at:** `localhost:6379`

### 3. Running the Worker (.NET)

Prerequisites: .NET 8.0 SDK installed

```bash
cd worker
dotnet restore
dotnet run
```

The worker will attempt to connect to Redis and Postgres automatically.

**Expected Output:**
```
Worker starting...
Connecting to redis at localhost:6379
Listening for votes...
```

### 4. Running Postgres

Prerequisites: Postgres 15+ installed

```bash
# Start Postgres (system-dependent)
# On macOS with Homebrew:
brew services start postgresql

# On Linux with systemd:
sudo systemctl start postgresql
```

Default credentials: `postgres` / `postgres`

**Accessible at:** `localhost:5432`

**Verify Connection:**
```bash
psql -U postgres -h localhost
```

### 5. Running the Result Service (Node.js)

Prerequisites: Node.js 18+ installed

```bash
cd result
npm install
node server.js
```

Access at [http://localhost:4000](http://localhost:4000)

**Expected Output:**
```
Server running on port 4000
Connected to database
```

---

## Docker & Docker Compose

### Building Individual Services

Each service has its own Dockerfile. Build them manually:

```bash
# Vote (Python)
docker build -t myorg/vote:latest ./vote
docker run --name vote -p 8080:80 -e REDIS_HOST=redis -e REDIS_PORT=6379 myorg/vote

# Redis (official image, no build needed)
docker run --name redis -p 6379:6379 redis:7-alpine

# Worker (.NET)
docker build -t myorg/worker:latest ./worker
docker run --name worker -e REDIS_HOST=redis -e POSTGRES_HOST=postgres myorg/worker

# Postgres
docker run --name postgres -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=postgres -p 5432:5432 postgres:15-alpine

# Result (Node.js)
docker build -t myorg/result:latest ./result
docker run --name result -p 8081:80 -e POSTGRES_HOST=postgres myorg/result
```

### Docker Compose Configuration

The `docker-compose.yml` handles all service orchestration, networking, and environment variables. Key features:

- **Automatic networking**: Services communicate by service name
- **Health checks**: Verifies Redis and Postgres are ready before starting dependents
- **Environment variables**: Configured for service discovery
- **Volume mounts**: Database persistence and code mounting for development

**Common Docker Compose Commands:**

```bash
# Start services in foreground (see logs)
docker compose up

# Start in background
docker compose up -d

# View logs
docker compose logs
docker compose logs -f vote

# Execute command in running service
docker compose exec vote bash

# Rebuild images
docker compose build

# Remove all containers and networks
docker compose down

# Remove containers, networks, AND volumes
docker compose down -v
```

---

## Troubleshooting

### General Issues

**Q: Services can't communicate**
- Ensure all services are running: `docker compose ps`
- Check logs: `docker compose logs service_name`
- Verify networks: `docker network ls` and `docker network inspect <network_name>`

**Q: Database connection refused**
- Postgres needs time to start. Check: `docker compose logs postgres`
- Ensure Postgres is healthy: `docker compose ps` (STATUS should be "healthy")
- Try restarting: `docker compose restart postgres`

**Q: "Address already in use" error**
- A port is already bound. Check: `lsof -i :8080` (macOS/Linux)
- Change port in docker-compose.yml: `ports: ["9000:80"]`

### Service-Specific Issues

**Vote Service Not Loading**
```bash
docker compose logs vote
# Check for REDIS_HOST connection issues
# Restart: docker compose restart vote
```

**Worker Not Processing Votes**
```bash
docker compose logs worker
# Verify Redis has votes: docker compose exec redis redis-cli LLEN votes
# Check Postgres connection: docker compose logs worker | grep -i postgres
```

**Result Not Showing Votes**
```bash
docker compose logs result
# Check database has data: docker compose exec postgres psql -U postgres -d voting -c "SELECT * FROM votes;"
```

**Redis Issues**
```bash
# Check Redis is running
docker compose exec redis redis-cli ping

# View all keys
docker compose exec redis redis-cli KEYS '*'

# Clear Redis (if stuck)
docker compose exec redis redis-cli FLUSHALL
```

### Cleaning Up

```bash
# Remove all containers and volumes (fresh start)
docker compose down -v

# Rebuild everything
docker compose build --no-cache
docker compose up
```

---

## Platform-Specific Notes

### macOS (Intel)

Standard Docker Desktop installation works fine.

### macOS (Apple Silicon M1/M2)

If you encounter architecture mismatch errors with pre-built images:

```bash
# Build for amd64 (Intel) architecture
docker buildx build --platform linux/amd64 -t myorg/worker:latest ./worker

# Or use Docker's native arm64 images when available
docker buildx build --platform linux/arm64 -t myorg/worker:latest ./worker
```

### Linux

Ensure Docker daemon is running:
```bash
sudo systemctl start docker
sudo usermod -aG docker $USER  # Add current user to docker group (requires logout/login)
```

### Windows (WSL2)

- Ensure WSL2 backend is enabled in Docker Desktop settings
- Use the same commands as Linux within WSL2 terminal
- Windows PowerShell may have path/escaping issues; use WSL2 terminal instead

---

## Development Workflow

### Making Changes

1. **Vote Service (Python):**
   - Edit `vote/app.py`
   - Restart: `docker compose restart vote`

2. **Result Service (Node.js):**
   - Edit `result/server.js`
   - Restart: `docker compose restart result`

3. **Worker Service (.NET):**
   - Edit `worker/Program.cs`
   - Rebuild: `docker compose build worker && docker compose up -d worker`

### Database Inspection

```bash
# Access Postgres directly
docker compose exec postgres psql -U postgres -d voting

# List tables
\dt

# View votes
SELECT * FROM votes;

# Exit
\q
```

### Redis Inspection

```bash
docker compose exec redis redis-cli

# View all keys
KEYS *

# Get vote count
LLEN votes

# Exit
EXIT
```

---

## Next Steps

After mastering this local setup:

1. **Deploy to Kubernetes**: Adapt docker-compose.yml to Kubernetes manifests
2. **Add Monitoring**: Integrate Prometheus and Grafana
3. **Implement CI/CD**: Use GitHub Actions or GitLab CI to build and push images
4. **Scale Services**: Experiment with load balancing and multiple replicas
5. **Deploy to Cloud**: Push to AWS ECS, Google Cloud Run, or Azure Container Instances

---

## Resources

- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Flask Documentation](https://flask.palletsprojects.com/)
- [Node.js Express Guide](https://expressjs.com/)
- [.NET 8.0 Docs](https://learn.microsoft.com/en-us/dotnet/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Redis Documentation](https://redis.io/documentation)

---

**Happy voting! 🗳️🐱🐶**
