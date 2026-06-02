# komoju-payment-processor

A production-grade payment processing API built in **Ruby on Rails 8.1**, simulating the core infrastructure of a payment gateway. Built as a portfolio project demonstrating backend engineering depth in the payments domain — merchants, API key authentication, charges, refunds, HMAC-SHA256 signed webhooks, idempotency keys, and async background job processing.

> Built to demonstrate alignment with [KOMOJU's](https://komoju.com) engineering domain and stack.

---

## Table of Contents

- [What This Is](#what-this-is)
- [Tech Stack](#tech-stack)
- [Architecture](#architecture)
- [Getting Started](#getting-started)
- [API Reference](#api-reference)
- [Full Demo Walkthrough](#full-demo-walkthrough)
- [Key Design Decisions](#key-design-decisions)
- [Running the Tests](#running-the-tests)
- [Project Structure](#project-structure)

---

## What This Is

A REST API that lets merchants:

- Register and receive a **one-time API key** (SHA-256 hashed — raw token shown once, never stored)
- Create **customers** and save **payment methods** (last 4 digits only — no card numbers stored)
- Create **charges** with idempotency key protection to prevent duplicate billing
- Issue **partial refunds** with over-refund validation
- Register **webhook endpoints** that receive HMAC-SHA256 signed event notifications
- Track an immutable **event log** with webhook delivery records

Everything runs with a single command:

```bash
docker-compose up
```

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| API | Ruby on Rails 8.1 (API-only mode) |
| Database | PostgreSQL 16 |
| Background jobs | Sidekiq 8 + Redis 7 |
| Auth | API key authentication (SHA-256 hashed) |
| Webhooks | HMAC-SHA256 signed payloads |
| Testing | RSpec, FactoryBot, Faker, Shoulda Matchers |
| Dev environment | Docker Compose |

---

## Architecture

```
┌─────────────────────────────────────────────────────┐
│                   Docker Compose                     │
│                                                      │
│  ┌──────────┐   ┌──────────┐   ┌──────────────────┐ │
│  │   api    │   │    db    │   │     sidekiq      │ │
│  │ Rails 8  │──▶│Postgres  │◀──│ Background Jobs  │ │
│  │ :3000    │   │   :5432  │   │                  │ │
│  └──────────┘   └──────────┘   └──────────────────┘ │
│       │                               │              │
│       │         ┌──────────┐          │              │
│       └────────▶│  redis   │◀─────────┘              │
│                 │  :6379   │                         │
│                 └──────────┘                         │
└─────────────────────────────────────────────────────┘
```

### Request flow for a charge

```
POST /api/v1/charges
        │
        ▼
 Authenticate API key
 (SHA-256 hash lookup)
        │
        ▼
 Check Idempotency-Key
 (return cached response if seen before)
        │
        ▼
 Validate charge
 (customer → merchant, payment method → customer)
        │
        ▼
 Save charge (status: succeeded)
        │
        ├──▶ Create Event record
        │         │
        │         └──▶ Enqueue WebhookDispatchJob (async)
        │                     │
        │                     └──▶ Sidekiq signs payload
        │                          HMAC-SHA256, HTTP POST
        │                          to merchant's webhook URL
        ▼
 Return JSON response (fast — no webhook delay)
```

---

## Getting Started

### Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) installed and running

### 1. Clone the repository

```bash
git clone https://github.com/aserawayneasera/komoju-payment-processor.git
cd komoju-payment-processor
```

### 2. Start all services

```bash
docker-compose up
```

Wait until you see:

```
api-1     | * Listening on http://0.0.0.0:3000
sidekiq-1 | Booted Rails 8.1.3 application in development environment
sidekiq-1 | Sidekiq 8.1.6 connecting to Redis
```

The API is now live at `http://localhost:3000`.

### 3. Open a second terminal for API calls

All `curl` commands below run in a separate terminal while `docker-compose up` stays running in the first.

---

## API Reference

All endpoints except `/auth/register` and `/auth/login` require:

```
Authorization: Bearer <your_api_token>
```

### Authentication

| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/api/v1/auth/register` | Create a merchant account. Returns a one-time API key. |
| `POST` | `/api/v1/auth/login` | Log in and receive a new API key. |

### API Keys

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/api/v1/api_keys` | List all active API keys for your merchant. |
| `POST` | `/api/v1/api_keys` | Create an additional API key. |
| `DELETE` | `/api/v1/api_keys/:id` | Revoke an API key. |

### Customers

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/api/v1/customers` | List all customers. |
| `POST` | `/api/v1/customers` | Create a customer. |
| `GET` | `/api/v1/customers/:id` | Get a customer. |

### Payment Methods

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/api/v1/customers/:id/payment_methods` | List payment methods for a customer. |
| `POST` | `/api/v1/customers/:id/payment_methods` | Add a payment method to a customer. |

### Charges

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/api/v1/charges` | List all charges (newest first). |
| `POST` | `/api/v1/charges` | Create a charge. Supports `Idempotency-Key` header. |
| `GET` | `/api/v1/charges/:id` | Get a charge including its refunds. |

### Refunds

| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/api/v1/charges/:id/refunds` | Issue a refund against a charge. |

### Webhook Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/api/v1/webhook_endpoints` | List webhook endpoints. |
| `POST` | `/api/v1/webhook_endpoints` | Register a webhook endpoint. Returns signing secret once. |
| `DELETE` | `/api/v1/webhook_endpoints/:id` | Delete a webhook endpoint. |

### Events

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/api/v1/events` | List all events (newest first). |
| `GET` | `/api/v1/events/:id` | Get an event with its webhook deliveries. |

---

## Full Demo Walkthrough

### Step 1 — Register a merchant

```bash
curl -s -X POST http://localhost:3000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Acme Corp",
    "email": "acme@example.com",
    "password": "password123",
    "password_confirmation": "password123"
  }' | python3 -m json.tool
```

Response:

```json
{
    "merchant": {
        "id": 1,
        "name": "Acme Corp",
        "email": "acme@example.com"
    },
    "api_key": "c263963958c7e9c4185893d9dccfb3fb...",
    "message": "Save this API key — it will not be shown again."
}
```

> ⚠️ Copy the `api_key` immediately — it is shown **once** and never stored in plain text.

Save it for the next steps:

```bash
TOKEN="paste_your_key_here"
```

---

### Step 2 — Create a customer

```bash
curl -s -X POST http://localhost:3000/api/v1/customers \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "name": "Jane Doe",
    "email": "jane@example.com",
    "phone": "090-1234-5678"
  }' | python3 -m json.tool
```

---

### Step 3 — Add a payment method

```bash
curl -s -X POST http://localhost:3000/api/v1/customers/1/payment_methods \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "payment_type": "card",
    "last_four": "4242",
    "brand": "Visa",
    "exp_month": 12,
    "exp_year": 2027,
    "is_default": true
  }' | python3 -m json.tool
```

---

### Step 4 — Create a charge

```bash
curl -s -X POST http://localhost:3000/api/v1/charges \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Idempotency-Key: charge-001" \
  -d '{
    "customer_id": 1,
    "payment_method_id": 1,
    "amount": 5000,
    "currency": "JPY",
    "description": "Web development services"
  }' | python3 -m json.tool
```

Response:

```json
{
    "id": 1,
    "amount": 5000,
    "currency": "JPY",
    "status": "succeeded",
    "idempotency_key": "charge-001",
    "created_at": "2026-06-02T01:27:30.676Z"
}
```

---

### Step 5 — Prove idempotency (send the same request again)

Run the **exact same curl command** from Step 4 again. The response is identical — same `id`, same `created_at`. No duplicate charge was created.

```bash
# Same command, same Idempotency-Key: charge-001
# Returns: same id: 1, same created_at — served from cache
```

---

### Step 6 — Issue a partial refund

```bash
curl -s -X POST http://localhost:3000/api/v1/charges/1/refunds \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "amount": 2000,
    "reason": "Customer request"
  }' | python3 -m json.tool
```

---

### Step 7 — Try to over-refund (see the validation)

```bash
curl -s -X POST http://localhost:3000/api/v1/charges/1/refunds \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"amount": 4000, "reason": "Test"}' | python3 -m json.tool
```

Response:

```json
{
    "errors": [
        "Amount exceeds refundable balance"
    ]
}
```

---

### Step 8 — Register a webhook endpoint

Use [https://webhook.site](https://webhook.site) to get a free test URL and watch deliveries arrive in real time.

```bash
curl -s -X POST http://localhost:3000/api/v1/webhook_endpoints \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "url": "https://webhook.site/your-unique-url",
    "events": ["charge.succeeded", "refund.succeeded"]
  }' | python3 -m json.tool
```

Response includes a one-time `secret` for signature verification. Every webhook delivered to your URL will include an `X-Webhook-Signature: sha256=<hmac>` header.

---

## Key Design Decisions

### API key hashing (SHA-256, not BCrypt)

API keys are long random strings (64 hex characters = 256 bits of entropy). Brute force is computationally impossible, so the slow hashing that BCrypt provides is unnecessary overhead on every request. SHA-256 is fast and still one-way — the raw token is gone after creation. This is the same model Stripe and GitHub use.

### Idempotency keys

Payment networks are unreliable. A client may send a charge request, the network drops before the response arrives, and the client retries — not knowing if the original charge succeeded. Without idempotency, this creates a duplicate charge. The `Idempotency-Key` header solves this: the first request is processed and the response is cached against the key. Subsequent requests with the same key return the cached response immediately.

### HMAC-SHA256 webhook signatures

A shared secret in the payload proves nothing — anyone who intercepts one delivery knows the secret. HMAC signs the payload with the secret without transmitting it. The receiver computes the same HMAC independently. If the signatures match, the payload is authentic and untampered. The secret itself is never exposed after creation.

### Amounts as integers

Floating point arithmetic is binary. `0.1 + 0.2 ≠ 0.3` in IEEE 754. For money, rounding errors accumulate into real financial discrepancies. All amounts are stored as integers in the smallest currency unit (¥5000 = 5000, $1.00 = 100 cents). All arithmetic is exact. This is the industry standard — Stripe does the same.

### No card numbers stored

Storing full card numbers requires PCI DSS Level 1 compliance. This system stores only the last four digits as a display hint. Full card tokenisation would happen at a PCI-compliant vault. This is enforced by design — there is no card number column in the schema.

### Cross-tenant data isolation

Every query is scoped to `@current_merchant`. The `Charge` model also validates that the customer belongs to the merchant and the payment method belongs to the customer. Even if an attacker knows IDs from another merchant's account, the validations reject the charge before any database write.

---

## Running the Tests

```bash
docker-compose run api bundle exec rspec --format documentation
```

Expected output:

```
ApiKey
  validations
    is expected to belong to merchant required: true
    is expected to validate that :name cannot be empty/falsy
  .generate_for
    returns a key and a raw token
    stores a digest, not the raw token
  .authenticate!
    returns the key for a valid token
    raises for an invalid token
    raises for a revoked token

Charge
  validations
    is expected to belong to merchant required: true
    ...
  cross-tenant validation
    rejects a customer from a different merchant
  #refundable_amount
    returns amount minus pending and succeeded refunds

...

Finished in 8.07 seconds
30 examples, 0 failures
```

---

## Project Structure

```
komoju-payment-processor/
├── app/
│   ├── controllers/
│   │   ├── application_controller.rb      # API key auth middleware
│   │   └── api/v1/
│   │       ├── auth_controller.rb         # Register + login
│   │       ├── api_keys_controller.rb
│   │       ├── customers_controller.rb
│   │       ├── payment_methods_controller.rb
│   │       ├── charges_controller.rb      # Idempotency logic
│   │       ├── refunds_controller.rb
│   │       ├── webhook_endpoints_controller.rb
│   │       └── events_controller.rb
│   ├── models/
│   │   ├── merchant.rb                    # has_secure_password, tenant root
│   │   ├── api_key.rb                     # SHA-256 hashing, authenticate!
│   │   ├── customer.rb                    # Scoped to merchant
│   │   ├── payment_method.rb              # Single-default callback
│   │   ├── charge.rb                      # Cross-tenant validation, refundable_amount
│   │   ├── refund.rb                      # Over-refund validation
│   │   ├── event.rb                       # Immutable audit log
│   │   ├── webhook_endpoint.rb            # HMAC secret generation
│   │   ├── webhook_delivery.rb            # Delivery tracking, retry logic
│   │   └── idempotency_key.rb             # find_or_lock!, complete!
│   └── jobs/
│       └── webhook_dispatch_job.rb        # Sidekiq async webhook delivery
├── config/
│   ├── routes.rb                          # Versioned API routes
│   ├── initializers/
│   │   ├── sidekiq.rb
│   │   └── cors.rb
│   └── database.yml
├── db/
│   └── migrate/                           # 10 migrations with indexes + constraints
├── spec/
│   ├── models/                            # 30 RSpec model specs
│   └── factories/                         # FactoryBot factories for all models
├── Dockerfile
└── docker-compose.yml                     # db + redis + api + sidekiq
```

---

## Database Schema

```
merchants
  └── api_keys          (SHA-256 hashed tokens, revocable)
  └── customers
        └── payment_methods  (last 4 digits only, single-default)
        └── charges
              └── refunds    (partial, with balance validation)
  └── events            (immutable audit log)
        └── webhook_deliveries
  └── webhook_endpoints  (HMAC-SHA256 signing secret)
  └── idempotency_keys   (request deduplication cache)
```

---

## Event Types

| Event | Triggered by |
|-------|-------------|
| `charge.succeeded` | Charge saved successfully |
| `charge.refunded` | Charge fully refunded |
| `refund.succeeded` | Refund processed |
| `customer.created` | New customer created |
| `payment_method.created` | Payment method added |

---

## Stopping and Resetting

```bash
# Stop (preserves data)
docker-compose down

# Full reset (wipes all data)
docker-compose down -v
docker-compose up
docker-compose run api rails db:migrate
```

---

## Author

**Asera Wayne Asera**  
PhD Candidate, Computer Science — Kumamoto University, Japan  
asera.wa@gmail.com  
[github.com/aserawayneasera](https://github.com/aserawayneasera)
