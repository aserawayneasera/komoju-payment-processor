# InvoiceLite

A full-stack invoicing SaaS application built with React, TypeScript, Python/Django, and PostgreSQL.

**Live demo:** [invoicelite-django-react.vercel.app](https://invoicelite-django-react.vercel.app)  
**API:** Deployed on Render  
**Source:** [github.com/aserawayneasera/invoicelite-django-react](https://github.com/aserawayneasera/invoicelite-django-react)

---

## What It Does

InvoiceLite lets freelancers and small businesses manage their billing end-to-end:

- Register and log in with JWT authentication (with automatic token refresh)
- Manage clients
- Create invoices with multiple line items, tax rates, and status tracking
- Convert quotes to invoices
- Download invoices as professionally formatted PDFs
- View a dashboard with revenue and invoice statistics by status
- Read help content managed through a Wagtail CMS

---

## Tech Stack

### Frontend
| Tool | Purpose |
|------|---------|
| React 18 + TypeScript | UI framework |
| Vite | Build tool |
| Tailwind CSS | Styling |
| React Query | Server state and caching |
| Axios | HTTP client with JWT interceptor |
| React Router | Client-side routing |
| Lucide React | Icons |
| Cypress | End-to-end tests |

### Backend
| Tool | Purpose |
|------|---------|
| Python + Django 6 | Web framework |
| Django REST Framework | REST API |
| SimpleJWT | JWT authentication |
| WeasyPrint | PDF generation from HTML templates |
| Wagtail | CMS for help/FAQ content |
| PostgreSQL | Database |
| pytest + pytest-django | Test suite |
| Gunicorn + WhiteNoise | Production server |

### Deployment
| Service | What's deployed |
|---------|----------------|
| Vercel | React frontend |
| Render | Django API + PostgreSQL |

---

## Features

### Authentication
- Register with email and password
- JWT access + refresh tokens
- Automatic silent token refresh via Axios response interceptor — users stay logged in without re-entering credentials
- Redirect to login on 401

### Clients
- Create, read, update, delete clients
- Each client is scoped to the authenticated user — no data leakage between accounts

### Invoices
- Create invoices with multiple line items (description, quantity, unit price, tax rate)
- Status workflow: `draft → sent → paid / overdue`
- Filter by status and search by client or invoice number
- Duplicate invoice number validation
- Download as PDF — authenticated blob download, not a plain link

### Quotes
- Create quotes with expiry dates and notes
- One-click conversion to invoice

### PDF Export
- Professionally formatted PDF generated server-side with WeasyPrint
- Includes line items, totals, tax, status badge, and notes
- Served as an authenticated API response (Bearer token required)
- Frontend fetches as a blob and triggers a native browser download

### Dashboard
- Total invoices, paid, sent, and overdue counts
- Revenue summary

### CMS (Wagtail)
- Help and FAQ content managed through Wagtail admin at `/cms/`
- `HelpIndexPage` and `HelpArticlePage` models with rich text editor
- Accessible at `/help/`

### Error Handling
- React Error Boundary wraps the entire app — a broken component cannot crash the whole UI
- API errors surface cleanly to the user

---

## Running Locally

### Prerequisites
- Python 3.11+
- Node.js 18+
- PostgreSQL

### Backend

```bash
cd backend
python -m venv ../venv
source ../venv/bin/activate
pip install -r requirements.txt

# Create a .env file (see .env.example)
cp .env.example .env

python manage.py migrate
python manage.py createsuperuser
python manage.py runserver
```

The API runs at `http://localhost:8000`.  
Wagtail CMS admin at `http://localhost:8000/cms/`.

### Frontend

```bash
cd frontend
npm install

# Create a .env.local file
echo "VITE_API_URL=http://localhost:8000/api" > .env.local

npm run dev
```

The app runs at `http://localhost:5173`.

---

## Running Tests

### Backend (pytest)

```bash
cd backend
source ../venv/bin/activate
pytest -v
```

15 tests across three apps:

| App | Tests |
|-----|-------|
| `accounts` | Register, login, wrong password, `/me` auth required, `/me` returns user |
| `clients` | Create, list own only, unauthenticated blocked, update, delete, cannot delete other user's client |
| `invoices` | Create with line items, summary endpoint, status filter, duplicate number rejected |

### Frontend (Cypress E2E)

With both servers running:

```bash
cd frontend
npx cypress run       # headless
npx cypress open      # interactive UI
```

Covers authentication flow and client creation.

---

## Project Structure

```
invoicelite/
├── backend/
│   ├── accounts/          # Custom user model, auth views
│   ├── clients/           # Client CRUD
│   ├── invoices/          # Invoice, Quote, Payment, PDF export
│   │   └── templates/invoices/invoice_pdf.html
│   ├── help_pages/        # Wagtail CMS models
│   ├── config/            # Django settings, URLs
│   ├── conftest.py        # pytest fixtures
│   └── requirements.txt
└── frontend/
    ├── src/
    │   ├── components/    # Layout, ErrorBoundary, UI primitives
    │   ├── contexts/      # AuthContext
    │   ├── lib/           # api.ts (Axios + interceptors), utils
    │   ├── pages/         # Dashboard, Invoices, Quotes, Clients, Login
    │   └── types/         # TypeScript interfaces
    └── cypress/e2e/       # E2E tests
```

---

## Data Model

```
User
 └── Client (owner FK)
      └── Invoice (client FK, owner FK)
           ├── InvoiceItem (invoice FK)
           └── Payment (invoice FK)
      └── Quote (client FK, owner FK)
```

All resources are owner-scoped — the API filters every query by `request.user`, so a user can only ever see their own data.

---

## Key Design Decisions

**Why JWT over sessions?** Stateless auth works cleanly with a decoupled frontend/backend on separate domains (Vercel + Render). Sessions would require shared cookie configuration across domains.

**Why React Query over plain useEffect?** Automatic caching, background refetching, and loading/error states without manual boilerplate. The dashboard and invoice list stay fresh without extra code.

**Why WeasyPrint for PDFs?** It renders PDFs from HTML + CSS templates, so the PDF layout is maintained with the same CSS skills used for the rest of the app — no proprietary PDF DSL to learn.

**Why Wagtail for help content?** Hard-coded help text requires a developer to update it. A CMS lets non-technical team members manage help content through a visual editor without touching code — the right separation of concerns for a SaaS product.

---

## What I Would Add Next

- Payment recording and status transitions
- Stripe integration for online payment links
- Email delivery of invoices via SendGrid
- Multi-currency support
- Recurring invoice scheduling
