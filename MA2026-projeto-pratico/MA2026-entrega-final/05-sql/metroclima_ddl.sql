-- metroclima_ddl.sql
-- Estrutura do banco relacional MetroClima (Etapa 5 - ILP590 Fatec-SP)
-- SGBD de referência: SQLite 3 (DB Browser for SQLite)

PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS entrada_diaria;
DROP TABLE IF EXISTS clima_diario;
DROP TABLE IF EXISTS estacao;
DROP TABLE IF EXISTS linha;
DROP TABLE IF EXISTS calendario;
DROP TABLE IF EXISTS stg_entradas;
DROP TABLE IF EXISTS stg_estacao;

-- 1) Dimensões / Cadastros (Normalizadas em 3FN)
CREATE TABLE linha (
    cod_linha VARCHAR(10) NOT NULL,
    nome_linha VARCHAR(30) NOT NULL,
    CONSTRAINT pk_linha PRIMARY KEY (cod_linha),
    CONSTRAINT ck_linha_valida CHECK (nome_linha IN ('Azul', 'Verde', 'Vermelha', 'Prata'))
);

CREATE TABLE estacao (
    id_estacao VARCHAR(15) NOT NULL,
    chave_estacao VARCHAR(60) NOT NULL,
    nome_estacao VARCHAR(60) NOT NULL,
    sigla VARCHAR(10) NOT NULL,
    cod_linha VARCHAR(10) NOT NULL,
    media_dia_util DECIMAL(12,2) NOT NULL DEFAULT 0,
    media_sabado DECIMAL(12,2) NOT NULL DEFAULT 0,
    media_domingo DECIMAL(12,2) NOT NULL DEFAULT 0,
    dias_registrados INT,
    dias_esperados INT,
    CONSTRAINT pk_estacao PRIMARY KEY (id_estacao),
    CONSTRAINT fk_estacao_linha FOREIGN KEY (cod_linha) REFERENCES linha (cod_linha),
    CONSTRAINT ck_medias_nao_negativas CHECK (media_dia_util >= 0 AND media_sabado >= 0 AND media_domingo >= 0)
);

CREATE TABLE calendario (
    data DATE NOT NULL,
    ano INT NOT NULL,
    mes INT NOT NULL,
    nome_mes VARCHAR(15) NOT NULL,
    ano_mes CHAR(7) NOT NULL,
    mes_inicio DATE NOT NULL,
    trimestre CHAR(2) NOT NULL,
    dia_semana INT NOT NULL,
    nome_dia VARCHAR(15) NOT NULL,
    fim_de_semana CHAR(3) NOT NULL,
    feriado CHAR(3) NOT NULL,
    CONSTRAINT pk_calendario PRIMARY KEY (data)
);

-- 2) Fato Principal (Grão: 1 estação em 1 dia)
CREATE TABLE entrada_diaria (
    data_ref DATE NOT NULL,
    id_estacao VARCHAR(15) NOT NULL,
    entradas INT NOT NULL,
    tipo_dia VARCHAR(15) NOT NULL,
    media_ref DECIMAL(12,2),
    razao_media DECIMAL(8,4),
    status_entradas VARCHAR(25) NOT NULL,
    CONSTRAINT pk_entrada_diaria PRIMARY KEY (data_ref, id_estacao),
    CONSTRAINT fk_entrada_calendario FOREIGN KEY (data_ref) REFERENCES calendario (data),
    CONSTRAINT fk_entrada_estacao FOREIGN KEY (id_estacao) REFERENCES estacao (id_estacao),
    CONSTRAINT ck_entradas_validas CHECK (entradas >= 0)
);

-- 3) Fator Externo (Reservada para API Open-Meteo na Etapa 6)
CREATE TABLE clima_diario (
    cidade VARCHAR(40) NOT NULL,
    data_ref DATE NOT NULL,
    temp_max DECIMAL(4,1),
    temp_min DECIMAL(4,1),
    precipitacao DECIMAL(5,1) NOT NULL DEFAULT 0,
    condicao_chuva VARCHAR(20) NOT NULL,
    CONSTRAINT pk_clima_diario PRIMARY KEY (cidade, data_ref),
    CONSTRAINT fk_clima_calendario FOREIGN KEY (data_ref) REFERENCES calendario (data)
);

-- 4) Índices nas Chaves Estrangeiras e Filtros Frequentes
CREATE INDEX ix_entrada_data ON entrada_diaria (data_ref);
CREATE INDEX ix_entrada_estacao ON entrada_diaria (id_estacao);
CREATE INDEX ix_entrada_status ON entrada_diaria (status_entradas);
CREATE INDEX ix_estacao_linha ON estacao (cod_linha);
CREATE INDEX ix_calendario_mes ON calendario (ano_mes);

-- 5) Tabelas de Staging (Recebem os CSVs da Etapa 2 exatamente como vieram)
CREATE TABLE stg_estacao (
    ID_Estacao TEXT,
    Chave TEXT,
    Estacao TEXT,
    Sigla TEXT,
    Linha TEXT,
    Nome_Linha TEXT,
    Estacao_Linha TEXT,
    Media_Dia_Util TEXT,
    Media_Sabado TEXT,
    Media_Domingo TEXT,
    Dias_Registrados TEXT,
    Dias_Esperados TEXT,
    Diferenca_Dias TEXT
);

CREATE TABLE stg_entradas (
    Data TEXT,
    Data_Trat TEXT,
    Ano TEXT,
    Mes TEXT,
    Nome_Mes TEXT,
    Dia_Semana TEXT,
    Dia_Semana_Num TEXT,
    Feriado TEXT,
    ID_Estacao TEXT,
    Chave_Estacao TEXT,
    Linha TEXT,
    Nome_Linha TEXT,
    Estacao TEXT,
    Estacao_Trat TEXT,
    Sigla TEXT,
    Sigla_Cad TEXT,
    Entradas TEXT,
    Tipo_Dia TEXT,
    Media_Ref TEXT,
    Razao_Media TEXT,
    Status_Entradas TEXT,
    Confere_Estacao TEXT,
    Status_Data TEXT,
    Pos_Cad TEXT,
    Problemas TEXT,
    Linha_Origem TEXT
);
