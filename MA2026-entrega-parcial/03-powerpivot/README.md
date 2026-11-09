# MetroClima — Etapa 3: Modelo de Dados e Power Pivot

## Objetivo da etapa

A Etapa 3 tem como objetivo consolidar os dados preparados na etapa anterior em um **Modelo de Dados do Excel**, organizar as tabelas e seus relacionamentos e criar medidas para analisar as entradas do metrô por linha, estação e período.

Também contempla a conferência dos resultados do modelo com os números de referência da Etapa 2, para verificar se a carga e as agregações preservaram os dados.

## Como abrir e atualizar

1. Abra o arquivo `MetroClima_03_PowerPivot.xlsx` no Excel.
2. Se o arquivo de origem estiver em outro local, abra as consultas/conexões e ajuste o parâmetro **`pArquivoEtapa2`** para apontar para o arquivo da Etapa 2.
3. No Excel, acesse **Dados → Atualizar Tudo**.
4. Aguarde a atualização das consultas e do Modelo de Dados. As tabelas dinâmicas e os indicadores vinculados ao modelo serão atualizados junto com os dados.

> Caso o nome do arquivo ou o caminho da origem seja diferente, mantenha o parâmetro apontando para o arquivo correto da Etapa 2 antes de atualizar.

## Tabelas e relacionamentos

O modelo utiliza uma tabela fato de entradas e dimensões para contextualizar as observações:

| Tabela | Papel | Conteúdo |
|---|---|---|
| `fEntradas` | Fato | Registros de entradas, com valores, data, identificação da estação/linha e campos de classificação/validação. |
| `dEstacao` | Dimensão | Cadastro das estações e informações associadas à linha, incluindo a referência de média utilizada na análise. |
| `dCalendario` | Dimensão | Datas e atributos de calendário, como mês, ano, trimestre e dia da semana. |

Os relacionamentos principais seguem o padrão estrela:

- `dEstacao` (lado **1**) → `fEntradas` (lado **muitos**), pela chave da estação.
- `dCalendario` (lado **1**) → `fEntradas` (lado **muitos**), pela data.

Assim, os filtros aplicados às dimensões de estação e calendário podem segmentar os registros da tabela fato.

O detalhamento das chaves, cardinalidades e do desenho do modelo está em [`docs/modelo_relacional.md`](docs/modelo_relacional.md).

## Medidas e perguntas respondidas

Abaixo estão as medidas identificadas no modelo e/ou utilizadas nos quadros de validação e análise desta etapa. Os nomes são mantidos conforme aparecem no arquivo.

| Medida | Pergunta que responde |
|---|---|
| `Entrada` | Qual é a quantidade total de entradas no contexto de filtros atual? |
| `Qtd Estações` | Quantas estações distintas estão representadas nos dados? |
| `Qtd Dias` | Quantos dias estão cobertos pela base? |
| `Média por estação` | Qual é a média de entradas por estação no contexto analisado? |
| `Média Esperada` | Qual é a quantidade de entradas esperada para o contexto, considerando a referência da estação e o tipo de dia? |
| `% Esperado` | Qual percentual das entradas observadas representa o total esperado? |
| `Qtd Quedas Atipicas` | Quantas ocorrências foram classificadas como quedas atípicas? |
| `Qtd Picos Atipicos` | Quantas ocorrências foram classificadas como picos atípicos? |
| `Conf Linhas fEntradas` | Quantas linhas válidas existem na tabela fato? |
| `Conf Linhas Rejeitados` | Quantas linhas foram rejeitadas no processo de carga/validação? |
| `Conf Linhas Lidas` | Quantas linhas foram lidas na origem? |
| `Conf Entradas sem Datas` | Existem entradas sem uma data válida associada? |
| `Conf PK Duplicada` | Existem chaves primárias duplicadas na tabela fato? |
| `Conf Dif Esperado` | Há diferença entre as entradas observadas e o valor esperado calculado? |

As medidas de conferência apoiam a validação da carga; as medidas de análise permitem comparar volumes observados e esperados, além de acompanhar as ocorrências atípicas.

## Resultados da conferência

A aba **`Conferencia`** compara os indicadores de referência da Etapa 2 com os valores calculados no Modelo de Dados da Etapa 3.

| Indicador | Etapa 2 (referência) | Modelo (Etapa 3) | Diferença |
|---|---:|---:|---:|
| Entradas (soma de `Entradas`) | 339.840.800 | 339.840.800 | 0 |
| Linhas aceitas | 11.946 | 11.946 | 0 |
| Linhas rejeitadas | 0 | 0 | 0 |
| Linhas lidas | 11.946 | 11.946 | 0 |
| Estações (linha + estação) | 66 | 66 | 0 |
| Dias | 181 | 181 | 0 |
| Quedas atípicas | 69 | 69 | 0 |
| Picos atípicos | 5 | 5 | 0 |

**Resultado:** todos os oito indicadores conferidos apresentam diferença igual a zero. Portanto, os totais e as contagens comparados entre a Etapa 2 e o Modelo de Dados da Etapa 3 coincidem.

A aba **`Validacao`** também apresenta a distribuição mensal das entradas por linha e a comparação entre entradas com referência e entradas esperadas. No total, foram registradas 332.538.700 entradas com referência, frente a aproximadamente 332.538.700 entradas esperadas (100% do esperado, considerando o arredondamento).

## Pendências herdadas da Etapa 2

As pendências abaixo permanecem abertas nesta etapa e **não devem ser interpretadas como erros já explicados ou corrigidos**:

- **74 atipicidades na tabela `Auditoria` permanecem com o status “Pendente de esclarecimento”**:
  - 69 quedas atípicas;
  - 5 picos atípicos.
- Das 69 quedas, **58 estão concentradas em 02/01/2026**. Essa concentração precisa ser investigada e esclarecida.
- O feriado de **Corpus Christi (04/06)** continua marcado como **“confirmar”**. A classificação do dia deve ser confirmada antes de tratar a referência de entradas como definitiva.

Esses itens devem continuar identificados como pendências até que haja confirmação da origem dos comportamentos e/ou validação das informações de calendário.

## Estrutura do arquivo

- `Validacao`: comparação mensal entre entradas observadas com referência e entradas esperadas, além da distribuição por linha das ocorrências atípicas.
- `Conferencia`: comparação dos indicadores da Etapa 2 com os resultados do Modelo de Dados da Etapa 3.
- Modelo de Dados: tabelas, relacionamentos e medidas usados nas análises.

---
