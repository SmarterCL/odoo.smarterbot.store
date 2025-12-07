# Bolt Lab - SmarterOS Documentation Generator Container
# Purpose: Isolated Python environment for running birth_of_bolt.py
# Version: 1.0.0
# Base: Python 3.12 slim

FROM python:3.12.2-slim

LABEL maintainer="SmarterOS Team <soporte@smarterbot.cl>"
LABEL description="Bolt Lab - AI-powered documentation generator for SmarterOS"
LABEL version="1.0.0"

# Set working directory
WORKDIR /workspace

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    vim \
    less \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY docker/requirements-bolt.txt /tmp/requirements-bolt.txt
RUN pip install --no-cache-dir -r /tmp/requirements-bolt.txt && \
    rm /tmp/requirements-bolt.txt

# Create directory structure
RUN mkdir -p /root/smarteros/specs \
    /root/smarteros/docs \
    /root/smarteros/scripts

# Copy specs and scripts (will be overridden by volume mount in production)
COPY specs/ /root/smarteros/specs/
COPY scripts/birth_of_bolt.py /root/smarteros/scripts/

# Make script executable
RUN chmod +x /root/smarteros/scripts/birth_of_bolt.py

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV OPENAI_MODEL=gpt-4-turbo-preview

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD python --version || exit 1

# Default command (interactive shell for manual execution)
CMD ["/bin/bash"]
