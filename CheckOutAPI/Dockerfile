FROM python:3.11.2-alpine

WORKDIR /app

COPY ./app.py .
COPY ./requirements.txt .

RUN pip install -r requirements.txt

EXPOSE 5002

CMD ["gunicorn", "-b", "0.0.0.0:5002", "app:app"]
