# Semiose

App (PWA) para quem é da comunicação achar o que ler todo dia: artigos de revistas científicas, ensaios, artigos de opinião e matérias sobre comunicação, semiótica, discurso e linguagem, jornalismo, mídia e imagem. É para ler **além do conteúdo de marketing**: as fontes de mercado publicitário ficam de fora e títulos com cara de dica de venda, SEO ou promoção são filtrados.

**Abrir:** https://oiyuriv.github.io/semiose/
No iPhone: Safari → Compartilhar → *Adicionar à Tela de Início*. No Android: Chrome → três pontinhos → *Instalar app*.

## O que tem

- **Hoje**: a seleção do dia (quantos artigos a pessoa escolheu ler por dia, com um de semiótica sempre que tiver) e o feed, que aprende com as notas, os salvos e o “menos disso”. O feed filtra por formato (artigos científicos, ensaios e opinião, matérias, blogs) e por tema, e cada card mostra o formato. O que já passou pela tela em outro dia não volta.
- **Explorar**: busca, temas, formatos (revistas científicas, ensaios e opinião, revistas e portais, blogs), idiomas e fontes.
- **Salvos**: o que ficou para ler depois e o que já foi lido.
- **Perfil**: nome, interesses, artigos por dia, lembrete diário, tema claro, escuro ou automático, estatísticas de leitura e backup.

Fonte Google Sans, cores no esquema do Material 3. Abre sempre no tema escuro; no Perfil dá para trocar para claro ou automático. No computador vira uma versão web (menu lateral, feed em grade). Tudo o que a pessoa faz fica só no aparelho dela (localStorage).

## Lembretes e avisos

Não há servidor de notificações. Por isso:

- **Lembrete diário pelo calendário** (funciona em qualquer celular): o perfil oferece um evento diário com alarme no horário escolhido. No iPhone e no computador abre `lembrete/HHMM.ics` (gerados por `tools/make-reminders.ps1`, das 6h às 23h30); no Android abre o Google Agenda com o evento repetindo todo dia.
- **Avisos do app** (onde o navegador deixa): com permissão, o número de leituras que faltam aparece no ícone do app; no Android, com o app instalado, o `sw.js` avisa quando a seleção do dia fica pronta (periodicSync, perto do horário escolhido).

Para ter notificação de verdade em qualquer celular com o app fechado, seria preciso um pequeno servidor de push (por exemplo, um Cloudflare Worker ou o OneSignal, que pedem uma conta).

## Como funciona o feed

- `tools/sources.json`: as fontes (revistas científicas do Brasil e de fora via OJS, SciELO e OpenEdition, ensaios, jornalismo e blogs de semiótica). Para incluir ou tirar uma fonte, é só editar esta lista. `kind` diz o formato; `filter` faz um veículo geral só entrar com assunto da área; `aberto` marca plataformas onde qualquer um publica (como o Medium), que passam por um filtro de bordões da extrema-direita. `bloqueados` lista sites de direita, extrema-direita e desinformação que nunca entram, nem como fonte nem como link.
- `tools/build-feed.ps1`: busca os feeds, traduz títulos e resumos de fora para o português, marca os temas, tira o que é marketing e grava `data/feed.json`.
- `.github/workflows/feed.yml`: roda o coletor a cada 2 horas no GitHub Actions e publica o site no GitHub Pages.
- `index.html`: o app inteiro. `sw.js`: funciona sem internet e dá os avisos. `make-icons.ps1`: gera os ícones.

Para testar no Windows: `powershell -File tools/build-feed.ps1` e depois `powershell -File serve.ps1` (porta 8802).
