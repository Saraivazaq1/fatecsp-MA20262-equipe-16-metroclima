// tst_Conexao -- diagnóstico da conexão (NÃO carregar no modelo: desmarque Habilitar carga)
// Mostra a versão do SQLite e quantas linhas cada view devolve.
let
    Fonte = Odbc.Query(pConexaoODBC,
        "SELECT sqlite_version()                      AS versao,
                (SELECT COUNT(*) FROM dim_estacao)    AS dim_estacao,
                (SELECT COUNT(*) FROM dim_tempo)      AS dim_tempo,
                (SELECT COUNT(*) FROM dim_clima)      AS dim_clima,
                (SELECT COUNT(*) FROM fato_entradas)  AS fato_entradas,
                (SELECT SUM(entradas) FROM fato_entradas) AS soma_entradas")
in
    Fonte
// Esperado: dim_estacao 66 | dim_tempo 181 | dim_clima 181 | fato_entradas 11946 | soma_entradas 339840800
