/**
 * Thrown by handlers. Maps directly onto the `ApiError` schema
 * (`{ message, code }`) shared by the Unauthorized/NotFound/ValidationError
 * responses in openapi.yaml.
 */
export class ApiError extends Error {
  statusCode: number;
  code: string | null;

  constructor(statusCode: number, message: string, code: string | null = null) {
    super(message);
    this.statusCode = statusCode;
    this.code = code;
  }
}

export class NotFoundError extends ApiError {
  constructor(message = 'Resource not found.') {
    // Deliberately identical whether the row doesn't exist or belongs to
    // someone else -- the spec's NotFound response says these are
    // indistinguishable by design, and a distinguishable error would let a
    // caller enumerate other farmers' resource IDs.
    super(404, message, 'not_found');
  }
}

export class BadRequestError extends ApiError {
  constructor(message: string, code: string | null = 'invalid_request') {
    super(400, message, code);
  }
}
