$URL = "https://www.magicleap.com"
$Iterations = 100
$i = 0
$resp_array = @()

While ($i -lt $Iterations)
{
    $Request = Invoke-RestMethod -Method Get -Uri $URL -UseDefaultCredentials #New-Object System.Net.WebClient
    #$Request.UseDefaultCredentials = $true
    $Start = Get-Date
    $PageRequest = $Request.DownloadString      #DownloadString($URL)
    $TimeTaken = ((Get-Date) - $Start).TotalMilliseconds
    $resp_array += $TimeTaken 
    #$Request
    Write-Host Request $i took $TimeTaken ms -ForegroundColor Green
    $i ++
}

# https://4sysops.com/archives/building-html-reports-in-powershell-with-convertto-html/