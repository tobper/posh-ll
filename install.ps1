$dest = "$HOME\Documents\WindowsPowerShell\Modules\posh-ls\"

if (Test-Path $dest)
{
    cmd /c rmdir /s /q $dest
}

pushd $PSScriptRoot
md $dest\scripts | Out-Null
cp .\* $dest -i *.ps?1, *.md, *.txt
cp .\scripts\* $dest\scripts
popd
