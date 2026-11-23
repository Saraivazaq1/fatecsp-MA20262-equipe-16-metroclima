// Rejeitados

let
    Fonte = cad_Etapa2{[Item = "Rejeitados", Kind = "Table"]}[Data],
    TudoTexto = Table.TransformColumnTypes(Fonte,
                    List.Transform(Table.ColumnNames(Fonte), each {_, type text})),
    SoLinhas = Table.SelectRows(TudoTexto, each [Linha_Origem] <> null and [Linha_Origem] <> ""),
    Tipos = Table.TransformColumnTypes(SoLinhas, {{"Linha_Origem", Int64.Type}})
in
    Tipos