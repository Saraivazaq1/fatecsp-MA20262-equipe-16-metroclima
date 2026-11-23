-- metroclima_diagnostico.sql
-- Consultas de diagnóstico na staging caso alguma restrição barre a carga
SELECT TRIM(Data_Trat) AS data, TRIM(ID_Estacao) AS estacao, COUNT(*) AS duplicatas
FROM stg_entradas
GROUP BY TRIM(Data_Trat), TRIM(ID_Estacao)
HAVING COUNT(*) > 1;

SELECT DISTINCT TRIM(e.ID_Estacao) AS estacao_orfa
FROM stg_entradas e
LEFT JOIN stg_estacao d ON TRIM(d.ID_Estacao) = TRIM(e.ID_Estacao)
WHERE d.ID_Estacao IS NULL;
