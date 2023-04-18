FROM python:3.11.2-alpine

WORKDIR /app

COPY ./app.py .
COPY ./requirements.txt .
COPY ./startup.sh .

RUN apk update && apk add curl
RUN pip install -r requirements.txt

EXPOSE 5002

CMD ["sh", "startup.sh"]
