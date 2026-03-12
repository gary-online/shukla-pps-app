import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req: Request) => {
  const { record, old_record } = await req.json()

  // Only trigger if status actually changed
  if (record.status === old_record.status) {
    return new Response(JSON.stringify({ skipped: true }), {
      headers: { 'Content-Type': 'application/json' },
    })
  }

  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
  )

  const statusLabel = record.status.replace(/_/g, ' ')
  const requestTypeLabel = record.request_type.replace(/_/g, ' ')

  // Create in-app notification for the rep
  await supabase.from('notifications').insert({
    user_id: record.rep_id,
    submission_id: record.id,
    title: 'Status Updated',
    body: `Your ${requestTypeLabel} was marked ${statusLabel}`,
  })

  // TODO: Send FCM push notification to rep's device
  // Requires: fetch push_tokens for record.rep_id, send via FCM HTTP v1 API

  return new Response(JSON.stringify({ success: true }), {
    headers: { 'Content-Type': 'application/json' },
  })
})
