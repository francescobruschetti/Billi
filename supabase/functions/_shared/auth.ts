import { supabase } from "./supabase.ts";

export type AuthResult = {
  userId: string;
  tokenId: string;
};

async function sha256(text: string): Promise<string> {
  const data = new TextEncoder().encode(text);

  const hashBuffer = await crypto.subtle.digest(
    "SHA-256", data,
  );

  return Array
    .from(new Uint8Array(hashBuffer))
    .map((b) =>
      b.toString(16).padStart(2, "0")
    )
    .join("");
}

export async function authenticateRequest(req: Request): Promise<AuthResult | null> {

  const authHeader = req.headers.get("Authorization");
  if (!authHeader?.startsWith("Bearer ")) {
    return null;
  }

  const token = authHeader.replace("Bearer ", "");
  const tokenHash = await sha256(token);
  const { data, error } = await supabase.rpc(
    "validate_api_token",
    {
      p_token_hash: tokenHash,
    },
  );
  if (error) {
    throw error;
  }

  if (!data?.length) {
    return null;
  }

  return {
    userId: data[0].user_id,
    tokenId: data[0].token_id,
  };
}