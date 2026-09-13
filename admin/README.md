# NutrIA Admin

Painel administrativo **web** separado do aplicativo mobile do NutrIA.

## Como funciona

O administrador acessa o site, entra com uma conta do Supabase Auth e só recebe acesso se `profiles.is_admin = true`.

### Fluxo de revisão

1. Usuário envia EAN + foto da tabela nutricional.
2. A submissão entra em `product_submissions` como `pending`.
3. OCR/IA poderá extrair os dados para facilitar a revisão.
4. O administrador confere a imagem e os valores.
5. Pode editar os campos necessários.
6. Aprova ou rejeita a submissão.
7. Ao aprovar, o produto entra em `product_catalog` com `validation_status = validated`.

## Painel atual

- Login administrativo.
- Dashboard com pendências, total de submissões e produtos validados.
- Lista de produtos pendentes.
- Tela individual de revisão.
- Edição dos dados nutricionais extraídos.
- Aprovação e publicação no catálogo.
- Rejeição com observações.
- Controle de acesso por `profiles.is_admin` + RLS.

## Estrutura

`nutria/mobile` continua sendo o aplicativo dos usuários.

`nutria/admin` é uma aplicação **Next.js** independente, preparada para ser publicada como um site próprio, por exemplo em um domínio como `admin.nutria.app`.

## Configuração local

```bash
cd admin
cp .env.example .env.local
npm install
npm run dev
```

As variáveis necessárias são:

- `NEXT_PUBLIC_SUPABASE_URL`
- `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY`

Apenas a chave **publishable** é usada no navegador. `service_role` nunca deve ser colocada no Admin.

## Deploy

O projeto pode ser publicado em Vercel, Netlify ou outro host compatível com Next.js. Configure as duas variáveis de ambiente no serviço de hospedagem.

## Segurança

O navegador acessa o Supabase usando a chave publishable. A autorização real é feita pelo Supabase Auth + RLS; a interface não é considerada uma barreira de segurança.

Nenhuma chave `service_role` deve ser colocada no navegador.

## Próximas etapas

- Bucket privado para fotos das tabelas nutricionais.
- URLs assinadas para exibir as evidências no painel.
- Busca e catálogo validado.
- Histórico de validações.
- Estatísticas operacionais.
- OCR/IA para pré-preenchimento.
