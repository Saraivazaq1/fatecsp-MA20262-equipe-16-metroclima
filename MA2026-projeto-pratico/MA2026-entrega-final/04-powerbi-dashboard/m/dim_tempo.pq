// dim_tempo -- view dim_tempo da etapa de SQL (= dCalendario da Etapa III)
// Grão: um dia (01/01/2026 a 30/06/2026 = 181). PK: data. Marcar como tabela de datas.
let
    Fonte = Odbc.Query(pConexaoODBC,
        "SELECT data, ano, mes, nome_mes, ano_mes, mes_inicio, trimestre,
                dia_semana, nome_dia, fim_de_semana, feriado
           FROM dim_tempo"),
    Tipos = Table.TransformColumnTypes(Fonte, {
        {"data", type date}, {"ano", Int64.Type}, {"mes", Int64.Type},
        {"nome_mes", type text}, {"ano_mes", type text}, {"mes_inicio", type date},
        {"trimestre", type text}, {"dia_semana", Int64.Type}, {"nome_dia", type text},
        {"fim_de_semana", type text}, {"feriado", type text}}, "en-US")
in
    Tipos
