<#
PowerShell script para normalizar las cabeceras de `anexos/data/encuesta.csv`, crear
`anexos/data/encuesta_clean.csv` y generar resúmenes simples (summary_*.txt).

Funciona en Windows PowerShell 5.1.
#>

$root = (Split-Path -Parent $MyInvocation.MyCommand.Path) | Split-Path -Parent
$dataDir = Join-Path $root 'anexos\data'
$input = Join-Path $dataDir 'encuesta.csv'
$clean = Join-Path $dataDir 'encuesta_clean.csv'

if (!(Test-Path $input)) {
    Write-Error "CSV no encontrado: $input"
    exit 1
}

# Leer el archivo crudo como texto con varios intentos de encoding
$content = $null
try {
    $content = Get-Content -Path $input -Raw -Encoding UTF8
} catch {
    try { $content = Get-Content -Path $input -Raw -Encoding Default } catch { $content = Get-Content -Path $input -Raw }
}

# Separar cabecera y resto
$lines = $content -split "\r?\n"
if ($lines.Length -lt 2) { Write-Error "Archivo CSV parece vacío o no tiene líneas"; exit 1 }
$headerLine = $lines[0]
$rest = $lines[1..($lines.Length -1)] -join "`n"

# Parsear cabeceras cuidando comillas y comas internas
# Usaremos un split simple en comas: si algunas cabeceras contienen comas esto puede romperse,
# pero en la práctica las cabeceras provistas parecen separadas por comas fuera de comillas.
$rawHeaders = $headerLine -split ','

# Normalizar: limpiar espacios, quitar comillas y caracteres no-alfa-numéricos, normalizar acentos
function Normalize-Header([string]$h, [int]$idx) {
    $s = $h.Trim() -replace '"',''
    # Reemplazar múltiples espacios por uno
    $s = $s -replace '\s+',' '
    # Simplificar: quitar/comprimir caracteres no alfanuméricos conservando guion bajo
    # (esto evita caracteres no-ASCII dentro del script)
    $s = $s -replace '[^0-9A-Za-z]','_'
    # Comprimir múltiples guiones bajos
    $s = $s -replace '_{2,}','_'
    # Evitar cabeceras vacías
    if ([string]::IsNullOrWhiteSpace($s)) { $s = "col$idx" }
    return $s
}

$headers = @()
for ($i=0; $i -lt $rawHeaders.Length; $i++) {
    $nh = Normalize-Header $rawHeaders[$i] $i
    $headers += $nh
}

# Hacer únicos los nombres duplicados agregando sufijo _1, _2...
$unique = @{}
for ($i=0; $i -lt $headers.Length; $i++) {
    $name = $headers[$i]
    if ($unique.ContainsKey($name)) {
        $unique[$name] += 1
        $newname = "${name}_$($unique[$name])"
        $headers[$i] = $newname
    } else {
        $unique[$name] = 0
        $headers[$i] = $name
    }
}

# Escribir CSV limpio: usar la nueva cabecera y las líneas originales sin alterar
$headerOut = ($headers -join ',')
Set-Content -Path $clean -Value $headerOut -Encoding UTF8
Add-Content -Path $clean -Value $rest -Encoding UTF8
Write-Output "CSV limpio creado: $clean" 

# Importar con las cabeceras nuevas (Import-Csv detecta bien comillas en los registros)
try {
    $csv = Import-Csv -Path $clean -Delimiter ',' -Encoding UTF8
} catch {
    Write-Warning "Import-Csv falló con UTF8, intentando Default encoding"
    $csv = Import-Csv -Path $clean -Delimiter ',' -Encoding Default
}

# Columnas de interés heurísticas (buscar por palabras clave dentro de las cabeceras normalizadas)
$cols = $csv | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name
$ageCol = ($cols | Where-Object { $_ -match '(?i)edad|rango|age' }) | Select-Object -First 1
$controlCol = ($cols | Where-Object { $_ -match '(?i)control|llevas|gastos' }) | Select-Object -First 1
$payCol = ($cols | Where-Object { $_ -match '(?i)precio|rango.*precio|price' }) | Select-Object -First 1
$ticketCol = ($cols | Where-Object { $_ -match '(?i)ticket|tipo.*ticket|compro' }) | Select-Object -First 1

# Fallback: elegir columnas por posición si heurística falla
if (-not $ageCol) { $ageCol = $cols[2] } # en tu CSV la edad está cerca de tercera columna
if (-not $controlCol) { $controlCol = $cols[3] }
if (-not $payCol) { $payCol = $cols | Where-Object { $_ -match '(?i)rango' } | Select-Object -First 1 }
if (-not $ticketCol) { $ticketCol = $cols | Where-Object { $_ -match '(?i)ticket' } | Select-Object -First 1 }

Write-Output "Columnas elegidas: age=$ageCol, control=$controlCol, pay=$payCol, ticket=$ticketCol"

# Función para generar resumen de frecuencias
function Save-Freq([string]$colname, [string]$outfile) {
    if (-not $colname) { Write-Warning "Columna no especificada para $outfile"; return }
    $freq = $csv | Group-Object -Property $colname | Sort-Object Count -Descending | ForEach-Object { "$($_.Name) : $($_.Count)" }
    $freq | Out-File -FilePath $outfile -Encoding UTF8
    Write-Output "Resumen guardado: $outfile"
}

Save-Freq $ageCol (Join-Path $dataDir 'summary_age.txt')
Save-Freq $controlCol (Join-Path $dataDir 'summary_control.txt')
Save-Freq $payCol (Join-Path $dataDir 'summary_pay.txt')
Save-Freq $ticketCol (Join-Path $dataDir 'summary_ticket.txt')

Write-Output "Proceso terminado. Revisa los archivos en $dataDir"
