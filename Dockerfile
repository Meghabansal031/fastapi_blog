# 1. Use an official lightweight Python image
FROM python:3.14.6-slim

# 2. Set environment variables to optimize Python behavior inside the container
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    WORKDIR=/app

# 3. Set the working directory
WORKDIR ${WORKDIR}

# 4. Install system dependencies if required (Optional, uncomment if needed)
# RUN apt-get update && apt-get install -y --no-install-recommends gcc && rm -rf /var/lib/apt/lists/*

# 5. Copy only the dependencies file first to leverage Docker layer caching
COPY requirements.txt .

# 6. Install Python packages without storing the cache to keep the image small
RUN pip install --no-cache-dir --upgrade -r requirements.txt

# 7. Create a non-privileged system user for security purposes
RUN useradd --create-home appuser && chown -R appuser:appuser ${WORKDIR}
USER appuser

# 8. Copy the rest of your application source code
COPY . .

# 9. Expose the port FastAPI will run on
EXPOSE 8080

# 10. Start the application using Uvicorn
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]


# To Build Docker
# docker build -t fastapi-app

# To Run Docker locally
# docker run -p 8080:8080 --env-file .env fastapi-app



## If we work with uv

# # BUILD STAGE
# FROM python:3.14.4-slim-bookworm AS builder

# # Copy UV binary from official image
# COPY --from=ghcr.io/astral-sh/uv:0.11.6 /uv /uvx /bin/

# WORKDIR /app

# # UV Docker optimizations
# ENV UV_COMPILE_BYTECODE=1
# ENV UV_LINK_MODE=copy
# ENV UV_PYTHON_DOWNLOADS=0

# # Install dependencies first (cached if unchanged)
# COPY pyproject.toml uv.lock ./
# RUN uv sync --locked --no-install-project --no-dev

# # Copy app code and install project
# COPY . ./
# RUN uv sync --locked --no-dev

# # PRODUCTION STAGE
# FROM python:3.14.4-slim-bookworm

# WORKDIR /app

# # Run as non-root user for security
# RUN useradd -m appuser && chown -R appuser:appuser /app
# USER appuser

# # Copy app and dependencies from builder stage
# COPY --from=builder --chown=appuser:appuser /app /app

# ENV PATH="/app/.venv/bin:$PATH"
# ENV PYTHONUNBUFFERED=1
# ENV PORT=8080

# # exec replaces shell so fastapi receives SIGTERM for clean shutdown
# CMD ["/bin/sh", "-c", "exec fastapi run --host 0.0.0.0 --port \"$PORT\" --proxy-headers --forwarded-allow-ips '*'"]