# syntax=docker/dockerfile:1.7

ARG VERSION=dev
ARG COMMIT=unknown
ARG BUILD_DATE=unknown

FROM golang:1.26-alpine AS builder

WORKDIR /src

RUN apk add --no-cache ca-certificates git

COPY go.mod go.sum ./
RUN --mount=type=cache,target=/go/pkg/mod \
    go mod download

COPY . .

RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    CGO_ENABLED=0 GOOS=linux \
    go build -trimpath -ldflags="-s -w" -o /out/api ./cmd/api

FROM gcr.io/distroless/static-debian12:nonroot

ARG VERSION
ARG COMMIT
ARG BUILD_DATE

LABEL org.opencontainers.image.title="momo-store-backend" \
      org.opencontainers.image.source="https://github.com/angryscorp/momo-store" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.revision="${COMMIT}" \
      org.opencontainers.image.created="${BUILD_DATE}"

WORKDIR /app
COPY --from=builder /out/api /app/api

USER nonroot:nonroot
EXPOSE 8081

ENTRYPOINT ["/app/api"]
