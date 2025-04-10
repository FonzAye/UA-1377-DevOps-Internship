# Use the official lightweight Python image
FROM python:3.11-slim

# Set working directory inside the container
WORKDIR /app

# Copy all project files to the container
COPY . .

# Install dependencies (adjust if you use requirements.txt)
RUN pip install --no-cache-dir -r requirements.txt

# Expose the port your app runs on (default for Flask is 5000)
EXPOSE 5000

# Start the app
CMD ["python", "app.py"]

