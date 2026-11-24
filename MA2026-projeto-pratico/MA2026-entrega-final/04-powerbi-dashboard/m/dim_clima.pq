// dim_clima -- view dim_clima da etapa de SQL (clima_diario SIMULADO até a Etapa 6 / API Open-Meteo)
// Grão: um dia em São Paulo (181). PK no modelo: data.
// O filtro cidade = 'São Paulo' é o mesmo das consultas C3 e C4 (todas as estações estão em SP).
// faixa_chuva: MESMA regra CASE da consulta C4 (o número na frente garante a ordem).
let
    Fonte = Odbc.Query(pConexaoODBC,
        "SELECT data, cidade, temp_max, temp_min, precipitacao, condicao_chuva
           FROM dim_clima
          WHERE cidade = 'São Paulo'"),
    Tipos = Table.TransformColumnTypes(Fonte, {
        {"data", type date}, {"cidade", type text},
        {"temp_max", type number}, {"temp_min", type number},
        {"precipitacao", type number}, {"condicao_chuva", type text}}, "en-US"),
    ComFaixa = Table.AddColumn(Tipos, "faixa_chuva",
        each if [precipitacao] = null then "0-Sem dado"
             else if [precipitacao] = 0 then "1-Seco (0 mm)"
             else if [precipitacao] < 10 then "2-Chuva Fraca (< 10 mm)"
             else "3-Chuva Forte (>= 10 mm)",
        type text),
    // só para ordenar condicao_chuva no eixo (Sem Chuva -> Chuva Leve -> Chuva Forte)
    ComOrdem = Table.AddColumn(ComFaixa, "ordem_condicao",
        each if [condicao_chuva] = "Sem Chuva" then 1
             else if [condicao_chuva] = "Chuva Leve" then 2
             else if [condicao_chuva] = "Chuva Forte" then 3
             else 9,
        Int64.Type)
in
    ComOrdem
