let
    Fonte = (Link_do_GoogleFolder as text, optional FiltrarExtensao as text) =>
let
      // Testar : https://drive.google.com/drive/folders/1W2hryU6rf3a3BbafLC5Jm6w8g0j7MoY5
     // Função para descobrir a extensão real
    fxExtensao = (txt as nullable text, linha as nullable text) as nullable text =>
        let
            t = if txt = null then "" else Text.Lower(txt),
            l = if linha = null then "" else Text.Lower(linha),
            ext =
                if Text.Contains(l, "application/vnd.google-apps.spreadsheet") then "sheet"
                else if Text.Contains(t, ".xlsx") then "xlsx"
                else if Text.Contains(t, ".xls") then "xls"
                else if Text.Contains(t, ".csv") then "csv"
                else if Text.Contains(t, ".tsv") then "tsv"
                else if Text.Contains(t, ".txt") then "txt"
                else if Text.Contains(t, ".json") then "json"
                else if Text.Contains(t, ".xml") then "xml"
                else if Text.Contains(t, ".pdf") then "pdf"
                else null
        in
            ext,

    // Função para limpar o nome e deixar só até a extensão
    fxNomeLimpo = (txt as nullable text, ext as nullable text) as nullable text =>
        let
            t = if txt = null then null else Text.Trim(txt),
            nome =
                if t = null then null
                else if ext = "sheet" then t
                else if ext = null then t
                else
                    let
                        pos = Text.PositionOf(Text.Lower(t), "." & ext)
                    in
                        if pos >= 0 then Text.Start(t, pos + Text.Length(ext) + 1) else t
        in
            nome,

    // Função para gerar URL de download/exportação
    fxLinkDownload = (id as text, ext as nullable text) as text =>
        if ext = "sheet" then
            "https://docs.google.com/spreadsheets/d/" & id & "/export?format=xlsx"
        else
            "https://drive.google.com/uc?export=download&id=" & id,

    // Detecta delimitador CSV/TXT
    fxDetectDelimiter = (bin as binary) as text =>
        let
            texto = Text.Start(Text.FromBinary(bin, 65001), 2000),
            linhas = List.FirstN(Lines.FromText(texto), 5),
            amostra = Text.Combine(linhas, "#(lf)"),

            qtdPontoVirgula = List.Count(Text.PositionOf(amostra, ";", Occurrence.All)),
            qtdVirgula = List.Count(Text.PositionOf(amostra, ",", Occurrence.All)),
            qtdPipe = List.Count(Text.PositionOf(amostra, "|", Occurrence.All)),
            qtdTab = List.Count(Text.PositionOf(amostra, "#(tab)", Occurrence.All)),

            candidatos = {
                {";", qtdPontoVirgula},
                {",", qtdVirgula},
                {"|", qtdPipe},
                {"#(tab)", qtdTab}
            },

            maximo = List.Max(List.Transform(candidatos, each _{1})),
            delimitador =
                if maximo = 0 then
                    ","
                else
                    List.First(List.Select(candidatos, each _{1} = maximo)){0}
        in
            delimitador,

    // Fallback para CSV/TXT tabulares
    fxLerTabelaDelimitada = (bin as binary, optional delimitadorPreferido as nullable text) =>
        let
            delimitadorDetectado = if delimitadorPreferido = null then fxDetectDelimiter(bin) else delimitadorPreferido,

            tentativa1 = try Csv.Document(bin, [Delimiter = delimitadorDetectado, Encoding = 65001, QuoteStyle = QuoteStyle.Csv]),
            tentativa2 = try Csv.Document(bin, [Delimiter = ";", Encoding = 65001, QuoteStyle = QuoteStyle.Csv]),
            tentativa3 = try Csv.Document(bin, [Delimiter = ",", Encoding = 65001, QuoteStyle = QuoteStyle.Csv]),
            tentativa4 = try Csv.Document(bin, [Delimiter = "|", Encoding = 65001, QuoteStyle = QuoteStyle.Csv]),
            tentativa5 = try Csv.Document(bin, [Delimiter = "#(tab)", Encoding = 65001, QuoteStyle = QuoteStyle.Csv]),

            resultado =
                if not tentativa1[HasError] then tentativa1[Value]
                else if not tentativa2[HasError] then tentativa2[Value]
                else if not tentativa3[HasError] then tentativa3[Value]
                else if not tentativa4[HasError] then tentativa4[Value]
                else if not tentativa5[HasError] then tentativa5[Value]
                else null,

            erro =
                if not tentativa1[HasError] then null
                else if not tentativa2[HasError] then null
                else if not tentativa3[HasError] then null
                else if not tentativa4[HasError] then null
                else if not tentativa5[HasError] then null
                else "Falha ao ler arquivo delimitado com fallback"
        in
            [Conteudo = resultado, Erro = erro],

    // Função resiliente com log
    fxExtrairConteudo = (link as text, ext as nullable text) as record =>
        let
            tentativaBin = try Web.Contents(link),

            semArquivo = [
                Conteudo = null,
                Status = "Erro",
                Erro = "Falha ao baixar arquivo"
            ],

            resultado =
                if tentativaBin[HasError] then
                    semArquivo
                else
                    let
                        bin = tentativaBin[Value],

                        leitura =
                            if ext = "xlsx" or ext = "xls" or ext = "sheet" then
                                let t = try Excel.Workbook(bin, null, true)
                                in
                                    if t[HasError] then
                                        [Conteudo = null, Status = "Erro", Erro = "Falha ao ler Excel"]
                                    else
                                        [Conteudo = t[Value], Status = "OK", Erro = null]

                            else if ext = "csv" then
                                let t = fxLerTabelaDelimitada(bin)
                                in
                                    if t[Conteudo] = null then
                                        [Conteudo = null, Status = "Erro", Erro = t[Erro]]
                                    else
                                        [Conteudo = t[Conteudo], Status = "OK", Erro = null]

                            else if ext = "tsv" then
                                let t = fxLerTabelaDelimitada(bin, "#(tab)")
                                in
                                    if t[Conteudo] = null then
                                        [Conteudo = null, Status = "Erro", Erro = t[Erro]]
                                    else
                                        [Conteudo = t[Conteudo], Status = "OK", Erro = null]

                            else if ext = "txt" then
                                let
                                    tentativaTabela = fxLerTabelaDelimitada(bin),
                                    tentativaLinhas = try Lines.FromBinary(bin, null, null, 65001)
                                in
                                    if tentativaTabela[Conteudo] <> null then
                                        [Conteudo = tentativaTabela[Conteudo], Status = "OK", Erro = null]
                                    else if not tentativaLinhas[HasError] then
                                        [Conteudo = tentativaLinhas[Value], Status = "OK", Erro = null]
                                    else
                                        [Conteudo = null, Status = "Erro", Erro = "Falha ao ler TXT"]

                            else if ext = "json" then
                                let t = try Json.Document(bin)
                                in
                                    if t[HasError] then
                                        [Conteudo = null, Status = "Erro", Erro = "Falha ao ler JSON"]
                                    else
                                        [Conteudo = t[Value], Status = "OK", Erro = null]

                            else if ext = "xml" then
                                let t = try Xml.Tables(bin)
                                in
                                    if t[HasError] then
                                        [Conteudo = null, Status = "Erro", Erro = "Falha ao ler XML"]
                                    else
                                        [Conteudo = t[Value], Status = "OK", Erro = null]

                            else if ext = "pdf" then
                                let t = try Pdf.Tables(bin)
                                in
                                    if t[HasError] then
                                        [Conteudo = null, Status = "Erro", Erro = "Falha ao ler PDF"]
                                    else
                                        [Conteudo = t[Value], Status = "OK", Erro = null]

                            else
                                [Conteudo = bin, Status = "OK", Erro = null]
                    in
                        leitura
        in
            resultado,

    Fonte = Web.BrowserContents(Link_do_GoogleFolder),
    Base = #table(1, {{Fonte}}),

    Expandido = Table.ExpandListColumn(
        Table.TransformColumns(
            Base,
            {
                {
                    "Column1",
                    Splitter.SplitTextByDelimiter("data-id=""", QuoteStyle.None),
                    let itemType = (type nullable text) meta [Serialized.Text = true] in type {itemType}
                }
            }
        ),
        "Column1"
    ),

    LinhasValidas = Table.SelectRows(Expandido, each not Text.StartsWith([Column1], "<html")),

    AddID = Table.AddColumn(
        LinhasValidas,
        "ID",
        each Text.Start([Column1], 33),
        type text
    ),

    AddNomeBruto = Table.AddColumn(
        AddID,
        "Nome Bruto",
        each try Text.BetweenDelimiters([Column1], "aria-label=""", """") otherwise null,
        type text
    ),

    AddTipo = Table.AddColumn(
        AddNomeBruto,
        "Tipo",
        each
            let txt = Text.Lower([Column1])
            in
                if Text.Contains(txt, "application/vnd.google-apps.folder") then "pasta"
                else if Text.Contains(txt, "application/vnd.google-apps.spreadsheet") then "google"
                else if [Nome Bruto] <> null then "arquivo"
                else null,
        type text
    ),

    AddExtensao = Table.AddColumn(
        AddTipo,
        "Extensão",
        each fxExtensao([Nome Bruto], [Column1]),
        type text
    ),

    AddNomeLimpo = Table.AddColumn(
        AddExtensao,
        "Nome do Arquivo",
        each fxNomeLimpo([Nome Bruto], [Extensão]),
        type text
    ),

    FiltraTipoNulo = Table.SelectRows(AddNomeLimpo, each [Tipo] <> null),
    RemovePastas = Table.SelectRows(FiltraTipoNulo, each [Tipo] <> "pasta"),
    RemoveSemExt = Table.SelectRows(RemovePastas, each [Extensão] <> null),
    RemoveSheets = Table.SelectRows(RemoveSemExt, each [Extensão] <> "sheet"),

    Decisao =
        if FiltrarExtensao = null then
            RemoveSheets
        else
            Table.SelectRows(RemoveSheets, each [Extensão] = Text.Lower(FiltrarExtensao)),

    AddLinkDownload = Table.AddColumn(
        Decisao,
        "Link de Download",
        each fxLinkDownload([ID], [Extensão]),
        type text
    ),

    AddResultadoLeitura = Table.AddColumn(
        AddLinkDownload,
        "Resultado Leitura",
        each fxExtrairConteudo([Link de Download], [Extensão]),
        type record
    ),

    ExpandResultado = Table.ExpandRecordColumn(
        AddResultadoLeitura,
        "Resultado Leitura",
        {"Conteudo", "Status", "Erro"},
        {"Conteúdo", "Status", "Erro"}
    ),

    Resultado = Table.SelectColumns(
        ExpandResultado,
        {"Nome do Arquivo", "Tipo", "Extensão", "Link de Download", "Conteúdo", "Status", "Erro"}
    )
in
    Resultado
in
    Fonte