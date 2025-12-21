# spring-boot-prod-template — Spring Boot 4 Production Starter (Java 25)
A production-minded **Spring Boot 4** starter/template repo you can fork and/or reuse for future services. Includes a small reference API, database migrations, observability, Docker, and CI so every new service starts "real".

## Goals
- **Latest stable stack** (Spring Boot 4 + Java 25)
- **Production defaults** (migrations, health/metrics, CI, containerization)
- **Template-friendly** (easy renaming, minimal opinionated business logic)
- **Noncommercial licensing** (personal + noncommercial OSS only)

---

## Stack (MVP)
- **Java:** 25 (LTS)
- **Spring Boot:** 4.0.1
- **Build:** Gradle (Kotlin DSL)
- **API:** Spring Web (MVC) + Validation
- **DB:** PostgreSQL 18
- **Migrations:** Flyway
- **Docs:** OpenAPI + Swagger UI (springdoc)
- **Security:** Spring Security (toggleable) + JWT Resource Server ready
- **Observability:** Actuator + Micrometer + Prometheus scrape endpoint
- **Testing:** **JUnit 6** + Spring Boot Test + **Testcontainers**
- **DevOps:** Docker, Docker Compose, GitHub Actions CI (+ vulnerability scan)

### Dependency version policy (important)
- **We do not hardcode versions** for dependencies managed by **Spring Boot's BOM**.
  - This keeps your template on a "latest compatible set" that is tested together.
- We only pin versions for **dependencies not managed by Boot** (example: `springdoc`).
- Keep versions current via **Dependabot** (recommended for a template repo).

---

## Quickstart (Docker)
```bash
docker compose up --build
```
