FROM python:3.12-slim

LABEL maintainer="SmarterOS Team <soporte@smarterbot.cl>"
LABEL description="MCP Server - Model Context Protocol Server for SmarterOS"
LABEL version="1.0.0"

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements
COPY requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt && \
    rm /tmp/requirements.txt

# Copy application
COPY app/ /app/
COPY agents/ /agents/
COPY config/ /config/

# Create logs directory
RUN mkdir -p /logs

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1

# Run server
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080", "--log-config", "/config/logging.yaml"]
