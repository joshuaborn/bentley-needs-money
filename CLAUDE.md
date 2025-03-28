# Bentley Needs Money - Developer Guide

## Build & Run Commands (Docker)
- Start development environment: `docker compose up`
- Run a command in the running container: `docker compose exec web COMMAND`
- Run all tests: `docker compose exec web bundle exec rspec`
- Run single test: `docker compose exec web bundle exec rspec spec/path/to/file_spec.rb:LINE_NUMBER`
- Ruby linting: `docker compose exec web bin/rubocop`
- TypeScript linting: `docker compose exec web npx eslint app/javascript/**.ts`
- Security check: `docker compose exec web bin/brakeman`
- Build JS: `docker compose exec web bun run build`
- Database setup: `docker compose exec web bin/rails db:setup`
- Database migrations: `docker compose exec web bin/rails db:migrate`

## Code Style Guidelines
- Ruby: Uses Rails Omakase conventions (check .rubocop.yml)
- TypeScript: Strict mode, follows eslint.config.js rules
- React: Functional components with TypeScript
- Testing: RSpec with FactoryBot for fixture generation

## Naming Conventions
- Ruby: snake_case for methods/variables, CamelCase for classes
- TypeScript: camelCase for variables/methods, PascalCase for components/types
- Type definitions in app/javascript/types.ts
- Controllers follow RESTful convention

## Error Handling
- Use Rails standard error handling in Ruby
- TypeScript: Prefer explicit error handling with types
- Use flash notifications for user-facing errors

## Project Structure
- Rails 8 app with React/TypeScript frontend
- Models in app/models/
- React components in app/javascript/components/
- Follow existing patterns for new code

## Docker Development
- Application runs in Docker with PostgreSQL database
- Docker Compose configuration in compose.yaml
- Development settings in development.Dockerfile
- Code changes are reflected immediately (volumes mounted)
- Database data persisted in pg_data volume