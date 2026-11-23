// fEntradas

let
    Fonte = cad_Etapa2{[Item = "fEntradas", Kind = "Table"]}[Data],
    Tipos = Table.TransformColumnTypes(Fonte, {
        {"Linha_Origem", Int64.Type}, {"Ano", Int64.Type}, {"Linha", Int64.Type},
        {"ID_Estacao", type text}, {"Estacao", type text}, {"Sigla", type text},
        {"Nome_Linha", type text}, {"Entradas", Int64.Type}, {"Estacao_Trat", type text},
        {"Status_Data", type text}, {"Chave_Estacao", type text}, {"Pos_Cad", Int64.Type},
        {"Sigla_Cad", type text}, {"Confere_Estacao", type text}, {"Mes", Int64.Type},
        {"Nome_Mes", type text}, {"Dia_Semana_Num", Int64.Type}, {"Dia_Semana", type text},
        {"Feriado", type text}, {"Tipo_Dia", type text}, {"Media_Ref", type number},
        {"Razao_Media", type number}, {"Status_Entradas", type text}, {"Problemas", type text}}),
    Datas = Table.TransformColumns(Tipos, {
        {"Data", each Date.From(_), type date},
        {"Data_Trat", each Date.From(_), type date}})
in
    Datas