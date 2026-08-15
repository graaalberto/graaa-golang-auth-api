# Use the official Golang image as a base image
FROM golang:1.24-alpine AS builder

WORKDIR /app
ENV GOTOOLCHAIN=local

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN go build -o /go-fleet-api ./cmd/fleet-api

FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=builder /go-fleet-api .
EXPOSE 8081
CMD ["./go-fleet-api"]
