// fnData
(valor as any) as nullable date =>
let
    T = try Date.From(valor, "pt-BR")
in
    if T[HasError] then null else T[Value]
