-- Ejecutar completo en Supabase > SQL Editor
create extension if not exists pgcrypto;
create table public.participants(
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
 name text not null check(char_length(trim(name)) between 1 and 60),
 pays boolean not null default true,
 fare_per_trip numeric(8,2) not null default 2.50 check(fare_per_trip>=0),
 archived boolean not null default false,
 created_at timestamptz not null default now(),
 unique(id,user_id)
);
create table public.trip_entries(
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
 participant_id uuid not null,
 trip_date date not null,
 direction text not null check(direction in ('ida','vuelta','ida_vuelta')),
 fare_applied numeric(8,2) not null default 0 check(fare_applied>=0),
 created_at timestamptz not null default now(),
 unique(participant_id,trip_date),
 foreign key(participant_id,user_id) references public.participants(id,user_id) on delete restrict
);
create index participants_user_idx on public.participants(user_id);
create index trip_entries_user_date_idx on public.trip_entries(user_id,trip_date);
alter table public.participants enable row level security;
alter table public.trip_entries enable row level security;
create policy "own participants" on public.participants for all using(auth.uid()=user_id) with check(auth.uid()=user_id);
create policy "own trips" on public.trip_entries for all using(auth.uid()=user_id) with check(auth.uid()=user_id);
