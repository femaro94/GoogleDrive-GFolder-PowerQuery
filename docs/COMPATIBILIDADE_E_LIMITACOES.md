# Compatibilidade e limitações do GFolder ⚠️

![Compatibilidade GFolder](../assets/img/gfolder-compatibilidade.png)

<p align="center">
  <strong><span style="color:#3fb950;">Compatível no Desktop</span></strong> • <strong><span style="color:#ffa657;">Limitado no Service</span></strong> • <strong><span style="color:#f85149;">Restrições conhecidas</span></strong>
</p>

> **Este documento complementa o [README.md](../README.md) e resume, de forma direta, onde a solução funciona bem, quais formatos ela suporta e quais limitações precisam ser respeitadas.**

## 🧭 Propósito deste documento

Este material existe para deixar o projeto mais transparente e mais profissional. A proposta do GFolder é poderosa, mas o valor real da solução aparece ainda mais quando o repositório explica com clareza o que ela faz, onde ela funciona e quais são os seus limites técnicos.

Se você quiser a visão geral do projeto, comece pelo [**README.md**](../README.md). Se quiser o passo a passo de instalação e uso, siga para o [**GUIA_DE_USO.md**](./GUIA_DE_USO.md).

## 📦 Versões disponíveis

O projeto possui duas versões finais da função, cada uma voltada para um ambiente específico.

| Arquivo | Ambiente recomendado | Observação principal |
|---|---|---|
| `FnGdrive(Fernando)V3.txt` | **Power BI Desktop** | Inclui suporte a arquivos `.parquet`. |
| `FnGdrive(Fernando)V3-Excel.txt` | **Excel / Power Query do Excel** | Não processa `.parquet`, para preservar compatibilidade. |

A diferença entre as duas não é de qualidade, e sim de **compatibilidade de runtime**. A versão do Excel foi ajustada para funcionar melhor no ambiente em que `Parquet.Document(...)` pode não estar disponível.

## 🧩 Formatos suportados

<p>
  <strong><span style="color:#58a6ff;">Leitura multi-formato:</span></strong> o projeto foi desenhado para transformar uma pasta pública do Google Drive em uma camada prática de ingestão para Power Query.
</p>

A tabela abaixo resume os formatos que as funções tentam interpretar.

| Formato | Extensão | Power BI | Excel | Estratégia de leitura |
|---|---|---:|---:|---|
| Excel | `.xlsx` | Sim | Sim | `Excel.Workbook(...)` |
| Excel legada | `.xls` | Sim | Sim | `Excel.Workbook(...)` |
| CSV | `.csv` | Sim | Sim | `Csv.Document(...)` com autodetecção e fallbacks |
| TSV | `.tsv` | Sim | Sim | `Csv.Document(...)` com delimitador tab |
| Texto | `.txt` | Sim | Sim | Leitura tabular com fallback para linhas |
| JSON | `.json` | Sim | Sim | `Json.Document(...)` |
| XML | `.xml` | Sim | Sim | `Xml.Tables(...)` |
| PDF | `.pdf` | Sim | Sim | `Pdf.Tables(...)` |
| Parquet | `.parquet` | Sim | Não | `Parquet.Document(...)` |

## 🚫 Itens que não retornam no resultado final

Embora a função consiga navegar pela página pública da pasta do Google Drive e identificar diferentes tipos de itens, o retorno final não inclui alguns elementos.

| Item | Retorna no resultado final? | Observação |
|---|---:|---|
| Google Docs | Não | Não entra como arquivo utilizável na tabela final. |
| Google Sheets | Não | Pode ser detectado como `sheet`, mas é removido pela etapa `RemoveSheets`. |
| Google Slides | Não | Não é retornado como conteúdo utilizável. |
| Subpastas internas | Não | São removidas pela etapa `RemovePastas`. |

Esse ponto é importante porque define o escopo real do projeto. O GFolder navega muito bem em uma pasta pública e lida com arquivos convencionais, mas **não foi desenhado para retornar artefatos nativos do Google nem estruturas hierárquicas internas**.

## 🌐 Requisitos de compartilhamento da pasta

A função foi concebida para operar sobre uma pasta pública do Google Drive, acessível por navegação web sem autenticação formal da API. Na prática, isso significa que o cenário de uso mais seguro é aquele em que a pasta está compartilhada de modo suficientemente aberto para permitir leitura via credencial **Anônima** no Power Query.

> **Cenário recomendado:** a pasta do Google Drive deve estar pública, em um nível que permita leitura pela web usando autenticação anônima no Power Query.

Se a pasta não estiver efetivamente pública, a consulta poderá falhar na listagem dos arquivos, no download ou na leitura do conteúdo.

## 💻 Compatibilidade por ambiente

A solução se comporta de forma diferente conforme o ambiente de execução.

| Ambiente | Situação de compatibilidade | Comentário |
|---|---|---|
| Power BI Desktop | ✅ Compatível | É o principal ambiente para a versão com suporte a Parquet. |
| Excel Power Query | ✅ Compatível | Deve usar a versão sem Parquet. |
| Power BI Service | ⚠️ Compatibilidade limitada | A atualização agendada não deve ser tratada como garantida. |

## ☁️ Situação do Power BI Service

<p>
  <strong><span style="color:#ffa657;">Atenção:</span></strong> este é o principal ponto de cautela do projeto. O uso em Desktop foi validado; já no serviço, o refresh automático precisa ser tratado como cenário de baixa previsibilidade.
</p>

A documentação oficial da Microsoft informa que, na maioria dos casos, modelos semânticos que usam **fontes dinâmicas** não podem ser atualizados no **Power BI Service**, salvo exceções específicas com `Web.Contents` estruturado com `RelativePath` e `Query` [1]. A Microsoft também explica que algumas fontes usadas no Power BI Desktop podem não oferecer suporte a atualização no serviço [2] [3].

Nesta solução, a pasta do Google Drive é lida via `Web.BrowserContents(...)` e os links de download são montados dinamicamente a partir dos itens encontrados. Por isso, o cenário deve ser tratado como **fonte web dinâmica / consulta artesanal**, o que reduz fortemente a previsibilidade de refresh automático no serviço [1] [2] [3].

> "In most cases, Power BI semantic models that use dynamic data sources can't be refreshed in the Power BI service." — Microsoft Learn [1]

Assim, a recomendação oficial do repositório deve ser esta:

> **A solução foi validada para Power BI Desktop e Excel Power Query. Para Power BI Service, a atualização agendada deve ser considerada limitada e não garantida.**

## 🔗 URLs aceitas

A função aceita tanto a URL direta da pasta quanto a URL de compartilhamento.

| Tipo de URL | Exemplo |
|---|---|
| URL direta da pasta | `https://drive.google.com/drive/folders/1W2hryU6rf3a3BbafLC5Jm6w8g0j7MoY5` |
| URL de compartilhamento | `https://drive.google.com/drive/folders/1W2hryU6rf3a3BbafLC5Jm6w8g0j7MoY5?usp=drive_link` |

## 🛡️ Leitura resiliente

Um dos avanços mais importantes da versão final é o retorno estruturado com colunas de auditoria.

| Coluna | Função |
|---|---|
| `Conteúdo` | Guarda o conteúdo interpretado do arquivo. |
| `Status` | Informa se a leitura foi bem-sucedida ou se houve falha. |
| `Erro` | Registra a mensagem de erro associada ao item. |

Esse desenho melhora muito o uso da função em cenários reais, porque permite identificar rapidamente quais arquivos foram carregados com sucesso e quais falharam. Em outras palavras, a função não apenas lista arquivos: ela também ajuda a **monitorar a qualidade da ingestão**. 🔍

## 🎯 Resumo executivo

| Tema | Conclusão |
|---|---|
| Pasta pública do Google Drive | Obrigatória para o cenário validado |
| Credencial recomendada | **Anônima** |
| Google Docs / Sheets / Slides | Não retornam no resultado final |
| Subpastas internas | Não retornam |
| Power BI Desktop | Compatível |
| Excel | Compatível com a versão sem Parquet |
| Power BI Service | Compatibilidade limitada, refresh não garantido |

## Referências

1. Microsoft Learn — [Data refresh in Power BI - Refresh and dynamic data sources][1]
2. Microsoft Learn — [Troubleshooting unsupported data source for refresh - Power BI][2]
3. Microsoft Learn — [Configure scheduled refresh - Power BI][3]

[1]: https://learn.microsoft.com/en-us/power-bi/connect-data/refresh-data#refresh-and-dynamic-data-sources
[2]: https://learn.microsoft.com/en-us/power-bi/connect-data/service-admin-troubleshoot-unsupported-data-source-for-refresh
[3]: https://learn.microsoft.com/en-us/power-bi/connect-data/refresh-scheduled-refresh
