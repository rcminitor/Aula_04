# Aula 04 — Claude Code com OpenRouter

Disciplina de Inteligência Artificial — IFCE Campus Caucaia — Prof. Romulo Cesar

Tutorial passo a passo. Ao final, você terá o Claude Code rodando no terminal, respondendo por um modelo do OpenRouter.

**Tempo estimado:** 30 a 40 minutos.

---

## O que vamos instalar

| Item | Para que serve |
|---|---|
| Node.js | Plataforma que executa o Claude Code |
| npm | Gerenciador de pacotes que vem junto com o Node |
| Claude Code | O assistente de terminal |
| Conta no OpenRouter | Fornece o modelo de linguagem e a chave de acesso |

> **Laboratório do IFCE:** as máquinas não permitem instalação pelo aluno. Se o Node já estiver instalado, pule para o Passo 2. Se não estiver, chame o professor — ou use a versão portátil indicada no Passo 1B.

---

## Passo 1 — Instalar o Node.js

Abra o **PowerShell** (tecla Windows, digite `powershell`, Enter) e rode:

```powershell
winget install OpenJS.NodeJS.LTS
```

Se o `winget` não existir, baixe o instalador LTS em <https://nodejs.org> e siga o assistente (Avançar até o fim).

**Feche e abra o PowerShell novamente.** Sem isso, o Windows não enxerga o comando novo.

### Passo 1B — Alternativa sem instalar (máquina bloqueada)

Baixe o pacote ZIP do Node em <https://nodejs.org/en/download> (opção *Windows Binary .zip*), extraia em uma pasta sua e, a cada sessão do terminal, rode:

```powershell
$env:Path = "C:\caminho\da\pasta\node;" + $env:Path
```

---

## Passo 2 — Conferir Node e npm

```powershell
node --version
npm --version
```

Você deve ver algo como `v24.19.0` e `11.17.0`. Qualquer Node a partir da versão 18 serve.

Se aparecer *"não é reconhecido como um cmdlet"*, o Node não está instalado ou você não reabriu o terminal.

---

## Passo 3 — Instalar o Claude Code

```powershell
npm install -g @anthropic-ai/claude-code
```

Confira:

```powershell
claude --version
```

Se o comando `claude` não for encontrado, feche e reabra o PowerShell. Persistindo, rode `npm config get prefix` e confirme que esse caminho está na variável PATH.

---

## Passo 4 — Criar a chave no OpenRouter

1. Acesse <https://openrouter.ai> e crie sua conta (pode entrar com Google ou GitHub).
2. Clique no seu avatar → **Keys** → **Create Key**.
3. No campo *Name*, escreva um apelido só para você reconhecer a chave depois, por exemplo `ia-aula-04`. Esse nome fica apenas na sua lista de chaves. O campo de limite de crédito pode ficar vazio.
4. **Copie a chave agora.** Ela começa com `sk-or-v1-` e só aparece uma vez.

> A chave é pessoal e vale como sua senha. Não publique no GitHub, não mande no grupo da turma e não deixe em máquina compartilhada.

---

## Passo 5 — Escolher o modelo

Na página <https://openrouter.ai/models?q=free> aparecem os modelos gratuitos. O nome de cada um (o *slug*) segue o padrão `autor/modelo:free`, por exemplo `qwen/qwen3.8-27b:free`.

Copie o slug do modelo que você escolher. Modelos gratuitos têm limite diário de requisições — se ele parar de responder, troque o slug por outro da mesma lista.

Para ver a lista pelo terminal:

```powershell
(Invoke-RestMethod https://openrouter.ai/api/v1/models).data | Where-Object { $_.id -like '*:free' } | Select-Object -First 15 -ExpandProperty id
```

---

## Passo 6 — Configurar o projeto

Abra o arquivo `.claude\settings.local.json` desta pasta e preencha dois campos:

- `ANTHROPIC_AUTH_TOKEN`: a chave que você copiou no Passo 4;
- `ANTHROPIC_MODEL`: o slug do Passo 5.

O arquivo deve ficar assim:

```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://openrouter.ai/api",
    "ANTHROPIC_AUTH_TOKEN": "sk-or-v1-COLE_SUA_CHAVE_AQUI",
    "ANTHROPIC_API_KEY": "",
    "ANTHROPIC_MODEL": "qwen/qwen3.8-27b:free"
  }
}
```

Três detalhes que fazem a configuração falhar se estiverem errados:

1. A base URL termina em `/api`, **sem** `/v1`. O Claude Code acrescenta o `/v1/messages` sozinho.
2. `ANTHROPIC_API_KEY` fica **vazio**. Se tiver qualquer valor, o Claude tenta falar com a Anthropic em vez do OpenRouter.
3. O arquivo é JSON: toda vírgula e aspas contam. Salve em UTF-8.

---

## Passo 7 — Testar

Ainda no PowerShell, entre na pasta da aula e rode o verificador:

```powershell
cd C:\Users\rcmin\Projetos\Teste_Aula_04
powershell -ExecutionPolicy Bypass -File .\verificar-ambiente.ps1
```

Ele confere Node, npm, Claude Code, o formato do JSON e se a chave foi preenchida.

Estando tudo verde, inicie o assistente:

```powershell
claude
```

Peça a ele, por exemplo: *"explique em três linhas o que é uma máscara de sub-rede"*. Para sair, digite `/exit`.

### Exercício da aula

1. Peça ao Claude para criar um script que calcule a quantidade de hosts de uma sub-rede /26.
2. Rode o script e confira o resultado à mão.
3. Peça a ele para explicar cada linha do que escreveu.
4. Troque o modelo no `settings.local.json` por outro da lista e repita a pergunta 1. Anote as diferenças entre as duas respostas.

---

## Problemas comuns

| Mensagem | Causa | Solução |
|---|---|---|
| `npm não é reconhecido` | Node não instalado, ou terminal não reaberto | Refaça o Passo 1 e abra um terminal novo |
| `claude não é reconhecido` | Pasta global do npm fora do PATH | Rode `npm config get prefix` e acrescente ao PATH |
| Erro 401 | Chave errada, com espaço sobrando, ou `ANTHROPIC_API_KEY` preenchido | Revise o Passo 6 |
| Erro 404 | Base URL com `/v1` no fim | Use `https://openrouter.ai/api` |
| `model not found` | Slug digitado errado | Copie de novo em openrouter.ai/models |
| Erro 429 | Limite diário do modelo gratuito | Troque para outro modelo `:free` |
| Script não executa | Política de execução do PowerShell | Use `powershell -ExecutionPolicy Bypass -File .\verificar-ambiente.ps1` |

---

## O que mudou em relação à Aula 03

| Aula 03 | Aula 04 |
|---|---|
| Modelo `openrouter/free`, que não é um slug válido | Slug real, escolhido pelo aluno na lista de gratuitos |
| Chave gravada no arquivo, igual para todos | Cada aluno usa a própria chave |
| Sem verificação | Script `verificar-ambiente.ps1` |
| Sem proteção da chave | `.gitignore` impede que o arquivo com a chave seja versionado |
| Sem roteiro | Este tutorial, com exercício e solução de problemas |

---

## Checklist final

- [ ] `node --version` responde
- [ ] `npm --version` responde
- [ ] `claude --version` responde
- [ ] Chave criada no OpenRouter e colada no `settings.local.json`
- [ ] Slug de um modelo gratuito colado no `settings.local.json`
- [ ] `verificar-ambiente.ps1` sem erros
- [ ] O Claude respondeu a uma pergunta no terminal
- [ ] Exercício feito e anotado
