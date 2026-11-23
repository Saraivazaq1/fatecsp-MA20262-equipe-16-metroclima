// Rejeitados
let
    Fonte = qTratamento_Base,
    Filtrados = Table.SelectRows(Fonte, each [Motivo_Rejeicao] <> null and [Motivo_Rejeicao] <> ""),
    Ordenados = Table.Sort(Filtrados, {{"Linha_Origem", Order.Ascending}})
in
    Ordenados
