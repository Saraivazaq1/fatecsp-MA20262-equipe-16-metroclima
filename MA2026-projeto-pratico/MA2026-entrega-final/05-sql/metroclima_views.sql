-- metroclima_views.sql
-- Camada analítica em estrela para o Power BI (Etapa 7)
DROP VIEW IF EXISTS fato_entradas;
DROP VIEW IF EXISTS dim_estacao;
DROP VIEW IF EXISTS dim_tempo;
DROP VIEW IF EXISTS dim_clima;

CREATE VIEW dim_estacao AS
SELECT
    e.id_estacao,
    e.chave_estacao,
    e.nome_estacao AS estacao,
    e.sigla,
    e.cod_linha AS linha,
    l.nome_linha,
    e.nome_estacao || ' (' || l.nome_linha || ')' AS estacao_linha,
    e.media_dia_util,
    e.media_sabado,
    e.media_domingo,
    e.dias_registrados,
    e.dias_esperados
FROM estacao e
JOIN linha l ON l.cod_linha = e.cod_linha;

CREATE VIEW dim_tempo AS
SELECT
    data,
    ano,
    mes,
    nome_mes,
    ano_mes,
    mes_inicio,
    trimestre,
    dia_semana,
    nome_dia,
    fim_de_semana,
    feriado
FROM calendario;

CREATE VIEW dim_clima AS
SELECT
    data_ref AS data,
    cidade,
    temp_max,
    temp_min,
    precipitacao,
    condicao_chuva
FROM clima_diario;

CREATE VIEW fato_entradas AS
SELECT
    ed.data_ref AS data,
    ed.id_estacao,
    e.cod_linha AS linha,
    ed.entradas,
    ed.tipo_dia,
    ed.media_ref,
    ed.razao_media,
    ed.status_entradas,
    CASE WHEN ed.status_entradas LIKE '%Queda%' THEN 1 ELSE 0 END AS flag_queda_atipica,
    CASE WHEN ed.status_entradas LIKE '%Pico%' THEN 1 ELSE 0 END AS flag_pico_atipico
FROM entrada_diaria ed
JOIN estacao e ON e.id_estacao = ed.id_estacao;
