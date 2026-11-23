// dEstacao
let
    Fonte = cad_Estacoes,
    Dimensao = Table.SelectColumns(
        Fonte,
        {
            "Chave",
            "Linha",
            "ID_Estacao",
            "Sigla",
            "Estacao",
            "Nome_Linha",
            "Media_Dia_Util",
            "Media_Sabado",
            "Media_Domingo",
            "Dias_Registrados",
            "Dias_Esperados",
            "Diferenca_Dias"
        }
    )
in
    Dimensao
