import { randomUUID } from 'node:crypto';

/**
 * A tiny in-memory double of the subset of the Supabase JS query builder
 * used by src/lib/resource.ts, src/lib/nestedResource.ts, src/lib/
 * idempotency.ts and src/lib/ownership.ts's assertOwnsActivity. It exists
 * so the authorization *logic* in those files (does every query really
 * filter by owner_user? does a 0-row result really become a 404?) can be
 * unit-tested without a running Postgres.
 *
 * It is not a general Postgrest emulator -- in particular it has no
 * support for embedded-relation filters (`table.column` dot-notation, used
 * by assertOwnsActivityFile's `activities!inner(owner_user)` join). That
 * function is covered by the real-Postgres RLS suite instead
 * (test/rls/ownership.rls.test.ts), not here.
 */

type Row = Record<string, unknown>;
interface FakeError {
  code?: string;
  message: string;
}

class FakeQueryBuilder implements PromiseLike<{ data: unknown; error: FakeError | null; count?: number }> {
  private filters: Array<(row: Row) => boolean> = [];
  private mode: 'select' | 'insert' | 'update' | 'delete' = 'select';
  private insertPayload?: Row;
  private updatePayload?: Row;
  private wantCount = false;
  private orderCol?: string;
  private orderAsc = true;
  private rangeFrom?: number;
  private rangeTo?: number;

  constructor(
    private readonly table: Row[],
    private readonly uniqueKeys: string[][],
  ) {}

  select(_cols: string, opts?: { count?: string }): this {
    this.wantCount = Boolean(opts?.count);
    return this;
  }

  insert(payload: Row): this {
    this.mode = 'insert';
    this.insertPayload = payload;
    return this;
  }

  update(payload: Row): this {
    this.mode = 'update';
    this.updatePayload = payload;
    return this;
  }

  delete(): this {
    this.mode = 'delete';
    return this;
  }

  eq(col: string, value: unknown): this {
    this.filters.push((row) => row[col] === value);
    return this;
  }

  order(col: string, opts?: { ascending?: boolean }): this {
    this.orderCol = col;
    this.orderAsc = opts?.ascending ?? true;
    return this;
  }

  range(from: number, to: number): this {
    this.rangeFrom = from;
    this.rangeTo = to;
    return this;
  }

  private matched(): Row[] {
    return this.table.filter((row) => this.filters.every((f) => f(row)));
  }

  private checkUnique(candidate: Row): FakeError | null {
    for (const keys of this.uniqueKeys) {
      const clash = this.table.some((row) => keys.every((k) => row[k] === candidate[k]));
      if (clash) return { code: '23505', message: 'duplicate key value violates unique constraint' };
    }
    return null;
  }

  async single(): Promise<{ data: Row | null; error: FakeError | null }> {
    const { data, error } = await this.resolve();
    if (error) return { data: null, error };
    const rows = Array.isArray(data) ? data : data ? [data] : [];
    if (rows.length !== 1) return { data: null, error: { message: 'not exactly one row' } };
    return { data: rows[0] ?? null, error: null };
  }

  async maybeSingle(): Promise<{ data: Row | null; error: FakeError | null }> {
    const { data, error } = await this.resolve();
    if (error) return { data: null, error };
    const rows = Array.isArray(data) ? data : data ? [data] : [];
    return { data: rows[0] ?? null, error: null };
  }

  then<TResult1 = { data: unknown; error: FakeError | null; count?: number }, TResult2 = never>(
    onfulfilled?: ((value: { data: unknown; error: FakeError | null; count?: number }) => TResult1 | PromiseLike<TResult1>) | null,
    onrejected?: ((reason: unknown) => TResult2 | PromiseLike<TResult2>) | null,
  ): PromiseLike<TResult1 | TResult2> {
    return this.resolve().then(onfulfilled, onrejected);
  }

  private async resolve(): Promise<{ data: unknown; error: FakeError | null; count?: number }> {
    if (this.mode === 'insert' && this.insertPayload) {
      const uniqueError = this.checkUnique(this.insertPayload);
      if (uniqueError) return { data: null, error: uniqueError };
      const row: Row = { id: randomUUID(), created_at: new Date().toISOString(), ...this.insertPayload };
      this.table.push(row);
      return { data: row, error: null };
    }

    if (this.mode === 'update') {
      const rows = this.matched();
      for (const row of rows) Object.assign(row, this.updatePayload);
      return { data: rows, error: null };
    }

    if (this.mode === 'delete') {
      const rows = this.matched();
      for (const row of rows) {
        const idx = this.table.indexOf(row);
        if (idx >= 0) this.table.splice(idx, 1);
      }
      return { data: rows, error: null };
    }

    let rows = this.matched();
    const count = rows.length;
    if (this.orderCol) {
      const col = this.orderCol;
      rows = [...rows].sort((a, b) => {
        const av = String(a[col]);
        const bv = String(b[col]);
        const cmp = av > bv ? 1 : av < bv ? -1 : 0;
        return this.orderAsc ? cmp : -cmp;
      });
    }
    if (this.rangeFrom !== undefined && this.rangeTo !== undefined) {
      rows = rows.slice(this.rangeFrom, this.rangeTo + 1);
    }
    return { data: rows, error: null, count: this.wantCount ? count : undefined };
  }
}

export class FakeSupabase {
  private store = new Map<string, Row[]>();
  private uniqueKeys = new Map<string, string[][]>();

  seed(table: string, rows: Row[]): void {
    this.store.set(table, [...rows]);
  }

  setUniqueKeys(table: string, keys: string[][]): void {
    this.uniqueKeys.set(table, keys);
  }

  rows(table: string): Row[] {
    return this.store.get(table) ?? [];
  }

  from(table: string): FakeQueryBuilder {
    if (!this.store.has(table)) this.store.set(table, []);
    return new FakeQueryBuilder(this.store.get(table) as Row[], this.uniqueKeys.get(table) ?? []);
  }
}
