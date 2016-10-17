function Icmp_Download
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

    $ICMPClient = New-Object System.Net.NetworkInformation.Ping
    $PingOptions = New-Object System.Net.NetworkInformation.PingOptions
    $PingOptions.DontFragment = $True
    $Offset = 0
    $ReponseAll = New-Object System.Io.MemoryStream
    $Continue = $true

    while ($Continue)
    {
        write-host -NoNewline "."
        $OffsetBytes = [BitConverter]::GetBytes($Offset)
        $SizeBytes = [BitConverter]::GetBytes($Size)[0..1]
        $sendbytes = ($OffsetBytes + $SizeBytes + [text.encoding]::ASCII.GetBytes($Filename))
        $reply = $ICMPClient.Send($IPAddress,10000, $sendbytes, $PingOptions)
        $Reponse = $reply.Buffer
        if ($Reponse)
        {
            $ReponseAll.write($Reponse,0,$Reponse.Length)
            if (-Not($Reponse.Length -eq $Size))
            {
                if (-Not ($FilenameDestination)) {
                    $FilenameDestination = $Filename
                }
                [System.Io.File]::WriteAllBytes($FilenameDestination,$ReponseAll.ToArray())
                $Continue = $false
                echo ""
                echo "Terminated"
            }
        }
        else
        {
            echo "No reply buffer"
            $Continue = $false
        }
        $Offset += $Size
    }
}

#Icmp_Download -IPAddress <destination IP address> -Filename <Filename>
