'use client';

import { FormEvent, useEffect, useState } from 'react';
import { supabase } from '../lib/supabase';

export default function Home() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  useEffect(() => {
    supabase.auth.getSession().then(({ data }) => {
      if (data.session) window.location.href = '/dashboard';
    });
  }, []);

  async function login(event: FormEvent) {
    event.preventDefault();
    setLoading(true); setError('');
    const { data, error } = await supabase.auth.signInWithPassword({ email, password });
    if (error || !data.user) {
      setError(error?.message ?? 'Não foi possível entrar.');
      setLoading(false);
      return;
    }
    const { data: profile } = await supabase.from('profiles').select('is_admin').eq('id', data.user.id).maybeSingle();
    if (!profile?.is_admin) {
      await supabase.auth.signOut();
      setError('Esta conta não possui acesso administrativo.');
      setLoading(false);
      return;
    }
    window.location.href = '/dashboard';
  }

  return <main className="login"><form className="loginbox" onSubmit={login}>
    <div className="brand">Nutr<span>IA</span> Admin</div>
    <h1 style={{marginTop:28}}>Entrar no painel</h1>
    <p className="muted">Acesso restrito a administradores.</p>
    {error && <div className="error">{error}</div>}
    <div className="field"><label>E-mail</label><input type="email" value={email} onChange={e=>setEmail(e.target.value)} required autoComplete="email" /></div>
    <div className="field"><label>Senha</label><input type="password" value={password} onChange={e=>setPassword(e.target.value)} required autoComplete="current-password" /></div>
    <button className="btn" style={{width:'100%',marginTop:8}} disabled={loading}>{loading ? 'Entrando…' : 'Entrar'}</button>
  </form></main>;
}
