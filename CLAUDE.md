# Bethel STL Church Website

## Deployment
- **Platform:** Fly.io (free tier)
- **Database:** SQLite (production and development)
- **DNS/CDN:** Cloudflare (DNS pointing to Fly.io)

All code, configuration, and architectural decisions must account for:
- Fly.io free tier constraints (single machine, shared CPU, 256MB RAM)
- SQLite as the sole database — no Postgres, no MySQL
- Single-server deployment (no multi-region, no horizontal scaling)
- Fly.io's persistent volume for SQLite storage

## Project Structure
- Rails app lives in `bethel_stl/`
- Ruby version: 3.4.8 (managed via mise)

## Guidelines
- Use Rails 8 SQLite-backed defaults: Solid Queue, Solid Cache, Solid Cable
- Keep resource usage low — optimize for minimal memory footprint
- Ensure the Dockerfile is Fly.io-compatible
- Always consider that SQLite requires a persistent volume on Fly.io
