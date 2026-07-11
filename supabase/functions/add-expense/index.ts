import { authenticateRequest } from "../_shared/auth.ts";

import { supabase }from "../_shared/supabase.ts";

import { unauthorized, badRequest, internalServerError, } from "../_shared/responses.ts";

Deno.serve(async (req) => {

  try {
    const auth = await authenticateRequest(req);

    // DEBUG: Log the current database user
    // const { data } = await supabase.rpc("current_db_user");
    // console.log("Current DB User:", data);

    if (!auth) {
      return unauthorized();
    }

    const body = await req.json();
    // const text = body.text?.toString().trim();
    // if (!text) {
    //   return badRequest("text is required");
    // }

    // TODO: 1. verificare che l'utente sia membro del gruppo

    const { error } = await supabase.rpc('insert_group_transaction_with_merchant_category', {
      'p_group_id': body.groupId,
      'p_user_id': auth.userId,
      'p_paid_amount': body.paidAmount ?? null,
      'p_total_amount': body.price,
      'p_split_rate': body.splitRateEnum ?? null,
      'p_merchant_name': body.merchant ?? null,
      'p_category_name': body.categories ?? null,
      'p_note': body.note ?? null,
      'p_transaction_type': 'EXPENSE',
    }).select().single();
      
    // const { error } = await supabase
    //   .from("transactions")
    //   .insert({
    //     user_id: auth.userId,
    //     merchant_id: null,
    //     category_id: null,
    //     note: "Prova inserimento spesa tramite API",
    //     total_amount: 123,
    //     transaction_type: "EXPENSE",
    //   });

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