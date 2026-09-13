# nutrIA

Aplicativo mobile de acompanhamento alimentar com análise nutricional assistida por IA.

## Visão

O nutrIA é um **diário alimentar inteligente**: o usuário registra o que comeu, o sistema identifica alimentos, pratos e combinações reais, estima os valores nutricionais e apresenta feedback específico para aquela refeição.

O produto combina:

- registro alimentar;
- análise de calorias e macronutrientes;
- feedback nutricional específico por prato e combinação;
- hidratação e metas diárias;
- reconhecimento inteligente de refeições reais;
- futuramente, IA multimodal, gamificação, notificações, modo offline, planejamento de cardápios, lista de compras e scanner de código de barras.

## Estado atual

O núcleo do aplicativo já possui autenticação, onboarding, perfil/metas, dashboard, registro de água, registro manual de refeições, controle de porções, cálculo nutricional, feedback por combinações e uma camada inicial de reconhecimento de refeições reais.

A documentação do projeto mantém separadas as funcionalidades implementadas das funcionalidades planejadas. Consulte `docs/roadmap.md` para o plano completo.

## Produto

### Entrada alimentar

O usuário poderá informar refeições de forma natural, como:

> "Comi um X-tudo com batata e Coca-Cola."

O objetivo é reconhecer a refeição como uma unidade quando houver correspondência no catálogo, em vez de exigir que cada ingrediente seja cadastrado manualmente.

O catálogo deve evoluir para representar refeições encontradas no mundo real: restaurantes, lanchonetes, padarias, delivery, fast-food, culinária japonesa, restaurantes por quilo, marmitas e preparações caseiras.

### Motor nutricional

A análise segue uma hierarquia de correspondência:

1. refeição real/combo específico;
2. combinação específica de alimentos;
3. alimento ou prato individual;
4. fallback nutricional.

Combinações são **canônicas e independentes da ordem** dos itens informados.

A IA não deve inventar o feedback nutricional a cada registro. Ela será usada principalmente para interpretar e estruturar entradas; o catálogo e as regras do nutrIA fornecem os dados e feedbacks consistentes.

## Funcionalidades planejadas

### Engajamento e UX

- Gamificação com streaks e medalhas;
- conquistas por meta de água, pontuação alimentar e registro completo das refeições;
- notificações push inteligentes e personalizadas;
- modo offline com armazenamento local e sincronização posterior com o Supabase.

### Nutrição avançada

- planejamento semanal de refeições;
- geração de cardápios considerando objetivo, restrições e preferências;
- personalização baseada no histórico alimentar;
- lista de compras gerada a partir do cardápio;
- scanner de código de barras para produtos industrializados;
- integração com base/API de produtos e cálculo dos macros conforme a quantidade consumida.

## Arquitetura

- **Mobile:** Flutter
- **Backend:** Supabase
- **Banco:** PostgreSQL
- **Auth:** Supabase Auth
- **Storage:** Supabase Storage
- **IA:** provedor externo via Edge Function/backend, nunca diretamente no aplicativo
- **Pagamentos:** Stripe + RevenueCat (planejado)
- **Armazenamento offline:** Hive ou Isar (a definir)

## Princípios

- Toda informação nutricional produzida por IA é uma **estimativa**, não uma medição clínica.
- O usuário deve poder revisar e corrigir alimentos e porções antes de salvar quando houver estimativa automática.
- Dados pessoais e alimentares devem ser protegidos com RLS.
- Chaves secretas nunca ficam no aplicativo.
- APIs externas com credenciais privadas devem ser acessadas pelo backend/Edge Functions.
- Recursos offline devem usar sincronização idempotente para evitar duplicação de registros.
- Notificações devem ser úteis, configuráveis e não excessivas.

## Estrutura

```text
NutrIA/
├── mobile/
├── docs/
├── supabase/
│   ├── functions/
│   └── migrations/
└── README.md
```

## Documentação

- `docs/roadmap.md` — fases, funcionalidades e critérios de conclusão.
- `docs/architecture.md` — arquitetura e regras técnicas.
- `docs/database.md` — modelo de dados.
- `docs/nutrition-feedback.md` — princípios do feedback nutricional.
- `docs/meal-combinations.md` e batches — catálogo de combinações e feedbacks.
- `docs/meal-matching.md` — correspondência de refeições.
