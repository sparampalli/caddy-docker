FROM abiosoft/caddy:builder as builder
RUN apk add --no-cache git gcc musl-dev
COPY builder.sh /usr/bin/builder.sh
ARG version="1.0.5"

# process wrapper
RUN go get -v github.com/abiosoft/parent && \
    VERSION=${version} /bin/sh /usr/bin/builder.sh

FROM alpine:latest

ENV CADDY_VERSION=1.0.5 \
    ACME_AGREE="false" \
    CADDYPATH=/caddy/certs \
    GCE_PROJECT="saastest-202018" \
    GOOGLE_APPLICATION_CREDENTIALS="/var/run/credentials/service-account-test-credentials.json"


RUN apk add --no-cache \
    ca-certificates \
    git \
    mailcap \
    openssh-client \
    tzdata


COPY --from=builder /install/caddy /usr/bin/caddy

RUN /usr/bin/caddy -version && \
    /usr/bin/caddy -plugins

EXPOSE 80 443 2015
VOLUME /root/.caddy /srv
WORKDIR /srv

COPY Caddyfile /etc/Caddyfile
COPY index.html /srv/index.html

COPY --from=builder /go/bin/parent /bin/parent

ENTRYPOINT ["/bin/parent", "caddy"]

CMD [ "--conf", "/etc/Caddyfile", "--log", "stdout", "--agree=$ACME_AGREE"]