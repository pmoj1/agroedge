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

### 2026-07-11 09:38 — agroedgeco
feat: antigravity initial UI redesign pass

### 2026-07-11 09:40 — agroedgeco
chore: add Antigravity project rules and ignore brain vault

### 2026-07-11 11:02 — agroedgeco
feat: integrate premium design system and micro-interactions

### 2026-07-11 11:31 — agroedgeco
fix: constrain mobile home screen max-width to 480px to prevent stretching on desktop web

### 2026-07-11 11:43 — agroedgeco
fix: resolve AppErrorState layout overflow and localhost CORS restrictions

### 2026-07-11 12:11 — agroedgeco
fix: revert home phone container wrapper, make quick actions responsive, and implement unified live activity/expense/income feed

### 2026-07-11 12:18 — agroedgeco
design: redesign mobile app home screen to mimic FarmVista mockup dashboard with custom weather card, custom custom-painted circular gauge chart, filter/export rows, drawer, and bottom navigation

### 2026-07-11 12:28 — agroedgeco
fix: change weather/gauge row crossAxisAlignment to start to resolve scrollable layout assertion error

### 2026-07-11 12:31 — agroedgeco
fix: replace LayoutBuilder with Builder + MediaQuery on home screen to fix web layout assertion exceptions

### 2026-07-11 12:32 — agroedgeco
fix: enforce mainAxisSize min on weather location/toggle and gauge dropdown rows to prevent layout stretch crashes

### 2026-07-12 02:29 — agroedgeco
feat: generate native android/ios platforms and add internet permission

### 2026-07-12 12:32 — agroedgeco
feat: complete AI agronomist chat, farm setup redesign, live weather API, AI Smart Fill forms, and multilingual settings

### 2026-07-12 12:33 — agroedgeco
docs: append build log entries

### 2026-07-12 12:40 — agroedgeco
chore: format files using dart format to satisfy CI requirements

### 2026-07-12 12:56 — agroedgeco
feat: add log out safety valve to AuthGate error screen

### 2026-07-12 13:08 — agroedgeco
fix: set stable v1 API version and implement automatic model fallback in GeminiService

### 2026-07-12 13:17 — agroedgeco
fix: extend fallback mechanism to handle quota-exceeded/limit-0 errors

### 2026-07-12 13:24 — agroedgeco
fix: use v1beta for legacy gemini-pro model in fallback

### 2026-07-12 13:35 — agroedgeco
chore: trigger build with updated GEMINI_API_KEY

### 2026-07-12 13:37 — agroedgeco
chore: force Netlify rebuild with updated GEMINI_API_KEY

### 2026-07-12 14:02 — agroedgeco
feat: integrate Groq API client, build Accounting Screen with credit scoring, and dynamic dashboard currencies

### 2026-07-12 14:05 — agroedgeco
fix: enclose inline return statements in curly braces to pass CI linter rules

### 2026-07-12 14:14 — agroedgeco
chore: deploy standard Gemini key to fix Web CORS restrictions

### 2026-07-12 17:44 — agroedgeco
chore: fix DropdownButtonFormField deprecation warning in gmb_board_screen.dart

### 2026-07-12 18:55 — agroedgeco
chore: ignore deprecated member warnings in web map and planner to pass CI analyze checks

### 2026-07-13 00:36 — agroedgeco
feat: revamp notifications with dynamic user data, change dark mode background to pure black, and fix MaterialApp translation title crash

### 2026-07-13 00:49 — agroedgeco
chore: add deploy trigger comment to mobile app

### 2026-07-13 06:46 — agroedgeco
fix: resolve weather and production overview text contrast in dark mode, map manual tn/nd locales to en

### 2026-07-13 06:49 — agroedgeco
chore: format files with dart format

### 2026-07-13 07:01 — agroedgeco
feat: add timezone-aware dynamic greeting and AI suggested to-do list, map Production Overview to user registered crops

### 2026-07-13 07:16 — agroedgeco
fix: add @activityListItemSubtitle block to tn/nd arb files to prevent delegate compilation mismatch, add custom to-do list drawer option and tab, translate drawer labels

### 2026-07-13 07:27 — agroedgeco
fix: sync dashboard todo list with custom todo list tab, add interactive whatsapp and sms connection card inside AI Chat
