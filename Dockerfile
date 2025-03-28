# ---- Stage 1: Build ----
FROM golang:1.24-alpine AS builder

ENV CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=amd64

WORKDIR /app

# hadolint ignore=DL3018
RUN apk --no-cache add git

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN go build -o /app/recipes-app

# ---- Stage 2: Run ----
FROM alpine:3.18

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

COPY --from=builder /app/recipes-app .

USER appuser

EXPOSE 8080

# HEALTHCHECK assumes you have a /health endpoint
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
  CMD curl --fail http://localhost:8080/health || exit 1

CMD ["./recipes-app", "serve"]
