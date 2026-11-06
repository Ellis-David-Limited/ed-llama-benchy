param(
    [Parameter(Mandatory)][string]$Label,
    [string]$BaseUrl = "http://ed-llm4.ellisdavid.net:8800/v1",
    [string]$Model = "qwen3.8-27b-int8-w8a16",
    [string]$Tokenizer = "Qwen/Qwen3.6-27B",
    [string]$HostTag = "ed-llm4-tp2",
    [string]$ApiKey = ""
)
# Prefill-vs-prompt-size sweep (cold prompts, no prefix-cache hits) + one decode figure.
# Run the same script with -Label before-... / after-... to compare around a GPU change.
$repo = "D:\dev\ed-llama-benchy"
$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$base = "$repo\results\$Model`_$HostTag`_$Label`_$stamp"
$keyArgs = if ($ApiKey) { @("--api-key", $ApiKey) } else { @() }
Set-Location $repo
Write-Host "Sweep $Label -> $base.json  (log: $base.log, progress: $base.progress.jsonl)"
& "$repo\.venv\Scripts\llama-benchy.exe" `
    --base-url $BaseUrl --model $Model --tokenizer $Tokenizer @keyArgs `
    --pp 1024 4096 16384 32768 65536 --tg 64 --depth 0 `
    --concurrency 1 --runs 3 --warmup-runs 1 --no-cache `
    --latency-mode generation `
    --format json --save-result "$base.json" --emit-progress "$base.progress.jsonl" 2>&1 |
    Tee-Object -FilePath "$base.log"
Write-Host "Done. Exit=$LASTEXITCODE  Result: $base.json"
