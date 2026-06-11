# Cards HTML Executivos

## Objetivo

Substituir a fileira atual de seis cards nativos do Power BI por um unico visual
HTML Content responsivo, informativo e orientado a leitura executiva.

Esta etapa altera somente os cards no topo da pagina. Os filtros, graficos,
tabelas e demais secoes do dashboard permanecem fora do escopo.

## Direcao visual

O bloco segue a identidade ja definida no prototipo
`Dashboard_MVP_PowerBI.html`:

- azul-marinho `#14213E` para valores e texto de destaque;
- dourado `#EDB013` como acento superior;
- fundo branco;
- fundo geral claro `#F6F7FA`;
- cinza `#6B7689` para rotulos e textos auxiliares;
- verde `#2F9E68` para desempenho positivo;
- vermelho `#D64550` para alertas;
- tipografia Segoe UI, com Arial como alternativa.

Cada card tera fundo branco, raio de 14 px, borda clara, faixa superior dourada
e sombra discreta. A hierarquia interna sera rotulo, valor principal e contexto
secundario.

## Conteudo

O visual exibira seis indicadores, na ordem atual:

1. Vendas totais, acompanhadas pela quantidade de vendas.
2. Ticket medio, acompanhado pela quantidade de vendas.
3. Variacao em relacao ao ano anterior, acompanhada pelo valor absoluto.
4. Canal lider, acompanhado pela participacao na receita.
5. Regiao lider, acompanhada pela participacao na receita.
6. Regiao de atencao, acompanhada por seu contexto de desempenho.

Valores positivos podem receber verde no texto auxiliar. O card de atencao pode
usar vermelho no texto auxiliar. O dourado permanece como acento estrutural e
nao como cor semantica.

## Implementacao

Uma nova medida DAX em `Medidas.tmdl` montara o HTML e o CSS do conjunto. O
visual HTML Content consumira apenas essa medida.

O visual ocupara a area horizontal dos seis cards existentes:

- inicio: `x = 52`, `y = 90`;
- largura: `1814`;
- altura: `150`.

Os seis visuais `cardVisual` atuais serao removidos depois que o novo visual
estiver definido e validado:

- `4c5815a55bb0c8101b6b`;
- `bb655692b046ca546ace`;
- `fb42910a0d9d905535d0`;
- `24c429908a2a2eaa5cd9`;
- `f9fce7631de990e3b992`;
- `36f0beac11387206013e`.

O bloco sera somente informativo. Ele respondera ao contexto de filtros do
relatorio, mas nao filtrara outros visuais por clique.

## Estados e formatacao

- Valores vazios serao exibidos como travessao.
- Percentuais usarao o formato percentual definido pelas medidas existentes.
- Valores monetarios usarao o formato brasileiro das medidas existentes.
- Textos dinamicos serao tratados no DAX para evitar HTML incompleto.
- O conteudo devera permanecer legivel dentro da altura atual sem rolagem.

## Validacao

A implementacao sera considerada pronta para revisao quando:

- o PBIP continuar com JSON e TMDL validos;
- existir exatamente um visual HTML na area dos cards;
- os seis cards nativos anteriores tiverem sido substituidos;
- a medida HTML referenciar apenas medidas existentes;
- os seis indicadores aparecerem na ordem definida;
- o estilo usar a paleta e a hierarquia desta especificacao;
- nenhuma outra secao ou visual for alterado por esta etapa.

Como a validacao visual final depende do Power BI Desktop, a entrega incluira
tambem verificacoes estruturais automatizadas e indicara o arquivo PBIP que deve
ser aberto para a aprovacao visual.
