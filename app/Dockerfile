# Dockerfile
FROM python:3.9-slim

WORKDIR /app

RUN apt-get update && apt-get install -y python3-venv

RUN python3 -m venv venv

COPY requirements.txt ./
RUN ./venv/bin/pip install -r requirements.txt

COPY . .

COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

CMD ["./start.sh"]