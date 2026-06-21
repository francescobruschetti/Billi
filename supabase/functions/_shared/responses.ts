export function unauthorized() {
  return Response.json(
    {
      error: "Unauthorized",
    },
    {
      status: 401,
    },
  );
}

export function badRequest(message: string) {
  return Response.json(
    {
      error: message,
    },
    {
      status: 400,
    },
  );
}

export function internalServerError() {
  return Response.json(
    {
      error: "Internal server error",
    },
    {
      status: 500,
    },
  );
}