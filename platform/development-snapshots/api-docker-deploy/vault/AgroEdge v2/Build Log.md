# Build Log

### 2026-07-10 18:26 — agroedgeco
test: build log setup

### 2026-07-10 18:31 — agroedgeco
add AgroEdge knowledge base notes

### 2026-07-10 18:39 — agroedgeco
import Notion export into vault

### 2026-07-10 18:42 — agroedgeco
clean up Notion import: strip IDs, convert links

### 2026-07-10 18:47 — agroedgeco
remove duplicate Notion CSV exports

### 2026-07-10 18:48 — agroedgeco
restore accidentally deleted Notion CSV exports

### 2026-07-11 01:09 — agroedgeco
feat: add root Dockerfile for services/api deployment

Render's native Node build detection has been unreliable with the npm
workspaces monorepo layout, so services/api now ships a Docker service
instead. The Dockerfile lives at the repo root since it needs the whole
workspace (root manifests + packages/shared + services/api) to install
and build correctly.

Also fixes a latent bug found while wiring this up: tsconfig.json's
rootDir: "." caused tsc to emit dist/src/server.js instead of
dist/server.js, which silently broke both `npm start` and the
runtime path resolution to packages/shared/openapi/openapi.yaml.
Added tsconfig.build.json (src-only, flat output) and pointed the
build script at it; typecheck still covers test/**.

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
