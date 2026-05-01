# Multi-stage build
# Stage 1: Build
FROM golang:1.21-alpine AS builder

WORKDIR /app

# Copy Go module files
COPY go.mod .
COPY go.sum .

# Download dependencies
RUN go mod download

# Copy source code
COPY main.go .

# Build the application
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o sample-app main.go

# Stage 2: Runtime
FROM alpine:3.19

WORKDIR /app

# Copy the binary from builder stage
COPY --from=builder /app/sample-app .

# Expose port 8080
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/ || exit 1

# Run as non-root user
USER nobody

# Run the application
ENTRYPOINT ["./sample-app"]
