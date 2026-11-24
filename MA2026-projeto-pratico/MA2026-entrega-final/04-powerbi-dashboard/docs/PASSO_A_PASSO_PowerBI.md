# Passo a passo – Etapa V (Power BI) adaptada para o MetroClima

Roteiro para seguir com o Power BI Desktop aberto. Ele segue a ordem do guia do Prof. Veríssimo (Atividades 1 a 6 e Seção 9), trocando o exemplo CaféData pelo MetroClima. Onde o guia diz `cafedata`, use `metroclima`. Os números esperados de cada passo estão em [`gabarito_esperado.md`](gabarito_esperado.md).

**Pergunta central do painel (MetroClima):** como se distribui a demanda de passageiros das Linhas 1-Azul, 2-Verde, 3-Vermelha e 15-Prata, como ela se compara ao esperado para cada estação e tipo de dia, e de que forma a chuva altera essa demanda e a ocorrência de quedas atípicas?

---

## Atividade 1 – Configuração (guia §2)

1. **Pastas** (§2.2): `MA2026-entrega-final/04-powerbi-dashboard/` já existe, com `dax`, `m`, `tema`, `docs` e `evidencias`. Os arquivos desta entrega já estão lá.
2. **Power BI Desktop** (§2.3): abra o `MetroClima_Dashboard.pbix` (está em branco). Em *Arquivo → Opções e configurações → Opções*:
   - Global → Configurações regionais → idioma **Português (Brasil)**, separadores DAX **padrão (vírgula)**.
   - Arquivo Atual → Carregamento de Dados → **desmarcar** *Data/hora automática*.
   - Arquivo Atual → Carregamento de Dados → **desmarcar** *detectar novos relacionamentos após o carregamento*.
   - Arquivo Atual → Configurações regionais → localidade de importação **Português (Brasil)**.
   - Os visuais de mapa não são usados: as estações não têm coordenadas no banco.
3. **Driver ODBC + DSN** (§2.4): instale o `sqliteodbc_w64.exe` (64 bits). Depois abra *Fontes de Dados ODBC (64 bits)* → **DSN de Usuário** → *Adicionar* → *SQLite3 ODBC Driver*:
   - Data Source Name: **`metroclima`**
   - Database Name: `...\Microinformatica\MA2026-entrega-final\05-sql\metroclima.db`
   - Marque **No Creat**. Feche o DB Browser antes de conectar (evita *database is locked*).
4. **Parâmetro e teste** (§2.5): *Transformar dados* → *Gerenciar Parâmetros* → *Novo*: `pConexaoODBC`, Texto, valor `dsn=metroclima`. Depois *Nova Fonte → Consulta Nula → Editor Avançado* e cole `m/tst_Conexao.pq`.
   - **Esperado:** dim_estacao 66 | dim_tempo 181 | dim_clima 181 | fato_entradas 11946 | soma_entradas 339840800.
   - Desmarque *Habilitar carga* em `tst_Conexao` e em `pConexaoODBC`.

## Atividade 2 – Power Query (guia §3)

Para cada arquivo abaixo: *Nova Fonte → Consulta Nula → Editor Avançado*, cole o código e dê à consulta **exatamente** o nome do arquivo, sem `.pq`.

| Consulta | Arquivo | Linhas esperadas |
|---|---|---:|
| `dim_estacao` | `m/dim_estacao.pq` | 66 |
| `dim_tempo` | `m/dim_tempo.pq` | 181 |
| `dim_clima` | `m/dim_clima.pq` | 181 |
| `fato_entradas` | `m/fato_entradas.pq` | 11.946 |

- Todas as conversões usam `"en-US"`. Isso impede que `media_ref = 36953.33` vire 3695333 (o mesmo erro do "6.5 → 65" do guia, §3.1).
- `dim_clima` ganha `faixa_chuva` (mesma regra da C4) e `ordem_condicao`.
- **Conferir** (*Exibição → Perfil da coluna*): na coluna `fato_entradas[entradas]`, Soma = **339.840.800**. Em `dim_clima[faixa_chuva]`, 3 valores distintos: 133 Seco, 24 Fraca e 24 Forte.
- Grupos (§3.5): `01_Parametros` (pConexaoODBC), `02_Dimensoes` (dim_estacao, dim_tempo, dim_clima), `03_Fatos` (fato_entradas), `99_Diagnostico` (tst_Conexao).
- *Fechar e Aplicar*. No painel Dados devem aparecer **4 tabelas** e nenhuma `LocalDateTable_...`.

## Atividade 3 – Modelo (guia §4)

1. *Gerenciar relações → Novo* (todas **Muitos para um**, direção **Única**, ativas):
   - **R1** `fato_entradas[id_estacao]` → `dim_estacao[id_estacao]`
   - **R2** `fato_entradas[data]` → `dim_tempo[data]`
   - **R3** `fato_entradas[data]` → `dim_clima[data]`. O Power BI pode sugerir 1:1 ou "Ambos". Troque para *Muitos para um* e *Única*.
   - **Não** ligue `dim_clima` a `dim_tempo`.
   - *Teste de fumaça:* uma tabela com `dim_estacao[nome_linha]` + Soma de `entradas` deve mostrar Azul 118.199.000, Prata 12.949.100, Verde 77.693.700, Vermelha 130.999.000. Apague a tabela depois do teste.
2. **Tabela de datas** (§4.3): `dim_tempo` → *Marcar como tabela de datas* → coluna `data`.
   - Classificar por coluna: `nome_mes` por `mes`, `nome_dia` por `dia_semana`, `dim_estacao[nome_linha]` por `dim_estacao[linha]` e `dim_clima[condicao_chuva]` por `ordem_condicao`.
   - Hierarquia **Calendário** em `dim_tempo`: ano → trimestre → nome_mes → data.
3. **Ocultar** (§4.4):

| Tabela | Ocultar | Deixar visível |
|---|---|---|
| fato_entradas | data, id_estacao, linha, entradas, media_ref, razao_media, flag_queda_atipica, flag_pico_atipico | tipo_dia, status_entradas |
| dim_estacao | id_estacao, chave_estacao, linha, media_dia_util, media_sabado, media_domingo, dias_registrados, dias_esperados | estacao, estacao_linha, sigla, nome_linha |
| dim_tempo | mes_inicio, dia_semana, mes | hierarquia Calendário, data, nome_mes, ano_mes, nome_dia, fim_de_semana, feriado |
| dim_clima | cidade, ordem_condicao | data, precipitacao, condicao_chuva, faixa_chuva, temp_max, temp_min |

   - Em ano, mes, linha e dia_semana use *Resumo → Não resumir*.
4. **_Medidas** (§4.5): *Página Inicial → Inserir dados* → nome `_Medidas` → Carregar. Depois da primeira medida, oculte `Coluna1`.

## Atividade 4 – Medidas DAX (guia §5)

1. Exibição **[DAX]** → *Nova consulta* → cole `dax/medidas_finais.dax` inteiro → **Executar**. O resultado tem de ser **339.840.800 | 11.946 | 66 | 181 | 69 | 5 | 99,71**.
2. Clique em **Atualizar modelo** (no topo ou acima de cada `MEASURE`) para gravar as 42 medidas em `_Medidas`. O guia pede que as 5 primeiras (Entradas, Qtd Registros, Qtd Estações, Qtd Dias, Entradas Esperadas) sejam digitadas à mão, para treinar.
3. Ajuste **formatos** e **pastas de exibição** pela tabela que está no fim do `medidas_finais.dax` (pastas 01 Demanda, 02 Esperado, 03 Anomalias, 04 Tempo, 05 Clima, 06 Rótulos, 99 Conferência).
4. Rode `dax/validacao.dax`, um bloco por vez (Seção 9 abaixo). Se V-K1 e V-K4 baterem, o modelo está pronto para os visuais.

**Medidas que respondem à especificação (mínimo de 5 documentadas):** `[Entradas]`, `[Média Diária da Rede]` (razão por unidade), `[% do Esperado]` (realizado × esperado), `[Qtd Quedas Atípicas]`/`[Taxa de Quedas %]` e `[Efeito Chuva Forte (p.p.)]` (cruzamento com o fator externo, o análogo do "% Bebidas Frias × faixa térmica").

## Atividade 5 – Visuais (guia §6)

**Tema** (§6.1): *Exibição → Temas → Procurar temas* → `tema/tema_metroclima.json`. Use página 16:9 e ative *Ajustar à grade*. Cores fixas: Azul #0455A1, Verde #007E5E, Vermelha #EE372F, Prata #8C9294 (medida `[Cor Linha]`). Verde, âmbar e vermelho ficam só para status (`[Cor % Esperado]`).

### Página 1 – Visão Geral ("Como está a demanda da rede e quais linhas puxam o volume?")

| Visual | Tipo | Campos | Título (pergunta) |
|---|---|---|---|
| V1 | Cartão (novo) | Entradas, Média Diária da Rede, % do Esperado, Qtd Quedas Atípicas, Qtd Picos Atípicos. Título fx = `[Título Visão Geral]`; subtítulo fx = `[Período Selecionado]` | (dinâmico) |
| V2 | Gráfico de linhas | Eixo X: hierarquia Calendário (nível nome_mes); Y: Entradas e Entradas Esperadas | Como a demanda evolui mês a mês, frente ao esperado? |
| V3 | Barras clusterizadas | Y: nome_linha; X: % do Esperado; cor fx = `[Cor % Esperado]`; linhas constantes 0,97 e 1 (Análise); eixo X começa em 0,95 | Quais linhas ficaram abaixo do esperado? |
| V4 | Matriz (mapa de calor) | Linhas: nome_linha; Colunas: nome_mes; Valores: % do Esperado. Cor da tela de fundo em gradiente: mín. 0,95 vermelho, centro 0,98 âmbar, máx. 1 verde | Em que meses cada linha ficou abaixo do esperado? |
| V5 | Colunas empilhadas | Eixo X: dim_tempo[data]; Y: Qtd Quedas Atípicas e Qtd Picos Atípicos | Quando aconteceram as quedas e os picos atípicos? |
| Segm. | – | nome_mes (lista suspensa), nome_linha (bloco), fato_entradas[tipo_dia] (bloco) | – |

**Esperado:** V1 = 339.840.800 | 1.877.573 | 99,71% | 69 | 5. V3 = Vermelha 99,79%, Azul 99,74%, Prata 99,65%, Verde 99,53%. V4 = só Janeiro abaixo de 100% (Azul 98,28, Verde 96,91, Vermelha 98,65, Prata 97,69); os demais meses ficam em 100,00. V5 = picos em 01/01 e quedas em 12/01 (59) e 19/01 (10).

### Página 2 – Linhas & Estações ("Onde a demanda se concentra e quais estações fogem do esperado?")

| Visual | Tipo | Campos | Título |
|---|---|---|---|
| V1 | Barras clusterizadas | Y: estacao_linha; X: Entradas; filtro do visual N superior 10 por Entradas; cor fx = `[Cor Linha]`; rótulos de dados | Quais estações recebem mais passageiros? |
| V2 | Matriz | Linhas: nome_linha → estacao_linha; Valores: Entradas, Participação %, % do Esperado, Qtd Quedas Atípicas; barras de dados em Entradas | Como o volume se distribui entre linhas e estações? |
| V3 | Treemap | Categoria: nome_linha; Detalhes: estacao; Valores: Entradas; cores das linhas | Qual o peso de cada linha no total? |
| V4 | Dispersão | Valores: estacao_linha; X: Média por Estação-Dia; Y: % do Esperado; Legenda: nome_linha; Tamanho: Qtd Quedas Atípicas; linha média em Y | Quais estações movimentam muito e ainda ficam abaixo do esperado? |
| V5 | Tabela | estacao_linha, ano_mes, Entradas, Entradas Esperadas, % do Esperado, Qtd Quedas Atípicas. Filtro do visual: `Flag Crítico C5` é 1 | Quais estações e meses foram críticos? |
| V6 | Cartão | Qtd Estações, Média por Estação-Dia, Taxa de Quedas % | – |

**Esperado:** V1 mostra **12 barras** (empates no 10º lugar; ver gabarito), começando por Corinthians-Itaquera com 11.760.731. V5 tem **10 linhas**, iguais à C5, todas de Janeiro e com 2 quedas. V6 = 66 | 28.448 | 0,58%.

### Página 3 – Chuva & Demanda ("A chuva reduz a demanda ou provoca quedas atípicas?")

Coloque no topo uma caixa de texto âmbar: **"Clima simulado – Etapa 6 (API Open-Meteo) pendente"**.

| Visual | Tipo | Campos | Título |
|---|---|---|---|
| V1 | Colunas clusterizadas | Eixo X: condicao_chuva; Y: % do Esperado; Legenda: nome_linha; eixo Y começa em 0,95 | Em dias de chuva forte, cada linha fica mais abaixo do esperado? |
| V2 | Dispersão (um ponto por dia) | Valores: dim_tempo[data]; X: Precipitação Média (mm); Y: % do Esperado; Tamanho: Entradas; linha de tendência ligada | Quanto mais chove, menor a demanda frente ao esperado? |
| V3 | Linhas e colunas clusterizadas | Eixo X: dim_tempo[data]; colunas: Precipitação Média (mm); linha: % do Esperado | Chuva e demanda andam juntas no tempo? |
| V4 | Matriz (= C4) | Linhas: faixa_chuva; Valores: Qtd Dias, Entradas, Qtd Quedas Atípicas, Qtd Picos Atípicos, Taxa de Quedas %, % do Esperado | Em que faixa de chuva se concentram as anomalias? |
| V5 | Cartão | Efeito Chuva Forte (p.p.), Taxa de Quedas Chuva Forte %, Dias com Chuva Forte, Precipitação Média (mm) | – |
| Segm. | – | nome_mes e nome_linha (sincronizadas) | – |

A especificação pede "segmentação por cidade", mas o MetroClima tem uma cidade só, então aqui vale a segmentação por **linha**. Registre isso no README.

**Esperado:** V4 = Seco 133 dias, 250.793.172, 0 quedas, 5 picos, 0,00%. Fraca 24 dias, 43.222.932, 0, 0, 0,00%. Forte 24 dias, 45.824.696, 69, 0, 4,36%. V1 em Chuva Forte = Azul 98,01%, Prata 97,46%, Verde 96,45%, Vermelha 98,31%. As demais condições ficam perto de 100%. V5 = −2,28% | 4,36% | 24 | 4,6.

> Não tire conclusões da Página 3 com o clima simulado. O simulado põe chuva forte justamente em 12/01 e 19/01, que são os dias das quedas. O que se confere agora é o mecanismo (cada número bate com a C3 e a C4).

### Dica de ferramenta (§6.5) – página "Dica Linha" (oculta)

Em *Informações da página*, ative *Permitir uso como dica de ferramenta* e use o tamanho 320 × 240. No campo *Dica de ferramenta* coloque `dim_estacao[nome_linha]`. Monte um cartão com Entradas, % do Esperado, Qtd Quedas Atípicas e Média Diária da Rede, com título fx = `[Título Visão Geral]`. Aplique a dica na P1 (V3 e V4) e na P2 (V1 e V3), em *Geral → Dicas de ferramenta → Página do relatório*.

## Atividade 6 – Interatividade (guia §7)

- **Segmentações:** mês e linha com seleção múltipla. Use cabeçalhos curtos ("Mês", "Linha", "Tipo de dia").
- **Sincronizar** (*Exibição → Sincronizar segmentações*): mês e linha nas 3 páginas, visíveis nas 3. Tipo de dia: sincronizado nas 3 e visível só na P1.
- **Editar interações:**
  - P1: V3 (linhas) filtra V2, V4 e V5. Em V4 (mapa de calor), a interação com V2 fica *Nenhum*.
  - P3: V4 (faixa) filtra V2 e V3.
- **Painel Filtros:** bloqueie o Top 10 (P2 V1) e o `Flag Crítico C5` (P2 V5) com o cadeado.
- **Drill-down:** V2 da P1 desce ano → trimestre → mês → dia. Salve no nível de mês.
- **Detalhamento – página "Detalhe da Estação":** campo *Detalhamento* = `dim_estacao[estacao_linha]` (mantenha *Manter todos os filtros*). Visuais:
  - Cartão: Entradas, Média por Estação-Dia, % do Esperado, Qtd Quedas, Qtd Picos; título fx = `[Título Estação]`.
  - Colunas: Média por Estação-Dia por `fato_entradas[tipo_dia]` ("Em que tipo de dia a estação é mais usada?").
  - Linhas: Entradas e Entradas Esperadas por `dim_tempo[data]` ("A estação seguiu o esperado dia a dia?").
  - Colunas: % do Esperado por `condicao_chuva` ("A chuva afeta esta estação?").
  - Teste: botão direito em "Trianon-Masp (Verde)" na P2 → Detalhamento. Esperado: 9.481.249 | 52.383 | 99,40% | 2 quedas | 0 picos.
- **Navegação:** em cada página, *Inserir → Botões → Navegador de página* e o botão *Limpar todas as segmentações* ("Limpar filtros"). No Desktop, os botões respondem a Ctrl + clique.

## Seção 9 – Conferência e entrega

1. **validacao.dax**, bloco por bloco. Compare com `05-sql/evidencias/` e com o `gabarito_esperado.md`. Copie os resultados para `evidencias/validacao_resultados.md`.

| Bloco | Compara com | Esperado |
|---|---|---|
| V-K1 | k1_batimento.csv | 11946 / 339840800 / 66 / 181 |
| V-K4 (+TOTAL) | k4_validacao_linhas.csv | 4 linhas + 339840800 / 69 / 5 |
| V-C1 | c1_ranking_estacoes.csv | 10 estações, mesma ordem |
| V-C2 | c2_entradas_linha_mes.csv | 24 linhas |
| V-C3 | c3_impacto_chuva_linhas.csv | 12 linhas |
| V-C4 | c4_anomalias_faixa_chuva.csv | 3 linhas |
| V-C5 | c5_estacoes_criticas.csv | 10 linhas |
| V-CONF | – | 11946 e oito zeros |

2. **Página "Conferência" (oculta):** cartão com todas as medidas `Conf ...` e uma tabela `nome_linha` × Entradas, Qtd Quedas, Qtd Picos (= K4) com totais. Não ponha segmentação nessa página.
3. **Teste de linhagem (§9.4), versão MetroClima:**
   - Na Etapa II, mude temporariamente um valor de entradas (por exemplo, `pLimiteQueda` de 0,5 para 0,7 muda a contagem de quedas).
   - Reexporte o CSV, recarregue o banco (`ddl` → importar CSV → `carga` → `clima_SIMULADO` → `views`) e feche o DB4S.
   - No Power BI, clique em *Atualizar*: o número tem de mudar no painel.
   - Desfaça tudo e atualize de novo. Tem de voltar a 69 quedas.
4. **Checklist visual (§9.5):** mesmo tema em tudo, títulos com "?", no máximo 6 visuais por página, nenhuma medida implícita, meses em ordem, segmentações sincronizadas, dica e detalhamento funcionando, faixa "clima simulado" visível, páginas de apoio ocultas e estado salvo com tudo selecionado.
5. **Exportar (§9.6):**
   - *Arquivo → Exportar → PDF* → `MetroClima_Dashboard.pdf`.
   - Print do diagrama → `docs/diagrama_modelo.png`.
   - Prints das páginas → `evidencias/p1_visao_geral.png`, `p2_linhas_estacoes.png`, `p3_chuva_demanda.png`, `detalhe_estacao.png`, `conferencia.png`.
   - Se mudar alguma consulta no Power BI, copie o código M de novo para `m/`.
   - Preencha a coluna "Power BI" do `README.md`, feche o Power BI e faça o commit.
