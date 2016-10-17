function DNS_Download {

  [CmdletBinding()] Param(

    [Parameter(Position = 0, Mandatory = $true)]
    [String]
    $Server,

    [Parameter(Position = 1, Mandatory = $true)]
    [String]
    $Filename,

    [Parameter(Position = 2, Mandatory = $false)]
    [Int]
    $Size = 3000,

    [Parameter(Position = 3, Mandatory = $false)]
    [String]
    $FilenameDestination = '',

    [Parameter(Position = 4, Mandatory = $false)]
    [String]
    $DNS = ''
  )

  $Set    = "abcdefghijklmnopqrstuvwxyz0123456789".ToCharArray()
  $RandomString = ""
  for ($x = 0; $x -lt 8; $x++) {
    $RandomString += $Set | Get-Random
  }

  $Continue = $true
  $Offset = 0
  while ($Continue)
  {
    write-host -NoNewline "."
    $Command='cmd.exe /C nslookup -type=TXT '+$Filename+'.'+$Offset+'.' + $Size +'.'+$RandomString+'.'+$Server+ ' ' +$DNS
    $ResultCmd=Invoke-Expression -Command:$Command
    $ResultCmd=[string]$ResultCmd
    $FirstIdx=$ResultCmd.IndexOf('"')+1
    $LastIdx=$ResultCmd.LastIndexOf('"')
    $Len=$LastIdx-$FirstIdx
    $Resultb64=$ResultCmd.Substring($FirstIdx,$Len)
    $Resultb64= $Resultb64 -replace '\s',''
    $Resultb64= $Resultb64 -replace '"',''
    $Result =  ([System.Text.Encoding]::ASCII.GetString([System.Convert]::FromBase64String($Resultb64)))
    $ResultAll = $ResultAll + $Result
    if (-Not($Result.Length -eq $Size))
    {
      $Continue = $false
      echo ""
      echo "Terminated"
    }
    $Offset += $Size
  }

  if (-Not ($FilenameDestination)) {
    $FilenameDestination = $Filename
  }
  [io.file]::WriteAllText($FilenameDestination,$ResultAll)

}

#DNS_Download -Server tun.scrt.fr -Filename monfichier
#DNS_Download -Server tun.scrt.fr -Filename monfichier -Size 45000 -FilenameDestination monfichier_copie -DNS server.fr
