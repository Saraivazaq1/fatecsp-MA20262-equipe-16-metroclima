// dEstacao

let
    Fonte = cad_Etapa2{[Item = "dEstacao", Kind = "Table"]}[Data],
    Tipos = Table.TransformColumnTypes(Fonte, {
        {"Chave", type text}, {"Linha", Int64.Type}, {"ID_Estacao", type text},
        {"Sigla", type text}, {"Estacao", type text}, {"Nome_Linha", type text},
        {"Media_Dia_Util", type number}, {"Media_Sabado", type number},
        {"Media_Domingo", type number}, {"Dias_Registrados", Int64.Type},
        {"Dias_Esperados", Int64.Type}, {"Diferenca_Dias", Int64.Type}}),
    Rotulo = Table.AddColumn(Tipos, "Estacao_Linha",
        each [Estacao] & " (L" & Text.From([Linha]) & ")", type text)
in
    Rotulo