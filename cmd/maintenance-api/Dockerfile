FROM golang:1.24-alpine AS builder

WORKDIR /app
ENV GOTOOLCHAIN=local

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN go build -o /go-maintenance-api ./cmd/maintenance-api

FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=builder /go-maintenance-api .
EXPOSE 8083
CMD ["./go-maintenance-api"]
