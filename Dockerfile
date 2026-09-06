# ============================================================
# Stage 1 - Build
# ============================================================
FROM node:22.12-alpine AS builder

WORKDIR /app

ENV COREPACK_INTEGRITY_KEYS=0

RUN corepack enable && corepack prepare pnpm@10.7.0 --activate

COPY pnpm-lock.yaml package.json ./

RUN pnpm install --frozen-lockfile

COPY . .

RUN pnpm run build


# ============================================================
# Stage 2 - Production
# ============================================================
FROM nginxinc/nginx-unprivileged:alpine AS production

COPY --chown=nginx:nginx \
    --from=builder \
    /app/build \
    /usr/share/nginx/html

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD wget -qO- http://localhost:8080 || exit 1

CMD ["nginx", "-g", "daemon off;"]
