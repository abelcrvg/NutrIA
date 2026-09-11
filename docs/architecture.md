# Arquitetura do nutrIA

## Visão geral

```text
Flutter / FlutterFlow
        |
        | HTTPS + Supabase client
        v
Supabase Auth ---- PostgreSQL + RLS
        |                 |
        |                 +-- profiles
        |                 +-- meals
        |                 +-- water_logs
        |                 +-- goals
        |                 +-- subscriptions
        |                 +-- community
        |
        +---- Storage (meal images)
        |
        +---- Edge Function: analyze-meal
                         |
                         v
                    OpenAI API
```

## Regra de segurança

O aplicativo cliente usa somente a chave pública/publishable do Supabase. Chaves secretas, especialmente a chave da OpenAI e credenciais administrativas, permanecem no backend/Edge Functions.

## Fluxo principal do MVP

1. Usuário autentica.
2. App carrega perfil e metas.
3. Usuário envia foto ou descrição da refeição.
4. App envia o conteúdo para `analyze-meal`.
5. A Edge Function valida a sessão e chama a OpenAI.
6. A função retorna um JSON estruturado de estimativa.
7. Usuário revisa/corrige os alimentos e porções.
8. App salva a refeição confirmada em `meals`.
9. Dashboard agrega as refeições do dia.

## IA

A IA deve produzir **estimativas**. O sistema não deve apresentar valores como medição exata. A interface deve permitir correção manual das porções antes do salvamento.

## Dados e autorização

Todas as tabelas expostas ao cliente devem ter RLS habilitado. As políticas devem limitar registros privados ao usuário autenticado correspondente. Conteúdo público da comunidade terá políticas específicas, separadas das tabelas privadas.

## Data API

Novos projetos Supabase não devem presumir exposição automática das tabelas do schema `public`. A exposição e os grants necessários serão configurados explicitamente quando o projeto Supabase for conectado.
