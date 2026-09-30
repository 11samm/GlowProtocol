import { createClient } from 'npm:@supabase/supabase-js@2';
import { SignJWT, importPKCS8, createRemoteJWKSet, jwtVerify } from 'npm:jose@6';

const appleKeys = createRemoteJWKSet(new URL('https://appleid.apple.com/auth/keys'));
const json = (body: unknown, status = 200) => Response.json(body, { status });

// Never trust a user_id supplied in the body. Resolve the caller with Supabase Auth.
Deno.serve(async (req: Request) => {
  if (req.method !== 'POST') return json({ error: 'Method not allowed' }, 405);
  const header = req.headers.get('Authorization') ?? '';
  if (!header.startsWith('Bearer ')) return json({ error: 'Sign in required' }, 401);
  const url = Deno.env.get('SUPABASE_URL');
  const key = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
  if (!url || !key) return json({ error: 'Account deletion is unavailable' }, 503);
  const admin = createClient(url, key, { auth: { persistSession: false, autoRefreshToken: false } });
  const { data: { user }, error } = await admin.auth.getUser(header.slice(7));
  if (error || !user) return json({ error: 'Sign in required' }, 401);
  try {
    const raw = await req.text();
    if (raw.length > 4096) return json({ error: 'Request too large' }, 413);
    const body = JSON.parse(raw || '{}');
    const apple = user.identities?.find((identity) => identity.provider === 'apple');
    if (apple) {
      const code = body.apple_authorization_code;
      if (typeof code !== 'string' || !code || code.length > 2048) return json({ error: 'Confirm with Apple to delete your account' }, 400);
      const clientID = Deno.env.get('APPLE_CLIENT_ID');
      const teamID = Deno.env.get('APPLE_TEAM_ID');
      const keyID = Deno.env.get('APPLE_KEY_ID');
      const privateKey = Deno.env.get('APPLE_PRIVATE_KEY');
      if (!clientID || !teamID || !keyID || !privateKey) return json({ error: 'Apple account deletion is not configured. Contact support.' }, 503);
      const signingKey = await importPKCS8(privateKey.replace(/\\n/g, '\n'), 'ES256');
      const secret = await new SignJWT({}).setProtectedHeader({ alg: 'ES256', kid: keyID })
        .setIssuer(teamID).setSubject(clientID).setAudience('https://appleid.apple.com')
        .setIssuedAt().setExpirationTime('5m').sign(signingKey);
      const tokenResponse = await fetch('https://appleid.apple.com/auth/token', {
        method: 'POST', headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: new URLSearchParams({ client_id: clientID, client_secret: secret, code, grant_type: 'authorization_code' }),
        signal: AbortSignal.timeout(15000),
      });
      if (!tokenResponse.ok) return json({ error: 'Apple confirmation expired. Please try again.' }, 400);
      const tokens = await tokenResponse.json();
      if (typeof tokens.id_token !== 'string') return json({ error: 'Apple confirmation failed' }, 400);
      const { payload } = await jwtVerify(tokens.id_token, appleKeys, { issuer: 'https://appleid.apple.com', audience: clientID });
      const expectedSubject = apple.identity_data?.sub;
      if (typeof expectedSubject !== 'string' || payload.sub !== expectedSubject) return json({ error: 'Confirm using the Apple account linked to this profile' }, 403);
      const revokeToken = tokens.refresh_token ?? tokens.access_token;
      if (typeof revokeToken !== 'string') return json({ error: 'Apple confirmation failed' }, 400);
      const revokeResponse = await fetch('https://appleid.apple.com/auth/revoke', {
        method: 'POST', headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: new URLSearchParams({ client_id: clientID, client_secret: secret, token: revokeToken, token_type_hint: tokens.refresh_token ? 'refresh_token' : 'access_token' }),
        signal: AbortSignal.timeout(15000),
      });
      if (!revokeResponse.ok) return json({ error: 'Apple access could not be revoked. Please retry.' }, 502);
    }
    const { error: deleteError } = await admin.auth.admin.deleteUser(user.id);
    if (deleteError) return json({ error: 'Account deletion could not finish. Please contact support.' }, 500);
    return json({ deleted: true });
  } catch {
    // Do not log tokens, Apple codes, names, or private keys.
    return json({ error: 'Account deletion could not finish. Please retry or contact support.' }, 500);
  }
});
