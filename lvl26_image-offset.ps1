function Get-ImageFromURL
{
    Param(
        [Parameter(Mandatory)]
        [string]$URL
    )

    $path = "$($env:TEMP)\img"
    Invoke-WebRequest -Uri $imgURL -OutFile $path
    [System.Drawing.Bitmap]::FromFile($path) | Write-Output
}

function Get-PasswordFromImage
{
    Param(
        [System.Drawing.Bitmap]$Image
    )

    $str = New-Object System.Text.StringBuilder
    for ($x = 0; $x -lt $Image.Height; $x++)
    { 
        for ($y = 0; $y -lt $Image.Width; $y++)
        { 
            if($Image.GetPixel($y,$x).Name -ne "ffffffff") {
                [void]$str.Append([String]::new((97 + $y)))
                break
            }  
        }
    }
    $str.ToString()
}

$bmp = Get-ImageFromURL -URL "https://www.0xf.at/data/tmp/9337cfb8435e1811052d2eae31a268bd.png?anticache=33103ef815416f775098fe977004015c6193"
Get-PasswordFromImage -Image $bmp