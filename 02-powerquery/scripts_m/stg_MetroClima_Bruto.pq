// stg_MetroClima_Bruto
let
    Fonte = Excel.CurrentWorkbook(){[Name="Tab_Bruto"]}[Content],
    Tipos = Table.TransformColumnTypes(
        Fonte,
        {
            {"date", type any},
            {"year", Int64.Type},
            {"line_number", Int64.Type},
            {"station_id", type text},
            {"station_name", type text},
            {"station_code", type text},
            {"line_name", type text},
            {"line_name_pt", type text},
            {"value", type number}
        },
        "pt-BR"
    )
in
    Tipos
