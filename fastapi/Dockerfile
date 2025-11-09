# The image build process for a GKE-ready FastAPI application uses a multi-stage

# build for a smaller final image size.

# --- STAGE 1: Builder Stage ---

# This stage installs all Python dependencies.
# 
FROM python:3.11-slim AS builder

# Set environment variables (fixed warnings from previous steps)

ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

WORKDIR /app

# Install application dependencies.

# We include uvicorn[standard] which installs the required tools.

RUN pip install --no-cache-dir fastapi uvicorn[standard]

# --- STAGE 2: Final Image ---

# Use a minimal, smaller image for the final production container.

FROM python:3.11-slim

# Copy the application code first

WORKDIR /app
COPY main.py .

# CRITICAL FIX: Copy the Python site-packages (libraries)

COPY --from=builder /usr/local/lib/python3.11/site-packages/ /usr/local/lib/python3.11/site-packages/

# CRITICAL FIX: Copy the executables (like 'uvicorn') into the final image's PATH.

# The uvicorn executable script is needed for the CMD command to work.

COPY --from=builder /usr/local/bin/uvicorn /usr/local/bin/uvicorn

# Expose the port (The Service in GKE will use this)

EXPOSE 8080

# The command to run the application using Uvicorn.

# We bind it to 0.0.0.0 and use the standard port 80.

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080", "--log-level", "info"]
