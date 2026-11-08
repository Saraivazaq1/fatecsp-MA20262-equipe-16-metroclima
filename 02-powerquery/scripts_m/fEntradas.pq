// fEntradas
let
    Fonte = qTratamento_Base,
    Aceitas = Table.SelectRows(Fonte, each [Motivo_Rejeicao] = null or [Motivo_Rejeicao] = ""),
    Colunas = Table.SelectColumns(Aceitas, {"Linha_Origem", "date", "year", "line_number", "station_id", "station_name", "station_code", "line_name_pt", "value", "Estacao_Trat", "Data_Trat", "Status_Data", "Chave_Estacao", "Pos_Cad", "Sigla_Cad", "Confere_Estacao", "Mes", "Nome_Mes", "Dia_Semana_Num", "Dia_Semana", "Feriado", "Tipo_Dia", "Media_Ref", "Razao_Media", "Status_Entradas", "Problemas"}),
    Renomeadas = Table.RenameColumns(Colunas, {{"date", "Data"}, {"year", "Ano"}, {"line_number", "Linha"}, {"station_id", "ID_Estacao"}, {"station_name", "Estacao"}, {"station_code", "Sigla"}, {"line_name_pt", "Nome_Linha"}, {"value", "Entradas"}})
in
    Renomeadas
