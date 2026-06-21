import { authenticateRequest } from "../_shared/auth.ts";

import { supabase }from "../_shared/supabase.ts";

import { unauthorized, badRequest, internalServerError, } from "../_shared/responses.ts";

Deno.serve(async (req) => {

  try {
    const auth = await authenticateRequest(req);
    if (!auth) {
      return unauthorized();
    }

    const body = await req.json();
    const text = body.text?.toString().trim();

    if (!text) {
      return badRequest("text is required");
    }

    const { error } = await supabase
      .from("transactions")
      .insert({
        user_id: auth.userId,
        merchant_id: null,
        category_id: null,
        note: "Prova inserimento spesa tramite API",
        total_amount: 123,
        transaction_type: "EXPENSE",
      });

    if (error) {
      throw error;
    }

    return Response.json({
      success: true,
    });

  } 
  catch (e) {
    console.error(e);
    return internalServerError();
  }
});