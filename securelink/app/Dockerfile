FROM python:3.11

WORKDIR /app

COPY . .

RUN pip install cryptography

CMD ["python", "message_client.py"]