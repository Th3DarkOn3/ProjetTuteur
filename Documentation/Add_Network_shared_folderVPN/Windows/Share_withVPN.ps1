if(!([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
    Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList "-File `"$($MyInvocation.MyCommand.Path)`"  `"$($MyInvocation.MyCommand.UnboundArguments)`""
    Exit
}
route add 172.16.2.0 mask 255.255.255.0 10.50.8.6 if 0x7
route add 172.16.1.0 mask 255.255.255.0 10.50.8.6 if 0x7
New-SmbMapping -LocalPath 'O:' -RemotePath '\\172.16.2.40\partage' -UserName 'olivier' -Password 'olivier' -Persistent $true