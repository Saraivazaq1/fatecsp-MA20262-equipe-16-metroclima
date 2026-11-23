// cad_Estacoes
let
    Fonte = Excel.CurrentWorkbook(){[Name="Tab_Estacoes"]}[Content],
    Tipos = Table.TransformColumnTypes(
        Fonte,
        {
            {"Chave", type text},
            {"Linha", Int64.Type},
            {"ID_Estacao", type text},
            {"Sigla", type text},
            {"Estacao", type text},
            {"Nome_Linha", type text},
            {"Media_Dia_Util", type number},
            {"Media_Sabado", type number},
            {"Media_Domingo", type number}
        },
        "pt-BR"
    ),
    Pos = Table.AddIndexColumn(Tipos, "Pos_Cad", 1, 1, Int64.Type)
in
    Pos
