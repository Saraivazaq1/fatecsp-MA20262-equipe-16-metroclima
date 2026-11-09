// lst_Feriados

let
    Fonte = cad_Etapa2{[Item = "Tab_Feriados", Kind = "Table"]}[Data],
    Datas = List.Transform(Fonte[Data], each Date.From(_))
in
    Datas