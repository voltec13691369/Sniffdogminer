﻿. .\Include.ps1

try
{
    $ahashpool_Request = Invoke-WebRequest "https://www.ahashpool.com/api/status" -UseBasicParsing | ConvertFrom-Json
}
catch
{
    return
}

if(-not $ahashpool_Request){return}

$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName

$Location = "US"

$ahashpool_Request | Get-Member -MemberType NoteProperty | Select -ExpandProperty Name | foreach {
    $ahashpool_Host = "$_.mine.ahashpool.com"
    $ahashpool_Port = $ahashpool_Request.$_.port
    $ahashpool_Algorithm = Get-Algorithm $ahashpool_Request.$_.name
    $ahashpool_Coin = "Unknown"

    $Divisor = 1000000
	
    switch($ahashpool_Algorithm)
    {
        "sha256"{$Divisor *= 1000000}
        "sha256t"{$Divisor *= 1000000}
        "blake"{$Divisor *= 1000}
        "blake2s"{$Divisor *= 1000}
	"blakecoin"{$Divisor *= 1000}
        "decred"{$Divisor *= 1000}
        "keccak"{$Divisor *= 1000}
        "keccakc"{$Divisor *= 1000}
	"lbry"{$Divisor *= 1000}
	"myr-gr"{$Divisor *= 1000}
	"quark"{$Divisor *= 1000}
        "qubit"{$Divisor *= 1000}
        "vanilla"{$Divisor *= 1000}
	"x11"{$Divisor *= 1000}
	"equihash"{$Divisor /= 1000}
        "yescrypt"{$Divisor /= 1000}
    }

    if((Get-Stat -Name "$($Name)_$($ahashpool_Algorithm)_Profit") -eq $null){$Stat = Set-Stat -Name "$($Name)_$($ahashpool_Algorithm)_Profit" -Value ([Double]$ahashpool_Request.$_.estimate_last24h/$Divisor)}
    else{$Stat = Set-Stat -Name "$($Name)_$($ahashpool_Algorithm)_Profit" -Value ([Double]$ahashpool_Request.$_.estimate_current/$Divisor)}
	
    if($Wallet)
    {
        [PSCustomObject]@{
            Algorithm = $ahashpool_Algorithm
            Info = $ahashpool_Coin
            Price = $Stat.Live
            StablePrice = $Stat.Week
            MarginOfError = $Stat.Fluctuation
            Protocol = "stratum+tcp"
            Host = $ahashpool_Host
            Port = $ahashpool_Port
            User = $Wallet
            Pass = "ID=$Workername,c=BTC"
            Location = $Location
            SSL = $false
        }
    }
}
