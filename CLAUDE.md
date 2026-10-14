# Bethel STL Church Website

## Deployment
- **Platform:** Self-hosted, deployed with Kamal (earlier Fly.io guidance was stale)
- **Database:** SQLite (production and development)
- **DNS/CDN:** Cloudflare (confirm actual production routing with the operator)

All code, configuration, and architectural decisions must account for:
- Single-machine deployment with low memory requirements; keep process counts small
- SQLite as the sole database — no Postgres, no MySQL
- Single-server deployment (no multi-region, no horizontal scaling)
- Kamal's persistent storage volume for SQLite and queue storage

## Project Structure
- Rails app lives in `bethel_stl/`
- Ruby version: 3.4.8 (managed via mise)

## Guidelines
- Use Rails 8 SQLite-backed defaults: Solid Queue, Solid Cache, Solid Cable
- Keep resource usage low — optimize for minimal memory footprint
- Keep the Dockerfile compatible with the self-hosted Kamal deployment
- SQLite requires a persistent volume, backups, and a continuously running job worker
- Keep the shared `config/credentials.yml.enc` and existing master key; do not introduce environment-specific credentials or rotate keys
- No live send, deployment, push, or provider/DNS change without explicit approval
