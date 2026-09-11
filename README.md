# nutrIA

Aplicativo mobile de acompanhamento alimentar com análise nutricional assistida por IA.

## Visão

O nutrIA combina registro alimentar, estimativas nutricionais por IA, metas diárias, hidratação e, posteriormente, uma comunidade premium de hábitos.

## MVP

1. Autenticação
2. Onboarding nutricional
3. Perfil e metas
4. Scanner de refeição por imagem/texto
5. Análise estruturada pela IA
6. Confirmação/correção da estimativa
7. Histórico de refeições
8. Dashboard diário
9. Registro de água

## Arquitetura

- Mobile: Flutter / FlutterFlow
- Backend: Supabase
- Banco: PostgreSQL
- Auth: Supabase Auth
- Storage: Supabase Storage
- IA: OpenAI API via Edge Function
- Web: Framer/Webflow
- Pagamentos: Stripe + RevenueCat

## Princípios

- Toda informação nutricional produzida por IA é uma **estimativa**, não uma medição clínica.
- O usuário deve poder revisar e corrigir a estimativa antes de salvar.
- Dados pessoais e alimentares devem ser protegidos com RLS.
- Chaves secretas nunca ficam no aplicativo.
- A API da OpenAI será acessada pelo backend, nunca diretamente pelo cliente.

## Estrutura

```text
NutrIA/
├── app/
├── docs/
├── supabase/
│   ├── functions/
│   └── migrations/
└── README.md
```

## Status

**Fase 0 — Fundação do projeto.**

Próximo marco: configurar o banco Supabase e implementar o primeiro fluxo de análise de refeição.
