FROM alpine:latest
RUN apk update && \
    apk add --no-cache git openssh-client python py-pip bash && \
    rm -rf /var/lib/apt/lists/* && \
    rm /var/cache/apk/* && \
    pip install awscli -no-cache-dir

ENTRYPOINT [ "sh" ]
