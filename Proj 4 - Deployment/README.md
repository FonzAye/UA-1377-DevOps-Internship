# 🗓️ Class Schedule Project

This project provides a complete containerized setup for deploying the **Class Schedule Project** using Docker Compose. It includes a frontend interface, backend logic, and databases to manage and display class schedules.

Whether you're evaluating the app or deploying it for local development, this setup helps you get everything running with a single command.

---

## 🚀 Features

- 💅 **Frontend** (JavaScript framework)  
- 🦰 **Backend** (Java + Gradle project)  
- 🐈 **PostgreSQL** for relational data storage  
- ⚡ **Redis** for caching  
- 🍃 **MongoDB** for document-based storage  
- 🔄 Database backup and restore scripts

---

## 📦 Prerequisites

Make sure you have the following installed:

- [Docker](https://www.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)

---

## 💂️ Project Structure

```
.
├── backup/                # Contains PostgreSQL dump files
│   └── 2024-08-19.dump
├── config/                # Checkstyle configuration
├── docker-compose.yml     # Docker Compose setup
├── Dockerfile-backend     # Dockerfile for backend
├── Dockerfile-frontend    # Dockerfile for frontend
├── env/                   # Contains .env file
├── frontend/              # Frontend source code
├── scripts/               # Helper scripts (see below)
├── src/                   # Backend source code
```

---

## ⚙️ Setup Instructions

1. **Clone the Repository**

   ```bash
   git clone https://github.com/FonzAye/UA-1377-DevOps-Internship.git
   cd 'Proj 4 - Deployment'
   ```

2. **Configure Environment Variables**

   Edit the file at `env/.env` to update any necessary values (e.g., database passwords, ports, etc.).

3. **Build and Start the Project**

   ```bash
   docker-compose up --build
   ```

   This command will build and start the following containers:
   - `frontend`
   - `backend`
   - `postgres`
   - `redis`
   - `mongo`
   
4. **Access the frontend on http://localhost:3000**
