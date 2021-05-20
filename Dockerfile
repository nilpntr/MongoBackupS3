FROM python:alpine3.9

RUN addgroup -S alpine --gid 1000 && adduser -S alpine --uid 1000 -G alpine

RUN echo 'http://dl-cdn.alpinelinux.org/alpine/v3.9/main' >> /etc/apk/repositories
RUN echo 'http://dl-cdn.alpinelinux.org/alpine/v3.9/community' >> /etc/apk/repositories
RUN apk -U upgrade

RUN wget https://github.com/s3tools/s3cmd/releases/download/v2.1.0/s3cmd-2.1.0.tar.gz && tar -xzvf s3cmd-2.1.0.tar.gz && mv s3cmd-2.1.0 /usr/local/bin/s3cmd

RUN apk add mongodb mongodb-tools bash yaml-cpp=0.6.2-r2

RUN pip install python-dateutil

COPY docker-entrypoint.sh /usr/local/bin

RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["bash", "/usr/local/bin/docker-entrypoint.sh"]