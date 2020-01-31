FROM python:3.6-alpine3.10 as base

# Copy the requirements & code and install them
# Do this in a separate image in a separate directory
# to not have all the build stuff in the final image
FROM base AS builder
RUN apk update
# Needed to build cffi
RUN apk add python-dev build-base libffi-dev
COPY . /code
WORKDIR /code

RUN mkdir /install
RUN pip install --no-warn-script-location \
                --prefix=/install \
                /code --requirement /code/docker-requirements.txt

FROM base
COPY --from=builder /install /usr/local
RUN cd / && mkdir -p /data/packages

RUN echo bricks-dev:{SHA}bdInDHy/CH0Ag8zZegzcNJzjwsY= > htpasswd.txt
RUN mv htpasswd.txt /data/htpasswd.txt

ENV PYTHONUNBUFFERED=0

VOLUME /data/packages
WORKDIR /data
EXPOSE 8080/tcp
ENTRYPOINT ["pypi-server","-v", "-p","8080","-P","/data/htpasswd.txt","-a","list,update,download","-r", "packages"]
