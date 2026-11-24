// fato_entradas -- view fato_entradas da etapa de SQL (= fEntradas da Etapa III)
// Grão: uma estação em um dia (66 x 181 = 11.946). Nenhuma regra de limpeza aqui:
// media_ref, razao_media, status e flags já vêm do banco.
let
    Fonte = Odbc.Query(pConexaoODBC,
        "SELECT data, id_estacao, linha, entradas, tipo_dia, media_ref, razao_media,
                status_entradas, flag_queda_atipica, flag_pico_atipico
           FROM fato_entradas"),
    Tipos = Table.TransformColumnTypes(Fonte, {
        {"data", type date}, {"id_estacao", type text}, {"linha", Int64.Type},
        {"entradas", Int64.Type}, {"tipo_dia", type text},
        {"media_ref", type number}, {"razao_media", type number},
        {"status_entradas", type text},
        {"flag_queda_atipica", Int64.Type}, {"flag_pico_atipico", Int64.Type}}, "en-US")
in
    Tipos
