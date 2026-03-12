import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req: Request) => {
  const { record } = await req.json() // Database webhook payload

  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
  )

  // Get the rep's name
  const { data: profile } = await supabase
    .from('profiles')
    .select('full_name')
    .eq('id', record.rep_id)
    .single()

  const repName = profile?.full_name ?? 'Unknown'

  // 1. Send Google Chat notification
  const webhookUrl = Deno.env.get('GOOGLE_CHAT_WEBHOOK_URL')
  if (webhookUrl) {
    const widgets = []
    if (record.tray_type) widgets.push({ keyValue: { topLabel: 'Tray Type', content: record.tray_type } })
    if (record.surgeon) widgets.push({ keyValue: { topLabel: 'Surgeon', content: record.surgeon } })
    if (record.facility) widgets.push({ keyValue: { topLabel: 'Facility', content: record.facility } })
    if (record.surgery_date) widgets.push({ keyValue: { topLabel: 'Surgery Date', content: record.surgery_date } })
    widgets.push({ keyValue: { topLabel: 'Priority', content: record.priority.toUpperCase() } })
    if (record.details) widgets.push({ textParagraph: { text: `<b>Details:</b> ${record.details}` } })

    await fetch(webhookUrl, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        cards: [{
          header: { title: `New ${record.request_type}`, subtitle: `From: ${repName}` },
          sections: [{ widgets }],
        }],
      }),
    })
  }

  // 2. Send Gmail notification (via Gmail API — requires OAuth credentials in env)
  // TODO: Implement Gmail notification matching email_service.py format

  // 3. Create in-app notifications for all admins
  const { data: admins } = await supabase
    .from('profiles')
    .select('id')
    .eq('role', 'admin')
    .eq('is_active', true)

  if (admins && admins.length > 0) {
    const notifications = admins.map((admin: { id: string }) => ({
      user_id: admin.id,
      submission_id: record.id,
      title: 'New Submission',
      body: `${repName} submitted a ${record.request_type.replace(/_/g, ' ')}`,
    }))

    await supabase.from('notifications').insert(notifications)
  }

  return new Response(JSON.stringify({ success: true }), {
    headers: { 'Content-Type': 'application/json' },
  })
})
