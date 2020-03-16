FROM gcr.io/google.com/cloudsdktool/cloud-sdk:alpine

COPY . /app
WORKDIR /app

CMD sh
