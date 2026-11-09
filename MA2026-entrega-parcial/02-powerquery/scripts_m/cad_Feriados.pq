// cad_Feriados
let
    Fonte = Excel.CurrentWorkbook(){[Name="Tab_Feriados"]}[Content],
    Tipos = Table.TransformColumnTypes(
        Fonte,
        {
            {"Data", type date},
            {"Descricao", type text},
            {"Tipo", type text}
        },
        "pt-BR"
    )
in
    Tipos
