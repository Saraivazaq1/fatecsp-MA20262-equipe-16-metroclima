-- metroclima_clima_SIMULADO.sql
-- PROVISÓRIO (apagar na Etapa 6 quando integrar a API Open-Meteo)
PRAGMA foreign_keys = ON;

DELETE FROM clima_diario;

INSERT INTO clima_diario (cidade, data_ref, temp_max, temp_min, precipitacao, condicao_chuva)
SELECT
    'São Paulo',
    data,
    CASE WHEN mes IN (1, 2, 3) THEN 29.5 ELSE 23.0 END,
    CASE WHEN mes IN (1, 2, 3) THEN 19.5 ELSE 14.0 END,
    CASE 
        WHEN CAST(STRFTIME('%d', data) AS INT) IN (4, 12, 19, 25) THEN 28.4
        WHEN CAST(STRFTIME('%d', data) AS INT) IN (2, 8, 15, 22) THEN 6.2
        ELSE 0.0
    END,
    CASE 
        WHEN CAST(STRFTIME('%d', data) AS INT) IN (4, 12, 19, 25) THEN 'Chuva Forte'
        WHEN CAST(STRFTIME('%d', data) AS INT) IN (2, 8, 15, 22) THEN 'Chuva Leve'
        ELSE 'Sem Chuva'
    END
FROM calendario;
