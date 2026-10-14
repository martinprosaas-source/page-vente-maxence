-- ============================================================
--  Page de vente Maxence Delmas — table des leads
--  À exécuter dans Supabase → SQL Editor → New query → Run
--  (sur le projet Supabase de Maxence, pas sur un autre)
-- ============================================================

create extension if not exists "pgcrypto";

-- ---------- Statut de traitement par les setters ----------
do $$
begin
  if not exists (select 1 from pg_type where typname = 'lead_status') then
    create type lead_status as enum (
      'nouveau',      -- vient d'arriver, personne ne l'a encore pris
      'a_rappeler',   -- tentative faite, pas joint
      'appele',       -- setter a eu la personne au téléphone
      'rdv_pris',     -- appel découverte calé
      'perdu'         -- injoignable ou pas qualifié
    );
  end if;
end $$;

-- ---------- Table ----------
create table if not exists public.leads (
  id           uuid primary key default gen_random_uuid(),
  created_at   timestamptz not null default now(),

  first_name   text not null,
  last_name    text not null,
  email        text not null,
  phone        text not null,

  page_url     text,
  source       text,          -- canal de tracking (?src=) ou referrer

  status       lead_status not null default 'nouveau',
  called_at    timestamptz,   -- quand un setter a appelé
  notes        text,          -- compte rendu de l'appel

  constraint leads_first_name_len check (char_length(first_name) between 1 and 80),
  constraint leads_last_name_len  check (char_length(last_name)  between 1 and 80),
  constraint leads_email_format   check (email ~* '^[^@[:space:]]+@[^@[:space:]]+\.[^@[:space:]]{2,}$'),
  constraint leads_email_len      check (char_length(email) <= 160),
  constraint leads_phone_len      check (char_length(phone) between 9 and 40),
  constraint leads_page_url_len   check (page_url is null or char_length(page_url) <= 300),
  constraint leads_source_len     check (source   is null or char_length(source)   <= 300)
);

create index if not exists leads_created_at_idx on public.leads (created_at desc);
create index if not exists leads_status_idx     on public.leads (status);

-- ============================================================
--  SÉCURITÉ (RLS)
--  La clé "anon" est publique : elle est dans le code de la page.
--  Le public peut donc UNIQUEMENT insérer. Aucune lecture, aucune
--  modification, aucune suppression — sinon n'importe qui pourrait
--  aspirer la liste des leads avec cette clé.
--  La lecture se fait via le dashboard Supabase ou avec la clé
--  service_role (jamais côté navigateur).
-- ============================================================
alter table public.leads enable row level security;
alter table public.leads force row level security;

drop policy if exists "public peut deposer un lead" on public.leads;
create policy "public peut deposer un lead"
  on public.leads
  for insert
  to anon
  with check (
    -- un formulaire ne doit jamais pouvoir préremplir le suivi interne
    status = 'nouveau'
    and called_at is null
    and notes is null
  );

-- Aucune policy select/update/delete pour anon : tout le reste est refusé.

-- Ceinture et bretelles : Supabase accorde par défaut tous les droits
-- sur le schéma public aux rôles anon et authenticated. On ne laisse à
-- anon que l'insertion, la RLS faisant le reste.
revoke all on public.leads from anon, authenticated;
grant insert on public.leads to anon;

-- ---------- Vue pratique pour les setters (dashboard) ----------
-- security_invoker : la vue s'exécute avec les droits de celui qui la
-- lit, donc la RLS de la table s'applique. Sans cette option, une vue
-- créée par postgres contourne la RLS, et comme Supabase accorde le
-- select aux rôles publics, la clé anon de la page suffirait à lire
-- noms, e-mails et téléphones via /rest/v1/leads_a_rappeler.
create or replace view public.leads_a_rappeler
  with (security_invoker = true) as
  select id, created_at, first_name, last_name, phone, email, page_url, source, status
  from public.leads
  where status in ('nouveau', 'a_rappeler')
  order by created_at desc;

revoke all on public.leads_a_rappeler from anon, authenticated;
