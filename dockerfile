FROM python:3.11-alpine3.17

WORKDIR /app

COPY . /app

RUN pip install --no-cache-dir -r requirements.txt
RUN apk add libcrypto3=3.1.0-r4 libssl3=3.1.0-r4 --repository=https://dl-cdn.alpinelinux.org/alpine/edge/main --no-cache && rm /var/cache/apk/*

CMD ["python","weither-api-call.py"]