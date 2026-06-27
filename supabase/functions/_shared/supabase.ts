import { createClient } from "jsr:@supabase/supabase-js@2";

export const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
);

// DEBUG
// console.log("SUPABASE_URL", Deno.env.get("SUPABASE_URL"));
// console.log(
//   "SERVICE_ROLE_KEY exists",
//   !!Deno.env.get("SUPABASE_SERVICE_ROLE_KEY"),
// );