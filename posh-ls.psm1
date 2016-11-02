param([switch]$NoVersionWarn = $false)

if (Get-Module posh-ls) { return }

$psv = $PSVersionTable.PSVersion

if ($psv.Major -lt 3 -and !$NoVersionWarn) {
    Write-Warning ("posh-gulp support for PowerShell 2.0 is deprecated; you have version $($psv).`n" +
    "To download version 5.0, please visit https://www.microsoft.com/en-us/download/details.aspx?id=50395`n" +
    "For more information and to discuss this, please visit https://github.com/dahlbyk/posh-git/issues/163`n" +
    "To suppress this warning, change your profile to include 'Import-Module posh-gulp -Args `$true'.")
}

Push-Location $psScriptRoot
. .\Scripts\Config.ps1
. .\Scripts\Utils.ps1
. .\Scripts\Write.ps1
. .\Scripts\Format.ps1
Pop-Location

$aliases = 'll', 'ls'
$functions = @(
    'Format-UnixList',
    'Format-UnixListLong'
)

Export-ModuleMember -Alias $aliases -Function $functions
