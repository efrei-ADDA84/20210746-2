FROM python:3.11-alpine3.17

WORKDIR /app

COPY . /app

RUN pip install -r requirements.txt

CMD ["python","weither-api-call.py"]