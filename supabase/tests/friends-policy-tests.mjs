// Run with PGLITE_MODULE=/absolute/path/to/pglite/dist/index.js node this-file.
// Production uses pgcrypto; local WASM tests use PostgreSQL's UUID generator for codes.
import { readFile } from 'node:fs/promises';
import assert from 'node:assert/strict';
const { PGlite } = await import(process.env.PGLITE_MODULE ?? '@electric-sql/pglite');
const db = new PGlite();
const a='11111111-1111-1111-1111-111111111111';
const b='22222222-2222-2222-2222-222222222222';
const c='33333333-3333-3333-3333-333333333333';
await db.exec(`create role anon; create role authenticated; create schema auth; create schema extensions;
create table auth.users(id uuid primary key);
create function auth.uid() returns uuid language sql stable as $$select nullif(current_setting('request.jwt.claim.sub',true),'')::uuid$$;
grant usage on schema auth to authenticated,anon; grant execute on function auth.uid() to authenticated,anon;
create function extensions.gen_random_bytes(n integer) returns bytea language sql as $$select decode(left(replace(gen_random_uuid()::text,'-',''),n*2),'hex')$$;
insert into auth.users values('${a}'),('${b}'),('${c}');`);
const sql=await readFile(new URL('../migrations/202609300001_friends.sql',import.meta.url),'utf8');
await db.exec(sql.replace('create extension if not exists pgcrypto with schema extensions;',''));
async function asUser(id,query,params=[]) {
  await db.exec('reset role');
  await db.query("select set_config('request.jwt.claim.sub',$1,false)",[id??'']);
  await db.exec(`set role ${id?'authenticated':'anon'}`);
  return db.query(query,params);
}
async function snapshot(id) { return (await asUser(id,'select public.glow_friends_snapshot() as data')).rows[0].data; }
async function denied(id,query,params=[]) {
  let failed=false;try{await asUser(id,query,params)}catch{failed=true}assert.ok(failed,query);
}
await denied(null,'select public.glow_friends_snapshot()');
await asUser(a,"select public.glow_save_profile('Ava')");
await asUser(b,"select public.glow_save_profile('Ruby')");
await asUser(c,"select public.glow_save_profile('Stranger')");
const code=(await snapshot(a)).profile.invite_code;
assert.equal(code.length,12);
await denied(b,'select * from public.profiles');
await denied(b,'select * from public.day_summaries');
await denied(b,'select public.glow_blocked($1,$2)',[a,b]);
await denied(b,"select public.glow_publish_summary(current_date,1,50)");
await asUser(a,'select public.glow_set_sharing(true)');
await asUser(a,'select public.glow_publish_summary(current_date,12,75)');
assert.equal((await snapshot(c)).connections.length,0);
await asUser(b,'select public.glow_request_friend($1)',[code]);
let pending=(await snapshot(a)).connections[0];
assert.equal(pending.status,'pending');assert.equal(pending.day_number,null);
await denied(b,'select public.glow_respond_friend($1,true)',[pending.id]);
await asUser(a,'select public.glow_respond_friend($1,true)',[pending.id]);
let connected=(await snapshot(b)).connections[0];
assert.equal(connected.completion_percent,75);
assert.equal(connected.day_number,12);
assert.equal(connected.invite_code,undefined);
await denied(c,'select public.glow_respond_friend($1,true)',[pending.id]);
await asUser(a,'select public.glow_set_sharing(false)');
assert.equal((await snapshot(b)).connections[0].completion_percent,null);
await db.exec('reset role');
assert.equal((await db.query('select count(*)::int as n from public.day_summaries')).rows[0].n,0);
await asUser(a,'select public.glow_set_sharing(true)');
await asUser(a,'select public.glow_publish_summary(current_date,13,50)');
await asUser(b,'select public.glow_block_friend($1)',[a]);
assert.equal((await snapshot(a)).connections.length,0);
assert.equal((await snapshot(b)).blocked.length,1);
await denied(a,'select public.glow_request_friend($1)',[(await snapshot(b)).profile.invite_code]);
await asUser(b,'select public.glow_unblock_friend($1)',[a]);
assert.equal((await snapshot(b)).connections.length,0); // Unblock does not reconnect.
await asUser(b,'select public.glow_request_friend($1)',[code]);
pending=(await snapshot(a)).connections[0];
await asUser(a,'select public.glow_respond_friend($1,true)',[pending.id]);
await asUser(b,"select public.glow_report_friend($1,'unwanted_contact','')",[a]);
await denied(a,'select * from public.friend_reports');
await asUser(b,'select public.glow_remove_friend($1)',[pending.id]);
assert.equal((await snapshot(a)).connections.length,0);
await denied(a,'select public.glow_save_profile($1)',['https://spam.example']);
await denied(a,'select public.glow_publish_summary(current_date,76,50)');
await denied(a,'select public.glow_publish_summary(current_date,12,101)');
await denied(a,'select public.glow_publish_summary(current_date-10,12,50)');
await db.exec('reset role');
await db.query('delete from auth.users where id=$1',[a]);
assert.equal((await db.query('select count(*)::int as n from public.profiles where id=$1',[a])).rows[0].n,0);
assert.equal((await db.query('select count(*)::int as n from public.day_summaries where user_id=$1',[a])).rows[0].n,0);
assert.equal((await db.query('select reported_id from public.friend_reports')).rows[0].reported_id,null);
console.log('PASS: anonymous/direct reads denied; acceptance, sharing revocation, blocks, reports, validation, deletion cascades.');
await db.close();
