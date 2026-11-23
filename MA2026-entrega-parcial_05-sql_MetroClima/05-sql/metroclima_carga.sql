-- metroclima_carga.sql
-- Carga DML das tabelas de staging para as tabelas finais normalizadas
PRAGMA foreign_keys = ON;

DELETE FROM entrada_diaria;
DELETE FROM estacao;
DELETE FROM linha;
DELETE FROM calendario;

-- 1) Gerar calendario contínuo (01/01/2026 a 30/06/2026 = 181 dias)
INSERT INTO calendario
    (data, ano, mes, nome_mes, ano_mes, mes_inicio, trimestre,
     dia_semana, nome_dia, fim_de_semana, feriado)
WITH RECURSIVE dias (d) AS (
    SELECT DATE('2026-01-01')
    UNION ALL
    SELECT DATE(d, '+1 day') FROM dias WHERE d < '2026-06-30'
)
SELECT
    d,
    CAST(SUBSTR(d, 1, 4) AS INT),
    CAST(SUBSTR(d, 6, 2) AS INT),
    CASE CAST(SUBSTR(d, 6, 2) AS INT)
        WHEN 1 THEN 'Janeiro' WHEN 2 THEN 'Fevereiro' WHEN 3 THEN 'Março'
        WHEN 4 THEN 'Abril'   WHEN 5 THEN 'Maio'      WHEN 6 THEN 'Junho'
        WHEN 7 THEN 'Julho'   WHEN 8 THEN 'Agosto'    WHEN 9 THEN 'Setembro'
        WHEN 10 THEN 'Outubro' WHEN 11 THEN 'Novembro' ELSE 'Dezembro' END,
    SUBSTR(d, 1, 7),
    SUBSTR(d, 1, 7) || '-01',
    'T' || ((CAST(SUBSTR(d, 6, 2) AS INT) + 2) / 3),
    (CAST(STRFTIME('%w', d) AS INT) + 6) % 7 + 1,
    CASE CAST(STRFTIME('%w', d) AS INT)
        WHEN 0 THEN 'domingo' WHEN 1 THEN 'segunda-feira' WHEN 2 THEN 'terça-feira'
        WHEN 3 THEN 'quarta-feira' WHEN 4 THEN 'quinta-feira' WHEN 5 THEN 'sexta-feira'
        ELSE 'sábado' END,
    CASE WHEN STRFTIME('%w', d) IN ('0', '6') THEN 'Sim' ELSE 'Não' END,
    CASE WHEN d IN ('2026-01-01', '2026-01-25', '2026-02-17', '2026-04-03', '2026-04-21', '2026-05-01', '2026-06-04')
         THEN 'Sim' ELSE 'Não' END
FROM dias;

-- 2) Carregar dimensão linha (4 linhas: 1-Azul, 2-Verde, 3-Vermelha, 15-Prata)
INSERT INTO linha (cod_linha, nome_linha)
SELECT DISTINCT
    TRIM(Linha),
    TRIM(Nome_Linha)
FROM stg_estacao
WHERE TRIM(Linha) IS NOT NULL AND TRIM(Linha) <> '';

-- 3) Carregar dimensão estacao (66 estações)
INSERT INTO estacao (
    id_estacao, chave_estacao, nome_estacao, sigla, cod_linha,
    media_dia_util, media_sabado, media_domingo, dias_registrados, dias_esperados
)
SELECT
    TRIM(ID_Estacao),
    TRIM(Chave),
    TRIM(Estacao),
    TRIM(Sigla),
    TRIM(Linha),
    CAST(REPLACE(REPLACE(COALESCE(NULLIF(TRIM(Media_Dia_Util), ''), '0'), '.', ''), ',', '.') AS DECIMAL(12,2)),
    CAST(REPLACE(REPLACE(COALESCE(NULLIF(TRIM(Media_Sabado), ''), '0'), '.', ''), ',', '.') AS DECIMAL(12,2)),
    CAST(REPLACE(REPLACE(COALESCE(NULLIF(TRIM(Media_Domingo), ''), '0'), '.', ''), ',', '.') AS DECIMAL(12,2)),
    CAST(TRIM(Dias_Registrados) AS INT),
    CAST(TRIM(Dias_Esperados) AS INT)
FROM stg_estacao;

-- 4) Carregar fato entrada_diaria (11.946 registros)
INSERT INTO entrada_diaria (
    data_ref, id_estacao, entradas, tipo_dia, media_ref, razao_media, status_entradas
)
SELECT
    CASE 
        WHEN INSTR(TRIM(Data_Trat), '/') > 0 THEN 
            SUBSTR(TRIM(Data_Trat), 7, 4) || '-' || SUBSTR(TRIM(Data_Trat), 4, 2) || '-' || SUBSTR(TRIM(Data_Trat), 1, 2)
        ELSE SUBSTR(TRIM(Data_Trat), 1, 10)
    END,
    TRIM(ID_Estacao),
    CAST(REPLACE(REPLACE(TRIM(Entradas), '.', ''), ',', '') AS INT),
    TRIM(Tipo_Dia),
    CASE WHEN TRIM(Media_Ref) = '' OR TRIM(Media_Ref) IS NULL THEN NULL
         ELSE CAST(REPLACE(REPLACE(TRIM(Media_Ref), '.', ''), ',', '.') AS DECIMAL(12,2)) END,
    CASE WHEN TRIM(Razao_Media) = '' OR TRIM(Razao_Media) IS NULL THEN NULL
         ELSE CAST(REPLACE(REPLACE(TRIM(Razao_Media), '.', ''), ',', '.') AS DECIMAL(8,4)) END,
    TRIM(Status_Entradas)
FROM stg_entradas;
