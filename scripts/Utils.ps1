function Get-FileColor
{
    param
    (
        [Parameter(ParameterSetName = 'File', Mandatory = $true, Position = 0)]
        [System.IO.FileSystemInfo]
        $File,

        [Parameter(ParameterSetName = 'Path', Mandatory = $true, Position = 0)]
        [String]
        $Path
    )

    if ($Path)
    {
        $File = Get-Item $Path -ErrorAction SilentlyContinue
    }

    if ($File -ne $null)
    {
        # Link
        if ($File.LinkType -eq 'Junction') { return $colors.Link }

        # Hidden directory
        if ($File.PSIsContainer -and $File.Attributes -band [IO.FileAttributes]::Hidden) { return $colors.DirectoryHidden }

        # Directory
        if ($File.PSIsContainer) { return $colors.Directory }

        # Config / Log
        if ($File.Name -match '\.(cfg|conf|config|ini|log)$') { return $colors.Config }

        # Compressed
        if ($File.Name -match '\.(zip|tar|gz|rar|7z|bz2|tgz|tcz)$') { return $colors.Compressed }

        # Executable
        if ($File.Name -match '\.(exe|bat|cmd|py|pl|ps1|psm1|ps1xml|vbs|rb|reg|fsx|msi|sh)$') { return $colors.Executable }

        # Image
        if ($File.Name -match '\.(jpg|jpeg|gif|png|tif|bmp|svg|xcf|psd)$') { return $colors.Image }

        # Backup file
        if ($File.Name -match '(\.bak|~)$') { return $colors.Backup }

        # Backup file 2 / linux hidden dotfile
        if ($File.Name -match '^(~|\.)') { return $colors.LinuxHidden }
    }

    # Default
    return $colors.Default
}

function Get-MaxColumnWidth
{
    param
    (
        [System.IO.FileSystemInfo[]]
        $Files
    )

    return ($Files | % { $_.Name.Length } | measure -Max).Maximum + 2
}

function Get-Column
{
    param
    (
        [System.IO.FileSystemInfo[]]
        $Files,

        [int]
        $Width
    )

    New-Object PSObject -Property @{
        Files = $Files
        Width = $Width
    }
}

function Get-Columns
{
    param(
        [System.IO.FileSystemInfo[]]
        $Files,

        [int]
        $ColumnCount
    )

	$rowCount = [Math]::Ceiling($Files.Count / $ColumnCount)
    $maxColumns = [Math]::Min($ColumnCount, $Files.Count)

    (0..($maxColumns-1)) |
        % {
            $lowerIndex  = $rowCount * $_
            $upperIndex  = $lowerIndex + $rowCount - 1
            $columnFiles = $Files[$lowerIndex..$upperIndex]
            $columnWidth = Get-MaxColumnWidth $columnFiles

            Get-Column $columnFiles $columnWidth
        }
}

function Find-BestFitColumns
{
    param
    (
        [System.IO.FileSystemInfo[]]
        $Files
    )

	$windowWidth = $Host.UI.RawUI.BufferSize.Width
	$maxColumnWidth = Get-MaxColumnWidth $Files
	$columnCount = [Math]::Floor($windowWidth / $maxColumnWidth)

    if ($columnCount -eq 0)
    {
        return @(Get-Column $Files $maxColumnWidth)
    }

	while ($True)
    {
    	$columns = Get-Columns $Files $columnCount
		$combinedWidth = ($columns | % { $_.Width } | measure -Sum).Sum

		if ($windowWidth -lt $combinedWidth)
        {
        	return Get-Columns $Files ($columnCount - 1)
		}

        if ($windowWidth -le ($combinedWidth + $maxColumnWidth))
        {
            return $columns
        }

        if ($columns.Count -lt $columnCount)
        {
            return $columns
        }

        $columnCount += 1
	}
}

function Get-FormattedDateTime
{
    param
    (
        [System.DateTimeOffset]
        $Date
    )

    $today = [System.DateTime]::Today

    if ($Date.Year -ne $today.Year)
    {
        $Date.ToString('yyyy MMM dd HH:mm')
    }
    elseif (($Date.Month -ne $today.Month) -or ($Date.Day -ne $today.Day))
    {
        $Date.ToString('     MMM dd HH:mm')
    }
    else
    {
        $Date.ToString('            HH:mm')
    }
}

function Get-DelimitedFileSize
{
    param
    (
        [Int64]
        $FileSize
    )

    $text = $FileSize.ToString()

    for ($i = $text.Length - 3; $i -gt 0; $i -= 3)
    {
        $text = $text.SubString(0, $i) + ' ' + $text.SubString($i)
    }

    $text
}

function Get-Files
{
    param
    (
        [string]
        $Path
    )

    if ($Path -eq '')
    {
        $Path = '.'
    }

    Get-ChildItem $Path -Force -ErrorAction Stop
}
