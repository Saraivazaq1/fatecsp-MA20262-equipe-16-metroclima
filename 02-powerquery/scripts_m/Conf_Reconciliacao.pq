// Conf_Reconciliacao
let
    Total_Bruto = Table.RowCount(stg_MetroClima_Bruto),
    Total_Aceitos = Table.RowCount(fEntradas),
    Total_Rejeitados = Table.RowCount(Rejeitados),
    Diferenca = Total_Bruto - Total_Aceitos - Total_Rejeitados,
    Resultado = #table(
        type table [
            Total_Bruto = Int64.Type,
            Total_Aceitos = Int64.Type,
            Total_Rejeitados = Int64.Type,
            Diferenca = Int64.Type,
            Situacao = text
        ],
        {
            {
                Total_Bruto,
                Total_Aceitos,
                Total_Rejeitados,
                Diferenca,
                if Diferenca = 0 then "OK" else "Divergência"
            }
        }
    )
in
    Resultado
