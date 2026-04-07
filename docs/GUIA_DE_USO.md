# Guia de uso do GFolder para Power BI e Excel 🛠️

![Fluxo de instalação do GFolder](../assets/img/gfolder-guia-fluxo.png)

<p align="center">
  <strong><span style="color:#58a6ff;">Instalação guiada</span></strong> • <strong><span style="color:#3fb950;">uso no Power BI e Excel</span></strong> • <strong><span style="color:#ffa657;">credencial anônima</span></strong>
</p>

> **Este guia mostra, passo a passo, como instalar, configurar e usar as funções GFolder no Power BI Desktop e no Excel com Power Query.**

## 🎯 Objetivo deste guia

Este material foi escrito para deixar a adoção da solução simples, visual e segura. A lógica geral de uso é direta: você cria uma consulta nula, abre o **Editor Avançado**, cola a função, salva e depois cria outra consulta para invocá-la com a URL de uma pasta pública do Google Drive.

Apesar de o fluxo ser simples, alguns detalhes fazem toda a diferença: usar a função correta para cada ambiente, configurar credenciais **Anônimas** e garantir que a pasta do Google Drive esteja realmente pública.

Se você quiser primeiro entender o projeto de forma geral, leia o [**README.md**](../README.md). Se quiser revisar as restrições técnicas antes da instalação, consulte [**COMPATIBILIDADE_E_LIMITACOES.md**](./COMPATIBILIDADE_E_LIMITACOES.md).

## ✅ Antes de começar

Antes de importar a função, confira os pré-requisitos abaixo.

| Item | Requisito |
|---|---|
| Compartilhamento da pasta | A pasta do Google Drive deve estar pública, idealmente em um cenário compatível com acesso anônimo. |
| URL da pasta | Pode ser a URL direta do navegador ou a URL de compartilhamento. |
| Credenciais | Ao configurar a fonte web, use **Anônimo**. |
| Escolha da função | Use a versão do **Power BI** no Power BI e a versão do **Excel** no Excel. |
| Parquet | Só a versão do Power BI aceita `.parquet`. |

As URLs de teste abaixo são válidas como referência de formato:

```text
https://drive.google.com/drive/folders/1W2hryU6rf3a3BbafLC5Jm6w8g0j7MoY5
https://drive.google.com/drive/folders/1W2hryU6rf3a3BbafLC5Jm6w8g0j7MoY5?usp=drive_link
```

## 🔵 Como instalar no Power BI Desktop

<p>
  <strong><span style="color:#58a6ff;">Objetivo desta seção:</span></strong> criar a função no Power BI, validá-la com uma consulta de teste e confirmar que a tabela retornada está pronta para expansão e modelagem.
</p>

No **Power BI Desktop**, a forma mais segura de usar a função é criar uma consulta exclusiva para armazenar a função e uma segunda consulta para invocá-la. Isso organiza melhor o projeto e facilita manutenção futura.

### 🟦 Etapa 1 — Abrir o Power BI Desktop

Abra o **Power BI Desktop** e crie um arquivo novo, ou então abra o seu arquivo de trabalho atual.

### 🟦 Etapa 2 — Abrir o Power Query Editor

Na faixa de opções, clique em **Transformar dados**. Isso abrirá o ambiente do **Power Query Editor**.

### 🟦 Etapa 3 — Criar uma consulta nula

No Power Query Editor, vá até **Página Inicial** e clique em **Nova Fonte**. Em seguida, escolha **Consulta Nula**.

Uma nova consulta vazia será criada no painel lateral esquerdo.

### 🟦 Etapa 4 — Renomear a consulta da função

No painel de consultas, clique com o botão direito sobre a nova consulta e renomeie para algo como:

```text
Fn Gdrive(Fernando-IA)V3
```

Você pode usar outro nome, mas, se quiser reutilizar os exemplos exatamente como estão nesta documentação, é melhor manter esse padrão.

### 🟦 Etapa 5 — Abrir o Editor Avançado

Com a consulta selecionada, clique em **Exibição** e depois em **Editor Avançado**.

Apague o conteúdo padrão e cole integralmente o código da função do arquivo:

```text
04-Fn Gdrive(Fernando-IA)V3.txt
```

Depois clique em **Concluído**.

### 🟦 Etapa 6 — Confirmar que a consulta virou uma função

Se tudo foi colado corretamente, a consulta deixará de ser uma tabela simples e passará a aparecer como **função**. Você verá a indicação de que ela recebe parâmetros.

Os parâmetros esperados são:

| Parâmetro | Tipo | Obrigatório | Função |
|---|---|---:|---|
| `Link_do_GoogleFolder` | texto | Sim | URL da pasta do Google Drive |
| `FiltrarExtensao` | texto | Não | Extensão para restringir o resultado |

### 🟦 Etapa 7 — Criar a consulta de invocação

Agora crie uma **nova consulta nula**. Essa segunda consulta será usada para chamar a função.

Renomeie essa nova consulta para algo como:

```text
Teste GFolder
```

Abra novamente o **Editor Avançado** e cole um exemplo de invocação como este:

```powerquery
let
    Fonte = #"Fn Gdrive(Fernando-IA)V3"(
        "https://drive.google.com/drive/folders/1W2hryU6rf3a3BbafLC5Jm6w8g0j7MoY5"
    )
in
    Fonte
```

Se quiser filtrar, por exemplo, apenas PDFs, use:

```powerquery
let
    Fonte = #"Fn Gdrive(Fernando-IA)V3"(
        "https://drive.google.com/drive/folders/1W2hryU6rf3a3BbafLC5Jm6w8g0j7MoY5?usp=drive_link",
        "pdf"
    )
in
    Fonte
```

Clique em **Concluído**.

### 🟦 Etapa 8 — Configurar as credenciais da fonte web

Quando o Power BI solicitar credenciais, escolha:

| Configuração | Valor recomendado |
|---|---|
| Tipo de acesso | **Anônimo** |
| Nível de privacidade | Conforme sua política interna, mas normalmente organizacional ou público, conforme o cenário |

Esse passo é essencial. Se você escolher um método incompatível, a função pode falhar logo no acesso à página da pasta.

### 🟦 Etapa 9 — Validar o retorno

Se a função estiver operando corretamente, a consulta retornará uma tabela com colunas como:

| Coluna | Significado |
|---|---|
| `Nome do Arquivo` | Nome tratado do arquivo encontrado |
| `Tipo` | Tipo do item retornado |
| `Extensão` | Extensão inferida |
| `Link de Download` | Link final gerado pela função |
| `Conteúdo` | Conteúdo lido pelo Power Query |
| `Status` | Resultado da tentativa de leitura |
| `Erro` | Mensagem de falha, quando houver |

### 🟦 Etapa 10 — Expandir e tratar o conteúdo

Dependendo do tipo de arquivo, a coluna **Conteúdo** poderá conter tabelas, listas, registros ou outros objetos do Power Query. A partir daí, você pode expandir essas estruturas e seguir com o tratamento normal dos dados.

No caso de planilhas Excel, por exemplo, o `Conteúdo` geralmente retornará uma tabela com abas, nomes de objetos e dados internos. No caso de CSV, a leitura tende a devolver uma tabela tabular mais direta.

### 🟦 Etapa 11 — Aplicar e carregar

Depois de validar a consulta, clique em **Fechar e Aplicar** para carregar os dados no modelo do Power BI.

> **Dica prática:** se a pasta tiver muitos arquivos, vale a pena testar primeiro com um filtro de extensão, como `pdf` ou `csv`, para validar a lógica com mais rapidez. 🚀

## 🟢 Como instalar no Excel

<p>
  <strong><span style="color:#3fb950;">Objetivo desta seção:</span></strong> repetir a lógica de instalação no Excel usando a versão segura da função, ajustada para o ambiente em que `Parquet.Document(...)` pode não estar disponível.
</p>

No **Excel**, a lógica é praticamente a mesma, mas é importante usar a versão correta da função: a edição sem suporte a Parquet.

### 🟩 Etapa 1 — Abrir o Excel

Abra uma pasta de trabalho nova ou o arquivo em que deseja usar a função.

### 🟩 Etapa 2 — Abrir o Power Query

Na faixa de opções do Excel, vá até a guia **Dados**. Em seguida, escolha **Obter Dados** e depois abra o **Editor do Power Query**.

Dependendo da sua versão do Excel, o caminho exato pode variar ligeiramente, mas a ideia é entrar no ambiente onde ficam as consultas.

### 🟩 Etapa 3 — Criar uma consulta nula

Dentro do Power Query, crie uma **Consulta Nula**.

### 🟩 Etapa 4 — Renomear a função

Renomeie a consulta para:

```text
Fn Gdrive(Fernando-IA)V3-Excel
```

### 🟩 Etapa 5 — Abrir o Editor Avançado

Com a consulta selecionada, vá em **Exibição** e abra o **Editor Avançado**.

Remova o conteúdo padrão e cole o código integral do arquivo:

```text
04-Fn Gdrive(Fernando-IA)V3-Excel.txt
```

Clique em **Concluído**.

### 🟩 Etapa 6 — Criar a consulta que invoca a função

Crie uma nova consulta nula e dê um nome como:

```text
Teste Fn Gdrive(Fernando-IA)V3-Excel
```

No **Editor Avançado**, cole um exemplo de chamada como este:

```powerquery
let
    Fonte = #"Fn Gdrive(Fernando-IA)V3-Excel"(
        "https://drive.google.com/drive/folders/1W2hryU6rf3a3BbafLC5Jm6w8g0j7MoY5"
    )
in
    Fonte
```

Se quiser filtrar por uma extensão específica, use o segundo parâmetro:

```powerquery
let
    Fonte = #"Fn Gdrive(Fernando-IA)V3-Excel"(
        "https://drive.google.com/drive/folders/1W2hryU6rf3a3BbafLC5Jm6w8g0j7MoY5?usp=drive_link",
        "csv"
    )
in
    Fonte
```

### 🟩 Etapa 7 — Informar credenciais anônimas

Quando o Excel solicitar as credenciais da fonte da web, selecione **Anônimo**.

Esse ponto é indispensável porque o acesso previsto pela solução ocorre sobre uma pasta pública do Google Drive.

### 🟩 Etapa 8 — Carregar a consulta

Depois de validar a pré-visualização, clique em **Fechar e Carregar**.

O Excel pode carregar o resultado em planilha, conexão ou modelo de dados, conforme a sua necessidade. No arquivo de teste analisado, a saída foi materializada em uma planilha chamada **Função Invocada**.

> **Dica prática:** no Excel, comece sempre com arquivos mais simples, como `csv`, `xlsx` ou `pdf`, antes de expandir o uso para cenários mais amplos. 📘

## 🆚 Diferença prática entre Power BI e Excel

A diferença operacional entre os dois ambientes é pequena, mas a escolha da função correta é obrigatória.

| Ambiente | Função correta | Observação |
|---|---|---|
| Power BI Desktop | `04-Fn Gdrive(Fernando-IA)V3.txt` | Suporta `.parquet`. |
| Excel | `04-Fn Gdrive(Fernando-IA)V3-Excel.txt` | Não suporta `.parquet`. |

Se você usar a função do Power BI no Excel, corre o risco de encontrar incompatibilidade por causa de `Parquet.Document(...)`.

## 🔎 Como filtrar por extensão

O segundo parâmetro da função é opcional. Se ele for omitido, a função retorna todos os arquivos elegíveis que conseguir detectar na pasta. Se ele for informado, a tabela será filtrada para manter apenas a extensão especificada.

| Objetivo | Valor do filtro |
|---|---|
| Apenas PDFs | `"pdf"` |
| Apenas CSVs | `"csv"` |
| Apenas arquivos Excel | `"xlsx"` ou `"xls"` |
| Apenas JSON | `"json"` |

O filtro deve ser informado em texto e, de preferência, em minúsculas.

## 📋 O que esperar no retorno

É importante entender que a função não devolve somente nomes de arquivos. Ela tenta também interpretar o conteúdo.

| Tipo de arquivo | Retorno típico na coluna `Conteúdo` |
|---|---|
| Excel | Estrutura com abas/tabelas internas |
| CSV / TSV | Tabela tabular |
| TXT | Tabela ou lista de linhas |
| JSON | Registro, lista ou tabela, dependendo da estrutura |
| XML | Tabelas XML |
| PDF | Tabelas extraídas do PDF |
| Parquet | Tabela, apenas no Power BI |

Por isso, o uso mais produtivo da função normalmente exige uma etapa posterior de expansão ou transformação da coluna `Conteúdo`.

## ⚠️ Limitações que o usuário precisa conhecer

<p>
  <strong><span style="color:#f85149;">Importante:</span></strong> compreender essas limitações antes da instalação evita erros de configuração e reduz falsas expectativas sobre o comportamento da função em ambientes diferentes.
</p>

As limitações abaixo devem ser consideradas desde o início do uso.

### 1. 🔓 A pasta precisa ser pública

A função foi pensada para cenários em que a pasta do Google Drive está acessível publicamente. Sem isso, o Power Query não conseguirá ler a página e/ou baixar os arquivos.

### 2. 📄 Arquivos nativos do Google não entram no retorno final

A solução **não retorna** no resultado final itens como:

| Tipo de item | Retorna no resultado final? |
|---|---:|
| Google Docs | Não |
| Google Sheets | Não |
| Google Slides | Não |
| Subpastas internas | Não |

No caso específico de Google Sheets, a função até consegue detectar o item como `sheet`, mas depois o remove da tabela final.

### 3. 🕸️ A estrutura depende da página pública do Google Drive

Como a solução não usa a API oficial do Google Drive, mas sim leitura da página HTML pública, eventuais mudanças estruturais do Google podem impactar o comportamento da função.

### 4. ☁️ Power BI Service não deve ser tratado como cenário garantido

A função foi pensada principalmente para uso em **Power BI Desktop** e **Excel**. No **Power BI Service**, a atualização agendada não deve ser tratada como garantida, por causa da combinação de `Web.BrowserContents` com URLs dinâmicas.

## 🧯 Solução de problemas

A presença das colunas `Status` e `Erro` ajuda bastante no diagnóstico. Quando algo falhar, o primeiro lugar para olhar é justamente o resultado retornado pela função.

| Sintoma | Possível causa | Ação sugerida |
|---|---|---|
| Nenhum arquivo retornado | Pasta não pública ou HTML diferente do esperado | Verifique o compartilhamento da pasta e teste a URL no navegador anônimo. |
| Erro ao baixar arquivo | Link gerado inacessível ou item indisponível | Confirme se o arquivo ainda existe e se a pasta continua pública. |
| `Status = Erro` em um arquivo específico | Formato inválido, arquivo corrompido ou falha do leitor correspondente | Analise a coluna `Erro` e teste o arquivo manualmente. |
| Falha no Excel com Parquet | Uso da função errada | Troque para `04-Fn Gdrive(Fernando-IA)V3-Excel.txt`. |
| Falha de credencial | Método de autenticação incorreto | Reconfigure a fonte como **Anônimo**. |

## 🌟 Boas práticas de uso

Para manter a solução organizada e mais fácil de compartilhar com outras pessoas, é recomendável separar a função da consulta que a invoca. Também vale a pena criar consultas específicas por extensão quando o volume da pasta for alto ou quando o projeto precisar de pipelines mais limpos.

| Boa prática | Benefício |
|---|---|
| Manter a função em consulta separada | Facilita manutenção e reutilização |
| Criar consulta de teste separada | Melhora legibilidade do projeto |
| Filtrar por extensão quando fizer sentido | Reduz volume desnecessário |
| Verificar `Status` e `Erro` antes de expandir `Conteúdo` | Melhora diagnóstico |
| Usar a função correta para cada ambiente | Evita incompatibilidades |

## 🔁 Exemplo de fluxo recomendado

Um fluxo de trabalho recomendável no dia a dia seria o seguinte: primeiro criar a função; depois testá-la com uma pasta pública do Google Drive; em seguida validar se a listagem retornou corretamente; depois filtrar, se necessário, por extensão; por fim expandir a coluna `Conteúdo` para consumir os dados desejados.

Esse modelo permite tratar a função como uma camada de descoberta e ingestão, enquanto as consultas posteriores ficam responsáveis pela modelagem analítica propriamente dita.

## ✅ Encerramento

As funções GFolder oferecem uma forma muito criativa de conectar **Power Query** a uma pasta pública do **Google Drive**, tanto no **Power BI Desktop** quanto no **Excel**. O uso correto depende principalmente de três cuidados: escolher a versão certa da função, configurar a fonte como anônima e garantir que a pasta esteja realmente pública.

Seguindo o passo a passo deste guia, você terá uma base sólida para instalar a função, validar o retorno e transformar os arquivos encontrados em tabelas e estruturas prontas para análise. Se quiser complementar a leitura, volte ao [**README.md**](../README.md) e ao [**COMPATIBILIDADE_E_LIMITACOES.md**](./COMPATIBILIDADE_E_LIMITACOES.md).
