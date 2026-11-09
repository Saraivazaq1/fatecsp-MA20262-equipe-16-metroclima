// cad_Etapa2

let
    Fonte = Excel.Workbook(File.Contents(pArquivoEtapa2), null, true),
    #"Linhas Filtradas" = Table.SelectRows(Fonte, each ([Kind] = "Table"))
in
    #"Linhas Filtradas"