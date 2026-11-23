// qTratamento_Base
let
    Fonte = stg_MetroClima_Bruto,
    ComOrigem = Table.AddIndexColumn(Fonte, "Linha_Origem", 2, 1, Int64.Type),
    DataTrat = Table.AddColumn(ComOrigem, "Data_Trat", each fnData([date]), type date),
    StatusData = Table.AddColumn(DataTrat, "Status_Data", each if [Data_Trat] = null then "Data inválida" else if [Data_Trat] < pDataInicio or [Data_Trat] > pDataFim then "Data fora do período" else "OK", type text),
    ChaveEstacao = Table.AddColumn(StatusData, "Chave_Estacao", each if [line_number] = null or [station_id] = null then null else Text.From([line_number]) & "|" & Text.Trim([station_id]), type text),
    EstacaoTrat = Table.AddColumn(ChaveEstacao, "Estacao_Trat", each if [station_name] = null then null else Text.Trim(Text.Clean(Text.From([station_name]))), type text),
    ChaveEvento = Table.AddColumn(EstacaoTrat, "Chave_Evento", each if [Data_Trat] = null or [line_number] = null or [station_id] = null then null else Date.ToText([Data_Trat], "yyyy-MM-dd") & "|" & Text.From([line_number]) & "|" & Text.Trim([station_id]), type text),
    Contagem = Table.Group(ChaveEvento, {"Chave_Evento"}, {{"Qtd_Chave", each Table.RowCount(_), Int64.Type}}),
    JuntaContagem = Table.NestedJoin(ChaveEvento, {"Chave_Evento"}, Contagem, {"Chave_Evento"}, "Contagem", JoinKind.LeftOuter),
    ExpandeContagem = Table.ExpandTableColumn(JuntaContagem, "Contagem", {"Qtd_Chave"}, {"Qtd_Chave"}),
    JuntaEstacao = Table.NestedJoin(ExpandeContagem, {"Chave_Estacao"}, cad_Estacoes, {"Chave"}, "Cadastro", JoinKind.LeftOuter),
    ExpandeEstacao = Table.ExpandTableColumn(JuntaEstacao, "Cadastro", {"Pos_Cad", "Sigla", "Estacao", "Media_Dia_Util", "Media_Sabado", "Media_Domingo"}, {"Pos_Cad", "Sigla_Cad", "Estacao_Cad", "Media_Dia_Util", "Media_Sabado", "Media_Domingo"}),
    Confere = Table.AddColumn(ExpandeEstacao, "Confere_Estacao", each if [Pos_Cad] = null then "Sem cadastro" else if [Estacao_Trat] <> [Estacao_Cad] or [station_code] <> [Sigla_Cad] then "Divergente" else "OK", type text),
    Mes = Table.AddColumn(Confere, "Mes", each if [Data_Trat] = null then null else Date.Month([Data_Trat]), Int64.Type),
    NomeMes = Table.AddColumn(Mes, "Nome_Mes", each if [Data_Trat] = null then null else Text.Proper(Date.MonthName([Data_Trat], "pt-BR")), type text),
    DiaNum = Table.AddColumn(NomeMes, "Dia_Semana_Num", each if [Data_Trat] = null then null else Date.DayOfWeek([Data_Trat], Day.Monday) + 1, Int64.Type),
    DiaNome = Table.AddColumn(DiaNum, "Dia_Semana", each if [Data_Trat] = null then null else Text.Proper(Date.DayOfWeekName([Data_Trat], "pt-BR")), type text),
    Feriado = Table.AddColumn(DiaNome, "Feriado", each if [Data_Trat] = null then "-" else if List.Contains(cad_Feriados[Data], [Data_Trat]) then "Sim" else "Não", type text),
    TipoDia = Table.AddColumn(Feriado, "Tipo_Dia", each if [Data_Trat] = null then "-" else if [Feriado] = "Sim" then "Feriado" else if [Dia_Semana_Num] = 6 then "Sábado" else if [Dia_Semana_Num] = 7 then "Domingo" else "Dia útil", type text),
    MediaRef = Table.AddColumn(TipoDia, "Media_Ref", each if [Pos_Cad] = null then null else if [Tipo_Dia] = "Dia útil" then [Media_Dia_Util] else if [Tipo_Dia] = "Sábado" then [Media_Sabado] else if [Tipo_Dia] = "Domingo" then [Media_Domingo] else null, type number),
    Razao = Table.AddColumn(MediaRef, "Razao_Media", each if [Media_Ref] = null or [Media_Ref] = 0 or [value] = null then null else Number.From([value]) / [Media_Ref], type number),
    StatusEntradas = Table.AddColumn(Razao, "Status_Entradas", each if [value] = null then "Vazia" else if not Value.Is([value], type number) then "Inválida" else if [value] < 0 then "Negativa" else if [value] = 0 then "Zero" else if [Razao_Media] <> null and [Razao_Media] < pLimiteQueda then "Queda atípica" else if [Razao_Media] <> null and [Razao_Media] > pLimitePico then "Pico atípico" else "OK", type text),
    Problemas = Table.AddColumn(StatusEntradas, "Problemas", each Text.Combine(List.RemoveNulls({if [Status_Data] <> "OK" then [Status_Data] else null, if [Confere_Estacao] = "Sem cadastro" then "Estação não cadastrada" else if [Confere_Estacao] = "Divergente" then "Estação divergente do cadastro" else null, if [Status_Entradas] <> "OK" then "Entradas: " & Text.Lower([Status_Entradas]) else null, if [Qtd_Chave] <> null and [Qtd_Chave] > 1 then "Chave de evento duplicada" else null}), "; "), type text),
    Motivo = Table.AddColumn(Problemas, "Motivo_Rejeicao", each Text.Combine(List.RemoveNulls({if [Status_Data] <> "OK" then [Status_Data] else null, if [Confere_Estacao] = "Sem cadastro" then "Estação não cadastrada" else if [Confere_Estacao] = "Divergente" then "Estação divergente do cadastro" else null, if List.Contains({"Vazia", "Inválida", "Negativa", "Zero"}, [Status_Entradas]) then "Entradas: " & Text.Lower([Status_Entradas]) else null, if [Qtd_Chave] <> null and [Qtd_Chave] > 1 then "Chave de evento duplicada" else null}), "; "), type text)
in
    Motivo
