# ---- Stage 1: Build stage ----
# Use official Python 3.9 Alpine image as a lightweight base for building
FROM python:3.9-alpine AS builder

# Set working directory inside the container
WORKDIR /app

# Copy dependency file to container
COPY requirements.txt .

# Install system dependencies required for building Python packages and PyInstaller
RUN apk add --no-cache gcc musl-dev libffi-dev openssl-dev \
    && pip install --no-cache-dir -r requirements.txt pyinstaller

# Copy the entire project into the build container
COPY . .

# Use PyInstaller to bundle the Python application into a single executable
RUN pyinstaller --add-data "templates:templates" --onefile --noconfirm --noconsole app.py

# ---- Stage 2: Runtime stage ----
# Use a clean and minimal Alpine base image for the final container
FROM alpine:3.21.3

# Install only runtime dependencies needed for the app to run
RUN apk add --no-cache libffi openssl

# Set working directory for the application
WORKDIR /app

# Copy the compiled standalone binary from the builder stage
COPY --from=builder /app/dist/app .

# Expose the port the app runs on
EXPOSE 5000

# Run the compiled binary directly (since it's built with PyInstaller)
CMD ["./app"]
