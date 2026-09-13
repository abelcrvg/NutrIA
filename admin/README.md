# NutrIA Admin

Painel administrativo do NutrIA para operação e validação do catálogo de produtos.

## Objetivo

O Admin é separado do aplicativo mobile. Ele permite que operadores autorizados revisem produtos enviados pelos usuários, confiram a foto da tabela nutricional, corrijam os dados extraídos e aprovem ou rejeitem o cadastro.

## Fluxo de revisão

1. Usuário envia EAN + foto da tabela nutricional.
2. A submissão entra em `product_submissions` como pendente.
3. OCR/IA poderá extrair os dados para facilitar a revisão.
4. O administrador confere a imagem e os valores.
5. Pode editar os campos necessários.
6. Aprova ou rejeita a submissão.
7. Produtos aprovados ficam disponíveis em `product_catalog` com `validation_status = validated`.

## Áreas previstas

- Dashboard operacional
- Produtos pendentes
- Tela de revisão
- Catálogo validado
- Busca por EAN, produto e marca
- Histórico de validação
- Observações do revisor
- Estatísticas de submissões

## Segurança

O acesso administrativo é controlado pelo campo `profiles.is_admin`. O usuário comum não recebe permissão para aprovar ou alterar o catálogo oficial.

O Admin deve usar somente sessão autenticada e as políticas RLS do Supabase. Nenhuma chave `service_role` deve ser colocada no navegador.

## Estado atual

A base de dados para catálogo e submissões já existe e o controle administrativo foi preparado no Supabase. A interface web será implementada em uma etapa separada.
