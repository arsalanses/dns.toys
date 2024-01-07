FROM --platform=${BUILDPLATFORM:-linux/amd64} alpine:3.19.0 as certs

RUN apk --update add ca-certificates

FROM --platform=${BUILDPLATFORM:-linux/amd64} golang:1.17 as builder

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG TARGETOS
ARG TARGETARCH
ARG APP_VERSION

WORKDIR /app/
ADD . .

RUN GO111MODULE=on CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -ldflags="-s -w -X 'main.version=${APP_VERSION}'" -o dnstoys main.go

FROM --platform=${TARGETPLATFORM:-linux/amd64} scratch

ARG DATE_CREATED
ARG APP_VERSION
ENV APP_VERSION=$APP_VERSION

LABEL org.opencontainers.image.created=$DATE_CREATED
LABEL org.opencontainers.version="$APP_VERSION"
LABEL org.opencontainers.image.authors="Kailash Nadh <kailash@nadh.in>"
LABEL org.opencontainers.image.vendor="GitHub"
LABEL org.opencontainers.image.title="dns.toys"
LABEL org.opencontainers.image.description="A DNS server that offers useful utilities and services over the DNS protocol."
LABEL org.opencontainers.image.source="https://github.com/knadh/dns.toys"
LABEL org.opencontainers.image.url="https://github.com/knadh/dns.toys"
LABEL org.opencontainers.image.documentation="https://github.com/knadh/dns.toys"

WORKDIR /app/

COPY --from=builder /app/dnstoys /app/dnstoys
COPY --from=certs /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt

ENTRYPOINT ["/app/dnstoys"]
