# ------------------------
# Stage 1: Build stage
# ------------------------
FROM python:3.11-alpine as builder

WORKDIR /app

# Install build dependencies and libffi for paramiko
RUN apk add --no-cache \
    build-base \
    libffi-dev \
    openssl-dev \
    cargo

# Pre-copy requirements to use Docker layer caching
COPY requirements.txt .

# Pre-build wheels for smaller final image
RUN pip install --upgrade pip && \
    pip wheel --no-cache-dir --wheel-dir /wheels -r requirements.txt

# ------------------------
# Stage 2: Minimal runtime stage
# ------------------------
FROM python:3.11-alpine

WORKDIR /app

# Install runtime dependencies only
RUN apk add --no-cache \
    libffi \
    openssl

# Copy wheels and install packages
COPY --from=builder /wheels /wheels
RUN pip install --no-cache-dir --no-index --find-links=/wheels /wheels/* && \
    rm -rf /wheels

# Copy only app files
COPY . .

# Create non-root user
RUN adduser -D appuser
USER appuser

EXPOSE 5000

CMD ["python", "app.py"]

