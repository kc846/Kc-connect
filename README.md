# KC CONNECT — MVP inicial

## O que esta versão já demonstra
- Loja pública responsiva com identidade preta/dourada.
- Configurador com seleção múltipla de funções.
- Cálculo automático de preço conforme a tabela inicial.
- Registro local de pedidos no navegador.
- Encaminhamento do resumo do pedido para o WhatsApp comercial.
- Área demonstrativa do cliente.
- Painel demonstrativo com lista/status de pedidos e edição de preços.

## Limitações importantes desta primeira entrega
Esta é uma **demonstração funcional local**, não um sistema pronto para produção:
- Os dados ficam no `localStorage` do navegador e não sincronizam entre aparelhos.
- Login de cliente e senha do administrador são apenas demonstrações, não autenticação real.
- Não há pagamento online, emissão fiscal ou envio automático de mensagens.
- Não grave links NFC reais até publicar a página individual em um domínio HTTPS.
- Não use informações pessoais ou pedidos reais nesta demonstração.

## Como testar
1. Extraia o ZIP.
2. Abra `index.html` em um navegador.
3. Faça um pedido de teste com nome e WhatsApp fictícios.
4. O pedido será salvo no navegador e o WhatsApp abrirá com a mensagem preenchida.
5. Para testar o painel, use a senha demonstrativa `admin123`.
6. Na aba Preços, altere os valores e salve.

## Próxima etapa para virar sistema real
1. Criar um projeto Supabase.
2. Executar `supabase/schema.sql` no SQL Editor.
3. Integrar Supabase Auth à loja, área do cliente e administração.
4. Substituir o armazenamento local por tabelas protegidas por RLS.
5. Criar rotas públicas `/p/slug` para as páginas digitais.
6. Publicar em hospedagem HTTPS e só então gravar as URLs em NFC/QR.

## Preços padrão
- Placa base: R$ 49,90
- Quatro funções incluídas
- Função adicional: R$ 8,00
- Modelo transparente: + R$ 10,00

WhatsApp comercial configurado: +55 98 98488-7267
