FROM gcr.io/google.com/cloudsdktool/cloud-sdk:alpine

ENV APP_HOME /app
WORKDIR $APP_HOME
COPY . ./

RUN pip3 install Flask gunicorn

CMD exec gunicorn --bind :$PORT --workers 1 --threads 8 app:app
