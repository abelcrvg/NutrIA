# Scanner de código de barras e validação de produtos

## Objetivo

Permitir que o usuário registre alimentos industrializados pelo código de barras sem depender de cadastro manual completo. Quando o produto não estiver no catálogo, o usuário envia uma foto da tabela nutricional para que o NutrIA extraia, valide e apresente os dados para confirmação.

## Fluxo

1. Usuário abre **Escanear produto**.
2. O app lê o EAN/GTIN pela câmera.
3. O NutrIA procura primeiro o código no catálogo próprio.
4. Se houver produto **validado**, seus dados são exibidos para confirmação e uso na refeição.
5. Se não houver produto validado, o app solicita uma foto clara da tabela nutricional da embalagem.
6. A camada de OCR/IA extrai os campos disponíveis.
7. O sistema executa validações de consistência, incluindo unidades, porção e coerência energética/macronutrientes.
8. O usuário revisa e confirma os dados.
9. A submissão fica registrada como **pendente** até validação.
10. Somente produtos aprovados entram no catálogo compartilhado como `validated`.

## Dados principais

`product_catalog` guarda o produto e seu estado de validação.

`product_submissions` guarda a evidência enviada pelo usuário (foto), dados extraídos e histórico da submissão.

Status do produto:

- `pending`: recebido, ainda não validado;
- `validated`: disponível para uso no catálogo;
- `rejected`: não aprovado.

## Segurança

- Cada submissão pertence ao usuário autenticado que a enviou.
- Usuários autenticados podem consultar produtos validados e suas próprias submissões.
- A foto da tabela deve ficar em Storage com acesso controlado; o caminho do arquivo é registrado na submissão.
- A informação extraída pela IA não deve ser tratada como verdade clínica sem confirmação/validação.

## Integração com o diário alimentar

O código de barras identifica o produto, mas não substitui o motor de análise do NutrIA. Um produto industrializado pode ser combinado com alimentos do catálogo e participar da análise completa da refeição.

Exemplo:

`iogurte escaneado + banana + aveia -> refeição -> análise nutricional NutrIA`

## Próximas etapas técnicas

1. Adicionar leitor EAN/GTIN ao Flutter.
2. Criar tela de resultado do scanner.
3. Criar captura/seleção da foto da tabela.
4. Implementar upload privado da evidência para Supabase Storage.
5. Criar Edge Function para OCR/estruturação dos dados.
6. Implementar validações automáticas.
7. Criar tela de confirmação pelo usuário.
8. Implementar processo de aprovação/rejeição do catálogo.
9. Integrar uma base externa de produtos para ampliar a cobertura, sem substituir o catálogo validado do NutrIA.
