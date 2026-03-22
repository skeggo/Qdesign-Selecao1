# knowledge_service — FastAPI
FROM python:3.11-slim

# Build tools needed for psycopg2, numpy, biopython, etc.
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install deps first (layer cache)
COPY requirements.txt /app/knowledge_service/requirements.txt
RUN pip install --no-cache-dir -r /app/knowledge_service/requirements.txt

# Copy service source as a Python package so
# "from knowledge_service.api import router" resolves correctly
COPY . /app/knowledge_service/

# /app is on PYTHONPATH so "knowledge_service" is importable
ENV PYTHONPATH=/app

EXPOSE 8001
CMD ["uvicorn", "knowledge_service.app:app", "--host", "0.0.0.0", "--port", "8001"]
