function ConvertFrom-TelephoneCode
{
    Param(
        [string]$TelephoneCode
    )

    $mapping = @{
	    "a" = "22"
	    "b" = "222"
	    "c" = "2222"
	    "d" = "33"
	    "e" = "333"
	    "f" = "3333"
	    "g" = "44"
	    "h" = "444"
	    "i" = "4444"
	    "j" = "55"
	    "k" = "555"
	    "l" = "555"
	    "m" = "66"
	    "n" = "666"
	    "o" = "666"
	    "p" = "77"
	    "q" = "777"
	    "r" = "7777"
	    "s" = "77777"
	    "t" = "88"
	    "u" = "888"
	    "v" = "8888"
	    "w" = "99"
	    "x" = "999"
	    "y" = "9999"
	    "z" = "99999"
	    "0" = "0"
	    "1" = "1"
	    "2" = "2"
	    "3" = "3"
	    "4" = "4"
	    "5" = "5"
	    "6" = "6"
	    "7" = "7"
	    "8" = "8"
	    "9" = "9"
    }



    for ($i = 0; $i -lt $TelephoneCode.Length; $i++) { 
        $encoded += $mapping[$TelephoneCode.Substring($i,1)]
    }

    $encoded | Write-Output
}

function Get-Sum
{
    Param(
        [Parameter(ValueFromPipeline)]
        [string]$EncodedString
    )
    [int]$total = 0
    $arr = 0..($EncodedString.Length -1) | ForEach-Object { $total += $EncodedString.Substring($_,1)}
    $total | Write-Output
}

ConvertFrom-TelephoneCode -TelephoneCode "4899431504d364871e5e7d0137fe7001" | Get-Sum