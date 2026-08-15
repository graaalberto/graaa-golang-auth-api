# Maintenance API

## Overview

`maintenance-api` is a standalone microservice for the Luena Fleet System that manages work orders, spare parts, and part usage for vehicle maintenance.

## Service location

- Main package: `cmd/maintenance-api`
- Dockerfile: `cmd/maintenance-api/Dockerfile`
- Internal domain: `internal/maintenance`

## Base URL

- Local Docker dev: `http://localhost:8084`
- API root: `/api/v1`

## Authentication

The API validates JWTs issued by `golang-auth-api`.

- Header: `Authorization: Bearer <token>`
- Token must include `user_id`, `app_id`, and `tenant_id`
- `MAINTENANCE_API_JWT_SECRET` falls back to `JWT_SECRET`

## Models

### WorkOrder

- `id` UUID
- `vehicle_id` UUID
- `priority` `LOW`, `MEDIUM`, `HIGH`
- `status` `PENDING`, `IN_PROGRESS`, `COMPLETED`, `CANCELLED`
- `description` string
- `total_cost` numeric
- `tenant_id` UUID
- `created_at` timestamp
- `completed_at` timestamp nullable

### SparePart

- `id` UUID
- `name` string
- `stock_code` string
- `stock_quantity` integer
- `unit_price` numeric

### WorkOrderPart

- `work_order_id` UUID
- `part_id` UUID
- `quantity_used` integer
- `created_at` timestamp

## Endpoints

### Create work order

`POST /api/v1/work-orders`

Request body:

```json
{
  "vehicle_id": "uuid",
  "priority": "MEDIUM",
  "description": "Preventive maintenance for brake system"
}
```

Response:

- `201 Created`
- Work order JSON

### List work orders

`GET /api/v1/work-orders`

Query parameters:

- `status` (optional)
- `vehicle_id` (optional)

Response:

- `200 OK`
- Array of work orders

### Update work order status

`PATCH /api/v1/work-orders/{id}/status`

Request body:

```json
{
  "status": "IN_PROGRESS"
}
```

Response:

- `204 No Content`

### Add parts to work order

`POST /api/v1/work-orders/{id}/parts`

Request body:

```json
{
  "parts": [
    { "part_id": "uuid", "quantity_used": 2 }
  ]
}
```

Response:

- `200 OK`
- `{ "alerts": ["Spare part 'X' stock low: 3 remaining"] }`

## Business rules

- Parts are reserved and stock is decreased in a DB transaction.
- If any part stock drops below `5`, the response includes a low-stock alert.
- A work order is isolated by `tenant_id` from the JWT.

## Environment variables

- `MAINTENANCE_API_PORT` (default `8083`)
- `DB_HOST`
- `DB_PORT`
- `DB_USER`
- `DB_PASSWORD`
- `DB_NAME`
- `MAINTENANCE_API_JWT_SECRET`
- `GIN_MODE`

## Docker

Build and run using Docker Compose:

```bash
docker compose up --build auth-api fleet-api maintenance-api
```

## Example curl requests

List work orders:

```bash
curl -H "Authorization: Bearer <token>" http://localhost:8084/api/v1/work-orders
```

Create work order:

```bash
curl -X POST http://localhost:8084/api/v1/work-orders \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "vehicle_id":"uuid",
    "priority":"HIGH",
    "description":"Corrective maintenance for engine overheating"
  }'
```

Add parts to work order:

```bash
curl -X POST http://localhost:8084/api/v1/work-orders/<id>/parts \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "parts":[{"part_id":"uuid","quantity_used":2}]
  }'
```
