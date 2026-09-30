begin;
create schema if not exists extensions;
create extension if not exists pgcrypto with schema extensions;

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null check (char_length(display_name) between 1 and 32 and display_name !~ '[[:cntrl:]]'),
  invite_code text not null unique default upper(encode(extensions.gen_random_bytes(6), 'hex')),
  sharing_enabled boolean not null default false,
  created_at timestamptz not null default now()
);
create table public.friendships (
  id uuid primary key default gen_random_uuid(),
  sender_id uuid not null references public.profiles(id) on delete cascade,
  recipient_id uuid not null references public.profiles(id) on delete cascade,
  status text not null default 'pending' check (status in ('pending','accepted')),
  created_at timestamptz not null default now(),
  check (sender_id <> recipient_id)
);
create unique index friendships_pair on public.friendships(least(sender_id,recipient_id), greatest(sender_id,recipient_id));
create index friendships_recipient on public.friendships(recipient_id);
create index friendships_sender on public.friendships(sender_id);
create table public.blocks (
  owner_id uuid not null references public.profiles(id) on delete cascade,
  blocked_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key(owner_id,blocked_id), check(owner_id <> blocked_id)
);
create table public.day_summaries (
  user_id uuid primary key references public.profiles(id) on delete cascade,
  local_date date not null,
  day_number integer not null check(day_number between 1 and 75),
  completion_percent integer not null check(completion_percent between 0 and 100),
  updated_at timestamptz not null default now()
);
create table public.friend_reports (
  id uuid primary key default gen_random_uuid(),
  reporter_id uuid references auth.users(id) on delete set null,
  reported_id uuid references auth.users(id) on delete set null,
  reason text not null check(reason in ('inappropriate_name','unwanted_contact','other')),
  details text not null default '' check(char_length(details) <= 500),
  created_at timestamptz not null default now()
);
-- Rate records survive canceled requests and reports; never readable by app roles.
create table public.friend_action_limits (
  user_id uuid not null references auth.users(id) on delete cascade,
  action text not null,
  window_start date not null default current_date,
  count integer not null default 0,
  primary key(user_id,action,window_start)
);

alter table public.profiles enable row level security;
alter table public.friendships enable row level security;
alter table public.blocks enable row level security;
alter table public.day_summaries enable row level security;
alter table public.friend_reports enable row level security;
alter table public.friend_action_limits enable row level security;
revoke all on public.profiles,public.friendships,public.blocks,public.day_summaries,public.friend_reports,public.friend_action_limits from anon,authenticated;
-- RPC-only access deliberately avoids leaking invite codes through profile queries.
-- RLS has no direct policies: authenticated users must use the checked functions below.

create function public.glow_require_user() returns uuid language plpgsql stable security invoker set search_path='' as $$
begin
  if auth.uid() is null then raise exception 'Sign in to continue'; end if;
  return auth.uid();
end $$;
create function public.glow_blocked(a uuid,b uuid) returns boolean language sql stable security definer set search_path='' as $$
  select exists(select 1 from public.blocks where (owner_id=a and blocked_id=b) or (owner_id=b and blocked_id=a));
$$;
create function public.glow_rate_limit(action_name text,maximum integer) returns void language plpgsql security definer set search_path='' as $$
declare who uuid := public.glow_require_user(); n integer;
begin
  insert into public.friend_action_limits(user_id,action,count) values(who,action_name,1)
  on conflict(user_id,action,window_start) do update set count=public.friend_action_limits.count+1 returning count into n;
  if n>maximum then raise exception 'Daily limit reached. Please try tomorrow.'; end if;
end $$;

create function public.glow_save_profile(name text) returns void language plpgsql security definer set search_path='' as $$
declare who uuid := public.glow_require_user();
begin
  if char_length(trim(name)) not between 1 and 32 or name ~ '[[:cntrl:]]' or name ~* '(https?://|www\.)' then raise exception 'Choose a name of 1–32 characters without links'; end if;
  insert into public.profiles(id,display_name) values(who,trim(name))
  on conflict(id) do update set display_name=excluded.display_name;
end $$;

create function public.glow_friends_snapshot() returns jsonb language plpgsql stable security definer set search_path='' as $$
declare who uuid:=public.glow_require_user(); result jsonb;
begin
  select jsonb_build_object(
    'profile',(select jsonb_build_object('id',id,'display_name',display_name,'invite_code',invite_code,'sharing_enabled',sharing_enabled) from public.profiles where id=who),
    'connections',coalesce((select jsonb_agg(jsonb_build_object(
      'id',f.id,'person_id',p.id,'display_name',p.display_name,'status',f.status,
      'incoming',f.recipient_id=who,
      'day_number',s.day_number,'completion_percent',s.completion_percent,'local_date',s.local_date
    ) order by f.created_at) from public.friendships f
      join public.profiles p on p.id=case when f.sender_id=who then f.recipient_id else f.sender_id end
      left join public.day_summaries s on s.user_id=p.id and p.sharing_enabled and f.status='accepted'
      where who in (f.sender_id,f.recipient_id) and not public.glow_blocked(who,p.id)), '[]'::jsonb),
    'blocked',coalesce((select jsonb_agg(jsonb_build_object('id',p.id,'display_name',p.display_name)) from public.blocks b join public.profiles p on p.id=b.blocked_id where b.owner_id=who),'[]'::jsonb)
  ) into result;
  return result;
end $$;

create function public.glow_request_friend(code text) returns void language plpgsql security definer set search_path='' as $$
declare who uuid:=public.glow_require_user(); target uuid;
begin
  -- Serialize relationship mutations so block/accept races cannot reopen access.
  perform pg_catalog.pg_advisory_xact_lock(712750);
  perform public.glow_rate_limit('request',20);
  if not exists(select 1 from public.profiles where id=who) then raise exception 'Create your profile first'; end if;
  select id into target from public.profiles where invite_code=upper(trim(code));
  if target is null or target=who or public.glow_blocked(who,target) then raise exception 'This invitation is unavailable'; end if;
  if (select count(*) from public.friendships where who in(sender_id,recipient_id))>=100 then raise exception 'Your circle is full'; end if;
  if (select count(*) from public.friendships where target in(sender_id,recipient_id))>=100 then raise exception 'This invitation is unavailable'; end if;
  insert into public.friendships(sender_id,recipient_id) values(who,target) on conflict do nothing;
end $$;
create function public.glow_respond_friend(connection_id uuid,accept boolean) returns void language plpgsql security definer set search_path='' as $$
declare who uuid:=public.glow_require_user(); row public.friendships;
begin
  -- Serialize relationship mutations so block/accept races cannot reopen access.
  perform pg_catalog.pg_advisory_xact_lock(712750);
  select * into row from public.friendships where id=connection_id and recipient_id=who and status='pending' for update;
  if row.id is null or public.glow_blocked(row.sender_id,who) then raise exception 'Request is no longer available'; end if;
  if accept then update public.friendships set status='accepted' where id=row.id;
  else delete from public.friendships where id=row.id; end if;
end $$;
create function public.glow_remove_friend(connection_id uuid) returns void language plpgsql security definer set search_path='' as $$
declare who uuid:=public.glow_require_user();
begin
  -- Serialize relationship mutations so block/accept races cannot reopen access.
  perform pg_catalog.pg_advisory_xact_lock(712750);
  delete from public.friendships where id=connection_id and who in(sender_id,recipient_id);
end $$;
create function public.glow_block_friend(person_id uuid) returns void language plpgsql security definer set search_path='' as $$
declare who uuid:=public.glow_require_user();
begin
  -- Serialize relationship mutations so block/accept races cannot reopen access.
  perform pg_catalog.pg_advisory_xact_lock(712750);
  if not exists(select 1 from public.friendships where (sender_id=who and recipient_id=person_id) or (sender_id=person_id and recipient_id=who)) then raise exception 'Connection is no longer available'; end if;
  insert into public.blocks(owner_id,blocked_id) values(who,person_id) on conflict do nothing;
  delete from public.friendships where (sender_id=who and recipient_id=person_id) or (sender_id=person_id and recipient_id=who);
end $$;
create function public.glow_unblock_friend(person_id uuid) returns void language plpgsql security definer set search_path='' as $$
begin
  -- Serialize relationship mutations so block/accept races cannot reopen access.
  perform pg_catalog.pg_advisory_xact_lock(712750);
  delete from public.blocks where owner_id=public.glow_require_user() and blocked_id=person_id;
end $$;
create function public.glow_report_friend(person_id uuid,report_reason text,report_details text) returns void language plpgsql security definer set search_path='' as $$
declare who uuid:=public.glow_require_user();
begin
  perform public.glow_rate_limit('report',10);
  if not exists(select 1 from public.friendships where (sender_id=who and recipient_id=person_id) or (sender_id=person_id and recipient_id=who)) and not exists(select 1 from public.blocks where owner_id=who and blocked_id=person_id) then raise exception 'Connection is no longer available'; end if;
  insert into public.friend_reports(reporter_id,reported_id,reason,details) values(who,person_id,report_reason,report_details);
end $$;
create function public.glow_set_sharing(enabled boolean) returns void language plpgsql security definer set search_path='' as $$
declare who uuid:=public.glow_require_user();
begin
  perform 1 from public.profiles where id=who for update;
  if not found then raise exception 'Create your profile first'; end if;
  update public.profiles set sharing_enabled=enabled where id=who;
  if not enabled then delete from public.day_summaries where user_id=who; end if;
end $$;
create function public.glow_publish_summary(summary_date date,summary_day integer,summary_percent integer) returns void language plpgsql security definer set search_path='' as $$
declare who uuid:=public.glow_require_user(); consent boolean;
begin
  select sharing_enabled into consent from public.profiles where id=who for update;
  if consent is not true then raise exception 'Enable sharing first'; end if;
  if summary_date not between current_date-1 and current_date+1 then raise exception 'Only current progress can be shared'; end if;
  insert into public.day_summaries(user_id,local_date,day_number,completion_percent) values(who,summary_date,summary_day,summary_percent)
  on conflict(user_id) do update set local_date=excluded.local_date,day_number=excluded.day_number,completion_percent=excluded.completion_percent,updated_at=now();
end $$;

-- Definer helpers must never be callable directly by untrusted roles.
revoke all on function public.glow_require_user(),public.glow_blocked(uuid,uuid),public.glow_rate_limit(text,integer) from public,anon,authenticated;
revoke all on function public.glow_save_profile(text),public.glow_friends_snapshot(),public.glow_request_friend(text),public.glow_respond_friend(uuid,boolean),public.glow_remove_friend(uuid),public.glow_block_friend(uuid),public.glow_unblock_friend(uuid),public.glow_report_friend(uuid,text,text),public.glow_set_sharing(boolean),public.glow_publish_summary(date,integer,integer) from public,anon;
grant execute on function public.glow_save_profile(text),public.glow_friends_snapshot(),public.glow_request_friend(text),public.glow_respond_friend(uuid,boolean),public.glow_remove_friend(uuid),public.glow_block_friend(uuid),public.glow_unblock_friend(uuid),public.glow_report_friend(uuid,text,text),public.glow_set_sharing(boolean),public.glow_publish_summary(date,integer,integer) to authenticated;
commit;
