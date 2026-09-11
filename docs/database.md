# Modelo de dados inicial

O banco será PostgreSQL via Supabase.

## Entidades do MVP

### profiles
Extensão de `auth.users`. Guarda somente dados de perfil e preferências nutricionais não sensíveis de autorização.

### goals
Metas nutricionais do usuário. Separar metas de perfil permite recalcular/alterar objetivos sem sobrescrever dados históricos.

### meals
Refeições confirmadas pelo usuário, com estimativas nutricionais e ingredientes em JSONB.

### water_logs
Eventos de ingestão de água. O dashboard agrega esses eventos por dia.

### subscriptions
Estado de assinatura sincronizado pelo backend. O cliente não deve decidir sozinho se possui acesso Premium.

### community_posts
Conteúdo público da comunidade. Curtidas e comentários serão entidades separadas para permitir unicidade e auditoria.

## Decisões

- IDs de usuários: UUID de `auth.users`.
- Timestamps: `timestamptz` em UTC.
- Valores nutricionais: `numeric`, não `integer`, para preservar estimativas fracionárias.
- Ingredientes: JSONB no MVP para manter o scanner flexível.
- Imagens: Supabase Storage; o banco guarda apenas o caminho/URL controlado.
- RLS: obrigatório em todas as tabelas do schema exposto.
- Autorização Premium: backend/entitlement, nunca baseada em campo editável pelo usuário.

## Próximo passo

Quando o projeto Supabase estiver criado, aplicar o schema por SQL e executar testes de leitura/escrita com usuários autenticados. A migration definitiva será gerada a partir do estado verificado do banco, em vez de inventar um histórico de migrations local.
