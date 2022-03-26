function Get-Wordlist
{
    Param(
        [Parameter(Mandatory)]
        [string]$URL
    )

    $zipFile = Split-Path $URL -Leaf
    $txtFile = $zipFile.Replace('.zip','.txt')

    $zipTMP = "$($env:TEMP)\$zipFile"
    $txtTMP = "$($env:TEMP)\$txtFile"

    Invoke-WebRequest -Uri $URL -OutFile $zipTMP -ErrorAction Stop
    Expand-Archive -Path $zipTMP -DestinationPath $env:TEMP
    
    $content = Get-Content $txtTMP
    $txtTMP,$zipTMP | Remove-Item

    $content | Write-Output
}

function Unscrambled-Word
{
    Param(
        [Parameter(Mandatory ,ValueFromPipeline)]
        [string[]]$Word,
        [Parameter(Mandatory)]
        [string[]]$WordList
    )

    PROCESS
    {
        foreach ($w in $Word)
        {
            [char[]]$sortedCharArr = $Word.ToCharArray() | Sort 
        
            $testWords = $WordList | Where-Object {$_.Length -eq $w.Length}
            
            foreach ($testWord in $testWords)
            {
                [char[]]$testSortedCharArr = $testWord.ToCharArray() | Sort
                if([System.Linq.Enumerable]::SequenceEqual($sortedCharArr,$testSortedCharArr)) {
                    $testWord | Write-Output
                    break
                }   
            }
        }   
    }
}


$scrambledWords = "arscbcim;socunt;istblrieaiyd;srazi;stenitcros;crksakuh;ebyde;atecr;omosdoiumlyc;eletedb"

$wordlist = Get-Wordlist -URL "https://www.0xf.at/data/dictionary.zip"
($scrambledWords.Split(';') | Unscrambled-Word -WordList $wordlist) -join ';'

