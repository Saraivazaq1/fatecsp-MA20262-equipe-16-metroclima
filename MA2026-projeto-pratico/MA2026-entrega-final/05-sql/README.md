# Etapa 5 — Banco de Dados & SQL (`MetroClima`)

## Objetivo
Persistir os dados auditados de demanda de passageiros das Linhas **1-Azul**, **2-Verde**, **3-Vermelha** e **15-Prata** do Metrô de São Paulo em um banco relacional SQLite (`metroclima.db`), validar integridade referencial, executar consultas analíticas investigando o impacto das chuvas e expor a camada em estrela (`dim_*` e `fato_entradas`) para o Power BI.

## Ordem de Execução
1. Abrir/criar `metroclima.db` no DB Browser for SQLite com `PRAGMA foreign_keys = ON;`
2. Executar `metroclima_ddl.sql`
3. Importar `csv/dEstacao.csv` em `stg_estacao` e `csv/fEntradas.csv` em `stg_entradas` (separador `;`, UTF-8)
4. Executar `metroclima_carga.sql`
5. Executar `metroclima_clima_SIMULADO.sql`
6. Executar `metroclima_views.sql`
7. Executar `metroclima_consultas.sql` e `metroclima_conferencia.sql`

## Batimento Oficial com a Etapa 3 (`MetroClima_03_PowerPivot.xlsx`)

| Indicador | Etapa 3 (Power Pivot) | Banco (`metroclima.db`) | Diferença |
| :--- | :---: | :---: | :---: |
| **Entradas (Soma)** | 339.840.800 | 339.840.800 | **0** |
| **Linhas aceitas (`fEntradas`)** | 11.946 | 11.946 | **0** |
| **Estações (`dEstacao`)** | 66 | 66 | **0** |
| **Dias (`dCalendario`)** | 181 | 181 | **0** |
| **Quedas atípicas** | 69 | 69 | **0** |
| **Picos atípicos** | 5 | 5 | **0** |
| **Total Linha 1-Azul** | 118.199.000 | 118.199.000 | **0** |
| **Total Linha 2-Verde** | 77.693.700 | 77.693.700 | **0** |
| **Total Linha 3-Vermelha** | 130.999.000 | 130.999.000 | **0** |
| **Total Linha 15-Prata** | 12.949.100 | 12.949.100 | **0** |
