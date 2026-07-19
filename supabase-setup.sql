-- ============================================================
-- CRM GARAGE — Script de création de la base Supabase
-- À coller dans : Supabase → SQL Editor → New query → Run
-- ============================================================

-- 1. Profils des utilisateurs (vendeurs + employeur)
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  nom text not null,
  role text not null default 'vendeur' check (role in ('vendeur','employeur')),
  created_at timestamptz default now()
);

-- 2. Clients
create table if not exists public.clients (
  id uuid primary key default gen_random_uuid(),
  nom text not null,
  telephone text,
  email text,
  notes text,
  created_at timestamptz default now()
);

-- 3. Véhicules du parc
create table if not exists public.vehicules (
  id uuid primary key default gen_random_uuid(),
  marque text not null,
  modele text not null,
  annee int,
  prix numeric,
  immat text,
  statut text not null default 'stock' check (statut in ('stock','vendu')),
  created_at timestamptz default now()
);

-- 4. Interactions (échanges vendeur ↔ client)
create table if not exists public.interactions (
  id uuid primary key default gen_random_uuid(),
  vendeur_id uuid not null references public.profiles(id) on delete cascade,
  client_id uuid references public.clients(id) on delete set null,
  vehicule_id uuid references public.vehicules(id) on delete set null,
  canal text not null,
  interet int not null check (interet between 1 and 5),
  statut text not null default 'en_cours' check (statut in ('en_cours','vendu','perdu')),
  commentaire text,
  date_interaction timestamptz not null default now(),
  created_at timestamptz default now()
);

-- 5. Création automatique du profil à l'inscription
--    (le premier compte créé devient automatiquement Employeur)
create or replace function public.handle_new_user()
returns trigger
language plpgsql security definer set search_path = public
as $$
declare
  nb int;
  role_choisi text;
begin
  select count(*) into nb from public.profiles;
  role_choisi := coalesce(new.raw_user_meta_data->>'role', 'vendeur');
  if nb = 0 then role_choisi := 'employeur'; end if;
  insert into public.profiles (id, nom, role)
  values (new.id, coalesce(new.raw_user_meta_data->>'nom', new.email), role_choisi);
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- 6. Sécurité (RLS) : accès réservé aux utilisateurs connectés
alter table public.profiles enable row level security;
alter table public.clients enable row level security;
alter table public.vehicules enable row level security;
alter table public.interactions enable row level security;

create policy "lecture profils" on public.profiles for select to authenticated using (true);
create policy "maj son profil" on public.profiles for update to authenticated using (auth.uid() = id);

create policy "clients tout" on public.clients for all to authenticated using (true) with check (true);
create policy "vehicules tout" on public.vehicules for all to authenticated using (true) with check (true);

create policy "interactions lecture" on public.interactions for select to authenticated using (true);
create policy "interactions creation" on public.interactions for insert to authenticated with check (vendeur_id = auth.uid());
create policy "interactions modification" on public.interactions for update to authenticated
  using (vendeur_id = auth.uid() or exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'employeur'));
create policy "interactions suppression" on public.interactions for delete to authenticated
  using (vendeur_id = auth.uid() or exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'employeur'));
