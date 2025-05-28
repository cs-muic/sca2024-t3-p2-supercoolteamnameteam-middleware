# ── build stage ────────────────────────────────────────────────────────────────
FROM golang:1.24-alpine AS builder
WORKDIR /app

# Cache modules
COPY go.mod go.sum ./
RUN go mod download

# Build the binary
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o upload ./cmd/main.go

# ── runtime stage ──────────────────────────────────────────────────────────────
FROM alpine:3.18
RUN apk add --no-cache ca-certificates tzdata

WORKDIR /app
# Copy the compiled binary
COPY --from=builder /app/auth .

# Expose the service port
EXPOSE 8080

# Launch
ENTRYPOINT ["./auth"]
