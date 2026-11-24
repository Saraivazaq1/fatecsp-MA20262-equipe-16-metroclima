// dim_estacao -- view dim_estacao da etapa de SQL (= dEstacao da Etapa III)
// Grão: uma estação em uma linha (66). PK: id_estacao.
let
    Fonte = Odbc.Query(pConexaoODBC,
        "SELECT id_estacao, chave_estacao, estacao, sigla, linha, nome_linha,
                estacao_linha, media_dia_util, media_sabado, media_domingo,
                dias_registrados, dias_esperados
           FROM dim_estacao"),
    Tipos = Table.TransformColumnTypes(Fonte, {
        {"id_estacao", type text}, {"chave_estacao", type text}, {"estacao", type text},
        {"sigla", type text}, {"linha", Int64.Type}, {"nome_linha", type text},
        {"estacao_linha", type text}, {"media_dia_util", type number},
        {"media_sabado", type number}, {"media_domingo", type number},
        {"dias_registrados", Int64.Type}, {"dias_esperados", Int64.Type}}, "en-US")
in
    Tipos
