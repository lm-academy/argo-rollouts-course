param (
    [string]$Url = "http://localhost",
    [int]$Count = 100,
    [double]$Sleep = 0.5,
    [switch]$Tester,
    [switch]$Public
)

$ErrorActionPreference = "Stop"

# Determine Mode
$Mode = "public"
if ($Tester) {
    $Mode = "tester"
}

# Display Configuration
if ($Mode -eq "tester") {
    $UserType = "TESTER (x-canary: true)"
    $UserColor = "Green"
} else {
    $UserType = "PUBLIC (No Headers)"
    $UserColor = "Cyan"
}

$CountDisp = if ($Count -eq -1) { "Infinite" } else { $Count }

Write-Host "🚀 Sending requests to " -NoNewline
Write-Host "$Url" -ForegroundColor Yellow
Write-Host "👤 User Mode: " -NoNewline
Write-Host "$UserType" -ForegroundColor $UserColor
Write-Host "🔢 Count: $CountDisp, Sleep: ${Sleep}s"
Write-Host "---------------------------------------------------"

$i = 1

try {
    while ($Count -eq -1 -or $i -le $Count) {
        try {
            $Headers = @{}
            if ($Mode -eq "tester") {
                $Headers["x-canary"] = "true"
            }

            $Response = Invoke-WebRequest -Uri $Url -Headers $Headers -Method Get -UseBasicParsing -TimeoutSec 2
            
            $StatusCode = [int]$Response.StatusCode
            $Content = $Response.Content

            # Extract H1
            if ($Content -match "<h1>(.*?)</h1>") {
                $H1 = $matches[1]
                Write-Host "[$i] Response: " -NoNewline
                Write-Host "$H1"
            } else {
                Write-Host "[$i] Response received ($StatusCode) but no <h1> tag found" -ForegroundColor Yellow
            }

        } catch {
            if ($_.Exception.Response) {
                $StatusCode = [int]$_.Exception.Response.StatusCode
                Write-Host "[$i] Request failed with status $StatusCode" -ForegroundColor Red
            } else {
                Write-Host "[$i] Connection failed ($($_.Exception.Message))" -ForegroundColor Red
            }
        }

        Start-Sleep -Seconds $Sleep
        $i++
    }
} finally {
    Write-Host "---------------------------------------------------"
    Write-Host "Done."
}
