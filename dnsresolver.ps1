#function Get-FileName
Function Get-FileName($initialDirectory)
{   
 [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") |
 Out-Null

 $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
 $OpenFileDialog.initialDirectory = $initialDirectory
 $OpenFileDialog.filter = "All files (*.*)| *.*"
 $OpenFileDialog.ShowDialog() | Out-Null
 $OpenFileDialog.filename
} 
#end function Get-FileName

$path = Get-FileName
if (-Not($path)) { exit } 
$hosts = Get-Content $path
$totalhosts = $hosts.length
echo "Looking up DNS records for $totalhosts hosts...please be patient..."
$textresults = @()
$hostcounter = 1
foreach ($indivhost in $hosts)
{
    echo "Looking up host $hostcounter of $totalhosts"
    $hostcounter += 1
    Try
    {
        $hostentry = [System.Net.Dns]::GetHostEntry($indivhost)
        $singletextresult = """$($hostentry.hostname)"""
        foreach ($address in $hostentry.addresslist)
        {
            $singletextresult += ",""$($address.IPAddressToString)"""
        }
        $textresults += $singletextresult
    }
    catch
    {
        $singletextresult = """$indivhost"",""Not Found"""
        $textresults += $singletextresult
    }
}
$savefilename = "DNSLookup_Results.csv"
$textresults | Out-File $savefilename -Encoding utf8
echo "DNS Lookups completed. Results are stored in $savefilename"
Write-Host "Press any key to continue ..."

$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
