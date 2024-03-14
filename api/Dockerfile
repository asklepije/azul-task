FROM python:3.9-slim

WORKDIR /app

RUN pip install --no-cache-dir requests boto3

COPY . .

CMD ["python", "api.py"]
