# Shorty — URL Shortener

A fast, feature-rich URL shortener built with Ruby on Rails 8.

## Features

- 🔗 Shorten any URL (with optional custom alias)
- 📊 Analytics: click counts, referrers, per-day breakdown
- 🔲 QR Code generation (SVG)
- 👤 User accounts via Devise (sign up / sign in)
- 🔑 REST API with token authentication
- 🗑 Delete your own URLs
- 🚀 Deploy-ready for Dokku

## Local Setup

```bash
bundle install
bin/rails db:create db:migrate
bin/rails server
```

## API Usage

All API endpoints require an `Authorization: Bearer <token>` header.
Find your API token on the Account page after signing in.

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v1/me` | Your profile & token |
| GET | `/api/v1/urls` | List your URLs |
| POST | `/api/v1/urls` | Create a short URL |
| GET | `/api/v1/urls/:id` | URL details + click history |
| DELETE | `/api/v1/urls/:id` | Delete a URL |

**Create URL example:**
```bash
curl -X POST https://your-app.com/api/v1/urls \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"url": {"original_url": "https://example.com/long-path"}}'
```

## Deploy on Dokku

```bash
# On your Dokku server
dokku apps:create shorty
dokku postgres:create shorty-db
dokku postgres:link shorty-db shorty
dokku config:set shorty \
  RAILS_ENV=production \
  RAILS_SERVE_STATIC_FILES=true \
  RAILS_LOG_TO_STDOUT=true \
  SECRET_KEY_BASE=$(openssl rand -hex 64)

# From your local machine
git remote add dokku dokku@your-server.com:shorty
git push dokku main
```

Dokku will automatically run `db:migrate` via `app.json` on each deploy.


* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
