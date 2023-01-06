FROM python:2.7-alpine

RUN apk update && apk upgrade && \
    apk add \
        gcc python python-dev py-pip \
        # greenlet
        musl-dev \
        # sys/queue.h
        bsd-compat-headers \
        # event.h
        libevent-dev \
    && rm -rf /var/cache/apk/*

# want all dependencies first so that if it's just a code change, don't have to
# rebuild as much of the container
ADD requirements.txt /opt/requestbin/
RUN python -m pip install --upgrade pip \
    && pip install -r /opt/requestbin/requirements.txt -i https://mirrors.aliyun.com/pypi/simple \
    && rm -rf ~/.pip/cache

# the code
ADD requestbin  /opt/requestbin/requestbin/

EXPOSE 8080

WORKDIR /opt/requestbin
CMD gunicorn -b 0.0.0.0:8080 --worker-class gevent --workers 2 --max-requests 1000 requestbin:app


