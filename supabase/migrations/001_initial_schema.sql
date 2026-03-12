-- ============================================================
-- PROFILES
-- ============================================================
create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text not null,
  full_name text not null,
  role text not null default 'rep' check (role in ('rep', 'admin')),
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

-- Reps can read their own profile
create policy "Users can read own profile"
  on public.profiles for select
  using (auth.uid() = id);

-- Admins can read all profiles
create policy "Admins can read all profiles"
  on public.profiles for select
  using (
    exists (
      select 1 from public.profiles p
      where p.id = auth.uid() and p.role = 'admin'
    )
  );

-- Admins can update profiles (activate/deactivate)
create policy "Admins can update profiles"
  on public.profiles for update
  using (
    exists (
      select 1 from public.profiles p
      where p.id = auth.uid() and p.role = 'admin'
    )
  );

-- Service role can insert profiles (used by create-user Edge Function)
create policy "Service role can insert profiles"
  on public.profiles for insert
  with check (true);

-- ============================================================
-- SUBMISSIONS
-- ============================================================
create table public.submissions (
  id uuid primary key default gen_random_uuid(),
  rep_id uuid not null references public.profiles(id),
  request_type text not null check (request_type in (
    'pps_case_report', 'fedex_label_request', 'bill_only_request',
    'tray_availability', 'delivery_status', 'other'
  )),
  tray_type text,
  surgeon text,
  facility text,
  surgery_date text,
  details text,
  priority text not null default 'normal' check (priority in ('normal', 'urgent')),
  status text not null default 'pending' check (status in (
    'pending', 'in_progress', 'completed', 'cancelled'
  )),
  status_note text,
  source text not null default 'app',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.submissions enable row level security;

-- Reps can read their own submissions
create policy "Reps can read own submissions"
  on public.submissions for select
  using (auth.uid() = rep_id);

-- Reps can insert their own submissions
create policy "Reps can insert own submissions"
  on public.submissions for insert
  with check (auth.uid() = rep_id);

-- Admins can read all submissions
create policy "Admins can read all submissions"
  on public.submissions for select
  using (
    exists (
      select 1 from public.profiles p
      where p.id = auth.uid() and p.role = 'admin'
    )
  );

-- Admins can update all submissions (status changes)
create policy "Admins can update all submissions"
  on public.submissions for update
  using (
    exists (
      select 1 from public.profiles p
      where p.id = auth.uid() and p.role = 'admin'
    )
  );

-- ============================================================
-- SUBMISSION STATUS HISTORY
-- ============================================================
create table public.submission_status_history (
  id uuid primary key default gen_random_uuid(),
  submission_id uuid not null references public.submissions(id) on delete cascade,
  status text not null,
  note text,
  changed_by uuid not null references public.profiles(id),
  created_at timestamptz not null default now()
);

alter table public.submission_status_history enable row level security;

-- Reps can read status history for their own submissions
create policy "Reps can read own submission history"
  on public.submission_status_history for select
  using (
    exists (
      select 1 from public.submissions s
      where s.id = submission_id and s.rep_id = auth.uid()
    )
  );

-- Admins can read all status history
create policy "Admins can read all status history"
  on public.submission_status_history for select
  using (
    exists (
      select 1 from public.profiles p
      where p.id = auth.uid() and p.role = 'admin'
    )
  );

-- Admins can insert status history
create policy "Admins can insert status history"
  on public.submission_status_history for insert
  with check (
    exists (
      select 1 from public.profiles p
      where p.id = auth.uid() and p.role = 'admin'
    )
  );

-- ============================================================
-- NOTIFICATIONS
-- ============================================================
create table public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  submission_id uuid not null references public.submissions(id) on delete cascade,
  title text not null,
  body text not null,
  is_read boolean not null default false,
  created_at timestamptz not null default now()
);

alter table public.notifications enable row level security;

-- Users can read their own notifications
create policy "Users can read own notifications"
  on public.notifications for select
  using (auth.uid() = user_id);

-- Users can update their own notifications (mark as read)
create policy "Users can update own notifications"
  on public.notifications for update
  using (auth.uid() = user_id);

-- Service role can insert notifications (used by Edge Functions)
create policy "Service role can insert notifications"
  on public.notifications for insert
  with check (true);

-- ============================================================
-- AUDIT LOG
-- ============================================================
create table public.audit_log (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.profiles(id),
  action text not null,
  details jsonb,
  created_at timestamptz not null default now()
);

alter table public.audit_log enable row level security;

-- Anyone can insert audit entries
create policy "All users can insert audit log"
  on public.audit_log for insert
  with check (true);

-- Only admins can read audit log
create policy "Admins can read audit log"
  on public.audit_log for select
  using (
    exists (
      select 1 from public.profiles p
      where p.id = auth.uid() and p.role = 'admin'
    )
  );

-- ============================================================
-- PUSH TOKENS
-- ============================================================
create table public.push_tokens (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  token text not null,
  platform text not null check (platform in ('ios', 'android')),
  created_at timestamptz not null default now(),
  unique(user_id, token)
);

alter table public.push_tokens enable row level security;

-- Users can manage their own push tokens
create policy "Users can manage own push tokens"
  on public.push_tokens for all
  using (auth.uid() = user_id);

-- ============================================================
-- TRIGGERS
-- ============================================================

-- Auto-update updated_at on profiles
create or replace function public.update_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger profiles_updated_at
  before update on public.profiles
  for each row execute function public.update_updated_at();

create trigger submissions_updated_at
  before update on public.submissions
  for each row execute function public.update_updated_at();

-- Auto-log status changes to submission_status_history
create or replace function public.log_status_change()
returns trigger as $$
begin
  if old.status is distinct from new.status then
    insert into public.submission_status_history (submission_id, status, note, changed_by)
    values (new.id, new.status, new.status_note, auth.uid());
  end if;
  return new;
end;
$$ language plpgsql security definer;

create trigger submissions_status_change
  after update on public.submissions
  for each row execute function public.log_status_change();

-- Enable Realtime on submissions and notifications tables
alter publication supabase_realtime add table public.submissions;
alter publication supabase_realtime add table public.notifications;
