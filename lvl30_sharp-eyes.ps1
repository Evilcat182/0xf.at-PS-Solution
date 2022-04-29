function Get-ImageFromURL
{
    Param(
        [Parameter(Mandatory)]
        [string]$URL
    )

    $path = New-TemporaryFile
    Invoke-WebRequest -Uri $URL -OutFile $path
    [System.Drawing.Bitmap]::FromFile($path) | Write-Output
}


$script:image = Get-ImageFromURL -URL "https://www.0xf.at/data/tmp/626c4dce8331c.png?nocache=1651264974"
$script:white = [System.Drawing.ColorTranslator]::FromHtml("#FFFFFF")
$script:mapping = Import-Clixml -Path "D:\scripts\0xf.at-PS-Solution\lvl30_letter-mapping.xml"

$tileAmountX = (0..($image.Width-1) | ForEach-Object { $image.GetPixel($_,0).Name } | Sort -Unique).Count
$tileAmountY = (0..($image.Height-1) | ForEach-Object { $image.GetPixel(0,$_).Name } | Sort -Unique).Count
$tileSizeX = $image.Width / $tileAmountX
$tileSizeY = $image.Height / $tileAmountY

class Tile
{
    [System.Numerics.Vector2]$Size
    [System.Numerics.Vector2]$GridPos
    [System.Drawing.Color]$Color
    [string]$Letter


    Tile([int]$GridPosX, [int]$GridPosY, [int]$SizeX, [int]$SizeY) {
        $this.Size = [System.Numerics.Vector2]::new($SizeX, $SizeY)
        $this.GridPos = [System.Numerics.Vector2]::new($GridPosX, $GridPosY)

        $this.Color = $this.GetPixel(0,0)
        $this.Letter = $this.GetLetter()
    }

    [System.Numerics.Vector2] GetRelativePos([int]$X, [int]$Y) {
        return $this.GridPos * $this.Size + [System.Numerics.Vector2]::new($x,$y)
    }

    [System.Drawing.Color]GetPixel([int]$X, [int]$Y)
    {
        $pos = $this.GetRelativePos($X,$Y)
        return $script:image.GetPixel($pos.X,$pos.Y)    
    }

    [string]GetLetter()
    {
        $allWhite = $this.GetWhitePixel()
        
        foreach ($letter in $script:mapping.Keys)
        {
            if($script:mapping[$letter].Count -ne $allWhite.Count) {
                continue
            }

            $doesMatch = -Not (@($script:mapping[$letter] | ForEach-Object {$allWhite -contains $_}) -contains $false)
            
            if($doesMatch) {
                return $letter
            }   
        }
        return "NoMatch"
    }

    [void]Print() { $this.Print(@()) }
    [void]Print([System.Numerics.Vector2[]]$highlight)
    {
        for ($y = 0; $y -lt $this.Size.Y; $y++)
        { 
            for ($x = 0; $x -lt $this.Size.X; $x++)
            {
                $pix = $this.GetPixel($x,$y)
                
                $ht = @{
                    Object = "."
                    NoNewline = $true
                    ForeGroundColor = "White"
                }
                
                if($highlight.Contains([System.Numerics.Vector2]::new($x,$y))) {
                    $ht["ForeGroundColor"] = "Red"
                }
                
                if($pix -eq $script:white) {
                     $ht["Object"] = "X"
                }

                Write-Host @ht
            }
            Write-Host ""
        }       
    }

    [System.Numerics.Vector2[]]GetWhitePixel()
    {
        $list = New-Object System.Collections.Generic.List[System.Numerics.Vector2]
        for ($y = 0; $y -lt $this.Size.Y; $y++){ 
            for ($x = 0; $x -lt $this.Size.X; $x++) {
                $pix = $this.GetPixel($x,$y)
                
                if($pix -eq $script:white) {
                    [void]$list.Add(([System.Numerics.Vector2]::new($x,$y)))
                }
            }
        }
        return $list.ToArray()
    }
}

$tileArr = New-Object 'Tile[,]' $tileAmountX,$tileAmountY

for ($y = 0; $y -lt $tileAmountY; $y++)
{ 
    for ($x = 0; $x -lt $tileAmountX; $x++)
    { 
        $tileArr[$x,$y] = [Tile]::new($x, $y, $tileSizeX, $tileSizeY)    
    }    
}
 
($tileArr | Sort -Descending -Property {$_.Color.Name}).Letter -join ""


