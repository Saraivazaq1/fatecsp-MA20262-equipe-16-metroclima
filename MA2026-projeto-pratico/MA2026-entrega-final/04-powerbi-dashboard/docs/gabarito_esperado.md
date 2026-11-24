# Gabarito esperado – MetroClima_Dashboard (calculado direto do metroclima.db)

Valores calculados a partir das views `dim_estacao`, `dim_tempo`, `dim_clima` e `fato_entradas` do `metroclima.db` (etapa de SQL), com o **clima SIMULADO**. São os números que o painel e o `validacao.dax` têm de reproduzir (diferença 0). Percentuais com 2 casas.

> Atenção: com o clima simulado, as conclusões sobre chuva **não valem** como análise. O script `metroclima_clima_SIMULADO.sql` marca chuva forte nos dias 4, 12, 19 e 25 de cada mês, e as 69 quedas atípicas caem em 12/01 (59) e 19/01 (10). A coincidência é do simulado, não do mundo real.

### Rede (sem filtros) – cartão da Página 1 e V-K1/V-K4

| Entradas | Registros | Estações | Dias | Entradas Esperadas | % do Esperado | Média por Estação-Dia | Média Diária da Rede | Quedas | Picos | Taxa de Quedas % | Precipitação Média (mm) | Temp Máx Média | Razão Média % |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 339.840.800 | 11.946 | 66 | 181 | 340.838.655 | 99,71 | 28.448 | 1.877.573 | 69 | 5 | 0,58 | 4,59 | 26,2 | 99,81 |

Medidas de clima da rede: **% do Esperado Chuva Forte** 97,74%; **% do Esperado Sem Chuva** 100,02%; **Efeito Chuva Forte (p.p.)** -2,28%; **Taxa de Quedas Chuva Forte %** 4,36%; **Dias com Chuva Forte** 24.

### Por linha (= K4; barras da Página 1)

| Linha | Entradas | Esperadas | % do Esperado | Quedas | Picos | Média Diária | Estações | Registros |
|---|---|---|---|---|---|---|---|---|
| Azul | 118.199.000 | 118.509.582 | 99,74 | 20 | 1 | 653.033 | 23 | 4.163 |
| Prata | 12.949.100 | 12.994.584 | 99,65 | 12 | 0 | 71.542 | 11 | 1.991 |
| Verde | 77.693.700 | 78.059.055 | 99,53 | 23 | 2 | 429.247 | 14 | 2.534 |
| Vermelha | 130.999.000 | 131.275.434 | 99,79 | 14 | 2 | 723.751 | 18 | 3.258 |

### Por mês (linha mensal da Página 1)

| Mês | Entradas | Esperadas | % do Esperado | Dias | Média Diária | Quedas | Cresc. MoM % | Acumulado Ano |
|---|---|---|---|---|---|---|---|---|
| 2026-01 | 51.288.300 | 52.286.155 | 98,09 | 31 | 1.654.461 | 69 | – | 51.288.300 |
| 2026-02 | 51.991.100 | 51.991.100 | 100,00 | 28 | 1.856.825 | 0 | 12,2 | 103.279.400 |
| 2026-03 | 62.564.000 | 62.564.000 | 100,00 | 31 | 2.018.194 | 0 | 8,7 | 165.843.400 |
| 2026-04 | 58.024.200 | 58.024.200 | 100,00 | 30 | 1.934.140 | 0 | -4,2 | 223.867.600 |
| 2026-05 | 59.552.300 | 59.552.300 | 100,00 | 31 | 1.921.042 | 0 | -0,7 | 283.419.900 |
| 2026-06 | 56.420.900 | 56.420.900 | 100,00 | 30 | 1.880.697 | 0 | -2,1 | 339.840.800 |

### Linha × mês (= C2; mapa de calor da Página 1)

| cod | Linha | Mês | Realizadas | Esperadas | % do Esperado |
|---|---|---|---|---|---|
| 1 | Azul | 2026-01 | 17.721.300 | 18.031.882 | 98,28 |
| 1 | Azul | 2026-02 | 18.053.100 | 18.053.100 | 100,00 |
| 1 | Azul | 2026-03 | 21.754.700 | 21.754.700 | 100,00 |
| 1 | Azul | 2026-04 | 20.357.400 | 20.357.400 | 100,00 |
| 1 | Azul | 2026-05 | 20.758.800 | 20.758.800 | 100,00 |
| 1 | Azul | 2026-06 | 19.553.700 | 19.553.700 | 100,00 |
| 2 | Verde | 2026-01 | 11.474.800 | 11.840.155 | 96,91 |
| 2 | Verde | 2026-02 | 11.955.200 | 11.955.200 | 100,00 |
| 2 | Verde | 2026-03 | 14.519.100 | 14.519.100 | 100,00 |
| 2 | Verde | 2026-04 | 13.259.100 | 13.259.100 | 100,00 |
| 2 | Verde | 2026-05 | 13.549.200 | 13.549.200 | 100,00 |
| 2 | Verde | 2026-06 | 12.936.300 | 12.936.300 | 100,00 |
| 3 | Vermelha | 2026-01 | 20.169.800 | 20.446.234 | 98,65 |
| 3 | Vermelha | 2026-02 | 20.030.600 | 20.030.600 | 100,00 |
| 3 | Vermelha | 2026-03 | 23.922.400 | 23.922.400 | 100,00 |
| 3 | Vermelha | 2026-04 | 22.184.700 | 22.184.700 | 100,00 |
| 3 | Vermelha | 2026-05 | 22.962.100 | 22.962.100 | 100,00 |
| 3 | Vermelha | 2026-06 | 21.729.400 | 21.729.400 | 100,00 |
| 15 | Prata | 2026-01 | 1.922.400 | 1.967.884 | 97,69 |
| 15 | Prata | 2026-02 | 1.952.200 | 1.952.200 | 100,00 |
| 15 | Prata | 2026-03 | 2.367.800 | 2.367.800 | 100,00 |
| 15 | Prata | 2026-04 | 2.223.000 | 2.223.000 | 100,00 |
| 15 | Prata | 2026-05 | 2.282.200 | 2.282.200 | 100,00 |
| 15 | Prata | 2026-06 | 2.201.500 | 2.201.500 | 100,00 |

### Top 10 estações (= C1; Página 2)

| id | Estação | Linha | Dias | Entradas | Média/dia |
|---|---|---|---|---|---|
| EST38 | Corinthians-Itaquera | Vermelha | 181 | 11.760.731 | 64.976 |
| EST45 | Tatuapé | Vermelha | 181 | 11.760.494 | 64.975 |
| EST50 | República | Vermelha | 181 | 11.760.494 | 64.975 |
| EST52 | Marechal Deodoro | Vermelha | 181 | 11.760.494 | 64.975 |
| EST53 | Palmeiras-Barra Funda | Vermelha | 181 | 11.760.494 | 64.975 |
| EST31 | Trianon-Masp | Verde | 181 | 9.481.249 | 52.383 |
| EST36 | Ana Rosa (L2) | Verde | 181 | 9.481.249 | 52.383 |
| EST24 | Vila Prudente | Verde | 181 | 9.481.144 | 52.382 |
| EST01 | Jabaquara | Azul | 181 | 8.755.748 | 48.374 |
| EST08 | Ana Rosa | Azul | 181 | 8.755.491 | 48.373 |

Empates: Tatuapé, República, Marechal Deodoro e Palmeiras-Barra Funda têm 11.760.494; Ana Rosa, Sé e Luz (Azul) têm 8.755.491. O filtro **N superior = 10** do Power BI inclui empatados e mostra **12 barras**; a C1 (LIMIT 10) corta em 10. Registrar no README.

### Linha × condição de chuva (= C3; Página 3)

| Linha | Condição | Registros | Média por Estação-Dia | Razão Média % | % do Esperado | Quedas | Picos |
|---|---|---|---|---|---|---|---|
| Azul | Chuva Forte | 552 | 28.858 | 98,73 | 98,01 | 20 | 0 |
| Azul | Chuva Leve | 552 | 27.238 | 100,00 | 100,00 | 0 | 0 |
| Azul | Sem Chuva | 3.059 | 28.517 | 100,01 | 100,01 | 0 | 1 |
| Prata | Chuva Forte | 264 | 6.615 | 98,41 | 97,46 | 12 | 0 |
| Prata | Chuva Leve | 264 | 6.250 | 100,00 | 100,00 | 0 | 0 |
| Prata | Sem Chuva | 1.463 | 6.529 | 100,00 | 100,00 | 0 | 0 |
| Verde | Chuva Forte | 336 | 31.222 | 97,60 | 96,45 | 23 | 0 |
| Verde | Chuva Leve | 336 | 29.352 | 100,00 | 100,00 | 0 | 0 |
| Verde | Sem Chuva | 1.862 | 30.795 | 100,04 | 100,04 | 0 | 2 |
| Vermelha | Chuva Forte | 432 | 40.875 | 98,87 | 98,31 | 14 | 0 |
| Vermelha | Chuva Leve | 432 | 38.600 | 100,00 | 100,00 | 0 | 0 |
| Vermelha | Sem Chuva | 2.394 | 40.378 | 100,03 | 100,03 | 0 | 2 |

Obs.: a C3 usa `ROUND(AVG(entradas),0)`; o Power BI arredonda igual só no formato (0 casas).

### Faixa de chuva (= C4; matriz da Página 3)

| Faixa | Dias | Entradas | Quedas | Picos | Taxa de Quedas % | % do Esperado |
|---|---|---|---|---|---|---|
| 1-Seco (0 mm) | 133 | 250.793.172 | 0 | 5 | 0,00 | 100,02 |
| 2-Chuva Fraca (< 10 mm) | 24 | 43.222.932 | 0 | 0 | 0,00 | 100,00 |
| 3-Chuva Forte (>= 10 mm) | 24 | 45.824.696 | 69 | 0 | 4,36 | 97,74 |

### Estações-mês críticas (= C5)

| Linha | Estação | Mês | Realizadas | Esperadas | % do Esperado | Quedas |
|---|---|---|---|---|---|---|
| Prata | Vila Prudente (L15) | 2026-01 | 307.534 | 320.081 | 96,08 | 2 |
| Verde | Trianon-Masp | 2026-01 | 1.400.309 | 1.457.431 | 96,08 | 2 |
| Verde | Sacomã | 2026-01 | 661.269 | 688.244 | 96,08 | 2 |
| Verde | Alto do Ipiranga | 2026-01 | 661.269 | 688.244 | 96,08 | 2 |
| Verde | Santos-Imigrantes | 2026-01 | 661.269 | 688.244 | 96,08 | 2 |
| Verde | Chácara Klabin | 2026-01 | 661.269 | 688.244 | 96,08 | 2 |
| Verde | Brigadeiro | 2026-01 | 661.269 | 688.244 | 96,08 | 2 |
| Verde | Consolação | 2026-01 | 661.269 | 688.244 | 96,08 | 2 |
| Verde | Vila Prudente | 2026-01 | 1.400.223 | 1.443.616 | 96,99 | 2 |
| Verde | Tamanduateí | 2026-01 | 661.269 | 681.750 | 97,00 | 2 |

### Por tipo de dia (Detalhe da Estação / segmentação)

| Tipo de dia | Registros | Entradas | % do Esperado |
|---|---|---|---|
| Dia Útil | 8.118 | 272.095.989 | 99,61 |
| Domingo/Feriado | 2.112 | 33.347.621 | 100,18 |
| Sábado | 1.716 | 34.397.190 | 100,00 |

### Dias de maior desvio da rede (dispersão por dia, Página 3)

| Data | Condição | Precipitação | Entradas | Esperadas | % do Esperado |
|---|---|---|---|---|---|
| 2026-01-12 | Chuva Forte | 28,4 | 1.942.731 | 2.842.142 | 68,35 |
| 2026-01-19 | Chuva Forte | 28,4 | 1.942.731 | 2.100.538 | 92,49 |
| 2026-01-02 | Chuva Leve | 6,2 | 1.942.731 | 1.942.731 | 100,00 |
| 2026-01-03 | Sem Chuva | 0,0 | 1.165.651 | 1.165.651 | 100,00 |
| 2026-01-04 | Chuva Forte | 28,4 | 679.959 | 679.959 | 100,00 |

### Exemplo de Detalhe da Estação – Trianon-Masp (Verde)

| Entradas | % do Esperado | Quedas | Picos | Média por dia |
|---|---|---|---|---|
| 9.481.249 | 99,40 | 2 | 0 | 52.383 |

### Conferência (V-CONF)

`[Conf Linhas fato_entradas]` = 11.946; todas as demais `Conf ...` = 0 (sem estação, sem data, sem clima, PK duplicada, lacunas estação-dia, dif. quedas, dif. picos, razão divergente).

### Contagens na exibição [Tabela]

dim_estacao 66 · dim_tempo 181 · dim_clima 181 · fato_entradas 11.946
