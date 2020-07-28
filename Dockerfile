FROM golang:1.13-alpine as builder
RUN apk add --no-cache git gcc musl-dev
COPY builder.sh /usr/bin/builder.sh
ARG version="1.0.5"
RUN VERSION=${version} /bin/sh /usr/bin/builder.sh


FROM alpine:latest

ENV CADDY_VERSION=1.0.5

ENV CADDYPATH=/caddy/certs

RUN apk add --no-cache \
    ca-certificates \
    git \
    mailcap \
    openssh-client \
    tzdata


COPY --from=builder /install/caddy /usr/bin/caddy

RUN /usr/bin/caddy -version
RUN /usr/bin/caddy -plugins

EXPOSE 80 443 2015
VOLUME /root/.caddy /srv
WORKDIR /srv

COPY Caddyfile /etc/Caddyfile
COPY index.html /srv/index.html

# install process wrapper
COPY --from=builder /go/bin/parent /bin/parent

ENTRYPOINT ["/bin/parent", "caddy"]

CMD ["caddy","--conf", "/caddy/Caddyfile", "--log", "stdout", "--agree"]