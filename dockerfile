FROM python:3.9-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    HF_HOME=/var/data/hf \
    TRANSFORMERS_CACHE=/var/data/hf \
    PORT=8000

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential gcc tesseract-ocr libgl1 libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY requirements.txt .
RUN pip install -U pip setuptools wheel && \
    pip install --prefer-binary \
      --extra-index-url https://download.pytorch.org/whl/cpu \
      -r requirements.txt

COPY . .
EXPOSE 8000
CMD ["sh","-c","uvicorn backend:app --host 0.0.0.0 --port ${PORT}"]
