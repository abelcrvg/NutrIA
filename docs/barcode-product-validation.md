# Scanner de código de barras e validação de produtos

## Objetivo

Permitir que o usuário registre alimentos industrializados pelo código de barras. O catálogo oficial só deve conter dados considerados validados pelo NutrIA.

## Fluxo do usuário

1. Usuário abre **Escanear produto**.
2. O app lê o EAN/GTIN pela câmera.
3. O NutrIA procura primeiro o código no catálogo próprio.
4. Se houver produto `validated`, seus dados são exibidos para confirmação e uso na refeição.
5. Se não houver produto validado, o app solicita uma foto clara da tabela nutricional da embalagem.
6. OCR/IA extrai os campos disponíveis e sugere os dados estruturados.
7. O sistema executa validações de consistência, incluindo unidades, porção e coerência energética/macronutrientes.
8. O usuário confere os dados extraídos e envia a submissão.
9. A submissão fica `pending` e não altera o catálogo oficial.
10. Um administrador revisa a foto e os dados no painel web.
11. O administrador pode corrigir os campos, adicionar observações, aprovar ou rejeitar.
12. Somente após aprovação o produto entra no catálogo compartilhado como `validated`.

## Separação entre submissão e catálogo

`product_submissions` é a área de evidência e revisão. Ela contém o EAN, a foto da tabela, os dados extraídos e o estado da análise.

`product_catalog` representa o catálogo oficial consumido pelo aplicativo. Dados enviados por usuários não devem ser tratados como oficiais até a aprovação administrativa.

## Estados

- `pending`: aguardando revisão;
- `validated`: aprovado e disponível para o catálogo;
- `rejected`: recusado;
- o produto pode ser posteriormente revisado ou atualizado pelo fluxo administrativo.

## Painel administrativo

O painel web é separado do aplicativo mobile. Operadores autorizados poderão:

- visualizar submissões pendentes;
- ampliar e conferir a foto da tabela nutricional;
- revisar os dados extraídos pela IA/OCR;
- editar valores e unidades;
- registrar observações;
- aprovar ou rejeitar;
- pesquisar produtos por EAN, nome e marca;
- consultar o catálogo validado;
- acompanhar histórico e estatísticas de submissões.

A autorização administrativa usa `profiles.is_admin` e as políticas RLS do Supabase. O navegador nunca deve receber `service_role` ou outra chave secreta.

## Evidência e qualidade

A foto da tabela nutricional é a evidência principal para novos produtos. A IA serve para acelerar a leitura e estruturação, mas não é a autoridade final. A aprovação humana é responsável por confirmar os dados que entrarão no catálogo oficial.

## Integração com o diário alimentar

O código de barras identifica o produto, mas não substitui o motor de análise do NutrIA. Um produto industrializado pode ser combinado com alimentos e pratos do catálogo e participar da análise completa da refeição.

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
8. Implementar painel administrativo web.
9. Implementar aprovação/rejeição e publicação no catálogo.
10. Integrar uma base externa de produtos para ampliar a cobertura, sem substituir o catálogo validado do NutrIA.
