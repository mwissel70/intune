Start-Transcript -Path $(Join-Path $env:temp "DriveMapping.log")

$driveMappingConfig=@()


######################################################################
#                section script configuration                        #
######################################################################

<#
   Add your internal Active Directory Domain name and custom network drives below
#>

$dnsDomainName= "rlc.ch"


$driveMappingConfig+= [PSCUSTOMOBJECT]@{
    DriveLetter = "E"
    UNCPath= "\\rlcag\rlc\Software"
    Description="Software"
}


$driveMappingConfig+=  [PSCUSTOMOBJECT]@{
    DriveLetter = "L"
    UNCPath= "\\rlcag\rlc\Messerli"
    Description="Messerli"
}

$driveMappingConfig+=  [PSCUSTOMOBJECT]@{
    DriveLetter = "Z"
    UNCPath= "\\rlcag\rlc\David"
    Description="David"
}

$driveMappingConfig+=  [PSCUSTOMOBJECT]@{
    DriveLetter = "H"
    UNCPath= "\\rlcag\rlc\Sekretariat"
    Description="Sekretariat"
}

$driveMappingConfig+=  [PSCUSTOMOBJECT]@{
    DriveLetter = "o"
    UNCPath= "\\rlcag\rlc\RLC_CAD"
    Description="RLC_CAD"
}

$driveMappingConfig+=  [PSCUSTOMOBJECT]@{
    DriveLetter = "I"
    UNCPath= "\\rlcag\rlc\rlc-daten"
    Description="rlc-daten"
}

$driveMappingConfig+=  [PSCUSTOMOBJECT]@{
    DriveLetter = "P"
    UNCPath= "\\rlcag\rlc\Immoprojekt"
    Description="Immoprojekt"
}

$driveMappingConfig+=  [PSCUSTOMOBJECT]@{
    DriveLetter = "K"
    UNCPath= "\\rlcag\rlc\CAD-Archive"
    Description="CAD-Archive"
}

$driveMappingConfig+=  [PSCUSTOMOBJECT]@{
    DriveLetter = "S"
    UNCPath= "\\rlcag\rlc\Scans"
    Description="Scans"
}

######################################################################
#               end section script configuration                     #
######################################################################

$connected=$false
$retries=0
$maxRetries=3

Write-Output "Starting script..."
do {
    
    if (Resolve-DnsName $dnsDomainName -ErrorAction SilentlyContinue){
    
        $connected=$true

    } else{
 
        $retries++
        
        Write-Warning "Cannot resolve: $dnsDomainName, assuming no connection to fileserver"
 
        Start-Sleep -Seconds 3
 
        if ($retries -eq $maxRetries){
            
            Throw "Exceeded maximum numbers of retries ($maxRetries) to resolve dns name ($dnsDomainName)"
        }
    }
 
}while( -not ($Connected))

#Map drives
    $driveMappingConfig.GetEnumerator() | ForEach-Object {

        Write-Output "Mapping network drive $($PSItem.UNCPath)"

        New-PSDrive -PSProvider FileSystem -Name $PSItem.DriveLetter -Root $PSItem.UNCPath -Description $PSItem.Description -Persist -Scope global

        (New-Object -ComObject Shell.Application).NameSpace("$($PSItem.DriveLEtter):").Self.Name=$PSItem.Description
}

Stop-Transcript