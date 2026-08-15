# Fleet API

## Overview

`fleet-api` is a lightweight service for managing vehicles and recording telemetry data. It is designed to work alongside the `auth_api` service, sharing the same JWT secret and application authentication model.

## Service Location

- Main package: `cmd/fleet-api`
- Dockerfile: `cmd/fleet-api/Dockerfile`

## Base URL

- Local Docker dev: `http://localhost:8082`
- API path: `/api/v1`

## Authentication

`fleet-api` uses the `Authorization: Bearer <token>` header.

The token must be a valid JWT signed with the same secret used by auth_api:

- `FLEET_API_JWT_SECRET`
- falls back to `JWT_SECRET`

### Required claims

- `user_id`
- `app_id`

### Optional claim

- `tenant_id` (when omitted, the fleet API resolves the tenant from `app_id`)

### Role requirement

- `POST /api/v1/vehicles` requires the `admin` role inside the token claim `roles`
- `GET /api/v1/vehicles` does not require `admin`
- `POST /api/v1/telemetry` does not require `admin`

Example token payload:

```json
{
  "user_id": "...",
  "app_id": "...",
  "roles": ["admin"]
}
```

## Endpoints

### Health

#### `GET /healthz`

- Description: Health check for fleet-api
- Auth: none
- Response:
  - `200 OK`
  - `{ "status": "ok" }`

### Vehicles

#### `GET /api/v1/vehicles`

- Description: List vehicles for the authenticated tenant
- Auth: Bearer token
- Roles: Any authenticated token with valid `app_id`

##### Response

- `200 OK`
- JSON array of vehicles

```json
[
  {
    "id": "uuid",
    "plate": "ABC1234",
    "chassis": "CHASSIS123456789",
    "model": "Model X",
    "year": 2025,
    "status": "ACTIVE",
    "tenant_id": "uuid",
    "created_at": "2026-08-08T12:00:00Z"
  }
]
```

#### `POST /api/v1/vehicles`

- Description: Create a new vehicle for the tenant
- Auth: Bearer token
- Roles: `admin` required

##### Request body

```json
{
  "plate": "ABC1234",
  "chassis": "CHASSIS123456789",
  "model": "Model X",
  "year": 2025,
  "status": "ACTIVE"
}
```

- `status` is optional and must be one of: `ACTIVE`, `MAINTENANCE`, `INACTIVE`

##### Response

- `201 Created`
- JSON of created vehicle

### Telemetry

#### `POST /api/v1/telemetry`

- Description: Record telemetry for a vehicle
- Auth: Bearer token
- Roles: Any authenticated token with valid `app_id`

##### Request body

```json
{
  "vehicle_id": "uuid",
  "latitude": -23.55052,
  "longitude": -46.633308,
  "speed": 80.5,
  "fuel_level": 45.2,
  "odometer_km": 12034.5,
  "timestamp": "2026-08-08T12:00:00Z"
}
```

- `timestamp` is optional; if omitted, the server uses the current time.

##### Response

- `201 Created`
- JSON of created telemetry

```json
{
  "id": "uuid",
  "vehicle_id": "uuid",
  "latitude": -23.55052,
  "longitude": -46.633308,
  "speed": 80.5,
  "fuel_level": 45.2,
  "odometer_km": 12034.5,
  "timestamp": "2026-08-08T12:00:00Z"
}
```

## Environment Variables

`fleet-api` reads configuration from environment variables and `.env`.

- `FLEET_API_PORT` - port the service listens on (default `8081`)
- `DATABASE_URL` - optional full database URL
- `DB_HOST` - database host
- `DB_PORT` - database port
- `DB_USER` - database user
- `DB_PASSWORD` - database password
- `DB_NAME` - database name
- `FLEET_API_JWT_SECRET` - JWT secret for token validation
- `MAINTENANCE_ALERT_URL` - optional alert endpoint used by telemetry service
- `GIN_MODE` - Gin mode (`release` by default)

## Docker

### Local Docker Compose

The service is included in `docker-compose.yml`.

- Auth API: `http://localhost:8080`
- Fleet API: `http://localhost:8082`

### Build and run

```bash
docker compose up --build auth-api fleet-api
```

## Example Requests

### List vehicles

```bash
curl -H "Authorization: Bearer <token>" http://localhost:8082/api/v1/vehicles
```

### Create a vehicle

```bash
curl -X POST http://localhost:8082/api/v1/vehicles \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "plate": "ABC1234",
    "chassis": "CHASSIS123456789",
    "model": "Model X",
    "year": 2025,
    "status": "ACTIVE"
  }'
```

### Record telemetry

```bash
curl -X POST http://localhost:8082/api/v1/telemetry \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "vehicle_id": "uuid",
    "latitude": -23.55052,
    "longitude": -46.633308,
    "speed": 80.5,
    "fuel_level": 45.2,
    "odometer_km": 12034.5,
    "timestamp": "2026-08-08T12:00:00Z"
  }'
```

## Notes

- If you get `"error": "Admin role required"`, your token does not include the `admin` role.
- If you get `"error": "Required role missing in token"`, the token does not contain any `roles` claim.
- For normal telemetry and listing vehicles, `admin` is not required.
