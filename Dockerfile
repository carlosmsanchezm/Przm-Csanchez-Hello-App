# Multi-stage Dockerfile optimized for Podman/Buildah
# Creates non-root container with production-ready entrypoint

FROM python:3.12-slim AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --upgrade pip \
 && pip wheel --no-cache-dir --wheel-dir /wheels -r requirements.txt

FROM python:3.12-slim
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=8080
WORKDIR /app

# Create non-root user/group with stable IDs
RUN groupadd -r app -g 10001 && useradd -r -g app -u 10001 app

# Install from prebuilt wheels (offline)
COPY --from=builder /wheels /wheels
COPY requirements.txt .
RUN pip install --no-cache-dir --no-index --find-links=/wheels -r requirements.txt

# App code
COPY --chown=app:app src/ /app/src/

USER 10001
EXPOSE 8080
# Gunicorn + Uvicorn worker for production
CMD ["gunicorn", "-k", "uvicorn.workers.UvicornWorker", "src.main:app", \
     "--bind", "0.0.0.0:8080", "--workers", "2", "--threads", "4", \
     "--timeout", "60", "--access-logfile", "-"]