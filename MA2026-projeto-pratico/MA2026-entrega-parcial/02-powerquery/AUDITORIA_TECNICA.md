# Auditoria técnica — MetroClima Etapa 02

Auditoria estática realizada sobre os arquivos do pacote recebido. Não executa Power Query nem substitui o teste `Dados > Atualizar Tudo` no Excel desktop.

| Verificação | Resultado |
|---|---|
| Origem `Tab_Bruto` | 11.946 linhas × 9 colunas |
| Nulos na origem | 0 |
| Chaves de evento duplicadas (data + linha + estação) | 0 |
| Datas da origem | 01/01/2026 a 30/06/2026 |
| Valores `value` não numéricos na origem atual | 0 |
| Registros em `fEntradas` | 11.946 |
| Colunas em `fEntradas` | 26 |
| Registros em `Rejeitados` | 0 |
| Registros em `dEstacao` | 66 |
| Reconciliação | 11.946 = 11.946 + 0; diferença 0 |
| `Conf_Motivos` | 0 linhas |
| `Conf_Colunas` | OK |
| Sinalizações de queda atípica | 69 |
| Sinalizações de pico atípico | 5 |
| Pendências de auditoria | 74, todas `Pendente de esclarecimento` |
| Comparação CSV × tabela `fEntradas` | 11.946 × 26; nenhuma divergência |

## Limite da auditoria

A execução de atualização das consultas no Excel desktop permanece a cargo do responsável local. A origem é uma tabela interna do arquivo (`Tab_Bruto`), portanto o teste equivalente ao reenvio de arquivos do exemplo CaféData é atualizar todas as consultas e conferir a manutenção dos totais, sem inserir registros artificiais.

## Limitação de tipagem observada

`stg_MetroClima_Bruto` converte `value` diretamente para número. Assim, texto não conversível pode gerar erro de tipo antes de `qTratamento_Base` classificar um valor como inválido. A origem atual não contém valores não numéricos; a limitação fica documentada para eventual ampliação da entrada.
