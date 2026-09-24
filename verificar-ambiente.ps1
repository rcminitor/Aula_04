# Aula 03 - verificacao do ambiente
# Uso: powershell -ExecutionPolicy Bypass -File .\verificar-ambiente.ps1

$erros = 0
function Ok($m)   { Write-Host "[OK]    $m" -ForegroundColor Green }
function Falha($m){ Write-Host "[FALHA] $m" -ForegroundColor Red; $script:erros++ }

Write-Host "`n=== Verificacao do ambiente - Aula 03 ===`n"

# 1. Node
$node = (node --version 2>$null)
if ($node) { Ok "Node instalado ($node)" } else { Falha "Node nao encontrado - refaca o Passo 1" }

# 2. npm
$npm = (npm --version 2>$null)
if ($npm) { Ok "npm instalado ($npm)" } else { Falha "npm nao encontrado - refaca o Passo 1" }

# 3. Claude Code
$claude = (claude --version 2>$null)
if ($claude) { Ok "Claude Code instalado ($claude)" } else { Falha "Claude Code nao encontrado - refaca o Passo 3" }

# 4. Arquivo de configuracao
$cfgPath = Join-Path $PSScriptRoot ".claude\settings.local.json"
if (-not (Test-Path $cfgPath)) {
    Falha "settings.local.json nao encontrado"
} else {
    try {
        $cfg = Get-Content $cfgPath -Raw | ConvertFrom-Json
        Ok "settings.local.json e um JSON valido"

        if ($cfg.env.ANTHROPIC_BASE_URL -eq "https://openrouter.ai/api") {
            Ok "Base URL correta"
        } else {
            Falha "Base URL deve ser https://openrouter.ai/api (sem /v1)"
        }

        foreach ($campo in "OPENROUTER_API_KEY", "ANTHROPIC_AUTH_TOKEN") {
            $tok = $cfg.env.$campo
            if ($tok -like "sk-or-v1-*" -and $tok -notlike "*COLE_SUA_CHAVE*") {
                Ok "Chave do OpenRouter preenchida em $campo"
            } else {
                Falha "Cole a sua chave do OpenRouter no campo $campo (Passo 4)"
            }
        }

        if ([string]::IsNullOrEmpty($cfg.env.ANTHROPIC_API_KEY)) {
            Ok "ANTHROPIC_API_KEY esta vazio, como deve ser"
        } else {
            Falha "ANTHROPIC_API_KEY precisa ficar vazio"
        }

        $modelo = $cfg.env.ANTHROPIC_MODEL
        if ($modelo -match '^[^/]+/[^/]+$') {
            Ok "Modelo definido ($modelo)"
        } else {
            Falha "ANTHROPIC_MODEL deve ser openrouter/free (ou outro slug autor/modelo:free)"
        }

        if ($cfg.PSObject.Properties.Name -contains "model") {
            Falha "Apague a linha ""model"" fora do bloco env: ela passa por cima do ANTHROPIC_MODEL"
        }

        if ($cfg.env.ENABLE_TOOL_SEARCH -eq "false") {
            Ok "ENABLE_TOOL_SEARCH desligado"
        } else {
            Falha "Defina ""ENABLE_TOOL_SEARCH"": ""false"" no bloco env (Passo 6)"
        }
    } catch {
        Falha "settings.local.json tem erro de sintaxe JSON - confira virgulas e aspas"
    }
}

Write-Host ""
if ($erros -eq 0) {
    Write-Host "Tudo certo. Rode:  claude" -ForegroundColor Green
} else {
    Write-Host "$erros item(ns) para corrigir. Veja a secao 'Problemas comuns' do TUTORIAL.md" -ForegroundColor Yellow
}
Write-Host ""
