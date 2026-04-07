# GFolder | Google Drive no Power Query para Power BI e Excel 🚀

![GFolder Hero](./assets/img/gfolder-hero.png)

![Status](https://img.shields.io/badge/status-ativo-success)

**Power Query** + **Google Drive** + **ingestão online** + **linguagem M**

---

![Power BI](https://img.shields.io/badge/Power%20BI-suporta%20Parquet-F2C811?logo=powerbi&logoColor=000)
![Excel](https://img.shields.io/badge/Excel-sem%20Parquet-217346?logo=microsoftexcel&logoColor=fff)
![Power Query](https://img.shields.io/badge/Power%20Query-linguagem%20M-6B46C1)
![Google Drive](https://img.shields.io/badge/Google%20Drive-pastas%20p%C3%BAblicas-4285F4?logo=googledrive&logoColor=fff)

> **Uma função M autoral para navegar em pastas públicas do Google Drive, listar arquivos, gerar links de download e interpretar conteúdo diretamente no Power Query.**

## ✨ Visão geral

Este projeto reúne duas funções personalizadas em **linguagem M** para **Power Query**, criadas para permitir que **Power BI** e **Excel** leiam, listem e interpretem arquivos armazenados dentro de uma pasta pública do **Google Drive**. Em termos práticos, a função recebe a URL de uma pasta, faz a leitura da página pública, identifica os arquivos exibidos, extrai seus IDs, monta links de download e tenta converter automaticamente o conteúdo para estruturas utilizáveis no ambiente Microsoft.

O ponto mais marcante desta solução é que ela cria uma ponte prática entre dois ecossistemas que normalmente trabalham de forma mais fechada entre si. De um lado, o mundo **Microsoft**, com conectores oficiais e regras mais rígidas. Do outro, o universo **Google**, com a flexibilidade da navegação web pública. O resultado é uma solução técnica criativa, útil e pouco comum, capaz de levar o Power Query além dos conectores tradicionais. 🔥

Ao mesmo tempo, o projeto foi documentado com honestidade técnica. Esta função **não é um conector oficial do Google Drive**; ela opera a partir da leitura da página HTML pública da pasta e da montagem dinâmica dos links de download. Por isso, a solução funciona muito bem dentro do seu escopo real, mas precisa ser usada com as limitações corretas em mente.

## 🧭 Navegação rápida

| Seção | Objetivo |
|---|---|
| [Funções incluídas](#-funções-incluídas) | Entender as duas versões publicadas |
| [Formatos suportados](#-formatos-suportados) | Ver quais extensões a função tenta interpretar |
| [Estrutura de retorno](#-estrutura-de-retorno) | Entender as colunas devolvidas pela função |
| [Limitações essenciais](#-limitações-técnicas-essenciais) | Saber onde a solução funciona e onde não funciona |
| [Atualização no Power BI Service](#-atualização-automática-no-power-bi-service) | Ver a situação real de refresh no serviço |
| [Compatibilidade e limitações](./docs/COMPATIBILIDADE_E_LIMITACOES.md) | Ler a análise complementar do projeto |
| [Guia de uso](./docs/GUIA_DE_USO.md) | Instalar e usar no Power BI e no Excel |

## 📦 Funções incluídas

As duas versões finais deste projeto são as seguintes:

| Arquivo | Ambiente-alvo | Diferença principal |
|---|---|---|
| `FnGdrive(Fernando)V3.txt` | **Power BI Desktop** | Suporta leitura de arquivos **Parquet** além dos demais formatos. |
| `FnGdrive(Fernando)V3-Excel.txt` | **Excel / Power Query do Excel** | Não usa `Parquet.Document`, para preservar compatibilidade com o Excel. |

A única diferença funcional entre elas está no tratamento do formato **Parquet**. Todo o restante da arquitetura, da lógica de descoberta dos arquivos e do formato de retorno permanece essencialmente igual.

## ⚙️ O que a função faz

A função recebe dois parâmetros: a URL da pasta do Google Drive e, opcionalmente, uma extensão para filtrar o resultado. A partir disso, ela executa uma cadeia de processamento bastante sofisticada.

Primeiro, a função usa `Web.BrowserContents(...)` para ler o HTML da pasta pública do Google Drive. Depois, divide esse HTML em fragmentos com base em ocorrências de `data-id=""`, que funcionam como ponto de apoio para capturar os IDs dos arquivos. Em seguida, extrai o nome bruto do item via `aria-label`, classifica o item como arquivo, pasta ou item Google, infere a extensão real, limpa o nome do arquivo, remove o que não interessa e cria um link de download compatível com o tipo encontrado.

Na etapa seguinte, a função tenta interpretar o conteúdo com base na extensão. Se o arquivo for Excel, usa `Excel.Workbook(...)`; se for CSV ou TSV, usa `Csv.Document(...)`; se for TXT, tenta primeiro leitura tabular e, em caso de falha, leitura por linhas; se for JSON, XML, PDF ou Parquet, aciona as funções específicas do Power Query para cada formato. Nas versões finais, o processo ainda foi enriquecido com **resiliência operacional**, pois a função passa a retornar colunas de **Status** e **Erro**, o que facilita auditoria, depuração e tratamento de falhas por arquivo.

## 🧩 Formatos suportados

<p>
  <strong><span style="color:#58a6ff;">Ponto-chave:</span></strong> a solução tenta interpretar automaticamente múltiplos formatos, o que transforma a função em uma camada de ingestão muito mais rica do que uma simples listagem de links.
</p>

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

Essa distinção é importante porque `Parquet.Document(...)` nem sempre está disponível no Power Query do Excel.

## 🧱 Estrutura de retorno

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

Esse desenho transforma a função em algo mais robusto do que uma simples listagem de links. Ela passa a atuar também como um mecanismo de **ingestão com log de processamento**, o que é extremamente valioso em cenários reais de ETL, automação e análise de dados.

![Compatibilidade e Limitações](./assets/img/gfolder-compatibilidade.png)

## 🔒 Limitações técnicas essenciais

A documentação deste projeto precisa ser clara quanto às limitações, porque isso evita uso incorreto e fortalece a credibilidade do repositório.

A primeira limitação é de **compartilhamento**. A função foi desenhada para funcionar quando a pasta do Google Drive está configurada para acesso público amplo, especialmente no cenário em que **qualquer pessoa com o link / da internet pode acessar ou editar**, permitindo o uso de credencial **Anônima** no Power Query. Sem esse tipo de compartilhamento público, a solução tende a falhar.

A segunda limitação é de **escopo de itens retornados**. A função **não retorna arquivos nativos do Google**, como **Google Docs**, **Google Sheets**, **Google Slides**, nem **subpastas internas** contidas dentro da pasta analisada. No caso específico de Google Sheets, a lógica consegue detectar o item internamente, mas ele é removido na etapa `RemoveSheets`. Da mesma forma, subpastas internas são removidas pela etapa `RemovePastas`.

A terceira limitação é de **natureza do mecanismo**. A função faz scraping da página pública da pasta, e não consulta uma API oficial. Isso a torna criativa e poderosa, mas também dependente da estrutura HTML exibida pelo Google Drive no momento da execução.

Para uma visão complementar e mais objetiva das restrições do projeto, consulte também o documento [**COMPATIBILIDADE_E_LIMITACOES.md**](./docs/COMPATIBILIDADE_E_LIMITACOES.md). 📘

## 🔗 Tipos de URL aceitos

Os testes informados para a função mostram que ela aceita tanto a URL da pasta obtida diretamente no navegador quanto a URL de compartilhamento com parâmetro adicional.

| Tipo de URL | Exemplo |
|---|---|
| URL direta da pasta | `https://drive.google.com/drive/folders/1W2hryU6rf3a3BbafLC5Jm6w8g0j7MoY5` |
| URL de compartilhamento | `https://drive.google.com/drive/folders/1W2hryU6rf3a3BbafLC5Jm6w8g0j7MoY5?usp=drive_link` |

## 🖥️ Análise da função para Power BI

A versão `FnGdrive(Fernando)V3.txt` é a edição mais completa da solução. Ela inclui suporte a `Parquet.Document(...)`, além de um fluxo resiliente de leitura baseado em tentativas. O ponto mais valioso da arquitetura está no encapsulamento da leitura em um registro com `Conteúdo`, `Status` e `Erro`, o que transforma a função em um pequeno motor de ingestão supervisionada.

Do ponto de vista arquitetural, essa versão combina três camadas de inteligência. A primeira é a camada de **descoberta de arquivos**, que entende a página do Google Drive. A segunda é a camada de **normalização**, responsável por classificar o tipo do item, deduzir extensão e construir o link final. A terceira é a camada de **interpretação**, que escolhe a função de leitura correta para cada formato.

Para **Power BI Desktop**, essa é a versão recomendada sempre que houver interesse em ler também arquivos **Parquet**.

## 📗 Análise da função para Excel

A versão `FnGdrive(Fernando)V3-Excel.txt` preserva praticamente toda a engenharia da versão para Power BI, porém remove o tratamento de Parquet. Essa decisão é tecnicamente acertada, porque prioriza compatibilidade real de execução dentro do Excel.

Em vez de manter uma função formalmente mais completa, mas potencialmente instável no Excel, esta versão assume uma postura mais robusta: restringe o conjunto de formatos àquilo que o ambiente do Excel tende a suportar com segurança. Isso deixa explícito que não se trata de uma versão inferior, mas de uma versão **adaptada ao runtime do Excel**.

## 🧪 Arquivos de amostra do repositório

O arquivo `samples/Gfolder.xlsx` confirma, de forma prática, o uso real da versão voltada para Excel. A análise interna do workbook mostrou conexões de consulta ligadas à função `FnGdrive(Fernando)V3-Excel` e a uma consulta de resultado materializada em uma planilha visível chamada **Função Invocada**, que contém a saída final da execução.

Além disso, a saída materializada observada no arquivo mostra uma tabela com as colunas **Nome do Arquivo**, **Tipo**, **Extensão**, **Link de Download**, **Conteúdo**, **Status** e **Erro**, exatamente como previsto no código. Os registros visíveis do exemplo retornam extensões como **xlsx**, **xls**, **pdf**, **csv** e **txt**, com **Status = OK** e **Erro em branco**, o que comprova o bom funcionamento da versão para Excel.

O arquivo `samples/Gfolder.pbix` confirma a existência de um projeto Power BI utilizado como ambiente de validação da solução. A inspeção estrutural do PBIX mostra os componentes típicos do formato, incluindo `Report/Layout`, `Settings`, `Metadata` e `DataModel`, o que confirma o papel do arquivo como **artefato de teste da versão Power BI**.

## ☁️ Atualização automática no Power BI Service

Este é um dos pontos mais importantes da documentação. A resposta técnica mais honesta e prudente é: **não se deve prometer atualização automática confiável no Power BI Service para esta solução em seu estado atual**.

A documentação oficial da Microsoft explica que a atualização agendada no Power BI Service depende do suporte da fonte de dados e alerta que modelos com **fontes dinâmicas** geralmente **não podem ser atualizados** no serviço, salvo exceções muito específicas com `Web.Contents` estruturado por `RelativePath` e `Query` [1] [3]. A Microsoft também informa que, quando uma fonte não é suportada, o serviço pode bloquear a configuração de refresh com a mensagem de que o modelo usa fontes que atualmente não oferecem suporte a atualização [2].

No caso desta solução, a função depende de `Web.BrowserContents(Link_do_GoogleFolder)` para ler a página HTML da pasta do Google Drive e, depois, constrói dinamicamente links de download com `Web.Contents(...)`. Essa arquitetura caracteriza um cenário fortemente associado a **fonte web dinâmica** e **consulta artesanal**, o que reduz fortemente a chance de compatibilidade plena com refresh agendado no Power BI Service [2] [3].

> "In most cases, Power BI semantic models that use dynamic data sources can't be refreshed in the Power BI service." — Microsoft Learn [3]

Assim, a formulação recomendada para este projeto é a seguinte:

> Esta solução foi validada principalmente para **Power BI Desktop** e **Excel Power Query**. No **Power BI Service**, a atualização agendada **não é garantida** e deve ser tratada como **limitada** ou **não suportada de forma confiável**, devido ao uso de `Web.BrowserContents` e à natureza dinâmica das URLs geradas.

## 🔐 Credenciais e configuração de acesso

Ao importar a função no Power BI ou no Excel, o cenário esperado é usar a credencial **Anônima** para as chamadas web. Isso ocorre porque o acesso se baseia em uma pasta pública do Google Drive. Se a pasta não estiver realmente aberta ao acesso público, o Power Query poderá falhar no carregamento, na listagem ou na leitura dos arquivos.

A documentação deve deixar explícito que a solução **não substitui autenticação oficial do Google Drive**. Ela funciona porque explora o acesso público à página e aos arquivos disponibilizados dentro dela.

## ▶️ Exemplo de invocação

<p>
  <strong><span style="color:#ffa657;">Dica:</span></strong> se você estiver começando a testar a função, vale usar primeiro uma pasta pequena e, se necessário, aplicar filtro por extensão para validar o comportamento com mais rapidez.
</p>

A função pode ser invocada sem filtro ou com filtro de extensão.

```powerquery
let
    Fonte = #"FnGdrive(Fernando)V3"(
        "https://drive.google.com/drive/folders/1W2hryU6rf3a3BbafLC5Jm6w8g0j7MoY5"
    )
in
    Fonte
```

```powerquery
let
    Fonte = #"FnGdrive(Fernando)V3"(
        "https://drive.google.com/drive/folders/1W2hryU6rf3a3BbafLC5Jm6w8g0j7MoY5?usp=drive_link",
        "pdf"
    )
in
    Fonte
```

No Excel, basta trocar o nome da função pela versão `FnGdrive(Fernando)V3-Excel`.

## 🗂️ Estrutura do repositório

![Fluxo de Instalação](./assets/img/gfolder-guia-fluxo.png)

| Caminho | Conteúdo |
|---|---|
| `/README.md` | Apresentação geral do projeto, diferenças entre versões, limitações e exemplos. |
| `/power-bi/FnGdrive(Fernando)V3.txt` | Função para Power BI. |
| `/excel/FnGdrive(Fernando)V3-Excel.txt` | Função para Excel. |
| `/code/FnGdrive(Fernando)V3.pq` | Visualização formatada do código da função para Power BI no GitHub. |
| `/code/FnGdrive(Fernando)V3-Excel.pq` | Visualização formatada do código da função para Excel no GitHub. |
| `/docs/GUIA_DE_USO.md` | Passo a passo completo de instalação e uso. |
| `/docs/COMPATIBILIDADE_E_LIMITACOES.md` | Resumo técnico das restrições, formatos e compatibilidade. |
| `/samples/Gfolder.pbix` | Arquivo de teste do Power BI. |
| `/samples/Gfolder.xlsx` | Arquivo de teste do Excel. |

## 🌟 Por que este projeto chama atenção

Este repositório reúne quatro qualidades que normalmente geram impacto positivo para quem chega pela primeira vez ao projeto.

| Diferencial | Valor entregue |
|---|---|
| **Originalidade** | Explora uma integração rara entre Google Drive e Power Query. |
| **Utilidade prática** | Resolve um problema real de navegação e ingestão de arquivos. |
| **Robustez** | Traz colunas de `Status` e `Erro` para observabilidade operacional. |
| **Clareza documental** | Explica com honestidade onde funciona, onde não funciona e por quê. |

## ✅ Conclusão

Este projeto representa uma solução altamente criativa de integração entre **Google Drive** e **Power Query**, com aplicações práticas em **Power BI Desktop** e **Excel**. A função não depende de conector oficial, consegue trabalhar com mais de um formato de URL pública da pasta, interpreta diversos tipos de arquivos e ainda devolve metadados operacionais importantes, como **Status** e **Erro**.

Suas limitações devem ser comunicadas com honestidade: a pasta precisa estar pública, arquivos nativos do Google e subpastas não entram no retorno final, e o refresh automático no Power BI Service não deve ser tratado como garantido. Justamente por isso, a documentação correta não diminui o projeto; ao contrário, mostra maturidade técnica. 💡

Se você quiser instalar a solução agora, siga o [**GUIA_DE_USO.md**](./docs/GUIA_DE_USO.md). Se quiser entender melhor as restrições de ambiente, leia o [**COMPATIBILIDADE_E_LIMITACOES.md**](./docs/COMPATIBILIDADE_E_LIMITACOES.md).

## Referências

1. Microsoft Learn — [Configure scheduled refresh - Power BI][1]
2. Microsoft Learn — [Troubleshooting unsupported data source for refresh - Power BI][2]
3. Microsoft Learn — [Data refresh in Power BI - Refresh and dynamic data sources][3]

[1]: https://learn.microsoft.com/en-us/power-bi/connect-data/refresh-scheduled-refresh
[2]: https://learn.microsoft.com/en-us/power-bi/connect-data/service-admin-troubleshoot-unsupported-data-source-for-refresh
[3]: https://learn.microsoft.com/en-us/power-bi/connect-data/refresh-data#refresh-and-dynamic-data-sources
