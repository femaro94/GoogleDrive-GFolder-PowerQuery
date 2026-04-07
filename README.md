# GFolder para Power Query: Google Drive no Power BI e no Excel

## Visão geral

Este projeto reúne duas funções personalizadas em **linguagem M** para **Power Query**, criadas para permitir que **Power BI** e **Excel** leiam, listem e interpretem arquivos armazenados dentro de uma pasta pública do **Google Drive**. Em termos práticos, a função recebe a URL de uma pasta do Google Drive, faz a leitura da página da pasta, identifica os arquivos exibidos, extrai seus IDs, monta links de download e tenta converter automaticamente o conteúdo para estruturas utilizáveis no Power Query.

A proposta é tecnicamente ousada e, sob muitos aspectos, **revolucionária** para o ecossistema Microsoft. O motivo é simples: o ambiente Microsoft tradicionalmente trabalha com conectores e integrações mais fechados, controlados e previsíveis. Já esta função cria uma ponte não oficial, porém extremamente engenhosa, para navegar em uma pasta do Google Drive a partir do Power Query, dispensando conectores proprietários e explorando apenas o comportamento público da web. Em outras palavras, a solução mostra que é possível **navegar em folders do Google Drive a partir de ferramentas Microsoft**, o que amplia muito as possibilidades de integração entre plataformas.

Ao mesmo tempo, a solução tem limites técnicos importantes. Ela **não foi concebida como um conector oficial do Google Drive**, mas como uma função M baseada em leitura da página HTML e posterior download dos arquivos detectados. Por essa razão, ela funciona em um cenário bem específico: a pasta do Google Drive precisa estar compartilhada de forma pública e permissiva, de modo que o Power Query consiga acessá-la usando credencial anônima. Além disso, a função **não retorna arquivos nativos do Google**, como **Google Docs**, **Google Sheets**, **Google Slides**, nem **subpastas internas** contidas dentro da pasta analisada. Essa limitação não invalida a solução; ela apenas define com clareza o seu escopo real.

## Funções incluídas

As duas versões finais deste projeto são as seguintes:

| Arquivo | Ambiente-alvo | Diferença principal |
|---|---|---|
| `04-Fn Gdrive(Fernando-IA)V3.txt` | Power BI | Suporta leitura de arquivos **Parquet** além dos demais formatos. |
| `04-Fn Gdrive(Fernando-IA)V3-Excel.txt` | Excel / Power Query do Excel | Não usa `Parquet.Document`, para preservar compatibilidade com o Excel. |

A única diferença funcional entre elas está no tratamento do formato **Parquet**. Todo o restante da arquitetura, da lógica de descoberta dos arquivos e do formato de retorno permanece essencialmente igual.

## O que a função faz

A função recebe dois parâmetros: a URL da pasta do Google Drive e, opcionalmente, uma extensão para filtrar o resultado. A partir disso, ela executa uma sequência de etapas bastante sofisticada.

Primeiro, a função usa `Web.BrowserContents(...)` para ler o HTML da pasta pública do Google Drive. Em seguida, ela divide esse HTML em fragmentos com base em ocorrências de `data-id=""`, que servem como ponto de apoio para capturar os IDs dos arquivos. Depois disso, extrai o nome bruto do item via `aria-label`, classifica o item como arquivo, pasta ou item Google, infere a extensão real, limpa o nome do arquivo, remove o que não interessa e cria um link de download compatível com o tipo encontrado.

Na etapa seguinte, a função tenta ler o conteúdo do arquivo de acordo com sua extensão. Se o arquivo for Excel, usa `Excel.Workbook(...)`; se for CSV ou TSV, usa `Csv.Document(...)`; se for TXT, tenta primeiro leitura tabular e, em caso de falha, leitura por linhas; se for JSON, XML, PDF ou Parquet, aciona as funções específicas do Power Query para cada formato. Nas versões mais recentes, o processo ainda foi enriquecido com **resiliência operacional**, pois a função passa a retornar colunas de **Status** e **Erro**, o que facilita depuração, auditoria e tratamento de falhas por arquivo.

## Formatos suportados

Na versão para **Power BI**, a função tenta interpretar os seguintes formatos:

| Formato | Extensão | Estratégia utilizada |
|---|---|---|
| Excel | `.xlsx` | `Excel.Workbook(...)` |
| Excel legada | `.xls` | `Excel.Workbook(...)` |
| CSV | `.csv` | `Csv.Document(...)` com autodetecção de delimitador e fallbacks |
| TSV | `.tsv` | `Csv.Document(...)` com delimitador tab |
| Texto | `.txt` | Tenta leitura tabular e, se falhar, leitura por linhas |
| JSON | `.json` | `Json.Document(...)` |
| XML | `.xml` | `Xml.Tables(...)` |
| Parquet | `.parquet` | `Parquet.Document(...)` |
| PDF | `.pdf` | `Pdf.Tables(...)` |

Na versão para **Excel**, o comportamento é o mesmo, com uma única exceção: **Parquet não é processado**.

| Formato | Power BI | Excel |
|---|---:|---:|
| `.xlsx` | Sim | Sim |
| `.xls` | Sim | Sim |
| `.csv` | Sim | Sim |
| `.tsv` | Sim | Sim |
| `.txt` | Sim | Sim |
| `.json` | Sim | Sim |
| `.xml` | Sim | Sim |
| `.pdf` | Sim | Sim |
| `.parquet` | Sim | Não |

Essa distinção é importante porque a função `Parquet.Document(...)` nem sempre está disponível no Power Query do Excel, o que comprometeria a compatibilidade da solução fora do Power BI.

## Estrutura de retorno

As versões finais retornam uma tabela com sete colunas principais:

| Coluna | Descrição |
|---|---|
| `Nome do Arquivo` | Nome tratado do arquivo encontrado na pasta. |
| `Tipo` | Classificação do item detectado. Na prática, os resultados finais trazem arquivos válidos. |
| `Extensão` | Extensão inferida pela função. |
| `Link de Download` | URL gerada para baixar o arquivo. |
| `Conteúdo` | Conteúdo interpretado pelo Power Query, normalmente em forma de tabela, lista, registro ou binário. |
| `Status` | Situação da tentativa de leitura, como `OK` ou `Erro`. |
| `Erro` | Mensagem textual quando há falha na leitura ou no download. |

Esse desenho é especialmente valioso porque transforma a função em algo mais robusto do que uma simples listagem de links. Ela passa a ser também um mecanismo de **ingestão com log de processamento**, o que ajuda muito em cenários reais de ETL e automação analítica.

## Diferenças entre a V2 e a V3

A evolução entre as versões anteriores e a versão final é relevante para a narrativa técnica do repositório. A versão V2 já identificava extensões, montava links e tentava ler diversos formatos, mas o retorno ainda era mais simples, sem um mecanismo de log estruturado por arquivo. Na V3, a solução passa a encapsular a leitura em um registro com `Conteudo`, `Status` e `Erro`, elevando significativamente a rastreabilidade.

| Aspecto | V2 | V3 |
|---|---|---|
| Leitura por tipo de arquivo | Sim | Sim |
| Filtro opcional por extensão | Sim | Sim |
| Remoção automática de `sheet` | Sim | Sim |
| Coluna `Conteúdo` | Sim | Sim |
| Coluna `Status` | Não | Sim |
| Coluna `Erro` | Não | Sim |
| Maior resiliência operacional | Parcial | Sim |

Portanto, para o GitHub, a V3 deve ser apresentada como a **versão madura e recomendada** da solução.

## Limitações técnicas essenciais

A documentação do repositório precisa ser muito clara quanto às limitações, porque isso reduz ruído, evita uso incorreto e fortalece a credibilidade do projeto.

A primeira limitação é de **compartilhamento**. A função foi desenhada para funcionar quando a pasta do Google Drive está configurada para acesso público amplo, em especial no cenário em que **qualquer pessoa da internet pode editar**. Na prática, isso permite usar a credencial **Anônima** em `Web.Contents` e em `Web.BrowserContents`. Sem esse tipo de compartilhamento público, a solução tende a falhar, porque não há autenticação oficial contra a API do Google Drive.

A segunda limitação é de **escopo de itens retornados**. A função **não retorna Google Docs, Google Sheets, Google Slides e outros artefatos nativos do ecossistema Google** no resultado final. Embora a lógica detecte `application/vnd.google-apps.spreadsheet` e até gere internamente a noção de `sheet`, esses itens são removidos pela etapa `RemoveSheets`, o que significa que **Google Sheets não aparecem no retorno final**. Da mesma forma, **subpastas internas são removidas** pela etapa `RemovePastas`.

A terceira limitação é de **natureza do mecanismo**. A função faz scraping da página pública da pasta, e não consulta uma API oficial. Isso a torna criativa e poderosa, mas também dependente da estrutura HTML exibida pelo Google Drive no momento da execução.

## Tipos de URL aceitos

Os testes informados para a função mostram que ela aceita tanto a URL da pasta obtida diretamente no navegador quanto a URL de compartilhamento com parâmetro adicional. Os dois exemplos abaixo são compatíveis com a lógica da função:

| Tipo de URL | Exemplo |
|---|---|
| URL direta da pasta | `https://drive.google.com/drive/folders/1W2hryU6rf3a3BbafLC5Jm6w8g0j7MoY5` |
| URL de compartilhamento | `https://drive.google.com/drive/folders/1W2hryU6rf3a3BbafLC5Jm6w8g0j7MoY5?usp=drive_link` |

Isso é um ponto forte importante para o README, porque demonstra que a função tem tolerância para mais de uma forma de link público do Google Drive.

## Análise da função para Power BI

A versão `04-Fn Gdrive(Fernando-IA)V3.txt` é a edição mais completa da solução. Ela inclui suporte a `Parquet.Document(...)`, além de um fluxo resiliente de leitura baseado em tentativas. O trecho mais importante da evolução está no encapsulamento da leitura em um registro com `Conteudo`, `Status` e `Erro`, o que transforma a função em um pequeno motor de ingestão supervisionada.

Do ponto de vista arquitetural, essa versão combina três camadas de inteligência. A primeira é a camada de **descoberta de arquivos**, que entende a página do Google Drive. A segunda é a camada de **normalização**, responsável por classificar o tipo do item, deduzir extensão e construir o link final. A terceira é a camada de **interpretação**, que escolhe a função de leitura correta para cada formato.

Para Power BI Desktop, essa é a versão recomendada sempre que houver interesse em ler também arquivos **Parquet**.

## Análise da função para Excel

A versão `04-Fn Gdrive(Fernando-IA)V3-Excel.txt` preserva praticamente toda a engenharia da V3 do Power BI, porém remove o tratamento de Parquet. Essa decisão é tecnicamente acertada, porque prioriza compatibilidade real de execução dentro do Excel.

Em vez de manter uma função formalmente mais completa, mas potencialmente instável no Excel, esta versão assume uma postura mais robusta: restringe o conjunto de formatos àquilo que o ambiente do Excel tende a suportar com segurança. Para GitHub, isso é excelente, porque deixa explícito que não se trata de uma versão inferior, mas de uma versão **adaptada ao runtime do Excel**.

## Análise do arquivo de teste `Gfolder.xlsx`

O arquivo `Gfolder.xlsx` confirma, de forma prática, o uso real da versão voltada para Excel. A análise interna do workbook mostra duas conexões de consulta, uma vinculada à função `Fn Gdrive(Fernando-IA)V3-Excel` e outra a uma consulta de teste chamada `Teste Fn Gdrive(Fernando-IA)V3-Excel`. A pasta de trabalho contém uma planilha visível chamada **Função Invocada**, que materializa o resultado final da execução.

Além disso, a saída materializada observada no arquivo mostra uma tabela com as colunas **Nome do Arquivo**, **Tipo**, **Extensão**, **Link de Download**, **Conteúdo**, **Status** e **Erro**, exatamente como previsto no código. Os registros visíveis do exemplo retornam extensões como **xlsx**, **xls**, **pdf**, **csv** e **txt**, com **Status = OK** e **Erro em branco**, o que comprova o bom funcionamento da versão para Excel no cenário de teste do projeto.

## Análise do arquivo de teste `Gfolder.pbix`

O arquivo `Gfolder.pbix` confirma a existência de um projeto Power BI utilizado como ambiente de validação da solução. A inspeção estrutural do PBIX mostra os componentes típicos do formato, incluindo `Report/Layout`, `Settings`, `Metadata` e `DataModel`. Isso confirma que o arquivo está íntegro como artefato de teste do Power BI.

Entretanto, como o PBIX é um contêiner binário e não expõe trivialmente o texto das consultas por leitura simples, não foi possível, neste fluxo, extrair de forma completa o mashup interno com a mesma transparência obtida no Excel. Mesmo assim, o fato de o PBIX existir como arquivo de teste do projeto e de o repositório conter a função específica para Power BI é suficiente para documentá-lo como **arquivo de validação da versão Power BI**.

Quanto à observação do projeto de que existe uma consulta chamada **PDF**, o arquivo PBIX deve ser descrito no GitHub como o ambiente de testes da função para Power BI, inclusive para cenários que envolvem leitura de PDF. Contudo, a identificação textual dessa consulta específica não pôde ser confirmada automaticamente por inspeção binária simples neste processo de análise.

## Atualização automática no Power BI Service

Este é um dos pontos mais importantes da documentação. A resposta técnica mais honesta e prudente é: **não se deve prometer atualização automática confiável no Power BI Service para esta solução em seu estado atual**.

A documentação oficial da Microsoft explica que a atualização agendada no Power BI Service depende do suporte da fonte de dados e alerta que modelos com **fontes dinâmicas** geralmente **não podem ser atualizados** no serviço, salvo exceções muito específicas com `Web.Contents` estruturado por `RelativePath` e `Query` [1] [3]. A Microsoft também informa que, quando uma fonte não é suportada, o serviço pode bloquear a configuração de refresh com a mensagem de que o modelo usa fontes que atualmente não oferecem suporte a atualização [2].

No caso desta solução, a função depende de `Web.BrowserContents(Link_do_GoogleFolder)` para ler a página HTML da pasta do Google Drive e, depois, constrói dinamicamente links de download com `Web.Contents(...)`. Essa arquitetura caracteriza um cenário fortemente associado a **fonte web dinâmica** e **consulta artesanal**, o que reduz fortemente a chance de compatibilidade plena com refresh agendado no Power BI Service [2] [3].

> "In most cases, Power BI semantic models that use dynamic data sources can't be refreshed in the Power BI service." — Microsoft Learn, seção *Refresh and dynamic data sources* [3]

Assim, a formulação recomendada para o GitHub é a seguinte:

> Esta solução foi validada principalmente para **Power BI Desktop** e **Excel Power Query**. No **Power BI Service**, a atualização agendada **não é garantida** e, no cenário atual, deve ser tratada como **limitada ou não suportada de forma confiável**, devido ao uso de `Web.BrowserContents` e à natureza dinâmica das URLs geradas.

Essa redação é firme, correta e protege a reputação do projeto.

## Credenciais e configuração de acesso

Ao importar a função no Power BI ou no Excel, o cenário esperado é usar a credencial **Anônima** para as chamadas web. Isso ocorre porque o acesso se baseia em uma pasta pública do Google Drive. Se a pasta não estiver realmente aberta ao acesso público, o Power Query poderá falhar no carregamento, na listagem ou na leitura dos arquivos.

A documentação deve deixar explícito que a solução **não substitui autenticação oficial do Google Drive**. Ela funciona porque explora o acesso público à página e aos arquivos disponibilizados dentro dela.

## Exemplo de invocação

A função pode ser invocada sem filtro ou com filtro de extensão.

```powerquery
let
    Fonte = #"Fn Gdrive(Fernando-IA)V3"(
        "https://drive.google.com/drive/folders/1W2hryU6rf3a3BbafLC5Jm6w8g0j7MoY5"
    )
in
    Fonte
```

```powerquery
let
    Fonte = #"Fn Gdrive(Fernando-IA)V3"(
        "https://drive.google.com/drive/folders/1W2hryU6rf3a3BbafLC5Jm6w8g0j7MoY5?usp=drive_link",
        "pdf"
    )
in
    Fonte
```

No Excel, basta trocar o nome da função pela versão `Fn Gdrive(Fernando-IA)V3-Excel`.

## Sugestão de posicionamento para o GitHub

Se a intenção é "bombar no GitHub", o posicionamento do projeto precisa destacar três mensagens centrais.

A primeira é que esta solução **leva o Power Query além do ecossistema fechado da Microsoft**, criando uma integração prática com pastas públicas do Google Drive. A segunda é que ela não se limita a listar arquivos, mas **já interpreta múltiplos formatos automaticamente**. A terceira é que o projeto possui versões distintas para **Power BI** e **Excel**, respeitando as limitações reais de cada ambiente.

Uma apresentação forte para o repositório pode enfatizar que se trata de uma função M capaz de **navegar em pastas públicas do Google Drive, listar arquivos, gerar links de download e converter conteúdo automaticamente para análise em Power BI ou Excel**.

## Estrutura sugerida para o repositório

| Caminho sugerido | Conteúdo |
|---|---|
| `/README.md` | Apresentação geral do projeto, diferenças entre versões, limitações e exemplos. |
| `/power-bi/04-Fn Gdrive(Fernando-IA)V3.txt` | Função para Power BI. |
| `/excel/04-Fn Gdrive(Fernando-IA)V3-Excel.txt` | Função para Excel. |
| `/docs/GUIA_DE_USO.md` | Passo a passo completo de instalação e uso. |
| `/samples/Gfolder.pbix` | Arquivo de teste do Power BI. |
| `/samples/Gfolder.xlsx` | Arquivo de teste do Excel. |

## Conclusão

Este projeto representa uma solução altamente criativa de integração entre **Google Drive** e **Power Query**, com aplicações práticas em **Power BI Desktop** e **Excel**. A função não depende de conector oficial, consegue trabalhar com mais de um formato de URL pública da pasta, interpreta diversos tipos de arquivos e ainda devolve metadados operacionais importantes, como **Status** e **Erro**.

Suas limitações devem ser comunicadas com honestidade: a pasta precisa estar pública, arquivos nativos do Google e subpastas não entram no retorno final, e o refresh automático no Power BI Service não deve ser tratado como garantido. Justamente por isso, a documentação correta não diminui o projeto; ao contrário, mostra maturidade técnica.

Quando bem apresentado, este repositório tem todos os elementos para chamar atenção no GitHub: **originalidade**, **utilidade prática**, **engenharia inteligente em M** e uma proposta de integração entre plataformas que foge do trivial.

## Referências

[1]: https://learn.microsoft.com/en-us/power-bi/connect-data/refresh-scheduled-refresh "Configure scheduled refresh - Power BI | Microsoft Learn"
[2]: https://learn.microsoft.com/en-us/power-bi/connect-data/service-admin-troubleshoot-unsupported-data-source-for-refresh "Troubleshooting unsupported data source for refresh - Power BI | Microsoft Learn"
[3]: https://learn.microsoft.com/en-us/power-bi/connect-data/refresh-data#refresh-and-dynamic-data-sources "Data refresh in Power BI - Refresh and dynamic data sources | Microsoft Learn"
