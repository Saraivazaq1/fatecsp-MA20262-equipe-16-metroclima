-- metroclima_conferencia.sql
-- Batimento obrigatório: prova diferença 0 entre Excel (Etapa 2/3) e SQLite (Etapa 5)

-- K1) Batimento volumétrico Staging vs. Banco Final
SELECT
    'Linhas aceitas (fEntradas)' AS indicador,
    (SELECT COUNT(*) FROM stg_entradas) AS staging,
    (SELECT COUNT(*) FROM entrada_diaria) AS banco,
    (SELECT COUNT(*) FROM entrada_diaria) - (SELECT COUNT(*) FROM stg_entradas) AS diferenca
UNION ALL
SELECT
    'Soma de Entradas',
    (SELECT SUM(CAST(REPLACE(REPLACE(TRIM(Entradas), '.', ''), ',', '') AS INT)) FROM stg_entradas),
    (SELECT SUM(entradas) FROM entrada_diaria),
    (SELECT SUM(entradas) FROM entrada_diaria) - (SELECT SUM(CAST(REPLACE(REPLACE(TRIM(Entradas), '.', ''), ',', '') AS INT)) FROM stg_entradas)
UNION ALL
SELECT
    'Estações cadastradas',
    (SELECT COUNT(*) FROM stg_estacao),
    (SELECT COUNT(*) FROM estacao),
    (SELECT COUNT(*) FROM estacao) - (SELECT COUNT(*) FROM stg_estacao)
UNION ALL
SELECT
    'Dias no calendário',
    181,
    (SELECT COUNT(*) FROM calendario),
    (SELECT COUNT(*) FROM calendario) - 181;

-- K2) Integridade referencial
PRAGMA foreign_key_check;

-- K3) Verificação de chaves órfãs
SELECT 'Entradas sem estação' AS teste, COUNT(*) AS ocorrencias
FROM entrada_diaria ed LEFT JOIN estacao e ON e.id_estacao = ed.id_estacao
WHERE e.id_estacao IS NULL
UNION ALL
SELECT 'Entradas fora do calendário', COUNT(*)
FROM entrada_diaria ed LEFT JOIN calendario cal ON cal.data = ed.data_ref
WHERE cal.data IS NULL
UNION ALL
SELECT 'Estações sem linha', COUNT(*)
FROM estacao e LEFT JOIN linha l ON l.cod_linha = e.cod_linha
WHERE l.cod_linha IS NULL;

-- K4) Batimento por Linha com a aba Validacao do Excel (Etapa 3)
SELECT
    de.nome_linha,
    SUM(fe.entradas) AS total_entradas,
    SUM(fe.flag_queda_atipica) AS qtd_quedas_atipicas,
    SUM(fe.flag_pico_atipico) AS qtd_picos_atipicos
FROM fato_entradas fe
JOIN dim_estacao de ON de.id_estacao = fe.id_estacao
GROUP BY de.nome_linha
UNION ALL
SELECT
    'TOTAL GERAL',
    SUM(entradas),
    SUM(flag_queda_atipica),
    SUM(flag_pico_atipico)
FROM fato_entradas;
