# co_scientist_service — FastAPI
FROM python:3.11-slim

# faiss-cpu and spacy need build tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

ENV PYTHONPATH=/app

EXPOSE 8003
# Run as a module so relative imports inside src/ resolve correctly
CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8003"]
