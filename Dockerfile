# syntax=docker/dockerfile:1

# ---- Stage 1: Build ----
FROM golang:1.24-alpine AS builder

# Ensure the binary is statically linked and built for linux/amd64
ENV CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=amd64

WORKDIR /app

# hadolint ignore=DL3018
RUN apk --no-cache add git file

# Copy go module files from src/
COPY src/go.mod src/go.sum ./
RUN go mod download

# Copy full source code from src/
COPY src/. .

# Build the application
RUN env GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o /app/recipes-app ./cmd && chmod +x /app/recipes-app && file /app/recipes-app

# ---- Stage 2: Run ----
FROM alpine:3.18

# Security: create a non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Copy the compiled binary
COPY --from=builder /app/recipes-app .

# Set permissions
RUN chmod +x /app/recipes-app

# Switch to non-root user
USER appuser

# Expose application port
EXPOSE 8080

# Health check 
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:8080/health || exit 1

# Start the app
CMD ["./recipes-app", "serve"]
