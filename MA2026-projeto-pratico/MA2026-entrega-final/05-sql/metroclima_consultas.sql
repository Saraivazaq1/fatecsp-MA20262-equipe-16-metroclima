-- metroclima_consultas.sql
-- Consultas analíticas C1 a C5 investigando o impacto das chuvas nas Linhas 1, 2, 3 e 15

-- C1) Ranking das 10 estações com maior volume de entradas no semestre
SELECT
    e.id_estacao,
    e.nome_estacao AS estacao,
    l.nome_linha AS linha,
    COUNT(ed.data_ref) AS dias_operacao,
    SUM(ed.entradas) AS total_entradas,
    ROUND(AVG(ed.entradas), 0) AS media_diaria
FROM entrada_diaria ed
JOIN estacao e ON e.id_estacao = ed.id_estacao
JOIN linha l ON l.cod_linha = e.cod_linha
GROUP BY e.id_estacao, e.nome_estacao, l.nome_linha
ORDER BY total_entradas DESC
LIMIT 10;

-- C2) Entradas realizadas vs. Entradas esperadas por Linha e Mês (% do Esperado)
SELECT
    l.cod_linha,
    l.nome_linha AS linha,
    cal.ano_mes,
    SUM(ed.entradas) AS entradas_realizadas,
    ROUND(SUM(ed.media_ref), 0) AS entradas_esperadas,
    ROUND(100.0 * SUM(ed.entradas) / NULLIF(SUM(ed.media_ref), 0), 2) AS pct_do_esperado
FROM entrada_diaria ed
JOIN estacao e ON e.id_estacao = ed.id_estacao
JOIN linha l ON l.cod_linha = e.cod_linha
JOIN calendario cal ON cal.data = ed.data_ref
WHERE ed.media_ref IS NOT NULL
GROUP BY l.cod_linha, l.nome_linha, cal.ano_mes
ORDER BY l.cod_linha, cal.ano_mes;

-- C3) Comportamento das Entradas e Razão Média por Linha e Condição de Chuva (Hipótese Central)
SELECT
    l.nome_linha AS linha,
    cl.condicao_chuva,
    COUNT(*) AS registros_estacao_dia,
    ROUND(AVG(ed.entradas), 0) AS media_entradas,
    ROUND(AVG(ed.razao_media) * 100, 2) AS pct_medio_vs_referencia,
    SUM(CASE WHEN ed.status_entradas LIKE '%Queda%' THEN 1 ELSE 0 END) AS qtd_quedas_atipicas,
    SUM(CASE WHEN ed.status_entradas LIKE '%Pico%' THEN 1 ELSE 0 END) AS qtd_picos_atipicos
FROM entrada_diaria ed
JOIN estacao e ON e.id_estacao = ed.id_estacao
JOIN linha l ON l.cod_linha = e.cod_linha
JOIN clima_diario cl ON cl.cidade = 'São Paulo' AND cl.data_ref = ed.data_ref
WHERE ed.media_ref IS NOT NULL
GROUP BY l.nome_linha, cl.condicao_chuva
ORDER BY l.nome_linha, cl.condicao_chuva;

-- C4) Taxa de Anomalias (Quedas e Picos Atípicos) por Faixa de Precipitação (mm)
SELECT
    CASE
        WHEN cl.precipitacao = 0 THEN '1-Seco (0 mm)'
        WHEN cl.precipitacao < 10 THEN '2-Chuva Fraca (< 10 mm)'
        ELSE '3-Chuva Forte (>= 10 mm)'
    END AS faixa_chuva,
    COUNT(DISTINCT ed.data_ref) AS dias_no_periodo,
    SUM(ed.entradas) AS total_entradas,
    SUM(CASE WHEN ed.status_entradas LIKE '%Queda%' THEN 1 ELSE 0 END) AS quedas_atipicas,
    SUM(CASE WHEN ed.status_entradas LIKE '%Pico%' THEN 1 ELSE 0 END) AS picos_atipicos,
    ROUND(100.0 * SUM(CASE WHEN ed.status_entradas LIKE '%Queda%' THEN 1 ELSE 0 END) / COUNT(*), 2) AS taxa_quedas_pct
FROM entrada_diaria ed
JOIN clima_diario cl ON cl.cidade = 'São Paulo' AND cl.data_ref = ed.data_ref
GROUP BY faixa_chuva
ORDER BY faixa_chuva;

-- C5) Estações e Meses críticos (Desempenho abaixo de 90% do esperado ou com >= 2 quedas atípicas)
SELECT
    l.nome_linha AS linha,
    e.nome_estacao AS estacao,
    cal.ano_mes,
    SUM(ed.entradas) AS entradas_realizadas,
    ROUND(SUM(ed.media_ref), 0) AS entradas_esperadas,
    ROUND(100.0 * SUM(ed.entradas) / NULLIF(SUM(ed.media_ref), 0), 2) AS pct_esperado,
    SUM(CASE WHEN ed.status_entradas LIKE '%Queda%' THEN 1 ELSE 0 END) AS quedas_atipicas
FROM entrada_diaria ed
JOIN estacao e ON e.id_estacao = ed.id_estacao
JOIN linha l ON l.cod_linha = e.cod_linha
JOIN calendario cal ON cal.data = ed.data_ref
WHERE ed.media_ref IS NOT NULL
GROUP BY l.nome_linha, e.nome_estacao, cal.ano_mes
HAVING (100.0 * SUM(ed.entradas) / NULLIF(SUM(ed.media_ref), 0)) < 90.0
    OR SUM(CASE WHEN ed.status_entradas LIKE '%Queda%' THEN 1 ELSE 0 END) >= 2
ORDER BY pct_esperado ASC, quedas_atipicas DESC;
