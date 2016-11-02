function Write-ShortList
{
    param
    (
        [System.IO.FileSystemInfo[]]
        $Files
    )

    $columns = (Find-BestFitColumns $Files)

    foreach ($row in 0..($Columns[0].Files.Count - 1))
    {
        foreach ($column in $Columns)
        {
            $file = $column.Files[$row]

            if ($file)
            {
                $foreground = Get-FileColor $file
                $text = $file.Name.PadRight($column.Width)

                Write-Host $text -Fore $foreground -NoNewLine
            }
        }

        Write-Host
    }
}

function Write-FileDetails
{
    param
    (
        [System.IO.FileSystemInfo[]]
        $Files
    )

    foreach ($file in $Files)
    {
        $color = Get-FileColor $file
        $date = Get-FormattedDateTime $file.LastWriteTime
        $mode = $file.Mode
        $name = $file.Name

        if (!($mode))
        {
            $mode = ' ' * 6
        }

        if ($file.PSIsContainer)
        {
            $size = ' ' * 15
        }
        else
        {
            $size = (Get-DelimitedFileSize $file.Length).PadLeft(15)
        }

        Write-Host "$mode  $date  $size  " -NoNewLine
        Write-Host $name -Fore $color -NoNewLine

        if ($file.Target -and $file.Attributes -band [IO.FileAttributes]::ReparsePoint)
        {
            Write-Host ' -> ' -NoNewLine
            Write-Host $file.Target -Fore (Get-FileColor ($file.Target | select -first 1)) -NoNewLine
        }

        Write-Host
    }
}

function Write-Legend
{
    Write-Host
    Write-Host 'Directory'                                                               -Fore $colors.Directory
    Write-Host 'Link'                                                                    -Fore $colors.Link
    Write-Host 'Config          cfg conf config ini log'                                 -Fore $colors.Config
    Write-Host 'Compressed      zip tar gz rar 7z bz2 tgz tcz'                           -Fore $colors.Compressed
    Write-Host 'Executable      exe bat cmd py pl ps1 psm1 ps1xml vbs rb reg fsx msi sh' -Fore $colors.Executable
    Write-Host 'Image           jpg jpeg gif png tif bmp svg xcf psd'                    -Fore $colors.Image
    Write-Host 'Backup          bak ~'                                                   -Fore $colors.Backup
    Write-Host 'Linux hidden    .*'                                                      -Fore $colors.LinuxHidden
    Write-Host 'Default'                                                                 -Fore $colors.Default
}
