// Conf_Colunas
let
    Esperadas = {
        "date",
        "year",
        "line_number",
        "station_id",
        "station_name",
        "station_code",
        "line_name",
        "line_name_pt",
        "value"
    },
    Encontradas = Table.ColumnNames(stg_MetroClima_Bruto),
    NaoMapeadas = List.Difference(Encontradas, Esperadas),
    Ausentes = List.Difference(Esperadas, Encontradas),
    Resultado = #table(
        type table [
            Colunas_Nao_Mapeadas = text,
            Colunas_Ausentes = text,
            Resultado = text
        ],
        {{
            Text.Combine(NaoMapeadas, "; "),
            Text.Combine(Ausentes, "; "),
            if List.IsEmpty(NaoMapeadas) and List.IsEmpty(Ausentes)
            then "OK"
            else "Revisar"
        }}
    )
in
    Resultado
