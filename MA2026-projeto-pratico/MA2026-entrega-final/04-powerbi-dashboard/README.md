# Etapa V – Dashboard no Power BI (`MetroClima`)

## Objetivo
Painel de três páginas que responde à pergunta central do MetroClima: como se distribui a demanda das Linhas 1-Azul, 2-Verde, 3-Vermelha e 15-Prata, como ela se compara ao esperado e de que forma a chuva altera a demanda e a ocorrência de quedas atípicas.

## Fonte e conexão
- Banco: `../05-sql/metroclima.db` (SQLite), via ODBC.
- Driver: SQLite3 ODBC Driver 64 bits; DSN de usuário `metroclima`; parâmetro `pConexaoODBC` (`m/pConexaoODBC.pq`).
- Importado: views `dim_estacao`, `dim_tempo`, `dim_clima` (de `clima_diario`, filtrada em São Paulo) e `fato_entradas`.
- Modo: Importar. Nenhum dado digitado no Power BI.
- Versão do Power BI Desktop: _(preencher: Ajuda → Sobre)_

## Como abrir em outro computador
1. Instalar o driver ODBC 64 bits e criar a DSN `metroclima` apontando para o seu clone de `05-sql/metroclima.db` (marcar *No Creat*).
2. Fechar o DB Browser for SQLite.
3. Abrir `MetroClima_Dashboard.pbix` → *Página Inicial → Atualizar*.

## Estrutura
| Pasta/arquivo | Conteúdo |
|---|---|
| `MetroClima_Dashboard.pbix` / `.pdf` | Painel e exportação |
| `m/` | Código M: `pConexaoODBC`, `tst_Conexao`, `dim_estacao`, `dim_tempo`, `dim_clima`, `fato_entradas` |
| `dax/medidas_finais.dax` | Todas as medidas (formato DEFINE MEASURE) |
| `dax/validacao.dax` | Consultas DAX de batimento com K1, K4 e C1–C5 |
| `tema/tema_metroclima.json` | Tema (cores das linhas do Metrô) |
| `docs/modelo_powerbi.md` | Tabelas, relacionamentos R1–R3, decisões |
| `docs/PASSO_A_PASSO_PowerBI.md` | Roteiro de montagem adaptado do guia |
| `docs/gabarito_esperado.md` | Valores esperados calculados do banco |
| `evidencias/` | Capturas e `validacao_resultados.md` |

## Modelo
4 tabelas + `_Medidas`. Relacionamentos R1 (estação), R2 (data → dim_tempo) e R3 (data → dim_clima), todos N:1 com direção única. `dim_tempo` marcada como tabela de datas. Diagrama: `docs/diagrama_modelo.png`.

## Páginas
1. **Visão Geral**: KPIs, evolução mensal × esperado, % do esperado por linha, mapa de calor linha × mês, anomalias por dia.
2. **Linhas & Estações**: top 10 estações (C1), matriz linha/estação, treemap, dispersão volume × % esperado, estações-mês críticas (C5).
3. **Chuva & Demanda** (clima simulado): % esperado por condição de chuva e linha (C3), dispersão por dia, precipitação × demanda no tempo, matriz por faixa de chuva (C4).
- Apoio: Detalhe da Estação (detalhamento), Dica Linha (dica de ferramenta, oculta), Conferência (oculta).

## Batimento (preencher a coluna Power BI com os valores do seu arquivo)
| Indicador | Etapa III | Etapa IV (SQL) | Power BI | Diferença |
|---|---:|---:|---:|---:|
| Entradas (soma) | 339.840.800 | K1/K4 339.840.800 | | |
| Linhas aceitas | 11.946 | K1 11.946 | | |
| Estações | 66 | K1 66 | | |
| Dias | 181 | K1 181 | | |
| Quedas atípicas | 69 | K4 69 | | |
| Picos atípicos | 5 | K4 5 | | |
| Total Linha 1-Azul | 118.199.000 | K4 118.199.000 | | |
| Total Linha 2-Verde | 77.693.700 | K4 77.693.700 | | |
| Total Linha 3-Vermelha | 130.999.000 | K4 130.999.000 | | |
| Total Linha 15-Prata | 12.949.100 | K4 12.949.100 | | |
| % do esperado Azul jan/26 | – | C2 98,28 | | |
| Top 1 estação (Corinthians-Itaquera) | – | C1 11.760.731 | | |
| Quedas em Chuva Forte | – | C4 69 (4,36%) | | |
| Estações-mês críticas | – | C5 10 linhas | | |

Validação contra **seis** consultas SQL (K1, K4, C1, C2, C4, C5) e mais a C3, acima do mínimo de quatro.

## Decisões registradas
- Clima **SIMULADO** até a Etapa 6 (faixa de aviso na Página 3). As quedas de 12/01 e 19/01 coincidem com a chuva forte simulada, então não é possível tirar conclusão causal.
- `[Entradas Esperadas]` = `SUM(media_ref)` (regra da Etapa II gravada no banco, igual à C2). A fórmula da Etapa III com `SWITCH` sobre as médias da estação não reproduz a C2.
- R3 pela coluna `data`, sem chave `cidade|data`: há uma cidade só (São Paulo), como nas consultas C3 e C4.
- Segmentação por **linha** no lugar de "por cidade" (o projeto tem uma cidade).
- Ranking com `DENSE`; a C1 desempata pelo id. O Top 10 do Power BI mostra 12 barras por causa de empates.
- Sem mapa: as estações não têm coordenadas no banco.
- Faixas de cor de `% do Esperado`: ≥ 99% verde, ≥ 97% âmbar, abaixo vermelho (a escala da rede fica entre 96% e 100%).

## Pendências herdadas
- 74 atipicidades (69 quedas, 5 picos) com status "Pendente de esclarecimento" desde a Etapa II.
- Corpus Christi (04/06) ainda "a confirmar".
- O README da Etapa III cita "58 quedas em 02/01/2026", mas o banco e o CSV mostram 59 quedas em **12/01** e 10 em 19/01. Corrigir o texto da Etapa III.

## Situação do relatório (24/11/2026)

- `MetroClima_Dashboard.pbix` (esta pasta) tem o modelo, as 42 medidas e as 6 páginas: Visão Geral, Linhas & Estações, Chuva & Demanda, Detalhe da Estação (detalhamento, oculta), Dica Linha (dica de ferramenta, oculta) e Conferência (oculta).
- O mesmo relatório está salvo como projeto aberto em `Microinformatica\MetroClima-pbip` (modelo em TMDL e páginas em JSON). As páginas foram geradas pelo script `docs/gerar_relatorio_pbir.py`. A pasta `pbip-projeto` aqui dentro é provisória e pode ser apagada.
- Conferido no Power BI:
  - P1: 339.840.800 | 1.877.573 | 99,71% | 69 | 5.
  - Dica da linha Verde: 77.693.700 | 99,53% | 23.
  - Detalhamento Trianon-Masp (Verde): 9.481.249 | 52.383 | 99,40% | 2 | 0.
  - P3: Efeito Chuva Forte -2,28 p.p. | 4,36% | 24 dias.
- Diferenças em relação ao passo a passo:
  - **Cartões:** os KPIs usam cartões clássicos (um por medida), para mostrar o número completo. O cartão novo arredondava para "340 Mi".
  - **Títulos dinâmicos:** viraram cartões de texto com as medidas `[Título Visão Geral]`, `[Período Selecionado]` e `[Título Estação]`.
  - **Mapa de calor e barras da P1:** usam as cores de `[Cor % Esperado]` (verde ≥ 99%, âmbar ≥ 97%, vermelho abaixo).
  - **Linhas constantes (0,97 e 1) da P1 V3:** não foram adicionadas. Se o professor cobrar, entram pelo painel Análise.
- PDF exportado: `MetroClima_Dashboard.pdf` (3 páginas: Visão Geral, Linhas & Estações, Chuva & Demanda).
