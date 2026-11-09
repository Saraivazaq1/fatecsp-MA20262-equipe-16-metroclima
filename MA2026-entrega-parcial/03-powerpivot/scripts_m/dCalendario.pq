// dCalendario

let
    Inicio = #date(2026, 1, 1),
    Fim = #date(2026, 6, 30),
    Dias = List.Dates(Inicio, Duration.Days(Fim - Inicio) + 1, #duration(1, 0, 0, 0)),
    Tabela = Table.FromList(Dias, Splitter.SplitByNothing(), type table [Data = date]),
    Ano = Table.AddColumn(Tabela, "Ano", each Date.Year([Data]), Int64.Type),
    Mes = Table.AddColumn(Ano, "Mes", each Date.Month([Data]), Int64.Type),
    NomeMes = Table.AddColumn(Mes, "NomeMes", each Text.Proper(Date.MonthName([Data], "pt-BR")), type text),
    MesAbrev = Table.AddColumn(NomeMes, "MesAbrev", each Text.Start([NomeMes], 3), type text),
    AnoMes = Table.AddColumn(MesAbrev, "AnoMes", each Date.ToText([Data], "yyyy-MM"), type text),
    Trimestre = Table.AddColumn(AnoMes, "Trimestre", each "T" & Text.From(Date.QuarterOfYear([Data])), type text),
    DiaSemana = Table.AddColumn(Trimestre, "DiaSemana", each Date.DayOfWeek([Data], Day.Monday) + 1, Int64.Type),
    NomeDia = Table.AddColumn(DiaSemana, "NomeDia", each Text.Proper(Date.DayOfWeekName([Data], "pt-BR")), type text),
    FimDeSemana = Table.AddColumn(NomeDia, "FimDeSemana", each if [DiaSemana] >= 6 then "Sim" else "Não", type text),
    Feriado = Table.AddColumn(FimDeSemana, "Feriado", each if List.Contains(lst_Feriados, [Data]) then "Sim" else "Não", type text),
    DiaAtipico = Table.AddColumn(Feriado, "Dia_Atipico", each if List.Contains(lst_DiasAtipicos, [Data]) then "Sim" else "Não", type text)
in
    DiaAtipico