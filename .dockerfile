# ---- Base: Python 3.9 ----
    FROM python:3.9-slim

    # Keep Python output unbuffered & put HF cache on a mountable path
    ENV PYTHONDONTWRITEBYTECODE=1 \
        PYTHONUNBUFFERED=1 \
        PIP_NO_CACHE_DIR=1 \
        HF_HOME=/var/data/hf \
        TRANSFORMERS_CACHE=/var/data/hf \
        PORT=8000
    
    # System packages:
    # - build-essential,gcc: rare fallback builds
    # - tesseract-ocr: for pytesseract
    # - libgl1, libglib2.0-0: for opencv-python wheels at runtime
    RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential gcc \
        tesseract-ocr \
        libgl1 \
        libglib2.0-0 \
        && rm -rf /var/lib/apt/lists/*
    
    WORKDIR /app
    
    # Install Python deps first for better caching
    COPY requirements.txt /app/requirements.txt
    
    # Use CPU PyTorch wheels so it doesn't try to fetch CUDA
    # If you already pin torch in requirements.txt, this still works.
    RUN pip install -U pip setuptools wheel && \
        pip install --prefer-binary \
          --extra-index-url https://download.pytorch.org/whl/cpu \
          -r requirements.txt
    
    # (Optional) Don’t fail the build if spaCy model validation warns
    # RUN python -m spacy validate || true
    
    # Copy the rest of your code
    COPY . /app
    
    EXPOSE 8000
    
    # IMPORTANT: change backend:app if your module/object are different
    # Using sh -c lets us honor $PORT for Fly/Railway
    CMD ["sh","-c","uvicorn backend:app --host 0.0.0.0 --port ${PORT}"]
    
