# ---- Stage 1: Build ----
FROM golang:1.24-alpine AS builder

# Set secure environment variables
ENV CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=amd64

WORKDIR /app

# Install build dependencies
RUN apk --no-cache add git

# Copy dependency files first to cache dependencies
COPY go.mod go.sum ./
RUN go mod download

# Copy application source code
COPY . .

# Build the application
RUN go build -o /app/recipes-app

# ---- Stage 2: Run ----
FROM alpine:latest

# Security: Create a non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Copy built binary from builder stage
COPY --from=builder /app/recipes-app .

# Use a non-root user
USER appuser

# Expose the application port (internal only)
EXPOSE 8080

# Health Check
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
  CMD curl --fail http://localhost:8080/health || exit 1

# Start application
CMD ["./recipes-app", "serve"]
