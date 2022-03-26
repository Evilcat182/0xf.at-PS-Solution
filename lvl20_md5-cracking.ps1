function Get-Wordlist
{
    Param(
        [string]$URL
    )

    $zipFile = Split-Path $URL -Leaf
    $txtFile = $zipFile.Replace('.zip','.txt')

    $zipTMP = "$($env:TEMP)\$zipFile"
    $txtTMP = "$($env:TEMP)\$txtFile"

    Invoke-WebRequest -Uri $URL -OutFile $zipTMP
    Expand-Archive -Path $zipTMP -DestinationPath $env:TEMP
    
    $content = Get-Content $txtTMP
    $txtTMP,$zipTMP | Remove-Item

    $content | Write-Output
}

function Get-MD5Hash
{
    Param(
        [string]$String
    )

    $md5 = [System.Security.Cryptography.MD5CryptoServiceProvider]::new()
    $utf8 = [System.Text.UTF8Encoding]::new()

    $byteHash = $md5.ComputeHash($utf8.GetBytes($String))
    $hashStr = [System.Text.StringBuilder]::new()

    foreach ($byte in $byteHash) {
        [void]$hashStr.Append($byte.ToString("x2")) 
    }
    $hashStr.ToString() | Write-Output
}


$wordlist = Get-Wordlist "https://www.0xf.at/data/wordlist.zip"
$md5 = "669b65319c231c079f9024767d449ada"

$startDate = Get-Date
for ($i = 1; $i -lt $wordlist.Count; $i++)
{ 
    for ($k = 1; $k -lt $wordlist.Count; $k++)
    { 
        $pw = "$($wordlist[$i])$($wordlist[$k])"
        $hash = Get-MD5Hash $pw
        if($hash -eq $md5) {
            $totalTime = ((Get-Date) - $startDate).TotalSeconds
            "Password `"$pw`" found in $totalTime secounds"
            return
        }
    }
    $i 
}
