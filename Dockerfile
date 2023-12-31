ARG tag

FROM alpine as certs
RUN apk --update add ca-certificates

FROM ubuntu:23.10 as downloads
RUN apt update && \
    apt install -y wget && \
    \
    mkdir /kaniko && \
    \
    wget -O /kaniko/jq \
    https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 && \
    chmod +x /kaniko/jq && \
    \
    wget -O /kaniko/reg \
    https://github.com/genuinetools/reg/releases/download/v0.16.1/reg-linux-386 && \
    chmod +x /kaniko/reg && \
    \
    wget -O /crane.tar.gz \ 
    https://github.com/google/go-containerregistry/releases/download/v0.8.0/go-containerregistry_Linux_x86_64.tar.gz && \
    tar -xvzf /crane.tar.gz crane -C /kaniko

FROM gcr.io/kaniko-project/executor:${tag}
SHELL ["/busybox/sh", "-c"]

COPY entrypoint.sh /

COPY --from=certs /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=downloads /kaniko /kaniko

ENTRYPOINT ["/entrypoint.sh"]
