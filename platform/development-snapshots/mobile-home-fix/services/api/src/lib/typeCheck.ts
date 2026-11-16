/**
 * Compile-time-only drift check between a resource's hand-written `columns`
 * array (the explicit SELECT allowlist -- db/CLAUDE.md: no `select('*')`)
 * and the generated response type it's supposed to match
 * (packages/shared/types/*.ts, generated from openapi.yaml).
 *
 * `AssertCovers<typeof columns, keyof SomeType>` resolves to `true` only if
 * every key of `SomeType` appears in `columns`; otherwise it resolves to an
 * object naming the missing key(s), which fails to satisfy `true` and
 * breaks the build. Combined with `satisfies readonly (keyof SomeType)[]`
 * on the array itself (which rejects any element that *isn't* a real key),
 * this makes `columns` exhaustively and exactly match the shared type: if
 * openapi.yaml adds, renames, or removes a field, `npm run generate:types`
 * in packages/shared followed by `tsc` here fails at the exact resource
 * file that's now out of sync, instead of silently under- or over-
 * selecting columns at runtime.
 *
 * Only applied to `columns` (see each resource file), not `createFields`/
 * `updateFields` -- a column missing from the SELECT allowlist breaks the
 * response shape (openapi-glue's response validation throws a 500), which
 * is exactly the "fail loudly" CLAUDE.md asks for. A field missing from
 * the writable allowlist just means that field silently isn't settable
 * yet, a lower-stakes gap that the `satisfies` clause alone (catching
 * typos/renames) already covers without needing full exhaustiveness.
 */
export type AssertCovers<Arr extends readonly PropertyKey[], K extends PropertyKey> = [K] extends [Arr[number]]
  ? true
  : { missingKeys: Exclude<K, Arr[number]> };
