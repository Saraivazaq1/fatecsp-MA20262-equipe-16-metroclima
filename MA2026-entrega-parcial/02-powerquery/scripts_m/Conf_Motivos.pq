// Conf_Motivos
let
    Fonte = Rejeitados,
    Lista = Table.AddColumn(
        Fonte,
        "Lista_Motivos",
        each Text.Split([Motivo_Rejeicao], "; "),
        type list
    ),
    Expandida = Table.ExpandListColumn(Lista, "Lista_Motivos"),
    Agrupada = Table.Group(
        Expandida,
        {"Lista_Motivos"},
        {{"Linhas", each Table.RowCount(_), Int64.Type}}
    ),
    Renomeada = Table.RenameColumns(
        Agrupada,
        {{"Lista_Motivos", "Motivo"}}
    ),
    Ordenada = Table.Sort(
        Renomeada,
        {{"Linhas", Order.Descending}, {"Motivo", Order.Ascending}}
    )
in
    Ordenada
