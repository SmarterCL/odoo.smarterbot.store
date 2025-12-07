FROM python:3.11-slim

WORKDIR /app

# Dependencias del sistema
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    git \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Instalar Nexa SDK y dependencias
RUN pip install --no-cache-dir \
    "nexaai>=0.1.0" \
    "fastapi>=0.104.0" \
    "uvicorn[standard]>=0.24.0" \
    "python-dotenv>=1.0.0" \
    "hvac>=1.2.0" \
    "pydantic>=2.0.0" \
    "python-multipart>=0.0.6" \
    "aiohttp>=3.9.0"

# Copiar código de la aplicación
COPY app ./app
COPY requirements.txt .

# Instalar dependencias adicionales si las hay
RUN if [ -f requirements.txt ]; then pip install --no-cache-dir -r requirements.txt; fi

ENV PYTHONUNBUFFERED=1
ENV NEXA_MODEL_STORE=/models

EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

CMD ["python", "-m", "app.main"]
