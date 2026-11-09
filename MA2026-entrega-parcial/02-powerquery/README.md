# MetroClima — Etapa 02: Power Query

## Estrutura da entrega

- `MetroClima_02_PowerQuery.xlsx`: pasta de trabalho com consultas, parâmetros e tabelas carregadas.
- `scripts_m/`: 15 arquivos `.pq`, um por consulta/função/parâmetro, em UTF-8 e com comentário inicial `// NomeDaConsulta`.
- `dados_limpos/fEntradas.csv`: exportação da tabela final `fEntradas`, em CSV UTF-8 com BOM e delimitador vírgula.
- `evidencias/`: cinco capturas de tela das consultas, etapas aplicadas e conferências.
- `AUDITORIA_TECNICA.md`: resultados da auditoria estática e limitações conhecidas.

## Organização das consultas no Power Query

| Grupo | Consultas |
|---|---|
| `01_Parametros` | `pDataInicio`, `pDataFim`, `pLimiteQueda`, `pLimitePico` |
| `02_Funcoes` | `fnData` |
| `03_Cadastros` | `cad_Estacoes`, `cad_Feriados` |
| `04_Staging` | `stg_MetroClima_Bruto`, `qTratamento_Base` |
| `05_Saida` | `fEntradas`, `Rejeitados`, `dEstacao` |
| `06_Conferencia` | `Conf_Reconciliacao`, `Conf_Motivos`, `Conf_Colunas` |

## Finalidade das consultas

| Consulta | Finalidade |
|---|---|
| `pDataInicio` / `pDataFim` | Delimitam o período analisado. |
| `pLimiteQueda` / `pLimitePico` | Definem os limites relativos para sinalização de quedas e picos atípicos. |
| `fnData` | Padroniza/converte valores de data. |
| `stg_MetroClima_Bruto` | Lê e prepara a tabela de origem `Tab_Bruto`. |
| `cad_Estacoes` | Disponibiliza o cadastro de estações. |
| `cad_Feriados` | Disponibiliza o cadastro de feriados. |
| `qTratamento_Base` | Aplica as regras de tratamento, validação e classificação dos registros. |
| `fEntradas` | Retém os registros aceitos e tratados. |
| `Rejeitados` | Retém registros que não passaram pelas regras de aceitação. |
| `dEstacao` | Disponibiliza a dimensão cadastral de estações. |
| `Conf_Reconciliacao` | Confere a igualdade entre registros brutos, aceitos e rejeitados. |
| `Conf_Motivos` | Resume os motivos associados aos registros rejeitados. |
| `Conf_Colunas` | Confere o mapeamento e a presença das colunas esperadas. |

## Parâmetros utilizados

| Parâmetro | Valor |
|---|---:|
| `pDataInicio` | 01/01/2026 |
| `pDataFim` | 30/06/2026 |
| `pLimiteQueda` | 0,5 |
| `pLimitePico` | 2 |

## Regras de rejeição

Os registros são rejeitados quando apresentam uma ou mais das seguintes condições:

1. Data inválida ou fora do intervalo definido pelos parâmetros.
2. Estação ausente no cadastro ou divergência entre identificação/nome da estação.
3. Valor ausente, inválido, negativo ou igual a zero.
4. Chave de evento duplicada, considerando data + linha + estação.

Quedas e picos atípicos são sinalizações para análise, não rejeições automáticas. Os registros sinalizados permanecem na tabela aceita até que a causa seja esclarecida.

## Resultados de conferência

- Origem `Tab_Bruto`: 11.946 registros e 9 colunas.
- `fEntradas`: 11.946 registros e 26 colunas.
- `Rejeitados`: 0 registros.
- `dEstacao`: 66 registros.
- `Conf_Reconciliacao`: 11.946 = 11.946 + 0; diferença 0; situação OK.
- `Conf_Motivos`: sem motivos, coerente com a ausência de rejeitados.
- `Conf_Colunas`: OK, sem colunas ausentes ou não mapeadas.
- Auditoria de anomalias: 69 sinalizações de queda e 5 de pico, totalizando 74 pendências de esclarecimento.

## Pendências de esclarecimento

A aba `Auditoria` contém 74 registros com situação `Pendente de esclarecimento` (69 quedas e 5 picos). As observações orientam confirmar possíveis causas de calendário ou operação, como recesso, greve, obra ou evento. Os valores originais não devem ser alterados sem confirmação.

O cadastro também mantém `Data_Inicio` como `Pendente de esclarecimento`, embora o parâmetro utilizado esteja definido como 01/01/2026. Essas pendências estão documentadas e devem ser tratadas conforme as decisões da equipe; não foram resolvidas artificialmente nesta etapa.

## Evidências incluídas

1. `01_consultas_grupos.png` — grupos e consultas no painel do Power Query.
2. `02_etapas_fEntradas.png` — consulta principal e etapas aplicadas.
3. `03_conf_reconciliacao.png` — resultado da reconciliação.
4. `04_conf_motivos.png` — conferência dos motivos de rejeição.
5. `05_conf_colunas.png` — conferência do mapeamento de colunas.

## Atualização no Excel

A atualização foi executada no Excel pelo responsável local usando **Dados → Atualizar Tudo**, sem ocorrência de erros (confirmação informada após a atualização).

A origem utilizada é a tabela interna `Tab_Bruto`. Por isso, o teste de reenvio de arquivo descrito no exemplo CaféData não se aplica literalmente; o teste equivalente nesta pasta de trabalho é atualizar todas as consultas e verificar se os totais e as conferências permanecem consistentes.

## Limitação técnica conhecida

A consulta `stg_MetroClima_Bruto` converte a coluna `value` diretamente para número. Um texto não conversível poderia gerar erro de tipo antes de `qTratamento_Base` classificá-lo como inválido. A origem atual não contém valores não numéricos; a limitação fica registrada para eventual ampliação das fontes.

## Git — registro da entrega

Na raiz do repositório, execute:

```bash
git status
git add 02-powerquery
git commit -m "Etapa 2: consultas Power Query e dados limpos"
```

Se o repositório remoto for utilizado:

```bash
git push
```

Cada integrante deve realizar seu próprio commit, conforme a orientação do guia da etapa.
