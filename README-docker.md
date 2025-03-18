# Docker Setup for UEProfile 5GCore

This guide explains how to run the UEProfile 5GCore application using Docker containers.

## Prerequisites

- Docker and Docker Compose installed on your system
- Git (to clone the repository if you haven't already)

## Getting Started

### 1. Clone the Repository (if you haven't already)

```bash
git clone https://github.com/lvdund/ueprofiles.git
cd ueprofiles-5GCore
```

### 2. Running the Application with Docker Compose

To start all services (MongoDB, Backend, and Frontend), run:

```bash
docker compose up -d
```

This command starts all three services in detached mode:
- MongoDB database (available at localhost:27017)
- Backend service (available at localhost:8080)
- Frontend application (available at localhost:3000)

### 3. Checking the Status

To check if all containers are running:

```bash
docker compose ps
```

To view logs from all containers:

```bash
docker-compose logs
```

To view logs from a specific service:

```bash
docker-compose logs backend
docker-compose logs frontend
docker-compose logs mongodb
```

### 4. Accessing the Application

- Frontend: Open your browser and visit `http://localhost:3000`
- Backend API: `http://localhost:8080`
- MongoDB: Connect using MongoDB Compass at `localhost:27017`

### 5. Stopping the Application

To stop all containers:

```bash
docker-compose down
```

To stop all containers and remove volumes (this will delete database data):

```bash
docker-compose down -v
```

## Configuration

### Environment Variables

You can modify the environment variables in the `docker-compose.yml` file to customize your setup:

- MongoDB connection string
- Backend API URL for the frontend

