"""Gera as páginas do relatório MetroClima no formato PBIR (pasta .Report do .pbip)."""
import json, os, shutil, sys

OUT = sys.argv[1]  # pasta .../MetroClima_Dashboard.Report
VSCHEMA = "https://developer.microsoft.com/json-schemas/fabric/item/report/definition/visualContainer/2.15.0/schema.json"
PSCHEMA = "https://developer.microsoft.com/json-schemas/fabric/item/report/definition/page/2.1.0/schema.json"
W, H = 1280, 720

# ---------- helpers de expressão ----------
def col(t, c):
    return {"Column": {"Expression": {"SourceRef": {"Entity": t}}, "Property": c}}

def mea(m):
    return {"Measure": {"Expression": {"SourceRef": {"Entity": "_Medidas"}}, "Property": m}}

def ref(f):
    k = "Column" if "Column" in f else "Measure"
    return f[k]["Expression"]["SourceRef"]["Entity"] + "." + f[k]["Property"]

def lit(v):
    return {"expr": {"Literal": {"Value": v}}}

def s(v):  # literal de texto
    return lit("'" + v.replace("'", "''") + "'")

def proj(f, active=None):
    p = {"field": f, "queryRef": ref(f), "nativeQueryRef": ref(f).split(".", 1)[1]}
    if active is not None:
        p["active"] = active
    return p

def fx(m):  # cor/texto vindo de medida
    return {"expr": mea(m)}

ALL = [{"dataViewWildcard": {"matchingOption": 1}}]

# ---------- campos ----------
LIN = col("dim_estacao", "nome_linha")
EST = col("dim_estacao", "estacao")
ESTL = col("dim_estacao", "estacao_linha")
MES = col("dim_tempo", "nome_mes")
ANOMES = col("dim_tempo", "ano_mes")
DATA = col("dim_tempo", "data")
TIPO = col("fato_entradas", "tipo_dia")
COND = col("dim_clima", "condicao_chuva")
FAIXA = col("dim_clima", "faixa_chuva")

M = mea

# ---------- montagem de visuais ----------
class Page:
    def __init__(self, name, display, **extra):
        self.name, self.display, self.extra = name, display, extra
        self.visuals = []

    def add(self, vid, vtype, x, y, w, h, roles=None, title=None, objects=None,
            vco=None, filters=None, sort=None, extra=None):
        v = {"visualType": vtype}
        if roles:
            qs = {}
            for role, fields in roles.items():
                qs[role] = {"projections": [f if "queryRef" in f else proj(f) for f in fields]}
            v["query"] = {"queryState": qs}
            if sort:
                v["query"]["sortDefinition"] = {"sort": [{"field": f, "direction": d} for f, d in sort],
                                                "isDefaultSort": False}
        if objects:
            v["objects"] = objects
        vco = dict(vco or {})
        if title is not None:
            tp = {"show": lit("true")}
            tp["text"] = fx(title[3:]) if title.startswith("fx:") else s(title)
            vco["title"] = [{"properties": tp}]
        if vco:
            v["visualContainerObjects"] = vco
        if extra:
            v.update(extra)
        if vtype not in ("textbox", "shape", "actionButton", "pageNavigator"):
            v["drillFilterOtherVisuals"] = True
        doc = {"$schema": VSCHEMA, "name": vid,
               "position": {"x": x, "y": y, "z": len(self.visuals) * 1000, "height": h, "width": w,
                            "tabOrder": len(self.visuals) * 1000},
               "visual": v}
        if filters:
            doc["filterConfig"] = {"filters": filters}
        self.visuals.append(doc)
        return vid

    def write(self, root):
        pdir = os.path.join(root, "definition", "pages", self.name)
        os.makedirs(os.path.join(pdir, "visuals"), exist_ok=True)
        page = {"$schema": PSCHEMA, "name": self.name, "displayName": self.display,
                "displayOption": "FitToPage", "height": H, "width": W}
        if self.extra.get("type") == "Tooltip":
            page.update({"height": 240, "width": 320})
        page.update(self.extra)
        dump(os.path.join(pdir, "page.json"), page)
        for v in self.visuals:
            vd = os.path.join(pdir, "visuals", v["name"])
            os.makedirs(vd, exist_ok=True)
            dump(os.path.join(vd, "visual.json"), v)


def dump(path, obj):
    with open(path, "w", encoding="utf-8") as fh:
        json.dump(obj, fh, ensure_ascii=False, indent=2)


def textbox(pg, vid, x, y, w, h, text, size=20, color="#1F4E79", bold=True, bg=None):
    style = {"fontSize": f"{size}pt", "color": color}
    if bold:
        style["fontWeight"] = "bold"
    objs = {"general": [{"properties": {"paragraphs": [{"textRuns": [{"value": text, "textStyle": style}]}]}}]}
    vco = {}
    if bg:
        vco["background"] = [{"properties": {"show": lit("true"),
                                             "color": {"solid": {"color": lit("'" + bg + "'")}},
                                             "transparency": lit("0D")}}]
    pg.add(vid, "textbox", x, y, w, h, objects=objs, vco=vco)


def header(pg, pref, titulo, pergunta):
    textbox(pg, pref + "_tit", 16, 8, 640, 40, titulo, 20)
    textbox(pg, pref + "_perg", 16, 46, 640, 28, pergunta, 11, "#3B3B3B", False)
    pg.add(pref + "_nav", "pageNavigator", 690, 12, 440, 44,
           objects={"pages": [{"properties": {"showHiddenPages": lit("false")}}]})
    pg.add(pref + "_limpar", "actionButton", 1140, 12, 124, 44,
           objects={"text": [{"properties": {"show": lit("true"), "text": s("Limpar filtros")},
                              "selector": {"id": "default"}}],
                    "icon": [{"properties": {"shapeType": s("blank")}, "selector": {"id": "default"}}]},
           vco={"visualLink": [{"properties": {"show": lit("true"), "type": s("ClearAllSlicers")}}],
                "title": [{"properties": {"show": lit("false")}}]})


def slicer(pg, vid, x, y, w, h, field, titulo, group, mode="Dropdown"):
    pg.add(vid, "slicer", x, y, w, h, roles={"Values": [field]}, title=titulo,
           objects={"data": [{"properties": {"mode": s(mode)}}],
                    "header": [{"properties": {"show": lit("false")}}]},
           extra={"syncGroup": {"groupName": group, "fieldChanges": True, "filterChanges": True}})


def kpi_row(pg, base, x, y, w, h, measures, cols=None, font=16):
    """Uma fileira (ou grade) de cartões clássicos, um por medida, com valor completo."""
    cols = cols or len(measures)
    rows = -(-len(measures) // cols)
    gap = 8
    cw = (w - gap * (cols - 1)) / cols
    ch = (h - gap * (rows - 1)) / rows
    for i, m in enumerate(measures):
        vid = base if i == 0 else f"{base}_{i + 1}"
        r, c = divmod(i, cols)
        pg.add(vid, "card", round(x + c * (cw + gap)), round(y + r * (ch + gap)), round(cw), round(ch),
               roles={"Values": [M(m)]},
               objects={"labels": [{"properties": {"fontSize": lit(f"{font}D"), "labelDisplayUnits": lit("1D"),
                                                   "color": {"solid": {"color": lit("'#252423'")}}}}],
                        "categoryLabels": [{"properties": {"show": lit("true"), "fontSize": lit("9D")}}]})


def text_card(pg, vid, x, y, w, h, measure, size=13, color="#1F4E79"):
    """Cartão clássico que mostra uma medida de texto (título dinâmico)."""
    pg.add(vid, "card", x, y, w, h, roles={"Values": [M(measure)]},
           objects={"labels": [{"properties": {"fontSize": lit(f"{size}D"),
                                               "color": {"solid": {"color": lit("'" + color + "'")}}}}],
                    "categoryLabels": [{"properties": {"show": lit("false")}}]},
           vco={"background": [{"properties": {"show": lit("false")}}],
                "border": [{"properties": {"show": lit("false")}}],
                "dropShadow": [{"properties": {"show": lit("false")}}]})


def labels_on():
    return [{"properties": {"show": lit("true"), "labelDisplayUnits": lit("1D")}}]


def color_by(measure):
    return [{"properties": {"fill": {"solid": {"color": fx(measure)}}}, "selector": {"data": ALL}}]


def tooltip_page():
    return {"visualTooltip": [{"properties": {"show": lit("true"), "type": s("Canvas"),
                                              "section": s("dica_linha")}}]}


def measure_filter(name, measure, kind, value):
    return {"name": name, "field": mea(measure), "type": "Advanced",
            "filter": {"Version": 2, "From": [{"Name": "m", "Entity": "_Medidas", "Type": 0}],
                       "Where": [{"Condition": {"Comparison": {
                           "ComparisonKind": kind,
                           "Left": {"Measure": {"Expression": {"SourceRef": {"Source": "m"}}, "Property": measure}},
                           "Right": {"Literal": {"Value": value}}}}}]},
            "howCreated": "User", "isLockedInViewMode": True}


def topn_filter(name, column_table, column, measure, n):
    return {"name": name, "field": col(column_table, column), "type": "TopN",
            "filter": {"Version": 2,
                       "From": [{"Name": "subquery", "Expression": {"Subquery": {"Query": {
                           "Version": 2,
                           "From": [{"Name": "d", "Entity": column_table, "Type": 0},
                                    {"Name": "m", "Entity": "_Medidas", "Type": 0}],
                           "Select": [{"Column": {"Expression": {"SourceRef": {"Source": "d"}}, "Property": column},
                                       "Name": "field"}],
                           "OrderBy": [{"Direction": 2, "Expression": {"Measure": {
                               "Expression": {"SourceRef": {"Source": "m"}}, "Property": measure}}}],
                           "Top": n}}}, "Type": 2},
                                {"Name": "d", "Entity": column_table, "Type": 0}],
                       "Where": [{"Condition": {"In": {
                           "Expressions": [{"Column": {"Expression": {"SourceRef": {"Source": "d"}}, "Property": column}}],
                           "Table": {"SourceRef": {"Source": "subquery"}}}}}]},
            "howCreated": "User", "isLockedInViewMode": True}


def std_slicers(pg, pref, y=80, tipo_visivel=False, w=200):
    slicer(pg, pref + "_s_mes", 16, y, w, 72, MES, "Mês", "sync_mes")
    slicer(pg, pref + "_s_lin", 26 + w, y, w, 72, LIN, "Linha", "sync_linha")
    if tipo_visivel:
        slicer(pg, pref + "_s_tipo", 36 + 2 * w, y, w, 72, TIPO, "Tipo de dia", "sync_tipo")


# =====================================================================
pages = []

# ---------- P1 Visão Geral (reaproveita a página/visual já criados) ----------
P1 = "d8936d3679cd55609464"
p1 = Page(P1, "Visão Geral")
header(p1, "p1", "MetroClima – Visão Geral",
       "Como está a demanda da rede e quais linhas puxam o volume?")
std_slicers(p1, "p1", tipo_visivel=True, w=160)
text_card(p1, "814c63ed3d00ff1a1597", 530, 72, 734, 50, "Título Visão Geral", 13)
text_card(p1, "p1_periodo", 16, 152, 500, 50, "Período Selecionado", 10, "#3B3B3B")
kpi_row(p1, "p1_v1", 530, 122, 734, 84, ["Entradas", "Média Diária da Rede", "% do Esperado",
                                        "Qtd Quedas Atípicas", "Qtd Picos Atípicos"], font=12)
p1.add("p1_v2", "lineChart", 16, 210, 620, 240,
       roles={"Category": [proj(MES, True), proj(DATA, False)],
              "Y": [M("Entradas"), M("Entradas Esperadas")]},
       title="Como a demanda evolui mês a mês, frente ao esperado?",
       sort=[(MES, "Ascending")])
p1.add("p1_v3", "clusteredBarChart", 650, 210, 614, 240,
       roles={"Category": [LIN], "Y": [M("% do Esperado")]},
       title="Quais linhas ficaram abaixo do esperado?",
       objects={"dataPoint": color_by("Cor % Esperado"), "labels": labels_on(),
                "valueAxis": [{"properties": {"start": lit("0.95D"), "end": lit("1.01D")}}]},
       vco=tooltip_page(), sort=[(M("% do Esperado"), "Descending")])
p1.add("p1_v4", "pivotTable", 16, 462, 620, 246,
       roles={"Rows": [LIN], "Columns": [MES], "Values": [M("% do Esperado")]},
       title="Em que meses cada linha ficou abaixo do esperado?",
       objects={"values": [{"properties": {"backColor": {"solid": {"color": fx("Cor % Esperado")}}},
                            "selector": {"data": ALL, "metadata": "_Medidas.% do Esperado"}}]},
       vco=tooltip_page())
p1.add("p1_v5", "columnChart", 650, 462, 614, 246,
       roles={"Category": [DATA], "Y": [M("Qtd Quedas Atípicas"), M("Qtd Picos Atípicos")]},
       title="Quando aconteceram as quedas e os picos atípicos?",
       sort=[(DATA, "Ascending")])
p1.extra["visualInteractions"] = [{"source": "p1_v4", "target": "p1_v2", "type": "NoFilter"}]
pages.append(p1)

# ---------- P2 Linhas & Estações ----------
p2 = Page("p2_linhas_estacoes", "Linhas & Estações")
header(p2, "p2", "MetroClima – Linhas & Estações",
       "Onde a demanda se concentra e quais estações fogem do esperado?")
std_slicers(p2, "p2")
textbox(p2, "p2_v6_tit", 650, 80, 614, 30, "Rede em números", 13)
kpi_row(p2, "p2_v6", 650, 112, 614, 86, ["Qtd Estações", "Média por Estação-Dia", "Taxa de Quedas %"])
p2.add("p2_v1", "clusteredBarChart", 16, 160, 420, 290,
       roles={"Category": [ESTL], "Y": [M("Entradas")]},
       title="Quais estações recebem mais passageiros?",
       objects={"dataPoint": color_by("Cor Linha"), "labels": labels_on()},
       vco=tooltip_page(), sort=[(M("Entradas"), "Descending")],
       filters=[topn_filter("f_top10", "dim_estacao", "estacao_linha", "Entradas", 10)])
p2.add("p2_v3", "treemap", 446, 210, 300, 240,
       roles={"Group": [LIN], "Details": [EST], "Values": [M("Entradas")]},
       title="Qual o peso de cada linha no total?", vco=tooltip_page())
p2.add("p2_v4", "scatterChart", 756, 210, 508, 240,
       roles={"Category": [ESTL], "Series": [LIN], "X": [M("Média por Estação-Dia")],
              "Y": [M("% do Esperado")], "Size": [M("Qtd Quedas Atípicas")]},
       title="Quais estações movimentam muito e ainda ficam abaixo do esperado?")
p2.add("p2_v2", "pivotTable", 16, 462, 560, 246,
       roles={"Rows": [LIN, ESTL], "Values": [M("Entradas"), M("Participação %"),
                                             M("% do Esperado"), M("Qtd Quedas Atípicas")]},
       title="Como o volume se distribui entre linhas e estações?",
       objects={"values": [{"properties": {"dataBars": {"positiveColor": {"solid": {"color": lit("'#6FA8DC'")}},
                                                        "negativeColor": {"solid": {"color": lit("'#B20000'")}},
                                                        "axisColor": {"solid": {"color": lit("'#3B3B3B'")}},
                                                        "reverseDirection": lit("false"),
                                                        "hideText": lit("false")}},
                            "selector": {"metadata": "_Medidas.Entradas"}}]})
p2.add("p2_v5", "tableEx", 586, 462, 678, 246,
       roles={"Values": [ESTL, ANOMES, M("Entradas"), M("Entradas Esperadas"),
                         M("% do Esperado"), M("Qtd Quedas Atípicas")]},
       title="Quais estações e meses foram críticos?",
       sort=[(M("% do Esperado"), "Ascending")],
       filters=[measure_filter("f_critico", "Flag Crítico C5", 0, "1L")])
pages.append(p2)

# ---------- P3 Chuva & Demanda ----------
p3 = Page("p3_chuva_demanda", "Chuva & Demanda")
header(p3, "p3", "MetroClima – Chuva & Demanda",
       "A chuva reduz a demanda ou provoca quedas atípicas?")
std_slicers(p3, "p3")
textbox(p3, "p3_aviso", 436, 84, 204, 64, "Clima simulado – Etapa 6 (API Open-Meteo) pendente",
        10, "#3B3B3B", True, bg="#F9D776")
textbox(p3, "p3_v5_tit", 650, 80, 614, 30, "Chuva forte em números", 13)
kpi_row(p3, "p3_v5", 650, 112, 614, 86, ["Efeito Chuva Forte (p.p.)", "Taxa de Quedas Chuva Forte %",
                                        "Dias com Chuva Forte", "Precipitação Média (mm)"])
p3.add("p3_v1", "clusteredColumnChart", 16, 210, 620, 240,
       roles={"Category": [COND], "Series": [LIN], "Y": [M("% do Esperado")]},
       title="Em dias de chuva forte, cada linha fica mais abaixo do esperado?",
       objects={"valueAxis": [{"properties": {"start": lit("0.95D")}}]},
       sort=[(COND, "Ascending")])
p3.add("p3_v2", "scatterChart", 650, 210, 614, 240,
       roles={"Category": [DATA], "X": [M("Precipitação Média (mm)")], "Y": [M("% do Esperado")],
              "Size": [M("Entradas")]},
       title="Quanto mais chove, menor a demanda frente ao esperado?",
       objects={"trend": [{"properties": {"show": lit("true")}}]})
p3.add("p3_v3", "lineClusteredColumnComboChart", 16, 462, 620, 246,
       roles={"Category": [DATA], "Y": [M("Precipitação Média (mm)")], "Y2": [M("% do Esperado")]},
       title="Chuva e demanda andam juntas no tempo?",
       sort=[(DATA, "Ascending")])
p3.add("p3_v4", "pivotTable", 650, 462, 614, 246,
       roles={"Rows": [FAIXA], "Values": [M("Qtd Dias"), M("Entradas"), M("Qtd Quedas Atípicas"),
                                          M("Qtd Picos Atípicos"), M("Taxa de Quedas %"), M("% do Esperado")]},
       title="Em que faixa de chuva se concentram as anomalias?")
pages.append(p3)

# ---------- Detalhe da Estação (detalhamento) ----------
pd = Page("detalhe_estacao", "Detalhe da Estação",
          visibility="HiddenInViewMode",
          pageBinding={"name": "pb_detalhe_estacao", "type": "Drillthrough", "referenceScope": "Default",
                       "parameters": [{"name": "par_estacao_linha", "boundFilter": "f_drill_estacao",
                                       "fieldExpr": ESTL}]},
          filterConfig={"filters": [{"name": "f_drill_estacao", "field": ESTL, "type": "Categorical",
                                     "howCreated": "Drillthrough"}]})
textbox(pd, "pd_tit", 16, 8, 900, 40, "MetroClima – Detalhe da Estação", 20)
textbox(pd, "pd_perg", 16, 46, 900, 28,
        "Clique com o botão direito numa estação (P2) → Detalhamento. Use a seta para voltar.", 11, "#3B3B3B", False)
pd.add("pd_voltar", "actionButton", 1140, 12, 124, 44,
       objects={"icon": [{"properties": {"shapeType": s("back")}, "selector": {"id": "default"}}],
                "text": [{"properties": {"show": lit("true"), "text": s("Voltar")},
                          "selector": {"id": "default"}}]},
       vco={"visualLink": [{"properties": {"show": lit("true"), "type": s("Back")}}]})
text_card(pd, "pd_v1_tit", 16, 72, 1248, 50, "Título Estação", 14)
kpi_row(pd, "pd_v1", 16, 124, 1248, 82, ["Entradas", "Média por Estação-Dia", "% do Esperado",
                                        "Qtd Quedas Atípicas", "Qtd Picos Atípicos"])
pd.add("pd_v2", "clusteredColumnChart", 16, 216, 400, 492,
       roles={"Category": [TIPO], "Y": [M("Média por Estação-Dia")]},
       title="Em que tipo de dia a estação é mais usada?", objects={"labels": labels_on()})
pd.add("pd_v3", "lineChart", 428, 216, 836, 240,
       roles={"Category": [DATA], "Y": [M("Entradas"), M("Entradas Esperadas")]},
       title="A estação seguiu o esperado dia a dia?", sort=[(DATA, "Ascending")])
pd.add("pd_v4", "clusteredColumnChart", 428, 468, 836, 240,
       roles={"Category": [COND], "Y": [M("% do Esperado")]},
       title="A chuva afeta esta estação?",
       objects={"labels": labels_on(), "valueAxis": [{"properties": {"start": lit("0.9D")}}]},
       sort=[(COND, "Ascending")])
pages.append(pd)

# ---------- Dica Linha (tooltip) ----------
pt = Page("dica_linha", "Dica Linha", visibility="HiddenInViewMode", type="Tooltip",
          pageBinding={"name": "pb_dica_linha", "type": "Tooltip",
                       "parameters": [{"name": "par_nome_linha", "boundFilter": "f_dica_linha", "fieldExpr": LIN}]},
          filterConfig={"filters": [{"name": "f_dica_linha", "field": LIN, "type": "Categorical",
                                     "howCreated": "Drillthrough"}]})
pt.extra.update({"displayOption": "ActualSize"})
text_card(pt, "pt_v1_tit", 0, 0, 320, 50, "Título Visão Geral", 10)
kpi_row(pt, "pt_v1", 4, 50, 312, 186, ["Entradas", "% do Esperado", "Qtd Quedas Atípicas",
                                      "Média Diária da Rede"], cols=2, font=13)
pages.append(pt)

# ---------- Conferência (oculta) ----------
pc = Page("conferencia", "Conferência", visibility="HiddenInViewMode")
textbox(pc, "pc_tit", 16, 8, 900, 40, "MetroClima – Conferência (página oculta)", 20)
textbox(pc, "pc_perg", 16, 46, 900, 28,
        "Os números batem com o banco? Esperado: 11946 linhas e todas as medidas Conf = 0.", 11, "#3B3B3B", False)
textbox(pc, "pc_v1_tit", 16, 80, 900, 30, "Medidas de conferência", 13)
kpi_row(pc, "pc_v1", 16, 112, 1248, 172, ["Conf Linhas fato_entradas", "Conf Entradas sem Estação",
        "Conf Entradas sem Data", "Conf Entradas sem Clima", "Conf PK Duplicada", "Conf Lacunas Estação-Dia",
        "Conf Dif Quedas", "Conf Dif Picos", "Conf Razão Divergente"], cols=5)
pc.add("pc_v2", "tableEx", 16, 296, 700, 240,
       roles={"Values": [LIN, M("Entradas"), M("Qtd Quedas Atípicas"), M("Qtd Picos Atípicos")]},
       title="Batimento por linha (= K4 do SQL)")
pages.append(pc)

# ---------- gravação ----------
root = OUT
for p in pages:
    p.write(root)
dump(os.path.join(root, "definition", "pages", "pages.json"), {
    "$schema": "https://developer.microsoft.com/json-schemas/fabric/item/report/definition/pagesMetadata/1.1.0/schema.json",
    "pageOrder": [p.name for p in pages], "activePageName": P1})

# tema personalizado
rr = os.path.join(root, "StaticResources", "RegisteredResources")
os.makedirs(rr, exist_ok=True)
shutil.copy(sys.argv[2], os.path.join(rr, "tema_metroclima.json"))
rep = json.load(open(sys.argv[3], encoding="utf-8"))
rep["themeCollection"]["customTheme"] = {
    "name": "tema_metroclima.json",
    "reportVersionAtImport": rep["themeCollection"]["baseTheme"]["reportVersionAtImport"],
    "type": "RegisteredResources"}
rep["resourcePackages"] = [r for r in rep["resourcePackages"] if r["name"] != "RegisteredResources"]
rep["resourcePackages"].append({"name": "RegisteredResources", "type": "RegisteredResources",
                                "items": [{"name": "tema_metroclima.json", "path": "tema_metroclima.json",
                                           "type": "CustomTheme"}]})
dump(os.path.join(root, "definition", "report.json"), rep)

n = sum(len(p.visuals) for p in pages)
print(f"{len(pages)} páginas, {n} visuais")
