FROM python:3.12-slim
WORKDIR /app
ENV PYTHONUNBUFFERED=1     PIP_NO_CACHE_DIR=1
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates curl && rm -rf /var/lib/apt/lists/*
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY app /app/app
COPY rules /rules
EXPOSE 8081
CMD ["python", "-m", "app.main"]
