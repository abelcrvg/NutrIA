'use client';

import Link from 'next/link';
import { useEffect, useState } from 'react';
import { supabase } from '../../lib/supabase';

type Submission = { id:string; barcode:string; product_name?:string|null; status:string; created_at:string; photo_path?:string|null; };

export default function Dashboard() {
  const [submissions,setSubmissions]=useState<Submission[]>([]);
  const [total,setTotal]=useState(0);
  const [validated,setValidated]=useState(0);
  const [email,setEmail]=useState('');
  const [loading,setLoading]=useState(true);
  const [error,setError]=useState('');

  async function load() {
    const {data:{session}}=await supabase.auth.getSession();
    if(!session){window.location.href='/';return;}
    setEmail(session.user.email ?? '');
    const {data:profile}=await supabase.from('profiles').select('is_admin').eq('id',session.user.id).maybeSingle();
    if(!profile?.is_admin){await supabase.auth.signOut();window.location.href='/';return;}
    const pending=await supabase.from('product_submissions').select('id,barcode,product_name,status,created_at,photo_path').eq('status','pending').order('created_at',{ascending:false}).limit(100);
    if(pending.error){setError(pending.error.message);} else setSubmissions((pending.data ?? []) as Submission[]);
    const counts=await Promise.all([
      supabase.from('product_submissions').select('id',{count:'exact',head:true}),
      supabase.from('product_catalog').select('id',{count:'exact',head:true}).eq('validation_status','validated'),
    ]);
    setTotal(counts[0].count ?? 0); setValidated(counts[1].count ?? 0); setLoading(false);
  }
  useEffect(()=>{load();},[]);
  async function logout(){await supabase.auth.signOut();window.location.href='/';}
  if(loading)return <main className="content"><p>Carregando painel…</p></main>;
  return <div className="shell"><header className="topbar"><div className="brand">Nutr<span>IA</span> Admin</div><div className="userbar">{email}<button className="btn secondary" onClick={logout}>Sair</button></div></header>
    <main className="content"><h1 className="title">Dashboard</h1><p className="muted">Operação e validação do catálogo de produtos.</p>
      {error&&<div className="error">{error}</div>}
      <section className="cards"><div className="card"><div className="muted">Pendentes</div><div className="metric">{submissions.length}</div></div><div className="card"><div className="muted">Submissões totais</div><div className="metric">{total}</div></div><div className="card"><div className="muted">Produtos validados</div><div className="metric">{validated}</div></div></section>
      <section className="card"><h2 className="section-title">Produtos aguardando revisão</h2>{submissions.length===0?<div className="empty">Nenhuma submissão pendente.</div>:<table className="table"><thead><tr><th>Produto</th><th>EAN</th><th>Status</th><th>Recebido</th><th></th></tr></thead><tbody>{submissions.map(s=><tr key={s.id}><td>{s.product_name||'Produto sem nome'}</td><td>{s.barcode}</td><td><span className="badge">Pendente</span></td><td>{new Date(s.created_at).toLocaleString('pt-BR')}</td><td><Link className="btn" href={`/review/${s.id}`}>Revisar</Link></td></tr>)}</tbody></table>}</section>
    </main></div>;
}
