import fp from 'fastify-plugin';
import type { FastifyInstance, FastifyReply, FastifyRequest } from 'fastify';
import type { SupabaseClient } from '@supabase/supabase-js';

export interface AuthenticatedUser {
  id: string;
  email: string | undefined;
}

declare module 'fastify' {
  interface FastifyRequest {
    user: AuthenticatedUser | null;
  }
}

class UnauthorizedError extends Error {
  statusCode = 401;
  constructor(message = 'Missing or invalid Supabase auth token.') {
    super(message);
  }
}

/**
 * securityHandlers implementation for fastify-openapi-glue. The spec names
 * its security scheme "supabaseAuth" (see components.securitySchemes in
 * openapi.yaml), so the method below must be named to match.
 *
 * This only proves *who* the caller is. It does not decide what rows they
 * may touch -- that's enforced per-handler in src/lib/resource.ts and
 * src/lib/nestedResource.ts, per CLAUDE.md ("authentication is not
 * authorisation").
 */
export class SupabaseSecurityHandlers {
  #supabase: SupabaseClient;

  constructor(supabase: SupabaseClient) {
    this.#supabase = supabase;
  }

  async supabaseAuth(request: FastifyRequest, _reply: FastifyReply): Promise<void> {
    const header = request.headers.authorization;
    if (!header?.startsWith('Bearer ')) {
      throw new UnauthorizedError();
    }
    const token = header.slice('Bearer '.length).trim();
    if (!token) {
      throw new UnauthorizedError();
    }

    const { data, error } = await this.#supabase.auth.getUser(token);
    if (error || !data?.user) {
      throw new UnauthorizedError();
    }

    request.user = { id: data.user.id, email: data.user.email };
  }
}

export default fp(async function authPlugin(fastify: FastifyInstance) {
  fastify.decorateRequest('user', null);
});
