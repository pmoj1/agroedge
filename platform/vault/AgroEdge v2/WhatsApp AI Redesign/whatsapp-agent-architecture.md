# WhatsApp AI Agents — Architecture Notes (concept, not built)

Companion to `farmer-whatsapp-mockup.html`. Describes how the two WhatsApp
agents shown in the mockup (Data Intake Agent, Agronomist Agent) would plug
into the existing AgroEdge stack per `CLAUDE.md`.

## Why WhatsApp as the primary farmer channel

Selling directly to farmers means removing every point of friction between
"hears about AgroEdge" and "gets value." An app install, account creation,
and OTP flow are all friction. WhatsApp removes them — the farmer saves a
number and starts talking.

## Two agents, one WhatsApp Business number

| Agent | Job | Reads/writes |
|---|---|---|
| **Data Intake Agent** | Turns free-form text/voice/photo into structured farm records (crop, area, planting date, input costs, activities) | Writes to farmer's `farm_records`, `expenses`, `activities` tables |
| **Agronomist Agent** | Answers agronomy questions, diagnoses pest/disease from photos, gives timing advice | Reads farm history + weather; does not write records unless the farmer confirms an action |

Both agents sit behind the same WhatsApp Business number. An intent router
(a lightweight classifier, not a full agent) decides which agent handles
each incoming message before handing off.

## Request flow

1. **WhatsApp Cloud API** (Meta) delivers an inbound message webhook to
   `services/integrations`. Africa's Talking currently handles SMS/USSD in
   this repo — WhatsApp is a distinct channel via Meta's own Business
   Platform, so this is new integration surface, not an extension of the
   existing Africa's Talking client.
2. **Intent router** classifies the message: data-entry vs. agronomy
   question vs. dashboard/report request.
3. **Agent invocation** — the relevant agent runs as a Claude tool-use loop
   with tools scoped to that agent (e.g. `log_expense`, `log_activity` for
   intake; `get_farm_history`, `get_weather`, `get_crop_stage` for
   agronomist — read-only).
4. **Action** — intake agent calls its tools to write structured data via
   the existing `services/api` endpoints (not directly to Postgres — the
   agent goes through the same API surface a human-facing client would, so
   RLS and validation apply identically).
5. **Reply** — a confirmation or answer is sent back over WhatsApp.

## Data residency constraints (hard requirement, per CLAUDE.md)

This is the part that needs the most care, because WhatsApp messages
naturally contain PII (phone number, sometimes photos of the farmer's
land or face) and the content is being sent to Claude.

- Strip or pseudonymise the farmer's phone number and any name before it
  reaches the Claude prompt — use an internal farmer ID, not the WhatsApp
  MSISDN, as the identifier passed to the model.
- Photos sent for diagnosis (crop/leaf images) are typically not personal
  data, but audit each prompt path to confirm no incidental PII (faces,
  ID documents, land titles) is forwarded.
- Voice notes must be transcribed by a provider whose data handling meets
  the same regional constraints as the Claude calls — don't introduce a
  new third-party transcription vendor without checking its data
  residency posture first.
- Meta/WhatsApp itself is an unavoidable third party in this design (the
  message transport) — that's a product decision to flag explicitly to
  the founders, since "no PII to third parties" is a stated hard
  constraint and WhatsApp messages inherently pass through Meta's
  infrastructure. Confirm this is an accepted tradeoff before building.

## Where this lives in the existing repo lanes

- New WhatsApp webhook handling and the two agents belong in
  `services/integrations/` (AONE's lane) — same place Africa's Talking and
  Claude API integration already live.
- No changes needed to `apps/` for this to work — the WhatsApp channel is
  additive, not a replacement for the mobile app. The mockup positions it
  as the low-friction front door; the app remains the deeper dashboard for
  farmers who want it.
- Any new `farm_records`/`expenses` fields needed to support conversational
  intake go through `db/` migrations, `up` and `down`, per existing
  convention.

## Suggested build order (not started)

1. Meta WhatsApp Business API sandbox + webhook receiver in
   `services/integrations`.
2. Intent router (simple classification, can be a small Claude call or a
   rules-based first pass).
3. Data Intake Agent with a narrow, explicit tool set (log crop, log
   expense, log activity) — no open-ended write access.
4. Agronomist Agent, read-only tools first, before adding any write
   capability.
5. Pilot with a small number of real farmers before wider rollout.

---
*Concept document for internal planning. No WhatsApp integration, agents, or
farmer-facing service currently exist in this codebase.*
