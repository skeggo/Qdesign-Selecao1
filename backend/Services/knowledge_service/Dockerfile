# ── Stage 1: build ───────────────────────────────────────────────────────────
# Full image with compilers to build native extensions (psycopg2, numpy, etc.)
FROM python:3.11 AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# ── Stage 2: runner ───────────────────────────────────────────────────────────
# Slim image — no compilers, only the installed packages copied over
FROM python:3.11-slim AS runner

WORKDIR /app

# Copy installed packages from builder
COPY --from=builder /install /usr/local

# Copy service source
COPY . /app/knowledge_service/

ENV PYTHONPATH=/app

EXPOSE 8001
CMD ["uvicorn", "knowledge_service.app:app", "--host", "0.0.0.0", "--port", "8001"]
