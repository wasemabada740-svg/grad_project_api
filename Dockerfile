# Use the official Python slim base image for low storage footprint
FROM python:3.12-slim

# Set environment variables to optimize Python performance and configuration
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=8000

# Set the working directory
WORKDIR /app

# Install system runtime dependencies (libgomp1 is required by CPU PyTorch & FAISS)
# Keep the layer size minimal by cleaning up the apt cache in the same RUN instruction
RUN apt-get update && apt-get install -y --no-install-recommends \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*

# Copy the requirements file first to take advantage of Docker layer caching
COPY requirements.txt /app/

# Install python dependencies without caching to keep the image slim.
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code
COPY . /app/

# Pre-collect static files for Whitenoise to serve them efficiently in production
RUN python manage.py collectstatic --noinput

# Expose port 8000 (Railway will dynamically bind to this or its own PORT environment variable)
EXPOSE 8000

# Start Django with Gunicorn, automatically running migrations before booting the web server
CMD ["sh", "-c", "python manage.py migrate && gunicorn recommendation_v1.wsgi:application --bind 0.0.0.0:$PORT"]
