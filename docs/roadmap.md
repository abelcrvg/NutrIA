# Roadmap do nutrIA

O roadmap acompanha o estado real do produto e separa funcionalidades já implementadas de evoluções planejadas.

## Fase 0 — Fundação

- [x] Criar repositório
- [x] Definir arquitetura inicial
- [x] Definir princípios de segurança
- [ ] Validar schema final do Supabase
- [ ] Validar RLS e acesso via Data API

## Fase 1 — Núcleo do produto

- [x] Auth: cadastro, login e logout
- [x] Onboarding
- [x] Perfil nutricional
- [x] Metas diárias
- [x] Dashboard
- [x] Registro de água
- [x] Histórico/registro de refeições
- [x] Controle de porções e quantidades
- [x] Cálculo de calorias e macronutrientes
- [x] Feedback nutricional específico por alimento e combinação
- [x] Reconhecimento de refeições reais e combinações comuns
- [ ] Ampliar continuamente o catálogo de pratos reais de restaurantes, padarias, lanchonetes, delivery e refeições caseiras

## Fase 2 — Entrada inteligente e análise

- [x] Registro manual por texto
- [x] Sugestões de alimentos durante a digitação
- [x] Normalização de texto e aliases
- [x] Correspondência de combinações alimentares independentemente da ordem dos itens
- [x] Camada inicial de reconhecimento de pratos/refeições reais
- [x] Tela de análise nutricional
- [x] Correção de porções antes do salvamento
- [x] Salvamento da refeição
- [ ] Upload/câmera para análise de imagem
- [ ] Compressão de imagem
- [ ] Entrada por áudio
- [ ] Edge Function para processamento de entradas multimodais
- [ ] Integração com provedor de IA
- [ ] JSON estruturado para identificação de alimentos e pratos
- [ ] Rate limiting e controle de custo

### Princípio da análise

A IA deve ajudar a **entender e estruturar o que o usuário comeu**. A identificação final deve ser cruzada com o catálogo e as regras do nutrIA para gerar feedback consistente e específico.

A prioridade de correspondência deve ser:

1. combinação exata de uma refeição real;
2. combinação exata de alimentos;
3. alimento/prato individual;
4. fallback nutricional genérico.

A ordem em que o usuário informa os itens não deve alterar a combinação reconhecida.

## Fase 3 — Engajamento e Experiência do Usuário (UX)

### Gamificação e Conquistas

- [ ] Streak de dias batendo a meta de água
- [ ] Streak de dias com pontuação alimentar acima de 80
- [ ] Streak de dias registrando todas as refeições
- [ ] Medalhas e conquistas desbloqueáveis
- [ ] Histórico de conquistas e recordes pessoais
- [ ] Feedback visual de progresso sem incentivar metas extremas

### Alertas e Notificações Push Inteligentes

- [ ] Lembrete personalizado para almoço não registrado até 14h
- [ ] Alertas de hidratação baseados na distância até a meta no fim da tarde
- [ ] Lembretes configuráveis pelo usuário
- [ ] Respeitar horários de silêncio e preferências de notificação
- [ ] Evitar notificações excessivas ou repetitivas

### Modo Offline e sincronização

- [ ] Persistência local de refeições e eventos pendentes
- [ ] Avaliar Hive ou Isar para armazenamento local no Flutter
- [ ] Fila de sincronização com o Supabase
- [ ] Sincronização automática quando a conexão retornar
- [ ] Controle de conflitos e idempotência para evitar duplicidade
- [ ] Indicador visual de itens pendentes de sincronização

## Fase 4 — Funcionalidades Nutricionais Avançadas

### Planejamento e geração de cardápios

- [ ] Usuário informar objetivo nutricional, como hipertrofia ou emagrecimento
- [ ] Registrar restrições e preferências alimentares
- [ ] Suporte a perfis como vegetariano e intolerância à lactose
- [ ] Geração de sugestões de refeições para a semana
- [ ] Personalização baseada no histórico alimentar e nos pratos que o usuário costuma consumir
- [ ] Ajuste das sugestões conforme metas e preferências
- [ ] Permitir substituir refeições sugeridas
- [ ] Revisão e confirmação do cardápio antes de salvar

### Lista de compras inteligente

- [ ] Gerar lista de compras a partir do cardápio semanal
- [ ] Consolidar ingredientes repetidos
- [ ] Agrupar itens por categoria
- [ ] Ajustar quantidades conforme número de pessoas/refeições
- [ ] Marcar itens como comprados

### Scanner de código de barras

- [ ] Leitura de código de barras pela câmera
- [ ] Integração com API/base de produtos industrializados
- [ ] Buscar produto por GTIN/EAN
- [ ] Exibir informação nutricional e porção do produto
- [ ] Calcular macros conforme a quantidade consumida
- [ ] Permitir correção manual quando o produto não for encontrado
- [ ] Cache local de produtos consultados

## Fase 5 — Monetização

- [ ] Definir plano Free
- [ ] Definir plano Premium
- [ ] Limites de uso de recursos de IA
- [ ] Stripe Checkout
- [ ] Webhooks
- [ ] Entitlements
- [ ] RevenueCat para compras mobile
- [ ] Tela de assinatura

## Fase 6 — Comunidade

- [ ] Feed
- [ ] Curtidas/reactions
- [ ] Comentários
- [ ] Canais temáticos
- [ ] Moderação
- [ ] Realtime

## Critério para avançar

Cada fase deve ter um fluxo funcional e verificável antes de adicionar complexidade à próxima fase.

Recursos que envolvem sincronização, notificações, IA ou dados externos devem ser validados em fluxo completo antes de serem considerados concluídos.
