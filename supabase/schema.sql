-- Disciplina v0.2 — Supabase PostgreSQL
-- Execute no SQL Editor do seu projeto Supabase.
create extension if not exists pgcrypto;

create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin new.updated_at = now(); return new; end; $$;

create table if not exists public.tasks (
  id uuid primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null check (char_length(title) between 1 and 200),
  category text not null default 'Outros',
  description text not null default '',
  task_date date not null,
  start_at time,
  end_at time,
  status text not null default 'pending' check (status in ('pending','in_progress','done','partial','skipped')),
  kind text not null default 'extra' check (kind in ('scheduled','extra')),
  source text not null default 'manual' check (source in ('manual','google')),
  google_event_id text,
  google_html_link text,
  calendar_dirty boolean not null default false,
  completion_note text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);
create unique index if not exists tasks_user_google_event on public.tasks(user_id,google_event_id) where google_event_id is not null;
create index if not exists tasks_user_date on public.tasks(user_id,task_date);

create table if not exists public.logs (
  id uuid primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  log_date date not null,
  category text not null,
  duration_minutes integer not null default 0 check (duration_minutes >= 0),
  activity text not null,
  result text not null default '',
  next_step text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists logs_user_date on public.logs(user_id,log_date);

create table if not exists public.ideas (
  id uuid primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  idea_date date not null,
  category text not null default 'Matemática',
  title text not null,
  content text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists ideas_user_date on public.ideas(user_id,idea_date desc);

create table if not exists public.goals (
  id uuid primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  category text not null,
  target numeric not null check (target > 0),
  unit text not null default 'sessões',
  period text not null default 'weekly' check (period in ('weekly','monthly')),
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.journal (
  id uuid primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  journal_date date not null,
  done text not null default '',
  obstacles text not null default '',
  tomorrow text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(user_id,journal_date)
);

-- Row Level Security: cada conta só lê/escreve suas próprias linhas.
do $$ declare t text; begin
  foreach t in array array['tasks','logs','ideas','goals','journal'] loop
    execute format('alter table public.%I enable row level security',t);
    execute format('drop policy if exists %I on public.%I','Users manage own '||t,t);
    execute format('create policy %I on public.%I for all to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id)','Users manage own '||t,t);
    execute format('drop trigger if exists %I on public.%I',t||'_set_updated_at',t);
    execute format('create trigger %I before update on public.%I for each row execute function public.set_updated_at()',t||'_set_updated_at',t);
    execute format('grant select, insert, update, delete on public.%I to authenticated',t);
  end loop;
end $$;
