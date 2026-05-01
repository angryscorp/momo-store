# syntax=docker/dockerfile:1.7

ARG VERSION=dev
ARG COMMIT=unknown
ARG BUILD_DATE=unknown
# Frontend talks to the API via the same origin under /api (handled by k8s ingress).
# docker-compose overrides this with http://localhost:8081 for local-only setups.
ARG VUE_APP_API_URL=/api

FROM node:20-alpine AS builder

WORKDIR /app

COPY package.json package-lock.json ./
RUN --mount=type=cache,target=/root/.npm \
    npm ci

COPY . .

ARG VUE_APP_API_URL
ENV VUE_APP_API_URL=${VUE_APP_API_URL}
ENV NODE_ENV=production

RUN npm run build

FROM nginxinc/nginx-unprivileged:1.27-alpine

ARG VERSION
ARG COMMIT
ARG BUILD_DATE

LABEL org.opencontainers.image.title="momo-store-frontend" \
      org.opencontainers.image.source="https://github.com/angryscorp/momo-store" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.revision="${COMMIT}" \
      org.opencontainers.image.created="${BUILD_DATE}"

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=builder /app/dist /usr/share/nginx/html/momo-store

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget -qO- http://127.0.0.1:8080/healthz >/dev/null || exit 1
