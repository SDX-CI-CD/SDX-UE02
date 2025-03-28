# syntax=docker/dockerfile:1

# ---- Stage 1: Build ----
FROM golang:1.24-alpine AS builder

ENV CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=amd64

WORKDIR /app

# hadolint ignore=DL3018
RUN apk --no-cache add git

# Copy go module files from src/
COPY src/go.mod src/go.sum ./
RUN go mod download

# Copy full source code from src/
COPY src/. .

# Build the application (entry point is in cmd/)
RUN go build -o /app/recipes-app ./cmd

# ---- Stage 2: Run ----
FROM alpine:3.18

# Security: create a non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Copy the compiled binary
COPY --from=builder /app/recipes-app .

# Switch to non-root user
USER appuser

# Expose application port
EXPOSE 8080

# Optional: Health check (assumes you have /health route)
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:8080/health || exit 1

# Start the app (remove "serve" if not used in main.go)
CMD ["./recipes-app", "serve"]
